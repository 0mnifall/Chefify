using backend.Models;

namespace backend.Dto;

public class RecipePreviewDto
{
    public int Id { get; set; }
    public required string Title { get; set; }
    public string Description { get; set; } = "";
    public int? CookingTime { get; set; }
    public int? Difficulty { get; set; }
    public float Rating { get; set; }
    public string? CategoryName { get; set; } = "";
    public List<string> Tags { get; set; } = [];
    
    public required string CreatorUsername { get; set; }
}