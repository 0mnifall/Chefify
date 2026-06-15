using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoryController(AppDbContext context) : ControllerBase
{
    [Authorize]
    [HttpPost]
    public async Task<IActionResult> CreateCategory(string name)
    {
        var category = new Category
        {
            Name = name
        };
        
        context.Categories.Add(category);
        await context.SaveChangesAsync();
        
        return CreatedAtAction(
            nameof(GetCategory),
            new { id = category.Id },
            new CategoryPreviewDto
            {
                Id = category.Id,
                Name = category.Name
            }
        );
    }

    [HttpGet]
    public async Task<IActionResult> GetCategories()
    {
        var categories = await context.Categories
            .Select(c => new CategoryPreviewDto
            {
                Id = c.Id,
                Name = c.Name
            })
            .ToListAsync();
        
        return Ok(categories);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetCategory(int id)
    {
        var category = await context.Categories
            .Include(c => c.Recipes)
            .ThenInclude(r => r.Creator)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category == null)
        {
            return NotFound();
        }

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
        
        var categoryDto = new CategoryDto
        {
            Name = category.Name,
            Recipes = recipes
        };
        
        return Ok(categoryDto);
    }
}