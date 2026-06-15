using backend.Data;
using backend.Dto;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController(AppDbContext context) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAllUsers()
    {
        var users = await context.Users
            .Select(u => new UserPreviewDto
            {
                Id = u.Id,
                Username = u.Username,
                //ProfilePictureRef = u.ProfilePictureRef,
            })
            .ToListAsync();
        
        return Ok(users);
    }
    
    [HttpGet("{id}")]
    public async Task<IActionResult> GetUser(int id)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == id);

        if (user == null)
        {
            return NotFound();
        }

        var userDto = new UserDto
        {
            Username = user.Username,
            //ProfilePictureRef = user.ProfilePictureRef
        };
        return Ok(userDto);
    }

    [HttpGet("{id}/recipes")]
    public async Task<ActionResult<IEnumerable<RecipePreviewDto>>> GetUserRecipes(int id)
    {
        var recipes = await context.Recipes.Where(r => r.CreatorId == id).Select(r => new RecipePreviewDto
            {
                Title = r.Title,
                Description = r.Description,
                CookingTime = r.CookingTime,
                Difficulty = r.Difficulty,
                CreatorUsername = r.Creator.Username
            })
            .ToListAsync();
        return Ok(recipes);
    }
}