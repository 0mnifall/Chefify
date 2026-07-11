using System.Security.Claims;
using backend.Dto;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]s")]
public class RecipeController(RecipeQueryService queries,
    RecipeCommandService commands,
    RecipeReviewService reviews,
    RecipeAuthorizationService recipeAuthorization) : ControllerBase
{
    private int CurrentUserId =>
        int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

    [Authorize(Roles = "User,Admin")]
    [HttpPost]
    public async Task<IActionResult> Create(CreateRecipeDto dto)
    {
        var id = await commands.AddRecipe(dto, CurrentUserId);

        if (id == 0)
        {
            return BadRequest("Invalid category ID.");
        }
        
        return CreatedAtAction(nameof(GetRecipe), new { id });
    }

    [Authorize(Roles = "User,Admin")]
    [HttpPatch("{id}")]
    public async Task<IActionResult> Patch(int id, PatchRecipeDto dto)
    {
        var recipe = await queries.GetRecipeForPatch(id);

        if (recipe == null)
        {
            return NotFound();
        }
        
        if (!await recipeAuthorization.IsAuthor(recipe.Id, CurrentUserId))
        {
            return Forbid();
        }

        await commands.PatchRecipe(recipe, dto);
        
        return NoContent();
    }
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<RecipePreviewDto>>> GetRecipes()
    {
        return Ok(await queries.GetAllRecipes());
    }


    [HttpGet("{id}")]
    public async Task<ActionResult<RecipeDto>> GetRecipe(int id)
    {
        var recipe = await queries.GetRecipeForDetails(id);
        
        if (recipe == null)
        {
            return NotFound();
        }
        
        var recipeDto = RecipeMapper.GetRecipeDetailsDto(recipe);
        
        return Ok(recipeDto);
    }

    [Authorize(Roles = "User,Admin")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteRecipe(int id)
    {
        var recipe = await queries.GetRecipeForDeleting(id);
        
        if (recipe == null)
        {
            return NotFound();
        }

        if (!await recipeAuthorization.IsAuthor(recipe.Id, CurrentUserId))
        {
            return Forbid();
        }

        await commands.DeleteRecipe(recipe);
        
        return NoContent();
    }

    [HttpPost("{id}/review")]
    [Authorize(Roles = "User,Admin")]
    public async Task<IActionResult> UploadReview(int id, CreateRecipeReview review)
    {
        var recipe = await queries.GetRecipeForRatingReview(id);

        if (recipe == null)
        {
            return NotFound();
        }

        await reviews.UploadReview(recipe, review, CurrentUserId);

        return Ok();
    }
}
