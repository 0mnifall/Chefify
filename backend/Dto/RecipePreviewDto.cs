namespace backend.Dto;

public class RecipePreviewDto
{
    public int Id { get; set; }
    public required string Title { get; set; }
    public required string Description { get; set; }
    public int CookingTime { get; set; }
    public int Difficulty { get; set; }
    public string Creator { get; set; }
}