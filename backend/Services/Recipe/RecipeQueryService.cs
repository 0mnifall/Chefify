using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class RecipeQueryService(AppDbContext context)
{
    public async Task<IEnumerable<RecipePreviewDto>> GetAllRecipes()
    {
        var recipes = await context.Recipes
            .Select(r => new RecipePreviewDto
            {
                Id = r.Id,
                Title = r.Title,
                Description = r.Description,
                CookingTime = r.CookingTime,
                Difficulty = r.Difficulty,
                CategoryName = r.Category != null ? r.Category.Name : null,
                Tags = r.Tags.Select(t => t.Name).ToList(),
                CreatorUsername = r.Creator.Username
            })
            .ToListAsync(); 
        
        return recipes;
    }

    public async Task<Recipe?> GetRecipeForDetails(int id)
    {
        return await context.Recipes
            .Include(r => r.Creator)
            .Include(r => r.Rating)
            .Include(r => r.Category)
            .Include(r => r.Tags)
            .Include(r =>  r.Blocks)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<Recipe?> GetRecipeForPatch(int id)
    {
        return await context.Recipes
            .Include(r => r.Tags)
            .Include(r => r.Blocks)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task<Recipe?> GetRecipeForDeleting(int id)
    {
        return await context.Recipes.FindAsync(id);
    }

    public async Task<Recipe?> GetRecipeForRatingReview(int id)
    {
        return await context.Recipes
            .Include(r => r.Rating)
            .Include(r => r.Reviews)
            .FirstOrDefaultAsync(r => r.Id == id);
    }
}