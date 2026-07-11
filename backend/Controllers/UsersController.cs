using backend.Dto;
using backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController(UserService service) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAllUsers()
    {
        var users = await service.GetAllUsers();
        
        return Ok(users);
    }
    
    [HttpGet("{id}")]
    public async Task<IActionResult> GetUser(int id)
    {
        var user = await service.GetUser(id);
        
        if (user == null)
        {
            return NotFound();
        }

        var userDto = UserService.ToDto(user);
        
        return Ok(userDto);
    }

    [HttpGet("{id}/recipes")]
    public async Task<ActionResult<IEnumerable<RecipePreviewDto>>> GetUserRecipes(int id)
    {
        var user = await service.GetUserEntity(id);

        if (user == null)
        {
            return NotFound();
        }

        var recipes = service.GetUserRecipes(user);
        
        return Ok(recipes);
    }
}