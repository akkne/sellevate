namespace Sellevate.Ai.Infrastructure.Configuration;

/// <summary>Server-side credentials for speech synthesis on the Fish Audio developer tier.</summary>
public sealed class FishAudioConfiguration
{
    public const string SectionName = "FishAudio";
    public string ApiKey { get; init; } = string.Empty;
}
