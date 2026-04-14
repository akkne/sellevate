namespace SalesTrainer.Api.Features.SkillTree.Models;

public record SkillTreeNodeDto(
    Guid SkillId,
    string Title,
    string? Description,
    int OrderInTree
);
