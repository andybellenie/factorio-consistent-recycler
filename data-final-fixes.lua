-- Make all recycling recipes match Fulgora scrap speed
for name, recipe in pairs(data.raw.recipe) do
  if recipe.category == "recycling" then
    if recipe.energy_required then
      recipe.energy_required = 0.2  -- same as scrap
    end
    for _, variant in pairs({"normal", "expensive"}) do
      if recipe[variant] and recipe[variant].energy_required then
        recipe[variant].energy_required = 0.2
      end
    end
  end
end
