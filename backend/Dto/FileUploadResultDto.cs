namespace backend.Dto;

public class FileUploadResultDto
{
    public required string Key { get; set; }
    public required string PresignedUrl { get; set; }
    public DateTime ExpiresAt { get; set; }
}
