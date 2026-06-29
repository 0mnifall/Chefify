using System.Security.Claims;
using backend.Dto;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]s")]
public class RecipeController(RecipeService service) : ControllerBase
{
    [Authorize(Roles = "User,Admin")]
    [HttpPost]
    public async Task<IActionResult> Create(CreateRecipeDto dto)
    {
        var creatorId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var id = await service.AddRecipe(dto, creatorId);
        
        return CreatedAtAction(nameof(GetRecipe), new { id });
    }

    [Authorize(Roles = "User,Admin")]
    [HttpPatch("{id}")]
    public async Task<IActionResult> Patch(int id, PatchRecipeDto dto)
    {
        var recipe = await service.GetRecipeForPatch(id);

        if (recipe == null)
        {
            return NotFound();
        }
        
        if (recipe.CreatorId != int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value))
        {
            return Forbid();
        }

        await service.PatchRecipe(id, dto, recipe);
        
        return NoContent();
    }
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<RecipePreviewDto>>> GetRecipes()
    {
        return Ok(await service.GetAllRecipes());
    }


    [HttpGet("{id}")]
    public async Task<ActionResult<RecipeDto>> GetRecipe(int id)
    {
        var recipe = await service.GetRecipeForReview(id);
        
        if (recipe == null)
        {
            return NotFound();
        }
        
        var recipeDto = service.ToDto(recipe);
        
        return Ok(recipeDto);
    }

    [Authorize(Roles = "User,Admin")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteRecipe(int id)
    {
        var recipe = await service.GetRecipeForDeleting(id);
        
        if (recipe == null)
        {
            return NotFound();
        }

        if (recipe.CreatorId != int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value))
        {
            return Forbid();
        }

        await service.DeleteRecipe(recipe);
        
        return NoContent();
    }

    [HttpPost("{id}/review")]
    [Authorize(Roles = "User,Admin")]
    public async Task<IActionResult> UploadReview(int id, CreateRecipeReview review)
    {
        var recipe = await service.GetRecipeForRatingReview(id);

        if (recipe == null)
        {
            return NotFound();
        }

        await service.UploadReview(recipe, review, int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value));

        return Ok();
    }
}