using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class CategoryService(AppDbContext context)
{
    public async Task CreateCategory(string name)
    {
        var category = new Category
        {
            Name = name
        };
        
        context.Categories.Add(category);
        
        await context.SaveChangesAsync();
    }
    public async Task<List<CategoryPreviewDto>> GetAllCategories()
    {
        return await context.Categories
            .Select(c => new CategoryPreviewDto
            {
                Id = c.Id,
                Name = c.Name
            })
            .ToListAsync();
    }

    public async Task<Category?> GetCategoryEntity(int id)
    {
        return await context.Categories
            .Include(c => c.Recipes)
            .ThenInclude(r => r.Creator)
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    public CategoryDto GetCategory(Category category)
    {
        var recipes = category.Recipes.Select(r => new RecipePreviewDto
            {
                Id = r.Id,
                Title = r.Title,
                Description = r.Description,
                CookingTime = r.CookingTime,
                Difficulty = r.Difficulty,
                CategoryName = category.Name,
                CreatorUsername = r.Creator.Username
            })
            .ToList();
        
        return new CategoryDto
        {
            Name = category.Name,
            Recipes = recipes
        };
    }
}