namespace backend.Models;

public class RecipeIngredient
{
    public int RecipeId { get; set; }
    public required Recipe Recipe { get; set; }

    public int IngredientId { get; set; }
    public required Ingredient Ingredient { get; set; }
}