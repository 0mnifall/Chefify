using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class AdminRecipeDto
{
    [Required]
    [StringLength(100, MinimumLength = 3)]
    public required string Title { get; set; }

    [StringLength(1000)]
    public required string Description { get; set; }

    [Range(1, 480)]
    public required int CookingTime { get; set; }

    [Range(1, 5)]
    public required int Difficulty { get; set; }

    [Range(1, int.MaxValue)]
    public int? CategoryId { get; set; }

    public required List<int> TagIds { get; set; }

    public required List<BlockTemplate> Blocks { get; set; }

    [Range(1, int.MaxValue)]
    public required int CreatorId { get; set; }
}
