using backend.Models;

namespace backend.Services;

public class RecipeAuthorizationService
{
    public bool CanModifyRecipe(Recipe recipe, int userId)
    {
        return recipe.CreatorId == userId;
    }
}
