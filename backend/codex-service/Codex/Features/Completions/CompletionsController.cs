using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Sellevate.Codex.Infrastructure;

namespace Sellevate.Codex.Features.Completions;

[ApiController]
[Route("internal/completions")]
[TypeFilter(typeof(InternalServiceAuthFilter))]
public sealed class CompletionsController(CodexCompletionService service) : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult<CompletionResponse>> CompleteAsync(CompletionRequest request, CancellationToken cancellationToken)
    {
        if (request.Messages.Length == 0 || request.Messages[0] is not { Role: "system" }
            || request.Messages.Skip(1).Any(message => message is not { Role: "user" or "assistant" })
            || request.MaxTokens <= 0
            || request.ResponseFormat is { } format && format.JsonSchema.Schema.ValueKind != JsonValueKind.Object)
        {
            return BadRequest();
        }

        var result = await service.CompleteAsync(request, cancellationToken);
        return result is null ? StatusCode(StatusCodes.Status502BadGateway) : Ok(result);
    }
}
