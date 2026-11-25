using System.Text.Json;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using NUnit.Framework;
using Sellevate.Codex.Features.Completions;
using Sellevate.Codex.Infrastructure;

namespace Sellevate.Codex.Tests;

[TestFixture]
[Platform(Exclude = "Win")]
public class CodexCompletionTests
{
    private DirectoryInfo _directory = null!;

    [SetUp]
    public void SetUp() => _directory = Directory.CreateTempSubdirectory("codex-test-");

    [TearDown]
    public void TearDown() => _directory.Delete(recursive: true);

    private CodexCompletionService CreateService(string script)
    {
        var executable = Path.Combine(_directory.FullName, "codex");
        File.WriteAllText(executable, "#!/bin/sh\nset -eu\n" + script);
        if (!OperatingSystem.IsWindows())
        {
            File.SetUnixFileMode(executable, UnixFileMode.UserRead | UnixFileMode.UserWrite | UnixFileMode.UserExecute);
        }
        return new CodexCompletionService(Options.Create(new CodexConfiguration { Executable = executable, TimeoutSeconds = 4 }),
            NullLogger<CodexCompletionService>.Instance);
    }

    private static CompletionRequest Request() => new("gpt-6.2-astra",
        [new CompletionMessage("system", "Test instructions"), new CompletionMessage("user", "Test input")], 40,
        new CompletionFormat(new NamedSchema(JsonSerializer.SerializeToElement(new { type = "object" }))));

    [Test]
    public async Task PassesInstructionsInputAndSchemaAndReturnsOnlyFinalMessageAndUsage()
    {
        var service = CreateService("""
            test "$1" = exec
            case "$*" in *'--model gpt-6.2-astra'*) ;; *) exit 1;; esac
            case "$*" in *'model_reasoning_effort="high"'*) ;; *) exit 1;; esac
            grep -q 'Test instructions' instructions.txt
            grep -q '"role":"user","content":"Test input"'
            while [ "$1" != "--output-schema" ]; do shift; done
            grep -q '"object"' "$2"
            echo '{"type":"item.completed","item":{"type":"agent_message","id":"1","text":"progress"}}'
            echo '{"type":"item.completed","item":{"type":"agent_message","id":"2","text":"final"}}'
            echo '{"type":"turn.completed","usage":{"input_tokens":12,"output_tokens":4}}'
            """);
        var result = await service.CompleteAsync(Request(), CancellationToken.None);
        Assert.That(result?.Message.Content, Is.EqualTo("final"));
        Assert.That(result?.Usage, Is.EqualTo(new TokenUsage(12, 4)));
    }

    [Test]
    public async Task ProcessFailureDiscardsPartialResponse()
    {
        var service = CreateService("""
            cat >/dev/null
            echo '{"type":"item.completed","item":{"type":"agent_message","id":"1","text":"partial"}}'
            exit 1
            """);
        Assert.That(await service.CompleteAsync(Request(), CancellationToken.None), Is.Null);
    }

    [Test]
    public void CancellingCallerStopsWaitingForCli()
    {
        var service = CreateService("cat >/dev/null\nexec sleep 60");
        using var cancellation = new CancellationTokenSource(TimeSpan.FromMilliseconds(200));
        Assert.ThrowsAsync<OperationCanceledException>(async () =>
            await service.CompleteAsync(Request(), cancellation.Token).WaitAsync(TimeSpan.FromSeconds(5)));
    }
}
