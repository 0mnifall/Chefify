using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class AuthResponse
{
    public string AccessToken { get; set; }
    [Required]
    public string RefreshToken { get; set; } 
}