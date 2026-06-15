using backend.Models;

namespace backend.Dto;

public class RecipeDto
{
    public required string Title { get; set; }
    public string Description { get; set; } = "";
    public int? CookingTime { get; set; }
    public int? Difficulty { get; set; }
    public float Rating { get; set; }
    public CategoryPreviewDto? Category { get; set; }
    public List<string> Tags { get; set; } = [];
    public int CreatorId { get; set; }
    public required UserDto Creator { get; set; }
}