using System.ComponentModel.DataAnnotations;
using backend.Models;

namespace backend.Dto;

public class CreateRecipeDto
{
    [Required]
    [StringLength(100)]
    public required string Title { get; set; }
    public string Description { get; set; } = "";
    
    [Range(1, 480)]
    public int? CookingTime { get; set; }

    [Range(1, 5)]
    public int? Difficulty { get; set; }
    public int? CategoryId { get; set; }
    public List<int> TagsId { get; set; } = [];
    public List<BlockTemplate> Blocks { get; set; } = [];
}