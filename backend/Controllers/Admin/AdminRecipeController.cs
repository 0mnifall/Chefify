using backend.Dto;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers.Admin;

[ApiController]
[Route("api/admin/[controller]")]
public class AdminRecipeController(RecipeQueryService queries,
    RecipeCommandService commands,
    AdminRecipeService adminService) : ControllerBase
{
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<IActionResult> CreateRecipe(CreateRecipeDto dto)
    {
        if (await commands.AddRecipe(dto, 1) == 0)
        {
            return BadRequest("Invalid category ID.");
        }
        
        return Ok();
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateRecipe(int id, AdminRecipeDto dto)
    {
        var recipe = await queries.GetRecipeForPatch(id);
        
        if (recipe == null)
        {
            return NotFound();
        }
        
        var error = await adminService.UpdateRecipe(recipe, dto);

        if (error != null)
        {
            return BadRequest(error);
        }
        
        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteRecipe(int id)
    {
        var recipe = await queries.GetRecipeForDeleting(id);
        
        if (recipe == null)
        {
            return NotFound();
        }

        await commands.DeleteRecipe(recipe);
        
        return NoContent();
    }
}
