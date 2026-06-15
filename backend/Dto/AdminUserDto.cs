using backend.Models;

namespace backend.Dto;

public class AdminUserDto
{
    public Role Role { get; set; }
    public required string Username { get; set; }
}