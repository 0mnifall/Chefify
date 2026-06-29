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
            Rating = new RecipeRating(),
            Category = await context.Categories.FindAsync(dto.CategoryId),
            Tags = tags,
            Blocks = dto.Blocks,
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
            .Include(r => r.Blocks)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    public async Task PatchRecipe(int id, PatchRecipeDto dto, Recipe recipe)
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
            .Include(r => r.Rating)
            .Include(r => r.Category)
            .Include(r => r.Tags)
            .Include(r =>  r.Blocks)
            .FirstOrDefaultAsync(r => r.Id == id);
    }
    public RecipeDto ToDto(Recipe recipe)
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
        recipe.Blocks = dto.Blocks;
        recipe.CreatorId = dto.CreatorId;
        
        context.Recipes.Update(recipe);
        await  context.SaveChangesAsync();
    }

    public async Task<Recipe?> GetRecipeForRatingReview(int id)
    {
        return await context.Recipes
            .Include(r => r.Rating)
            .Include(r => r.Reviews)
            .FirstOrDefaultAsync(r => r.Id == id);
    }

    private async Task CalculateAvgRating(Recipe recipe)
    {
        int sum = 0;
        for (int i = 1; i <= 5; i++)
        {
            sum += recipe.Rating.ByRate[i - 1] * i;
        }

        recipe.Rating.Avg = Single.Round(sum / (float)recipe.Rating.Quantity, 2);
        
        await context.SaveChangesAsync();
    }

    public async Task UploadReview(Recipe recipe, CreateRecipeReview review, int reviewerId)
    {
        recipe.Rating.Quantity++;
        recipe.Rating.ByRate[review.Rate - 1]++;
        await CalculateAvgRating(recipe);
        
        recipe.Reviews.Add(new RecipeReview
        {
            ReviewerId = reviewerId,
            Rate = review.Rate,
            Overview = review.Overview
        });
        
        await context.SaveChangesAsync();
    }
}