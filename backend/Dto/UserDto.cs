using backend.Models;
using static System.Net.Mime.MediaTypeNames;

namespace backend.Dto;

public class UserDto
{
    public string Username { get; set; }
    public string ProfilePictureRef { get; set; }
}