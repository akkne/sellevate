using Sellevate.Ai.Features.Dialog.Seeders;

namespace Sellevate.Ai.Features.Dialog.Helpers;

/// <summary>Keeps the full scenario, persona, and edited mode prompts while shortening stock voice instructions.</summary>
internal static class LocalVoicePrompt
{
    private static readonly string Rules = ReadRules();

    private static string ReadRules()
    {
        using var resource = typeof(LocalVoicePrompt).Assembly.GetManifestResourceStream("LocalVoiceRules")
            ?? throw new InvalidOperationException("Missing local voice instructions");
        using var reader = new StreamReader(resource);
        return reader.ReadToEnd().TrimEnd();
    }

    public static string Build(string modeAndContext)
    {
        var role = modeAndContext;
        if (HasStockPrefix(role, CompanyCallModeSeeder.ChatSystemPromptTemplate))
        {
            role = "Ты покупатель, звонящий — продавец. Говори от лица своей компании. Учитывай цель звонящего и характер персонажа. "
                + "Ты решаешь, нужно ли тебе предложение. Продукт и его демонстрацию предлагает продавец. На конкретику отвечай с интересом, на давление — с сомнением."
                + role[CompanyCallModeSeeder.ChatSystemPromptTemplate.Length..];
        }
        else if (HasStockPrefix(role, CustomScenarioModeSeeder.ChatSystemPromptTemplate))
        {
            role = "Играй собеседника из сценария. Реагируй на слова звонящего, сохраняя свою роль и интересы."
                + role[CustomScenarioModeSeeder.ChatSystemPromptTemplate.Length..];
        }

        return Rules + "\n" + role + "\nОтветь собеседнику по-русски одной короткой репликой, обычно 6–14 слов.";
    }

    private static bool HasStockPrefix(string prompt, string template) =>
        prompt.StartsWith(template, StringComparison.Ordinal)
        && (prompt.Length == template.Length || char.IsWhiteSpace(prompt[template.Length]));
}
