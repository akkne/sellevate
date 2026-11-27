using System.Net.Http.Json;
using System.Text.Json;
using Sellevate.Ai.Features.Quotas.Services.Implementation;

namespace Sellevate.Ai.Infrastructure.Http;

/// <summary>Requests a complete structured reply from a model running on the local inference host.</summary>
internal static class LocalVoiceCompletionClient
{
    public const string ClientName = "LocalVoice";
    // Fixed punctuation avoids generating arbitrary whitespace or an unused reason on ongoing calls.
    public const string ReplyGrammar = """
        root ::= "{\"reply\":" spoken ",\"endCall\":" ("false,\"endCallReason\":null}" | "true,\"endCallReason\":" string "}")
        spoken ::= "\"" [А-Яа-яЁё0-9] char* "\""
        string ::= "\"" char+ "\""
        char ::= [^"\\\x00-\x1F] | "\\" ["\\/bfnrt] | "\\u" [0-9a-fA-F]{4}
        """;

    public sealed record Result(string? ReplyJson, AiCompletionUsage? Usage);

    public static async Task<Result?> TryCompleteAsync(
        HttpClient client, Uri endpoint, object payload, ILogger logger, CancellationToken cancellationToken)
    {
        try
        {
            using var response = await client.PostAsJsonAsync(endpoint, payload, cancellationToken);
            response.EnsureSuccessStatusCode();
            using var body = await response.Content.ReadFromJsonAsync<JsonDocument>(cancellationToken);
            if (body is null)
            {
                throw new JsonException("Empty local completion");
            }

            var root = body.RootElement;
            var choice = root.GetProperty("choices")[0];
            var json = choice.GetProperty("message").GetProperty("content").GetString();
            var completed = choice.GetProperty("finish_reason").GetString() == "stop" && IsCompleteReply(json);
            if (!completed)
            {
                logger.LogWarning("Incomplete local voice reply; using the configured dialog provider");
            }

            return new Result(completed ? json : null, OpenAiUsageReader.Read(root));
        }
        catch (Exception error) when (!cancellationToken.IsCancellationRequested &&
            error is HttpRequestException or OperationCanceledException or JsonException or KeyNotFoundException
                or InvalidOperationException or IndexOutOfRangeException)
        {
            logger.LogWarning("Local voice inference unavailable ({Reason}); using the configured dialog provider", error.GetType().Name);
            return null;
        }
    }

    private static bool IsCompleteReply(string? json)
    {
        if (string.IsNullOrWhiteSpace(json))
        {
            return false;
        }

        try
        {
            using var body = JsonDocument.Parse(json);
            var root = body.RootElement;
            return root.ValueKind == JsonValueKind.Object &&
                root.TryGetProperty("reply", out var reply) && reply.ValueKind == JsonValueKind.String &&
                !string.IsNullOrWhiteSpace(reply.GetString()) &&
                root.TryGetProperty("endCall", out var stop) && stop.ValueKind is JsonValueKind.True or JsonValueKind.False &&
                root.TryGetProperty("endCallReason", out var reason) && reason.ValueKind is JsonValueKind.String or JsonValueKind.Null;
        }
        catch (JsonException)
        {
            return false;
        }
    }
}
