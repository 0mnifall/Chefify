namespace backend.Models;

public class Category
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public List<Recipe> Recipes { get; set; } = [];
}