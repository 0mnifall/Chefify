using backend.Dto;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers.Admin;

[ApiController]
[Route("api/admin/[controller]")]
public class AdminRecipeController(RecipeService service) : ControllerBase
{
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<IActionResult> CreateRecipe(CreateRecipeDto dto)
    {
        await service.AddRecipe(dto, 1);
        
        return Ok();
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateRecipe(int id, AdminRecipeDto dto)
    {
        var recipe = await service.GetRecipeForPatch(id);
        
        if (recipe == null)
        {
            return NotFound();
        }
        
        await service.UpdateRecipe(recipe, dto);
        
        return NoContent();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteRecipe(int id)
    {
        var recipe = await service.GetRecipeForDeleting(id);
        
        if (recipe == null)
        {
            return NotFound();
        }

        await service.DeleteRecipe(recipe);
        
        return NoContent();
    }
}