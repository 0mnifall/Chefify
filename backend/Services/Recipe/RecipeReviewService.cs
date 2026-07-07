using backend.Data;
using backend.Dto;
using backend.Models;

namespace backend.Services;

public class RecipeReviewService(AppDbContext context)
{
    private void CalculateAvgRating(Recipe recipe)
    {
        int sum = 0;
        for (int i = 1; i <= 5; i++)
        {
            sum += recipe.Rating.ByRate[i - 1] * i;
        }

        recipe.Rating.Avg = float.Round(sum / (float)recipe.Rating.Quantity, 2);
    }

    public async Task UploadReview(Recipe recipe, CreateRecipeReview review, int reviewerId)
    {
        recipe.Rating.Quantity++;
        recipe.Rating.ByRate[review.Rate - 1]++;
        CalculateAvgRating(recipe);
        
        recipe.Reviews.Add(new RecipeReview
        {
            ReviewerId = reviewerId,
            Rate = review.Rate,
            Overview = review.Overview
        });
        
        await context.SaveChangesAsync();
    }
}