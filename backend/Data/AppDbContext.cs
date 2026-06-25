using Microsoft.EntityFrameworkCore;
using backend.Models;

namespace backend.Data;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Recipe> Recipes { get; set; }
    
    public DbSet<Category> Categories { get; set; }
    
    public DbSet<Tag> Tags { get; set; }

    public DbSet<Ingredient> Ingredients { get; set; }

    public DbSet<RecipeIngredient> RecipeIngredients { get; set; }
    
    public DbSet<User> Users { get; set; }
    
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<RecipeIngredient>()
            .HasKey(ri => new { ri.RecipeId, ri.IngredientId });

        modelBuilder.Entity<Tag>()
            .HasIndex(t => t.Name)
            .IsUnique();
        
        modelBuilder.Entity<Category>()
            .HasIndex(c => c.Name)
            .IsUnique();
        
        modelBuilder.Entity<Recipe>()
            .OwnsMany(r => r.Blocks);
        
        base.OnModelCreating(modelBuilder);
    }
}