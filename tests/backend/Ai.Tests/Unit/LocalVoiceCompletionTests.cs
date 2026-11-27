using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FluentAssertions;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using NSubstitute;
using NUnit.Framework;
using Sellevate.Ai.Features.Dialog.Helpers;
using Sellevate.Ai.Features.Dialog.Models;
using Sellevate.Ai.Features.Dialog.Seeders;
using Sellevate.Ai.Features.Dialog.Services.Implementation;
using Sellevate.Ai.Features.Quotas.Services.Abstract;
using Sellevate.Ai.Infrastructure.Configuration;
using Sellevate.Ai.Infrastructure.Http;

namespace Sellevate.Ai.Tests.Unit;

[TestFixture]
public class LocalVoiceCompletionTests
{
    private sealed class CompletionHandler(string reply, string finish) : HttpMessageHandler
    {
        public HttpRequestMessage? Request { get; private set; }
        public JsonElement Payload { get; private set; }

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            Request = request;
            Payload = await request.Content!.ReadFromJsonAsync<JsonElement>(cancellationToken);
            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = JsonContent.Create(new
                {
                    choices = new[] { new { finish_reason = finish, message = new { content = reply } } },
                    usage = new { prompt_tokens = 20, completion_tokens = 12 },
                }),
            };
        }
    }

    [Test]
    public void ShortensOnlyKnownRoleInstructionsAndKeepsTheCompanyContext()
    {
        const string context = "\nКомпания: пример. В команде шесть менеджеров.";
        var stock = CompanyCallModeSeeder.ChatSystemPromptTemplate;
        var compressed = LocalVoicePrompt.Build(stock + context);
        compressed.Should().Contain(context);
        compressed.Length.Should().BeLessThan(stock.Length);
        const string edited = "Администратор задал особую роль директора.";
        LocalVoicePrompt.Build(edited + context).Should().Contain(edited + context);
    }

    [TestCase("stop", false)]
    [TestCase("length", true)]
    public async Task UsesWholeLocalReplyOrFallsBackAndMetersTheModelsUsed(string finish, bool fallback)
    {
        const string reply = """{"reply":"Здравствуйте!","endCall":false,"endCallReason":null}""";
        var local = new CompletionHandler(reply, finish);
        var remote = new CompletionHandler(reply, "stop");
        var factory = Substitute.For<IHttpClientFactory>();
        factory.CreateClient(LocalVoiceCompletionClient.ClientName).Returns(_ => new HttpClient(local));
        factory.CreateClient("Codex").Returns(_ => new HttpClient(remote) { BaseAddress = new Uri("http://worker/") });
        var options = Options.Create(new OpenAiConfiguration { LocalVoiceUrl = "http://localhost:15142/v1/chat/completions", LocalVoiceModel = "local-model" });
        var meter = Substitute.For<IAiSpendMeter>();
        var chat = new OpenAiChatService(factory, options, meter, NullLogger<OpenAiChatService>.Instance);
        var replies = new List<string>();
        await foreach (var text in chat.StreamChatMessageAsync("Role", [new DialogMessage { Role = "user", Content = "hello" }], voiceTurn: true))
        {
            replies.Add(text);
        }
        replies.Should().Equal(reply);
        local.Payload.GetProperty("stream").GetBoolean().Should().BeFalse();
        local.Request!.Headers.Authorization.Should().BeNull();
        local.Payload.GetProperty("response_format").GetProperty("json_schema").GetProperty("strict").GetBoolean().Should().BeTrue();
        await meter.Received(1).RecordLlmUsageAsync("local-model", 20, 12, false, Arg.Any<CancellationToken>());
        factory.Received(fallback ? 1 : 0).CreateClient("Codex");
    }
}
