namespace backend.Dto;

public class UserPreviewDto
{
    public int Id { get; set; }
    public required string Username { get; set; }
    public string? ProfilePictureRef { get; set; }
}