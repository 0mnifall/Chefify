using backend.Dto;
using backend.Models;

namespace backend.Services;

public static class RecipeMapper
{
    public static RecipeDto GetRecipeDetailsDto(Recipe recipe)
    {
        return new RecipeDto
        {
            Title = recipe.Title,
            Description = recipe.Description,
            CookingTime = recipe.CookingTime,
            Difficulty = recipe.Difficulty,
            Rating = recipe.Rating.Avg,
            Category = recipe.Category != null ? new CategoryPreviewDto
            {
                Id = recipe.Category.Id,
                Name = recipe.Category.Name
            } : null,
            Tags = recipe.Tags.Select(t => t.Name).ToList(),
            Blocks = recipe.Blocks,
            CreatorId = recipe.Creator.Id,
            Creator = new UserDto
            {
                Username = recipe.Creator.Username,
                //ProfilePictureRef = recipe.Creator.ProfilePictureRef
            }
        };
    }

}