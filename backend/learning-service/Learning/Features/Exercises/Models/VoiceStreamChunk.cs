namespace Sellevate.Learning.Features.Exercises.Models;

public sealed record VoiceStreamChunk(
    string Text,
    byte[] AudioMp3,
    bool IsStopSignal,
    bool IsFinal);
