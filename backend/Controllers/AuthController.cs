using backend.Dto;
using backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(AuthService service) : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterDto dto)
    {
        if (await service.IsExist(dto.Email))
        {
            return BadRequest("Email already exists");
        }

        await service.Register(dto);
        
        return Ok();
    }
    
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var user = await service.FindUser(dto.Email);

        if (user == null)
        {
            return NotFound();
        }

        if (!service.Verify(dto.Password, user.PasswordHash))
        {
            return Unauthorized();
        }

        return Ok(await service.Login(user));
    }
    
    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh(RefreshRequest request)
    {
        var user = await service.FindRefresh(request.RefreshToken);

        if (user == null)
        {
            return Unauthorized("Invalid refresh token");
        }
        
        return Ok(await service.Login(user));
    }
}