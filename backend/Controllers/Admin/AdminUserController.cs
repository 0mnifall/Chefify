using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers.Admin;

[ApiController]
[Route("api/[controller]")]
public class AdminUserController(AppDbContext context) : ControllerBase
{
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<IActionResult> CreateUser(RegisterDto dto)
    {
        var exists = await context.Users.AnyAsync(x => x.Email == dto.Email);

        if (exists)
        {
            return BadRequest("Email already exists");
        }

        var user = new User
        {
            Username = dto.Username,
            Email = dto.Email,

            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password)
        };
            
        context.Users.Add(user);

        await context.SaveChangesAsync();

        return Ok();
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateUser(int id, AdminUserDto dto)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == id);

        if (user == null)
        {
            return NotFound();
        }

        user.Role = dto.Role;
        user.Username = dto.Username;
        
        context.Users.Update(user);
        await context.SaveChangesAsync();
        
        return Ok();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == id);

        if (user == null)
        {
            return NotFound();
        }
        
        context.Users.Remove(user);
        await context.SaveChangesAsync();
        
        return NoContent();
    }
}