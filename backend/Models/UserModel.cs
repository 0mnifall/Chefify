using System.ComponentModel.DataAnnotations;

namespace backend.Models;

public enum Role
{
    User,
    Admin
}
public class User
{
    public int Id { get; set; }
    public Role Role { get; set; }
    public required string Username { get; set; }
    //public string ProfilePictureRef { get; set; }
    
    public required string Email { get; set; }
    public required string PasswordHash { get; set; }
    
    public string? RefreshToken { get; set; }
    public DateTime Expires { get; set; }

    public List<Recipe> Recipes { get; set; }
}