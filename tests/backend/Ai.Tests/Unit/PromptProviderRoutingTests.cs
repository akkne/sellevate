using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FluentAssertions;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using NSubstitute;
using NUnit.Framework;
using Sellevate.Ai.Features.Dialog.Models;
using Sellevate.Ai.Features.Dialog.Services.Implementation;
using Sellevate.Ai.Features.Evaluation.Services.Implementation;
using Sellevate.Ai.Features.Quotas.Services.Abstract;
using Sellevate.Ai.Infrastructure.Configuration;
using Sellevate.Ai.Infrastructure.Http;

namespace Sellevate.Ai.Tests.Unit;

[TestFixture]
public class PromptProviderRoutingTests
{
    private sealed class CompletionHandler : HttpMessageHandler
    {
        public JsonElement Payload { get; private set; }

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            request.RequestUri!.AbsoluteUri.Should().Be("http://worker/internal/completions");
            Payload = await request.Content!.ReadFromJsonAsync<JsonElement>(cancellationToken);
            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = JsonContent.Create(new
                {
                    message = new { content = """{"passed":true,"rating":9,"feedback":"OK"}""" },
                    usage = new { prompt_tokens = 17, completion_tokens = 9 },
                }),
            };
        }
    }

    [TestCase("text")]
    [TestCase("stream")]
    [TestCase("grading")]
    public async Task CodexUsesWorkerAndMetersConfiguredModel(string operation)
    {
        var handler = new CompletionHandler();
        var factory = Substitute.For<IHttpClientFactory>();
        factory.CreateClient("Codex").Returns(_ => new HttpClient(handler) { BaseAddress = new Uri("http://worker/") });
        var options = Options.Create(new OpenAiConfiguration { CodexModel = "test-codex" });
        var meter = Substitute.For<IAiSpendMeter>();
        var chat = new OpenAiChatService(factory, options, meter, NullLogger<OpenAiChatService>.Instance);
        if (operation == "grading")
        {
            var grader = new FreeTextEvaluationStrategy(factory, options, meter, NullLogger<FreeTextEvaluationStrategy>.Instance);
            var result = await grader.EvaluateAnswerAsync(JsonSerializer.SerializeToElement(new { instruction = "grade" }),
                JsonSerializer.SerializeToElement(new { text = "answer" }), null);
            result.Score.Should().Be(90);
        }
        else if (operation == "stream")
        {
            var chunks = new List<string>();
            await foreach (var chunk in chat.StreamChatMessageAsync("system", [new DialogMessage { Role = "user", Content = "answer" }]))
            {
                chunks.Add(chunk);
            }
            chunks.Should().ContainSingle();
            handler.Payload.GetProperty("response_format").GetProperty("json_schema").TryGetProperty("schema", out _).Should().BeTrue();
        }
        else
        {
            (await chat.GenerateTextAsync("system", "answer", model: "api-override")).Should().Contain("OK");
        }

        handler.Payload.GetProperty("model").GetString().Should().Be("test-codex");
        handler.Payload.GetProperty("messages")[1].GetProperty("content").GetString().Should().Contain("answer");
        await meter.Received(1).EnsureLlmAllowanceAsync(Arg.Any<string>(), Arg.Any<CancellationToken>());
        await meter.Received(1).RecordLlmUsageAsync("test-codex", 17, 9, false, Arg.Any<CancellationToken>());
        factory.DidNotReceive().CreateClient("OpenAI");
    }

    [TestCase(OpenAiProvider.OpenAi, "Authorization", "Bearer test-key")]
    [TestCase(OpenAiProvider.F5Ai, "X-Auth-Token", "test-key")]
    public void ApiProvidersUseConfiguredEndpointAndHeader(OpenAiProvider provider, string header, string value)
    {
        var settings = new OpenAiConfiguration { Provider = provider, BaseUrl = "https://api.example/", ApiKey = "test-key" };
        var factory = Substitute.For<IHttpClientFactory>();
        factory.CreateClient("OpenAI").Returns(new HttpClient());
        var (client, url) = PromptProviderClient.Create(factory, settings);

        url.Should().Be("https://api.example/v1/chat/completions");
        client.DefaultRequestHeaders.GetValues(header).Should().ContainSingle().Which.Should().Be(value);
        settings.ResolvePromptModel("api-model").Should().Be("api-model");
        factory.DidNotReceive().CreateClient("Codex");
    }
}
