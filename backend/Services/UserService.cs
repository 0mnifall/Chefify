using backend.Data;
using backend.Dto;
using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Services;

public class UserService(AppDbContext context)
{
    public async Task<IEnumerable<UserPreviewDto>> GetAllUsers()
    {
        var users = await context.Users
            .Select(u => new UserPreviewDto
            {
                Id = u.Id,
                Username = u.Username,
                //ProfilePictureRef = u.ProfilePictureRef,
            })
            .ToListAsync();
        return users;
    }

    public async Task<User?> GetUser(int id)
    {
        return await context.Users.FirstOrDefaultAsync(u => u.Id == id);
    }

    public UserDto ToDto(User user)
    {
        var userDto = new UserDto
        {
            Username = user.Username,
            //ProfilePictureRef = user.ProfilePictureRef
        };
        
        return userDto;
    }

    public async Task<User?> GetUserEntity(int id)
    {
        return await context.Users.Include(u => u.Recipes).FirstOrDefaultAsync(u => u.Id == id);
    }

    public IEnumerable<RecipePreviewDto> GetUserRecipes(User user)
    {
        var recipes = user.Recipes.Select(r => new RecipePreviewDto
            {
                Title = r.Title,
                Description = r.Description,
                CookingTime = r.CookingTime,
                Difficulty = r.Difficulty,
                CreatorUsername = r.Creator.Username
            })
            .ToList();

        return recipes;
    }

    public async Task UpdateUser(User user, AdminUserDto dto)
    {
        user.Role = dto.Role;
        user.Username = dto.Username;
        
        context.Users.Update(user);
        await context.SaveChangesAsync();
    }
}