namespace backend.Dto;

public class AdminRecipeDto
{
    public required string Title { get; set; }
    public required string Description { get; set; }
    public required int CookingTime { get; set; }
    public required int Difficulty { get; set; }
    public required int CategoryId { get; set; }
    public required List<int> TagIds { get; set; }
    public required List<BlockTemplate> Blocks { get; set; }
    public required int CreatorId { get; set; }
}