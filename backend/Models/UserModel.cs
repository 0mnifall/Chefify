using System.ComponentModel.DataAnnotations;

namespace backend.Models;

public class User
{
    public int Id { get; set; }
    public string Username { get; set; }
    //public string ProfilePictureRef { get; set; }
    
    public string Email { get; set; }
    public string PasswordHash { get; set; }
    
    public string? RefreshToken { get; set; }
    public DateTime Expires { get; set; }

    public List<Recipe> Recipes { get; set; }
}