using backend.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Amazon;
using Amazon.Runtime;
using Amazon.S3;
using backend.Options;
using backend.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddScoped<RecipeQueryService>();
builder.Services.AddScoped<RecipeCommandService>();
builder.Services.AddScoped<RecipeReviewService>();
builder.Services.AddScoped<RecipeAuthorizationService>();
builder.Services.AddScoped<AdminRecipeService>();
builder.Services.AddScoped<UserService>();
builder.Services.AddScoped<AuthService>();
builder.Services.AddScoped<CategoryService>();
builder.Services.AddScoped<S3FileStorageService>();

builder.Services.Configure<S3Options>(builder.Configuration.GetSection(S3Options.SectionName));

builder.Services.AddSingleton<IAmazonS3>(_ =>
{
    var s3Options = builder.Configuration
        .GetSection(S3Options.SectionName)
        .Get<S3Options>() ?? new S3Options();

    if (string.IsNullOrWhiteSpace(s3Options.BucketName))
    {
        throw new InvalidOperationException("S3:BucketName is not configured.");
    }

    if (string.IsNullOrWhiteSpace(s3Options.Region))
    {
        throw new InvalidOperationException("S3:Region is not configured.");
    }

    var region = RegionEndpoint.GetBySystemName(s3Options.Region);

    if (!string.IsNullOrWhiteSpace(s3Options.AccessKey) &&
        !string.IsNullOrWhiteSpace(s3Options.SecretKey))
    {
        return new AmazonS3Client(
            new BasicAWSCredentials(s3Options.AccessKey, s3Options.SecretKey),
            region);
    }

    return new AmazonS3Client(region);
});


var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException("ConnectionStrings:DefaultConnection is not configured.");
}

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));


builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutter", policy =>
    {
        var allowedOrigins = builder.Configuration
            .GetSection("Cors:AllowedOrigins")
            .Get<string[]>() ?? [];

        if (allowedOrigins.Length == 0)
        {
            if (!builder.Environment.IsDevelopment())
            {
                throw new InvalidOperationException("Cors:AllowedOrigins is not configured.");
            }

            allowedOrigins =
            [
                "http://localhost:8088",
                "http://localhost:8089",
                "http://localhost:8090"
            ];
        }

        policy
            .WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var jwtKey = builder.Configuration["Jwt:Key"];

if (string.IsNullOrWhiteSpace(jwtKey))
{
    throw new InvalidOperationException("Jwt:Key is not configured.");
}

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters =
            new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,

                ValidIssuer = builder.Configuration["Jwt:Issuer"],
                ValidAudience = builder.Configuration["Jwt:Audience"],

                IssuerSigningKey = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(jwtKey))
            };
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    // Опис поля для введення токена
    options.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "Введіть токен у форматі: Bearer {ваш_токен}"
    });

    // Глобальна або вибіркова вимога авторизації для ендпоінтів
    options.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
    
    options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "Chefify API",
        Version = "v1",
        Description = "API for cooking"
    });
});

builder.Services.AddControllers();
var app = builder.Build();

await app.InitializeDatabaseAsync();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseCors("AllowFlutter");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.Run();