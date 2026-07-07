using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Data;

public static class DatabaseInitializer
{
    public static async Task InitializeDatabaseAsync(this WebApplication app)
    {
        using var scope = app.Services.CreateScope();

        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var config = scope.ServiceProvider.GetRequiredService<IConfiguration>();

        await context.Database.MigrateAsync();

        await SeedAdminAsync(context, config);
    }

    private static async Task SeedAdminAsync(AppDbContext context, IConfiguration config)
    {
        var adminEmail = config["ADMIN_EMAIL"];
        var adminPassword = config["ADMIN_PASSWORD"];

        if (string.IsNullOrWhiteSpace(adminEmail) ||
            string.IsNullOrWhiteSpace(adminPassword))
        {
            return;
        }

        var adminExists = await context.Users.AnyAsync(u => u.Email == adminEmail);

        if (adminExists)
        {
            return;
        }

        context.Users.Add(new User
        {
            Id = 1,
            Username = "admin",
            Email = adminEmail,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(adminPassword),
            Role = Role.Admin
        });

        await context.SaveChangesAsync();
    }
}