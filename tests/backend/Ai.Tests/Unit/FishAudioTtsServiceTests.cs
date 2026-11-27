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

    private sealed class RecordingHandler : HttpMessageHandler
    {
        public List<string?> Speakers { get; } = [];

        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            using var payload = JsonDocument.Parse(await request.Content!.ReadAsStringAsync(cancellationToken));
            Speakers.Add(payload.RootElement.GetProperty("reference_id").GetString());
            return new HttpResponseMessage(HttpStatusCode.OK) { Content = new ByteArrayContent(new byte[2]) };
        }
    }
}
