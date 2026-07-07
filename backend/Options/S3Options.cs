namespace backend.Options;

public class S3Options
{
    public const string SectionName = "S3";

    public string BucketName { get; set; } = "";
    public string Region { get; set; } = "";
    public string? AccessKey { get; set; }
    public string? SecretKey { get; set; }
    public int PresignedUrlMinutes { get; set; } = 15;
    public long MaxUploadBytes { get; set; } = 10 * 1024 * 1024;
}
