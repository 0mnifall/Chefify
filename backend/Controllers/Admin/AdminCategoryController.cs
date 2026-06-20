using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers.Admin;

[ApiController]
[Route("api/admin/[controller]")]
public class AdminCategoryController(CategoryService service) : ControllerBase
{
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<IActionResult> CreateCategory(string name)
    {
        await service.CreateCategory(name);
        
        return Ok();
    }
}