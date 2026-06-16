using backend.Models;

namespace backend.Dto;

public class AdminUserDto
{
    public required Role Role { get; set; }
    public required string Username { get; set; }
}