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
            CreatorId = creatorId
        };
        
        context.Recipes.Add(recipe);
        await context.SaveChangesAsync();
        
        return CreatedAtAction(nameof(GetRecipe), new { id = recipe.Id }, recipe);
    }

    [Authorize]
    [HttpPatch("{id}")]
    public async Task<IActionResult> Patch(int id, PatchRecipeDto dto)
    {
        var recipe = await context.Recipes
            .Include(r => r.Tags)
            .FirstOrDefaultAsync(r => r.Id == id);
        if (recipe == null)
        {
            return NotFound();
        }
        
        if (recipe.CreatorId != int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value))
        {
            return Forbid();
        }
        
        recipe.Description = dto.Description ?? recipe.Description;
        recipe.CookingTime = dto.CookingTime ?? recipe.CookingTime;
        recipe.Difficulty = dto.Difficulty ?? recipe.Difficulty;
        
        if (dto.TagIds != null)
        {
            recipe.Tags = await context.Tags
                .Where(t => dto.TagIds.Contains(t.Id))
                .ToListAsync();
        }
        
        await  context.SaveChangesAsync();
        
        return NoContent();
    }
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<RecipePreviewDto>>> GetRecipes()
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
        
        return Ok(recipes);
    }


    [HttpGet("{id}")]
    public async Task<ActionResult<RecipeDto>> GetRecipe(int id)
    {
        var recipe = await context.Recipes
            .Include(r => r.Creator)
            .Include(r => r.Category)
            .Include(r => r.Tags)
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
        return Ok(recipeDto);
    }

    [Authorize]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteRecipe(int id)
    {
        var recipe = await context.Recipes.FindAsync(id);
        if (recipe == null)
        {
            return NotFound();
        }

        if (recipe.CreatorId != int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value))
        {
            return Forbid();
        }
        
        context.Recipes.Remove(recipe);
        await context.SaveChangesAsync();
        
        return NoContent();
    }
}