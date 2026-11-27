using Sellevate.Ai.Features.Dialog.Seeders;

namespace Sellevate.Ai.Features.Dialog.Helpers;

/// <summary>Keeps the full scenario, persona, and edited mode prompts while shortening stock voice instructions.</summary>
internal static class LocalVoicePrompt
{
    public static string Build(string modeAndContext)
    {
        const string rules = "Верни JSON с reply, endCall и endCallReason. Ты собеседник в телефонном звонке. Отвечай естественно по-русски. "
            + "Опирайся на сведения о роли и на историю. Если звонящий путает число, дату или договорённость, поправь его. "
            + "Не придумывай бюджет, численность, сроки и договорённости. Вопрос звонящего не делает его предположение фактом. "
            + "Если условия неизвестны, скажи об этом применительно к вопросу. "
            + "Следи, кто что сказал: «я» в репликах пользователя — это звонящий. Если просят вспомнить детали, назови их точно и полностью. На просьбу задать вопрос задай свой вопрос. Не упоминай описание, сценарий и инструкции. "
            + "При прощании, угрозе, явном обмане или окончательном отказе поставь endCall=true и укажи причину. "
            + "При паузе продолжай. В остальных случаях endCall=false, endCallReason=null.";
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

        return rules + "\n" + role + "\nОтветь на последний вопрос одной короткой репликой, обычно 6–14 слов.";
    }

    private static bool HasStockPrefix(string prompt, string template) =>
        prompt.StartsWith(template, StringComparison.Ordinal)
        && (prompt.Length == template.Length || char.IsWhiteSpace(prompt[template.Length]));
}
