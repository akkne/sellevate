using System.Reflection;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.OpenApi.Models;
using Microsoft.OpenApi.Writers;
using Swashbuckle.AspNetCore.Swagger;

var outputDirectory = args.Single();
Directory.CreateDirectory(outputDirectory);
foreach (var project in Directory.GetFiles("backend", "Sellevate.*.csproj", SearchOption.AllDirectories)
             .Where(path => path.Split(Path.DirectorySeparatorChar)[1].EndsWith("-service", StringComparison.Ordinal))
             .Order(StringComparer.Ordinal))
{
    var name = Path.GetFileNameWithoutExtension(project);
    var assembly = Assembly.Load(name);
    var builder = WebApplication.CreateBuilder();
    builder.Logging.ClearProviders();
    builder.Services.AddControllers().ConfigureApplicationPartManager(manager => manager.ApplicationParts.Clear())
        .AddApplicationPart(assembly);
    builder.Services.AddSwaggerGen(options =>
    {
        options.SwaggerDoc("v1", new OpenApiInfo { Title = name, Version = "v1" });
        options.CustomSchemaIds(type => type.FullName?.Replace("+", ".") ?? type.Name);
    });
    await using var app = builder.Build();
    app.MapControllers();
    var document = app.Services.GetRequiredService<ISwaggerProvider>().GetSwagger("v1");
    var slug = name.Split('.').Last().ToLowerInvariant();
    var descriptions = app.Services.GetRequiredService<IApiDescriptionGroupCollectionProvider>()
        .ApiDescriptionGroups.Items.SelectMany(group => group.Items).ToArray();
    if (document.Paths.Count == 0 || descriptions.Length == 0)
    {
        throw new InvalidOperationException($"Пустой контракт {name}");
    }

    var routes = new StringBuilder($"# HTTP {name}\n\n");
    routes.AppendLine("| Метод | Маршрут | Доступ и политики |");
    routes.AppendLine("| --- | --- | --- |");
    foreach (var description in descriptions.OrderBy(route => route.RelativePath, StringComparer.Ordinal)
                 .ThenBy(route => route.HttpMethod, StringComparer.Ordinal))
    {
        var action = (ControllerActionDescriptor)description.ActionDescriptor;
        var metadata = action.EndpointMetadata;
        var access = metadata.OfType<IAuthorizeData>()
            .Select(attribute => attribute.Policy ?? attribute.Roles ?? "JWT").Distinct().ToList();
        if (metadata.Any(attribute => attribute is IAllowAnonymous))
        {
            access.Clear();
            access.Add("Публичный");
        }
        if (metadata.Any(attribute => attribute.GetType().Name.Contains("TenantScoped", StringComparison.Ordinal)))
        {
            access.Add("Контекст организации");
        }
        if (action.FilterDescriptors.Any(filter => filter.Filter is TypeFilterAttribute typeFilter
            && typeFilter.ImplementationType.Name.Contains("InternalServiceAuth", StringComparison.Ordinal)
            || filter.Filter is ServiceFilterAttribute serviceFilter
            && serviceFilter.ServiceType.Name.Contains("InternalServiceAuth", StringComparison.Ordinal)))
        {
            access.Add("Межсервисный ключ");
        }
        var policies = access.Count > 0 ? string.Join(", ", access) : "По конфигурации сервиса";
        routes.AppendLine($"| {description.HttpMethod} | `/{description.RelativePath}` | {policies} |");
    }
    File.WriteAllText(Path.Combine(outputDirectory, slug + ".md"), routes.ToString().ReplaceLineEndings("\n"));
    using var writer = new StringWriter();
    document.SerializeAsV3(new OpenApiJsonWriter(writer));
    File.WriteAllText(Path.Combine(outputDirectory, slug + ".json"), writer.ToString().ReplaceLineEndings("\n") + "\n");
}
