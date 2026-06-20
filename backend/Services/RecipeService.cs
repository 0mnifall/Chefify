using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class RecipeService(AppDbContext context)
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
        
        var recipe = new Recipe
        {
            Title = dto.Title,
            Description = dto.Description,
            CookingTime = dto.CookingTime,
            Difficulty = dto.Difficulty,
            Category = await context.Categories.FindAsync(dto.CategoryId),
            Tags = tags,
            CreatorId = creatorId
        };
        
        context.Recipes.Add(recipe);
        await context.SaveChangesAsync();
        
        return recipe.Id;
    }

    public async Task<Recipe?> GetRecipeForPatch(int id)
    {
        return await context.Recipes
            .Include(r => r.Tags)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task PatchRecipe(int id, PatchRecipeDto dto, Recipe recipe)
    {
        recipe!.Description = dto.Description ?? recipe.Description;
        recipe.CookingTime = dto.CookingTime ?? recipe.CookingTime;
        recipe.Difficulty = dto.Difficulty ?? recipe.Difficulty;
        
        if (dto.TagIds != null)
        {
            recipe.Tags = await context.Tags
                .Where(t => dto.TagIds.Contains(t.Id))
                .ToListAsync();
        }
        
        await  context.SaveChangesAsync();
    }

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

    public async Task<Recipe?> GetRecipeForReview(int id)
    {
        return await context.Recipes
            .Include(r => r.Creator)
            .Include(r => r.Category)
            .Include(r => r.Tags)
            .FirstOrDefaultAsync(r => r.Id == id);
    }
    public RecipeDto GetRecipeDto(int id, Recipe recipe)
    {
        var recipeDto = new RecipeDto
        {
            Title = recipe.Title,
            Description = recipe.Description,
            CookingTime = recipe.CookingTime,
            Difficulty = recipe.Difficulty,
            
            Category = recipe.Category != null ? new CategoryPreviewDto
            {
                Id = recipe.Category.Id,
                Name = recipe.Category.Name
            } : null,
            Tags = recipe.Tags.Select(t => t.Name).ToList(),
            CreatorId = recipe.Creator.Id,
            Creator = new UserDto
            {
                Username = recipe.Creator.Username,
                //ProfilePictureRef = recipe.Creator.ProfilePictureRef
            }
        };
        
        return recipeDto;
    }

    public async Task<Recipe?> GetRecipeForDeleting(int id)
    {
        return await context.Recipes.FindAsync(id);
    }
    
    public async Task DeleteRecipe(Recipe recipe)
    {
        context.Recipes.Remove(recipe);
        await context.SaveChangesAsync();
    }

    public async Task UpdateRecipe(Recipe recipe, AdminRecipeDto dto)
    {
        recipe.Title = dto.Title;
        recipe.Description = dto.Description;
        recipe.CookingTime = dto.CookingTime;
        recipe.Difficulty = dto.Difficulty;
        recipe.Category = await context.Categories.FindAsync(dto.CategoryId);
        recipe.Tags = await context.Tags
            .Where(t => dto.TagIds.Contains(t.Id))
            .ToListAsync();
        recipe.CreatorId = dto.CreatorId;
        
        context.Recipes.Update(recipe);
        await  context.SaveChangesAsync();
    }
}