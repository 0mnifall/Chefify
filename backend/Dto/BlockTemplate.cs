namespace backend.Dto;

public class BlockTemplate
{
    public required string Type {get; set;}
    public string? Text { get; set; } = null;
    public string? Url { get; set; } = null;
    public string? Caption { get; set; } = null;
    public List<string>? Items { get; set; } = null;
}