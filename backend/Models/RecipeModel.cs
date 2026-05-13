using Microsoft.EntityFrameworkCore;

namespace backend.Models;

public class Recipe
{
    public int Id { get; set; }
    public required string Title { get; set; }
    public required string Description { get; set; }
    public int CookingTime { get; set; }
    public int Difficulty { get; set; }
    
    public int CreatorId { get; set; }
    public User Creator { get; set; }

    //public List<RecipeIngredient> RecipeIngredients { get; set; }
}