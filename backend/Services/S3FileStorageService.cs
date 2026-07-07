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

    private readonly S3Options options = options.Value;

    public async Task<FileUploadResultDto> UploadImageAsync(IFormFile file, int id, string type)
    {
        ValidateImage(file);
        string key;
        if (type == "pfp")
        {
            key = CreatePfpImageKey(file.FileName, id);
        }
        else if (type == "hero" || type == "content")
        {
            key = CreateRecipeContentImageKey(file.FileName, id, type);
        }
        else
        {
            throw new ArgumentException("Invalid image type. Must be 'pfp' or 'recipe'.");
        }

        await using var stream = file.OpenReadStream();
        await s3.PutObjectAsync(new PutObjectRequest
        {
            BucketName = options.BucketName,
            Key = key,
            InputStream = stream,
            ContentType = file.ContentType
        });

        return CreatePresignedResult(key);
    }

    public FileUploadResultDto CreatePresignedResult(string key)
    {
        var expiresAt = DateTime.UtcNow.AddMinutes(options.PresignedUrlMinutes);
        var url = s3.GetPreSignedURL(new GetPreSignedUrlRequest
        {
            BucketName = options.BucketName,
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

        if (file.Length > options.MaxUploadBytes)
        {
            throw new ArgumentException($"File is too large. Max size is {options.MaxUploadBytes} bytes.");
        }

        if (!AllowedImageContentTypes.Contains(file.ContentType))
        {
            throw new ArgumentException("Only webp images are allowed.");
        }
    }

    private static string CreatePfpImageKey(string fileName, int userId)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        return $"images/pfp/{userId}/{Guid.NewGuid():N}{extension}";
    }

    private static string CreateRecipeContentImageKey(string fileName, int recipeId, string type)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        return $"images/recipes/{recipeId}/{type}/{Guid.NewGuid():N}{extension}";
    }
}
