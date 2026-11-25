using Sellevate.Codex.Infrastructure;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddHealthChecks();
builder.Services.AddOptions<CodexConfiguration>()
    .BindConfiguration("Codex")
    .Validate(options => Enum.IsDefined(options.ReasoningEffort) && options.TimeoutSeconds > 0
        && !string.IsNullOrWhiteSpace(options.Executable), "Invalid Codex configuration")
    .ValidateOnStart();
builder.Services.AddSingleton<CodexCompletionService>();
var app = builder.Build();
app.MapControllers();
app.MapHealthChecks("/healthz");
app.MapHealthChecks("/readyz");
app.Run();
