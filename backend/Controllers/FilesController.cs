using System.Security.Claims;
using backend.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FilesController(S3FileStorageService storage) : ControllerBase
{
    private int CurrentUserId =>
        int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

    [HttpPost("images")]
    [Authorize(Roles = "User,Admin")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    public async Task<IActionResult> UploadImage(IFormFile file, [FromForm] string type)
    {
        try
        {
            return Ok(await storage.UploadImageAsync(file, CurrentUserId, type));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpGet("presigned-url")]
    [Authorize(Roles = "User,Admin")]
    public IActionResult GetPresignedUrl([FromQuery] string key)
    {
        if (string.IsNullOrWhiteSpace(key))
        {
            return BadRequest("Key is required.");
        }

        return Ok(storage.CreatePresignedResult(key));
    }
}
