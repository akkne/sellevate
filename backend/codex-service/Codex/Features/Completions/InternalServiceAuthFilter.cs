using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace Sellevate.Codex.Features.Completions;

public sealed class InternalServiceAuthFilter(IConfiguration configuration) : IAuthorizationFilter
{
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var secret = configuration["InternalAuth:ServiceSecret"];
        var supplied = context.HttpContext.Request.Headers["X-Internal-Service-Secret"];
        if (string.IsNullOrWhiteSpace(secret) || supplied.Count != 1 ||
            !CryptographicOperations.FixedTimeEquals(Encoding.UTF8.GetBytes(secret), Encoding.UTF8.GetBytes(supplied.ToString())))
        {
            context.Result = new StatusCodeResult(StatusCodes.Status403Forbidden);
        }
    }
}
