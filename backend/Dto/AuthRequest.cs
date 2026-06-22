using backend.Models;

namespace backend.Dto;

public class AuthRequest
{
    public int Id { get; set; }
    public required string Email { get; set; }
    public required string Username { get; set; }
    public Role Role { get; set; }
    public required string PasswordHash { get; set; }
}