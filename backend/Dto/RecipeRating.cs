namespace backend.Dto;

public class RecipeRating
{
    public int Quantity { get; set; }
    public float Avg { get; set; }
    public List<int> ByRate { get; set; } = [0, 0, 0, 0, 0];
}