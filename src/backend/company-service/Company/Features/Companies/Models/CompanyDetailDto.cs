namespace Sellevate.Company.Features.Companies.Models;

public sealed record CompanyDetailDto(
    Guid Id,
    string Name,
    string Description,
    int CallLogCount,
    int PracticeCallCount,
    int ContactCount,
    DateTime CreatedAt,
    DateTime UpdatedAt);
