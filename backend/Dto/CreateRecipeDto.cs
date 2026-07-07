using System.ComponentModel.DataAnnotations;
using backend.Models;

namespace backend.Dto;

public class CreateRecipeDto
{
    [Required]
    [StringLength(100, MinimumLength = 3)]
    public required string Title { get; set; }

    [StringLength(1000)]
    public string Description { get; set; } = "";
    
    [Range(1, 480)]
    public int? CookingTime { get; set; }

    [Range(1, 5)]
    public int? Difficulty { get; set; }
    [Range(1, int.MaxValue)]
    public int? CategoryId { get; set; }

    public List<int> TagsId { get; set; } = [];

    public List<BlockTemplate> Blocks { get; set; } = [];
}
