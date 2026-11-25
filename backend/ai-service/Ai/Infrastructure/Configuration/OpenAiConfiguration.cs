using Sellevate.Ai.Common.Constants;

namespace Sellevate.Ai.Infrastructure.Configuration;

/// <summary>
/// Selects the text transport. The HTTP adapters also select their authentication and schema format here.
/// </summary>
public enum OpenAiProvider
{
    /// <summary>Standard OpenAI (api.openai.com) — uses Bearer token and json_schema wrapper.</summary>
    OpenAi,

    /// <summary>F5 AI gateway — uses X-Auth-Token and a flat json_schema object.</summary>
    F5Ai,

    OPENAI_CODEX,
}

/// <summary>
/// The OpenAI-compatible provider this service talks to: where it lives, which key opens it, and the
/// model and token budget of each kind of call.
///
/// <para>
/// <c>ApiKey</c> is injected from the root <c>.env</c>; <c>appsettings.json</c> carries only the
/// <c>INJECTED_FROM_ENV</c> marker. Every model name and token cap is a per-call-type option rather
/// than one shared pair, so re-pricing the feedback pass cannot silently re-price a dialog turn.
/// </para>
/// </summary>
public sealed class OpenAiConfiguration
{
    public const string SectionName = "OpenAI";

    public string ApiKey { get; init; } = string.Empty;
    public string BaseUrl { get; init; } = "https://api.openai.com";
    public string ChatCompletionsPath { get; init; } = "/v1/chat/completions";

    public OpenAiProvider Provider { get; init; } = OpenAiProvider.OPENAI_CODEX;
    public string CodexModel { get; init; } = "gpt-6.2-astra";

    public bool CanSendPrompts => Provider == OpenAiProvider.OPENAI_CODEX || AiSecretPlaceholders.IsRealSecret(ApiKey);

    public string ResolvePromptModel(string apiModel) => Provider == OpenAiProvider.OPENAI_CODEX ? CodexModel : apiModel;

    public string OpenQuestionModel { get; init; } = "gpt-4.1";

    /// <summary>
    /// Model driving the roleplay character during a dialog. Defaults to a stronger
    /// conversational model (gpt-4o) so the simulated interlocutor reasons and reacts
    /// more naturally. Override via <c>OPENAI_DIALOG_MODEL</c>.
    /// </summary>
    public string DialogModel { get; init; } = "gpt-4o";
    public int MaximumOpenQuestionTokenCount { get; init; } = 300;
    public int MaximumDialogTokenCount { get; init; } = 500;
    public int MaximumFeedbackTokenCount { get; init; } = 1500;
    public double DialogTemperature { get; init; } = 0.7;

    /// <summary>
    /// Model used for the company pre-call briefing ("шпаргалка", 39.12). Dedicated option
    /// (rather than reusing <see cref="OpenQuestionModel"/>) so briefing can be tuned/priced
    /// independently of the open-question feature it happened to share config with initially.
    /// Defaults to the same value as <see cref="OpenQuestionModel"/> so unset config keeps
    /// today's behavior.
    /// </summary>
    public string BriefingModel { get; init; } = "gpt-4.1";

    /// <summary>
    /// Max tokens for the company pre-call briefing (39.12). Dedicated option (rather than
    /// reusing <see cref="MaximumFeedbackTokenCount"/>) for the same reason as
    /// <see cref="BriefingModel"/>. Defaults to the same value as
    /// <see cref="MaximumFeedbackTokenCount"/> so unset config keeps today's behavior.
    /// </summary>
    public int MaximumBriefingTokenCount { get; init; } = 1500;
}
