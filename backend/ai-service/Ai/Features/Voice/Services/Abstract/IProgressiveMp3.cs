namespace Sellevate.Ai.Features.Voice.Services.Abstract;

/// <summary>Continuous MP3 bytes produced by one synthesis request for a complete reply.</summary>
internal interface IProgressiveMp3
{
    bool SupportsProgressiveMp3 { get; }
    IAsyncEnumerable<byte[]> StreamMp3Async(string text, string? voiceId, CancellationToken cancellationToken);
}
