using backend.Models;
using backend.Data;

namespace backend.Services;

public class RecipeAuthorizationService(AppDbContext context)
{
    public async Task<bool> IsAuthor(int recipeId, int userId)
    {
        var recipe = await context.Recipes.FindAsync(recipeId);
        return recipe != null && recipe.CreatorId == userId;
    } 
}
