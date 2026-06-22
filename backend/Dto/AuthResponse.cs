using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class AuthResponse
{
    [Required]
    public required string AccessToken { get; set; }
    [Required]
    public required string RefreshToken { get; set; } 
}