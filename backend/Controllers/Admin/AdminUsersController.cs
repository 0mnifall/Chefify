using backend.Dto;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers.Admin;

[ApiController]
[Route("api/admin/[controller]")]
public class AdminUsersController(UserService service, AuthService auth) : ControllerBase
{
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<IActionResult> CreateUser(RegisterDto dto)
    {
        if (await auth.IsExist(dto.Email))
        {
            return BadRequest("Email already exists");
        }

        await auth.Register(dto);
        
        return Ok();
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateUser(int id, AdminUserDto dto)
    {
        var user = await service.GetUser(id);

        if (user == null)
        {
            return NotFound();
        }
        
        return Ok();
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        var user = await service.GetUser(id);

        if (user == null)
        {
            return NotFound();
        }

        await auth.DeleteUser(user);
        
        return NoContent();
    }
}