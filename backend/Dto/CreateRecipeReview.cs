using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class CreateRecipeReview
{
    [Range(1, 5)]
    public required int Rate {get; set;}

    [StringLength(1000)]
    public string? Overview {get; set;}
}
