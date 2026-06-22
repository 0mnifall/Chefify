using backend.Dto;
using backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoryController(CategoryService service) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IEnumerable<CategoryPreviewDto>>> GetCategories()
    {
        return Ok(await service.GetAllCategories());
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetCategory(int id)
    {
        var category = await service.GetCategoryEntity(id);

        if (category == null)
        {
            return NotFound();
        }
        
        return Ok(service.GetCategory(category));
    }
}