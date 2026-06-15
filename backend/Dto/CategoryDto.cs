namespace backend.Dto;

public class CategoryDto
{
    public required string Name { get; set; }
    public required List<RecipePreviewDto> Recipes { get; set; }
}