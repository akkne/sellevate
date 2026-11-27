using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Runtime.CompilerServices;
using Microsoft.Extensions.Options;
using Sellevate.Ai.Common.Constants;
using Sellevate.Ai.Features.Quotas.Models;
using Sellevate.Ai.Features.Quotas.Services.Abstract;
using Sellevate.Ai.Features.Voice.Services.Abstract;
using Sellevate.Ai.Infrastructure.Configuration;

namespace Sellevate.Ai.Features.Voice.Services.Implementation;

/// <summary>Synthesizes speech with the configured speaker and an explicit Fish Audio model.</summary>
internal sealed class FishAudioTtsService(
    IHttpClientFactory httpClientFactory,
    IOptions<FishAudioConfiguration> options,
    IAiSpendMeter spendMeter) : ITtsRouter, IProgressiveMp3
{
    private const string Model = "s2.1-pro-free";
    private const string DefaultVoiceId = "9cc4883d4bbe4276bb67584db3cd117b";

    private const int SampleRate = 44100;

    public bool IsConfigured => AiSecretPlaceholders.IsRealSecret(options.Value.ApiKey);

    public bool SupportsProgressiveMp3 => IsConfigured && options.Value.LowLatencyMp3;

    private HttpRequestMessage CreateRequest(string text, string? modeVoiceId)
    {
        if (!IsConfigured)
        {
            throw new InvalidOperationException("Fish Audio API key is not configured.");
        }

        var request = new HttpRequestMessage(HttpMethod.Post, "https://api.fish.audio/v1/tts");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", options.Value.ApiKey);
        request.Headers.Add("model", Model);
        var compact = options.Value.LowLatencyMp3;
        var payload = new Dictionary<string, object>
        {
            ["text"] = text,
            ["format"] = compact ? "mp3" : "pcm",
            ["sample_rate"] = SampleRate,
            ["reference_id"] = Guid.TryParseExact(modeVoiceId, "N", out var voiceId) ? voiceId.ToString("N") : DefaultVoiceId,
        };
        if (compact)
        {
            payload["latency"] = "low";
            payload["mp3_bitrate"] = 128;
        }
        request.Content = JsonContent.Create(payload);

        return request;
    }

    public async IAsyncEnumerable<byte[]> StreamMp3Async(string text, string? voiceId,
        [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        using var request = CreateRequest(text, voiceId);
        var client = httpClientFactory.CreateClient(AiProviderHttpConstants.FishAudioClientName);
        using var response = await client.SendAsync(request, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        response.EnsureSuccessStatusCode();
        await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
        var buffer = new byte[8192];
        var received = false;
        int count;
        while ((count = await stream.ReadAsync(buffer, cancellationToken)) > 0)
        {
            if (!received)
            {
                await spendMeter.RecordSpeechUsageAsync(AiUsageKinds.Tts, Model, text.Length, cancellationToken);
                received = true;
            }
            yield return buffer[..count];
        }

        if (!received)
        {
            throw new InvalidOperationException("Fish Audio returned empty audio.");
        }
    }

    public async Task<Stream> SynthesizeSpeechAsync(string text, string? modeVoiceId, CancellationToken cancellationToken = default)
    {
        using var request = CreateRequest(text, modeVoiceId);
        var compact = options.Value.LowLatencyMp3;
        var client = httpClientFactory.CreateClient(AiProviderHttpConstants.FishAudioClientName);
        using var response = await client.SendAsync(request, cancellationToken);
        response.EnsureSuccessStatusCode();
        var audio = await response.Content.ReadAsByteArrayAsync(cancellationToken);
        if (audio.Length == 0 || (!compact && audio.Length % sizeof(short) != 0))
        {
            throw new InvalidOperationException("Fish Audio returned invalid audio.");
        }

        await spendMeter.RecordSpeechUsageAsync(AiUsageKinds.Tts, Model, text.Length, cancellationToken);
        return new MemoryStream(compact ? audio : PcmWave.Encode(audio, SampleRate), writable: false);
    }
}
