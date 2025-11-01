local time = settings.startup["recycler-default-time"].value or 0.2

for _, recipe in pairs(data.raw.recipe) do
  if recipe.category == "recycling" then
    if recipe.energy_required then
      recipe.energy_required = time
    end
    for _, diff in pairs({"normal", "expensive"}) do
      if recipe[diff] and recipe[diff].energy_required then
        recipe[diff].energy_required = time
      end
    end
  end
end
