using backend.Dto;

namespace backend.Models;

public class Recipe
{
    public int Id { get; set; }
    public required string Title { get; set; }
    public required string Description { get; set; }
    public int? CookingTime { get; set; }
    public int? Difficulty { get; set; }

    public RecipeRating Rating { get; set; } = new RecipeRating();
    public Category? Category { get; set; }
    public required List<Tag> Tags { get; set; } = [];
    
    public required List<BlockTemplate> Blocks { get; set; } = [];

    public List<RecipeReview> Reviews { get; set; } = [];
    
    public int CreatorId { get; set; }
    public User Creator { get; set; } = null!;

    //public List<RecipeIngredient> RecipeIngredients { get; set; }
}