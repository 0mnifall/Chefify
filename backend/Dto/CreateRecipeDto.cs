using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class CreateRecipeDto
{
    [Required]
    [StringLength(100)]
    public string Title { get; set; }

    [Required]
    public string Description { get; set; }

    [Range(1, 480)]
    public int CookingTime { get; set; }

    [Range(1, 5)]
    public int Difficulty { get; set; }
}