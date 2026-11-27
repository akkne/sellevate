using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Sellevate.Codex.Features.Completions;

public sealed record CompletionMessage(string Role, string Content);

public sealed record CompletionRequest(
    string Model,
    [MinLength(1)] CompletionMessage[] Messages,
    [property: JsonPropertyName("max_tokens")] int MaxTokens,
    [property: JsonPropertyName("response_format")] CompletionFormat? ResponseFormat,
    [property: JsonPropertyName("voice_turn")] bool VoiceTurn = false);

public sealed record CompletionFormat([property: JsonPropertyName("json_schema")] NamedSchema JsonSchema);
public sealed record NamedSchema(JsonElement Schema);
public sealed record TokenUsage(
    [property: JsonPropertyName("prompt_tokens")] int PromptTokens,
    [property: JsonPropertyName("completion_tokens")] int CompletionTokens);
public sealed record CompletionResponse(CompletionMessage Message, TokenUsage? Usage);
