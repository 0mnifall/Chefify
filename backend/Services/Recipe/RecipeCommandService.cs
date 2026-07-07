using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class RecipeCommandService(AppDbContext context)
{
    public async Task<int> AddRecipe(CreateRecipeDto dto, int creatorId)
    {
        var tags = new List<Tag>();
        
        if (dto.TagsId.Count > 0)
        {
            tags = await context.Tags
                .Where(t => dto.TagsId.Contains(t.Id))
                .ToListAsync();
        }
        

        Category? category = null;

        if (dto.CategoryId.HasValue)
        {
            category = await context.Categories.FindAsync(dto.CategoryId.Value);

            if (category == null)
            {
                return 0;
            }
        }
        

        var recipe = new Recipe
        {
            Title = dto.Title,
            Description = dto.Description,
            CookingTime = dto.CookingTime,
            Difficulty = dto.Difficulty,
            Rating = new RecipeRating(),
            Category = category,
            Tags = tags,
            Blocks = dto.Blocks,
            CreatorId = creatorId
        };
        
        context.Recipes.Add(recipe);
        await context.SaveChangesAsync();
        
        return recipe.Id;
    }

    public async Task PatchRecipe(Recipe recipe, PatchRecipeDto dto)
    {
        recipe.Description = dto.Description ?? recipe.Description;
        recipe.CookingTime = dto.CookingTime ?? recipe.CookingTime;
        recipe.Difficulty = dto.Difficulty ?? recipe.Difficulty;
        recipe.Blocks = dto.Blocks ?? recipe.Blocks;
        
        if (dto.TagIds != null)
        {
            recipe.Tags = await context.Tags
                .Where(t => dto.TagIds.Contains(t.Id))
                .ToListAsync();
        }
        
        await  context.SaveChangesAsync();
    }
    
    public async Task DeleteRecipe(Recipe recipe)
    {
        context.Recipes.Remove(recipe);
        await context.SaveChangesAsync();
    }
}