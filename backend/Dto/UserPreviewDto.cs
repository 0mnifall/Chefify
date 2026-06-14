using backend.Models;
using static System.Net.Mime.MediaTypeNames;

namespace backend.Dto;

public class UserPreviewDto
{
    public int Id { get; set; }
    public string Username { get; set; }
    //public string ProfilePictureRef { get; set; }
}