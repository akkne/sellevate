using System.Net;
using System.Text.Json;
using Microsoft.Extensions.Options;
using NSubstitute;
using NUnit.Framework;
using Sellevate.Ai.Features.Quotas.Services.Abstract;
using Sellevate.Ai.Features.Voice.Services.Implementation;
using Sellevate.Ai.Infrastructure.Configuration;

namespace Sellevate.Ai.Tests.Unit;

[TestFixture]
public class FishAudioTtsServiceTests
{
    [TestCase(null, "9cc4883d4bbe4276bb67584db3cd117b")]
    [TestCase("alena", "9cc4883d4bbe4276bb67584db3cd117b")]
    [TestCase("aabbccddeeff00112233445566778899", "aabbccddeeff00112233445566778899")]
    public async Task EachSentenceUsesTheSameSpeaker(string? modeVoiceId, string expectedSpeaker)
    {
        var handler = new RecordingHandler();
        using var client = new HttpClient(handler);
        var factory = Substitute.For<IHttpClientFactory>();
        factory.CreateClient(Arg.Any<string>()).Returns(client);
        var service = new FishAudioTtsService(factory,
            Options.Create(new FishAudioConfiguration { ApiKey = "test-key" }), Substitute.For<IAiSpendMeter>());

        using var first = await service.SynthesizeSpeechAsync("Добрый день.", modeVoiceId);
        using var next = await service.SynthesizeSpeechAsync("Какие условия вы предлагаете?", modeVoiceId);

        Assert.That(handler.Speakers, Is.EqualTo(new[] { expectedSpeaker, expectedSpeaker }));
    }

    [Test]
    public async Task ProgressiveAudioUsesOneRequestAndChargesTheWholeReplyOnce()
    {
        const string text = "Добрый день. Когда удобно обсудить предложение?";
        var handler = new RecordingHandler();
        using var client = new HttpClient(handler);
        var factory = Substitute.For<IHttpClientFactory>();
        factory.CreateClient(Arg.Any<string>()).Returns(client);
        var meter = Substitute.For<IAiSpendMeter>();
        var service = new FishAudioTtsService(factory,
            Options.Create(new FishAudioConfiguration { ApiKey = "test-key", LowLatencyMp3 = true }), meter);

        var size = 0;
        await foreach (var bytes in service.StreamMp3Async(text, null, CancellationToken.None))
        {
            size += bytes.Length;
        }

        Assert.That(size, Is.EqualTo(2));
        Assert.That(handler.Requests, Has.Count.EqualTo(1));
        var request = handler.Requests.Single();
        Assert.That(request.GetProperty("text").GetString(), Is.EqualTo(text));
        Assert.That(request.GetProperty("format").GetString(), Is.EqualTo("mp3"));
        Assert.That(request.GetProperty("latency").GetString(), Is.EqualTo("low"));
        await meter.Received(1).RecordSpeechUsageAsync("tts", "s2.1-pro-free", text.Length, CancellationToken.None);
    }

    private sealed class RecordingHandler : HttpMessageHandler
    {
        public List<JsonElement> Requests { get; } = [];
        public List<string?> Speakers { get; } = [];

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            using var payload = JsonDocument.Parse(await request.Content!.ReadAsStringAsync(cancellationToken));
            Requests.Add(payload.RootElement.Clone());
            Speakers.Add(payload.RootElement.GetProperty("reference_id").GetString());
            return new HttpResponseMessage(HttpStatusCode.OK) { Content = new ByteArrayContent(new byte[2]) };
        }
    }
}
