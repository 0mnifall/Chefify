using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace backend.Services;

public class AuthService(AppDbContext context, IConfiguration configuration)
{
    public async Task<bool> IsExist(string email)
    {
        return await context.Users.AnyAsync(x => x.Email == email);
    }

    public async Task Register(RegisterDto dto)
    {
        var user = new User
        {
            Username = dto.Username,
            Email = dto.Email,

            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password)
        };
            
        context.Users.Add(user);
        user.ProfilePictureRef = $"images/pfp/{user.Id}";
        await context.SaveChangesAsync();
    }

    public async Task<AuthRequest?> FindUser(string email)
    {
        return await context.Users.Select(u => new AuthRequest
        {
            Id = u.Id,
            Username = u.Username,
            Email = u.Email,
            Role = u.Role,
            PasswordHash = u.PasswordHash
        }).FirstOrDefaultAsync(s => s.Email == email);
    }
    
    private string GenerateJwtToken(AuthRequest user)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.Role, user.Role.ToString())
        };
        
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["Jwt:Key"]!));

        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: configuration["Jwt:Issuer"],
            audience: configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
    
    private string GenerateRefreshToken()
    {
        var randomNumber = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);

        return Convert.ToBase64String(randomNumber);
    }

    public bool Verify(string password, string passwordHash)
    {
        return BCrypt.Net.BCrypt.Verify(password, passwordHash);
    }

    public async Task<AuthResponse> Login(AuthRequest user)
    {
        var accessToken = GenerateJwtToken(user);
        var refreshToken = GenerateRefreshToken();

        await context.Users.Where(u => u.Email == user.Email)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(u => u.RefreshToken, refreshToken)
                .SetProperty(u => u.Expires, DateTime.UtcNow.AddDays(7)));
        
        await context.SaveChangesAsync();

        return new AuthResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken
        };
    }

    public async Task<AuthRequest?> FindRefresh(string refreshToken)
    {
        return await context.Users
            .Where(u => u.RefreshToken == refreshToken &&
                        u.Expires > DateTime.UtcNow)
            .Select(u => new AuthRequest
            {
                Id = u.Id,
                Email = u.Email,
                Username = u.Username,
                PasswordHash = u.PasswordHash,
                Role = u.Role
            })
            .FirstOrDefaultAsync();
    }

    public async Task DeleteUser(User user)
    {
        context.Users.Remove(user);
        await context.SaveChangesAsync();
    }
}