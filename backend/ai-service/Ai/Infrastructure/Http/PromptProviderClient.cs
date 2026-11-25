using System.Net.Http.Headers;
using Sellevate.Ai.Common.Constants;
using Sellevate.Ai.Infrastructure.Configuration;

namespace Sellevate.Ai.Infrastructure.Http;

/// <summary>Selects the text transport and attaches only the credentials for its destination.</summary>
internal static class PromptProviderClient
{
    public const string CodexClientName = "Codex";

    public static (HttpClient Client, string Url) Create(IHttpClientFactory factory, OpenAiConfiguration settings)
    {
        if (settings.Provider == OpenAiProvider.OPENAI_CODEX)
        {
            return (factory.CreateClient(CodexClientName), "internal/completions");
        }

        var client = factory.CreateClient(AiProviderHttpConstants.OpenAiClientName);
        client.DefaultRequestHeaders.Remove(AiProviderHttpConstants.F5AuthenticationTokenHeaderName);
        client.DefaultRequestHeaders.Authorization = null;
        if (settings.Provider == OpenAiProvider.F5Ai)
        {
            client.DefaultRequestHeaders.Add(AiProviderHttpConstants.F5AuthenticationTokenHeaderName, settings.ApiKey);
        }
        else
        {
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(AiProviderHttpConstants.BearerScheme, settings.ApiKey);
        }

        return (client, settings.BaseUrl.TrimEnd('/') + settings.ChatCompletionsPath);
    }
}
