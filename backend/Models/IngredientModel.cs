namespace backend.Models;

public class Ingredient
{
    public int Id { get; set; }

    public required string Name { get; set; }

    public required List<RecipeIngredient> RecipeIngredients { get; set; }
}