using Amazon.S3;
using Amazon.S3.Model;
using backend.Dto;
using backend.Options;
using Microsoft.Extensions.Options;

namespace backend.Services;

public class S3FileStorageService(IAmazonS3 s3, IOptions<S3Options> options)
{
    private static readonly HashSet<string> AllowedImageContentTypes =
    [
        "image/webp"
    ];

    private readonly S3Options _options = options.Value;

    public async Task<FileUploadResultDto> UploadImageAsync(IFormFile file, string key)
    {
        ValidateImage(file);
        await using var stream = file.OpenReadStream();
        await s3.PutObjectAsync(new PutObjectRequest
        {
            BucketName = _options.BucketName,
            Key = key,
            InputStream = stream,
            ContentType = file.ContentType
        });
        
        return await CreatePresignedResult(key);
    }

    public async Task<FileUploadResultDto> CreatePresignedResult(string key)
    {
        await s3.GetObjectMetadataAsync(new GetObjectMetadataRequest
        {
            BucketName = _options.BucketName,
            Key = key
        });
            
        var expiresAt = DateTime.UtcNow.AddMinutes(_options.PresignedUrlMinutes);
        var url = await s3.GetPreSignedURLAsync(new GetPreSignedUrlRequest
        {
            BucketName = _options.BucketName,
            Key = key,
            Expires = expiresAt,
            Verb = HttpVerb.GET
        });

        return new FileUploadResultDto
        {
            Key = key,
            PresignedUrl = url,
            ExpiresAt = expiresAt
        };
    }

    private void ValidateImage(IFormFile file)
    {
        if (file.Length == 0)
        {
            throw new ArgumentException("File is empty.");
        }

        if (file.Length > _options.MaxUploadBytes)
        {
            throw new ArgumentException($"File is too large. Max size is {_options.MaxUploadBytes} bytes.");
        }

        if (!AllowedImageContentTypes.Contains(file.ContentType))
        {
            throw new ArgumentException("Only webp images are allowed.");
        }
    }

    public static string CreatePfpImageKey(string fileName, int userId)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        return $"images/pfp/{userId}{extension}";
    }

    public static string CreateRecipeImageKey(string fileName, int recipeId, string type)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        return $"images/recipes/{recipeId}/{type}/{Guid.NewGuid():N}{extension}";
    }
}
