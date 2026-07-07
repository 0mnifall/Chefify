using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class RefreshRequest
{
    [Required]
    public string RefreshToken { get; set; } = string.Empty;
}
