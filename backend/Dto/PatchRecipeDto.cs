using backend.Models;

namespace backend.Dto;

public class PatchRecipeDto
{
    public string? Description { get; set; }
    public int? CookingTime { get; set; }
    public int? Difficulty { get; set; }
    public List<int>? TagIds { get; set; }
}