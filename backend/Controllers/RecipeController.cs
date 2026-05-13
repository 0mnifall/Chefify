using System.ComponentModel.DataAnnotations;
using System.Security.Claims;
using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]s")]
public class RecipeController(AppDbContext context) : ControllerBase
{
    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Create(CreateRecipeDto dto)
    {
        var creatorId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        
        var recipe = new Recipe
        {
            Title = dto.Title,
            Description = dto.Description,
            CookingTime = dto.CookingTime,
            Difficulty = dto.Difficulty,
            CreatorId = creatorId
        };
        
        context.Recipes.Add(recipe);
        await context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetRecipe), new { id = recipe.Id }, recipe);
    }
    
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Recipe>>> GetRecipes()
    {
        var recipes = await context.Recipes
            .Include(r => r.Creator)
            .Select(r => new RecipeDto
            {
                Title = r.Title,
                Description = r.Description,
                CookingTime = r.CookingTime,
                Difficulty = r.Difficulty,
                Creator = r.Creator.Username
            })
            .ToListAsync();
        return Ok(recipes);
    }


    [HttpGet("{id}")]
    public async Task<ActionResult<Recipe>> GetRecipe(int id)
    {
        var recipe = await context.Recipes
            .Include(r => r.Creator)
            .FirstOrDefaultAsync(r => r.Id == id);
        if (recipe == null)
        {
            return NotFound();
        }

        var recipeDto = new RecipeDto
        {
            Title = recipe.Title,
            Description = recipe.Description,
            CookingTime = recipe.CookingTime,
            Difficulty = recipe.Difficulty,
            Creator = recipe.Creator.Username
        };
        return Ok(recipeDto);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteRecipe(int id)
    {
        var recipe = await context.Recipes.FindAsync(id);
        if (recipe == null)
        {
            return NotFound();
        }
        
        context.Recipes.Remove(recipe);
        await context.SaveChangesAsync();
        
        return NoContent();
    }
}