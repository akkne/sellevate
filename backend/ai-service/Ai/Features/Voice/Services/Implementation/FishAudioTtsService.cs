using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.Extensions.Options;
using Sellevate.Ai.Common.Constants;
using Sellevate.Ai.Features.Quotas.Models;
using Sellevate.Ai.Features.Quotas.Services.Abstract;
using Sellevate.Ai.Features.Voice.Services.Abstract;
using Sellevate.Ai.Infrastructure.Configuration;

namespace Sellevate.Ai.Features.Voice.Services.Implementation;

/// <summary>Synthesizes WAV audio with the free Fish Audio model selected explicitly on each request.</summary>
internal sealed class FishAudioTtsService(
    IHttpClientFactory httpClientFactory,
    IOptions<FishAudioConfiguration> options,
    IAiSpendMeter spendMeter) : ITtsRouter
{
    private const string Model = "s2.1-pro-free";

    private const int SampleRate = 44100;

    public bool IsConfigured => AiSecretPlaceholders.IsRealSecret(options.Value.ApiKey);

    public async Task<Stream> SynthesizeSpeechAsync(string text, string? modeVoiceId, CancellationToken cancellationToken = default)
    {
        if (!IsConfigured)
        {
            throw new InvalidOperationException("Fish Audio API key is not configured.");
        }

        using var request = new HttpRequestMessage(HttpMethod.Post, "https://api.fish.audio/v1/tts");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", options.Value.ApiKey);
        request.Headers.Add("model", Model);
        request.Content = JsonContent.Create(new
        {
            text,
            format = "pcm",
            sample_rate = SampleRate,
            reference_id = Guid.TryParseExact(modeVoiceId, "N", out var voiceId) ? voiceId.ToString("N") : null,
        });

        var client = httpClientFactory.CreateClient(AiProviderHttpConstants.FishAudioClientName);
        using var response = await client.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        var pcm = await response.Content.ReadAsByteArrayAsync(cancellationToken);
        if (pcm.Length == 0 || pcm.Length % sizeof(short) != 0)
        {
            throw new InvalidOperationException("Fish Audio returned invalid PCM audio.");
        }

        await spendMeter.RecordSpeechUsageAsync(AiUsageKinds.Tts, Model, text.Length, cancellationToken);
        return new MemoryStream(PcmWave.Encode(pcm, SampleRate), writable: false);
    }
}
