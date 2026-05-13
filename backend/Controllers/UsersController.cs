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
            .Select(u => new UserDto
            {
                Username = u.Username,
                Recipes = u.Recipes.Select(r => new RecipeDto
                {
                    Title = r.Title,
                    Description = r.Description,
                    CookingTime = r.CookingTime,
                    Difficulty = r.Difficulty,
                    Creator = u.Username
                }).ToList()
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

        var recipes = await context.Recipes
            .Where(r => r.CreatorId == id)
            .Select(r => new RecipeDto
            {
                Title = r.Title,
                Description = r.Description,
                CookingTime = r.CookingTime,
                Difficulty = r.Difficulty,
                Creator = user.Username
            }).ToListAsync();

        var userDto = new UserDto
        {
            Username = user.Username,
            Recipes = recipes
        };
        return Ok(userDto);
    }
}