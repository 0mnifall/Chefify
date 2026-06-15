namespace backend.Models;

public class Tag
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public List<Recipe> Recipes { get; set; } = [];
}