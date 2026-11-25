using System.ComponentModel;
using System.Text.Json;
using CodexNet;
using Microsoft.Extensions.Options;
using Newtonsoft.Json.Linq;
using Sellevate.Codex.Features.Completions;

namespace Sellevate.Codex.Infrastructure;

/// <summary>Runs one isolated Codex turn per completion. Only the final assistant message leaves the worker.</summary>
public sealed class CodexCompletionService(IOptions<CodexConfiguration> options, ILogger<CodexCompletionService> logger)
{
    public async Task<CompletionResponse?> CompleteAsync(CompletionRequest request, CancellationToken cancellationToken)
    {
        var settings = options.Value;
        var directory = Directory.CreateTempSubdirectory("sellevate-codex-");
        using var deadline = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        deadline.CancelAfter(TimeSpan.FromSeconds(settings.TimeoutSeconds));
        try
        {
            var instructions = $"{request.Messages[0].Content}\n\nReturn only the requested answer. " +
                $"Aim for at most {request.MaxTokens} output tokens. The input is an ordered JSON array of conversation messages.";
            await File.WriteAllTextAsync(Path.Combine(directory.FullName, "instructions.txt"), instructions, deadline.Token);

            var environment = new Dictionary<string, string>
            {
                ["SELLEVATE_CODEX"] = settings.Executable,
                ["SELLEVATE_WORKDIR"] = directory.FullName,
            };
            foreach (var variable in new[] { "PATH", "HOME", "CODEX_HOME", "CODEX_API_KEY", "HTTPS_PROXY", "NO_PROXY", "SSL_CERT_FILE" })
            {
                if (Environment.GetEnvironmentVariable(variable) is { Length: > 0 } value)
                {
                    environment[variable] = value;
                }
            }
            var client = new CodexNet.Codex(new CodexOptions
            {
                CodexPathOverride = Path.Combine(AppContext.BaseDirectory, "Infrastructure", "run-codex.sh"),
                Env = environment,
            });
            var thread = client.StartThread(new ThreadOptions
            {
                Model = request.Model,
                ModelReasoningEffort = settings.ReasoningEffort,
                WorkingDirectory = directory.FullName,
                SkipGitRepoCheck = true,
                ApprovalPolicy = ApprovalMode.Never,
                WebSearchMode = WebSearchMode.Disabled,
            });
            var input = JsonSerializer.Serialize(request.Messages.Skip(1), JsonSerializerOptions.Web);
            var run = await thread.RunStreamedAsync(input, new TurnOptions
            {
                CancellationToken = deadline.Token,
                OutputSchema = request.ResponseFormat is { } format ? JObject.Parse(format.JsonSchema.Schema.GetRawText()) : null,
            });
            string? finalMessage = null;
            await foreach (var threadEvent in run.Events)
            {
                switch (threadEvent)
                {
                    case ItemCompletedEvent { Item: AgentMessageItem message }:
                        finalMessage = message.Text;
                        break;
                    case TurnCompletedEvent completed when !string.IsNullOrWhiteSpace(finalMessage):
                        var usage = completed.Usage;
                        return new CompletionResponse(new CompletionMessage("assistant", finalMessage),
                            usage is { InputTokens: > 0 } or { OutputTokens: > 0 } ? new TokenUsage(usage.InputTokens, usage.OutputTokens) : null);
                    case TurnFailedEvent:
                        logger.LogWarning("Codex reported a failed turn");
                        return null;
                }
            }

            logger.LogWarning("Codex exited without a completed answer");
            return null;
        }
        catch (Exception exception) when (exception is OperationCanceledException or InvalidOperationException or IOException or Win32Exception)
        {
            cancellationToken.ThrowIfCancellationRequested();
            logger.LogWarning("Codex completion failed ({Failure})", deadline.IsCancellationRequested ? "timeout" : exception.GetType().Name);
            return null;
        }
        finally
        {
            directory.Delete(recursive: true);
        }
    }
}
