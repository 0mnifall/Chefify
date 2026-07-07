using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class AdminRecipeService(AppDbContext context)
{
    public async Task<string?> UpdateRecipe(Recipe recipe, AdminRecipeDto dto)
    {
        Category? category = null;

        if (dto.CategoryId.HasValue)
        {
            category = await context.Categories.FindAsync(dto.CategoryId.Value);

            if (category == null)
            {
                return "Invalid category ID.";
            }
        }

        var creatorExists = await context.Users.AnyAsync(u => u.Id == dto.CreatorId);
        if (!creatorExists)
        {
            return "Invalid creator ID.";
        }

        var tags = await context.Tags
            .Where(t => dto.TagIds.Contains(t.Id))
            .ToListAsync();

        if (tags.Count != dto.TagIds.Distinct().Count())
        {
            return "One or more tag IDs are invalid.";
        }

        recipe.Title = dto.Title;
        recipe.Description = dto.Description;
        recipe.CookingTime = dto.CookingTime;
        recipe.Difficulty = dto.Difficulty;
        recipe.Category = category;
        recipe.Tags = tags;
        recipe.Blocks = dto.Blocks;
        recipe.CreatorId = dto.CreatorId;
        
        context.Recipes.Update(recipe);
        await  context.SaveChangesAsync();

        return null;
    }
}
