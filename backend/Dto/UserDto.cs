using backend.Models;
using static System.Net.Mime.MediaTypeNames;

namespace backend.Dto;

public class UserDto
{
    public required string Username { get; set; }
    //  TO DO
    //
    //  Recipes
    //
    public string? ProfilePictureRef { get; set; }
}