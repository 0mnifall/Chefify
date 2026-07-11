using System.Security.Claims;
using Amazon.S3;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FilesController(S3FileStorageService storage, RecipeAuthorizationService service) : ControllerBase
{
    private int CurrentUserId =>
        int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
    
    [HttpPost("pfp")]
    [Authorize(Roles = "User,Admin")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    public async Task<IActionResult> UploadPfp(IFormFile file)
    {
        try
        {
            return Ok(await storage.UploadImageAsync(file, S3FileStorageService.CreatePfpImageKey(file.FileName, CurrentUserId)));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpPost("recipe/{recipeId}")]
    [Authorize(Roles = "User,Admin")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    public async Task<IActionResult> UploadRecipeImage(IFormFile file, int recipeId, [FromForm] string type)
    {
        if (!await service.IsAuthor(recipeId, CurrentUserId))
        {
            return Forbid();
        }
        
        try
        {
            return Ok(await storage.UploadImageAsync(file, S3FileStorageService.CreateRecipeImageKey(file.FileName, recipeId, type)));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpGet("presigned-url")]
    public async Task<IActionResult> GetPresignedUrl([FromQuery] string key)
    {
        if (string.IsNullOrWhiteSpace(key))
        {
            return BadRequest("Key is required.");
        }

        try
        {
            return Ok(await storage.CreatePresignedResult(key));
        }
        catch (AmazonS3Exception ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            return NotFound(ex.Message);
        }
    }
}
