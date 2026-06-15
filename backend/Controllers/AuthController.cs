using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController(AppDbContext context, IConfiguration configuration) : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterDto dto)
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

    
    private string GenerateJwtToken(User user)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.Role, user.Role.ToString())
        };
        
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]));

        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: configuration["Jwt:Issuer"],
            audience: configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
    
    
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var user = await context.Users.FirstOrDefaultAsync(s => s.Email == dto.Email);

        if (user == null)
        {
            return Unauthorized();
        }
        
        var verified = BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash);

        if (!verified)
        {
            return Unauthorized();
        }
        
        var accessToken = GenerateJwtToken(user);
        var refreshToken = GenerateRefreshToken();
        
        user.RefreshToken = refreshToken;
        user.Expires = DateTime.UtcNow.AddDays(7);
        
        await context.SaveChangesAsync();
        
        return Ok(new AuthResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken
        });
    }

    private string GenerateRefreshToken()
    {
        var randomNumber = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);

        return Convert.ToBase64String(randomNumber);
    }
    
    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh(AuthResponse request)
    {
        var user = await context.Users.FirstOrDefaultAsync(s => s.RefreshToken == request.RefreshToken);

        if (user == null)
        {
            return Unauthorized();
        }

        if (user.Expires < DateTime.UtcNow)
        {
            return Unauthorized("Refresh token expired");
        }

        var newAccessToken = GenerateJwtToken(user);
        var newRefreshToken = GenerateRefreshToken();

        user.RefreshToken = newRefreshToken;
        user.Expires = DateTime.UtcNow.AddDays(7);

        await context.SaveChangesAsync();
        
        return Ok(new AuthResponse
        {
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken
        });
    }
}