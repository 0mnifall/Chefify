using System.ComponentModel.DataAnnotations;

namespace backend.Dto;

public class CategoryPreviewDto
{
    public int Id { get; set; }
    [Required]
    public required string Name { get; set; }
}