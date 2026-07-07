using backend.Models;
using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class PatchRecipeDto
{
    [StringLength(1000)]
    public string? Description { get; set; }

    [Range(1, 480)]
    public int? CookingTime { get; set; }

    [Range(1, 5)]
    public int? Difficulty { get; set; }

    public List<int>? TagIds { get; set; }

    public List<BlockTemplate>? Blocks { get; set; }
}
