using backend.Models;
using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class AdminUserDto
{
    [Required]
    public required Role Role { get; set; }

    [Required]
    [StringLength(50, MinimumLength = 3)]
    public required string Username { get; set; }
}
