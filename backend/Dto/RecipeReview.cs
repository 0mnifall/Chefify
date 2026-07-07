namespace backend.Dto;

public class RecipeReview
{
    public required int ReviewerId { get; set; }
    public required int Rate {get; set;}
    public string? Overview {get; set;}
}