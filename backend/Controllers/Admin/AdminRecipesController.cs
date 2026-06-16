using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers.Admin;

[ApiController]
[Route("api/admin/[controller]")]
public class RecipesController(AppDbContext context) : ControllerBase
{
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<IActionResult> CreateRecipe(CreateRecipeDto dto)
    {
        var tags = await context.Tags
            .Where(t => dto.TagsId.Contains(t.Id))
            .ToListAsync();

        var recipe = new Recipe
        {
            Title = dto.Title,
            Description = dto.Description,
            CookingTime = dto.CookingTime,
            Difficulty = dto.Difficulty,
            Category = await context.Categories.FindAsync(dto.CategoryId),
            Tags = tags,
            CreatorId = -1
        };
        
        context.Recipes.Add(recipe);
        await context.SaveChangesAsync();
        
        return Ok();
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateRecipe(int id, AdminRecipeDto dto)
    {
        var recipe = await context.Recipes
            .Include(r => r.Tags)
            .FirstOrDefaultAsync(r => r.Id == id);
        if (recipe == null)
        {
            return NotFound();
        }
        
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
        
        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteRecipe(int id)
    {
        var recipe = await context.Recipes.FirstOrDefaultAsync(r => r.Id == id);
        
        if (recipe == null)
        {
            return NotFound();
        }

        context.Recipes.Remove(recipe);
        await context.SaveChangesAsync();
        
        return NoContent();
    }
}