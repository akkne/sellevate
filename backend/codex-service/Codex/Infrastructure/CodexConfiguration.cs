using CodexNet;

namespace Sellevate.Codex.Infrastructure;

public sealed class CodexConfiguration
{
    public string Executable { get; init; } = "codex";
    public ModelReasoningEffort ReasoningEffort { get; init; } = ModelReasoningEffort.High;
    public int TimeoutSeconds { get; init; } = 180;
}
