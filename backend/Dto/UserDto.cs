using backend.Models;

namespace backend.Dto;

public class UserDto
{
    public string Username { get; set; }
    public List<RecipeDto> Recipes { get; set; }
}