local enable_field_upgrades = true
local enable_technic_upgrades = true

local recipes = {
  [1] = function(item, material)
    return {
      {material},
      {item}
    }
  end,
  [2] = function(item, material)
    return {
      {material, material},
      {item, ""}
    }
  end,
  [0] = function(item, material)
    return {
      {material, material, material},
      {"",item,""}
    }
  end
}

titanite.max_levels = 10
titanite.shard_count = {}
titanite.shard_total = {}
for level=1,titanite.max_levels do
  local material = math.floor((level-1)/3)
  local quantity = 1+((level-1)%3)
  titanite.shard_count[level] = math.pow(4, material)*quantity
  titanite.shard_total[level] = titanite.shard_count[level] + (titanite.shard_total[level-1] or 0)
end

local armor_multipliers = {
  armor_head = 1,
  armor_torso = 1,
  armor_legs = 1,
  armor_feet = 1,
  armor_shield = 1,
  armor_uses = 0.1,
}

titanite.get_upgrade_name = function(item, level)
  return item.."_"..level
end

titanite.get_upgrade_description = function(desc, level)
  return desc.." +"..level
end

titanite.get_upgrade_overlay = function(level)
  return "upgrade_"..level..".png"
end

local function upgrade_recipe(item, level)
  local upgrade_name = titanite.get_upgrade_name(item, level)
  local prev = level <= 1 and item or titanite.get_upgrade_name(item, level-1)
  local quantity = (level % 3)
  local material = 
    level > 9 and titanite.block 
    or level > 6 and titanite.chunk
    or level > 3 and titanite.large_shard
    or titanite.small_shard
  -- Direct crafting recipe
  if enable_field_upgrades then
	  minetest.register_craft({
		output = upgrade_name,
		recipe = recipes[quantity](prev,material)
	  })
  end
  -- Technic Alloying Recipes
  if technic and enable_technic_upgrades then
    local shards = titanite.shard_count[level]
    technic.register_alloy_recipe({input = {prev, titanite.small_shard.." "..shards}, output = upgrade_name})
    technic.register_extractor_recipe({
        input = {upgrade_name}, 
        output = {prev,titanite.small_shard.." "..math.floor(shards/2)}
    })
  end
end

titanite.power = function(level)
  return math.sqrt(titanite.shard_total[level] / titanite.shard_total[titanite.max_levels])
end

local function ratio(value, mul)
  mul = mul or 1.0
  return 1.0 + (value*mul)
end

local function copy_table (this, that)
  that = that or {}
  for key,value in pairs(this) do
    that[key] = type(value) == "table" and copy_table(value)
      or value
  end
  return that
end

local function floor(value, pow_ten)
  local mult = math.pow(10, pow_ten or 0)
  return math.floor(value*mult)/mult
end

local function ceil(value, pow_ten)
  local mult = math.pow(10, pow_ten or 0)
  return math.ceil(value*mult)/mult
end

local native_register_tool = minetest.register_tool
function titanite.register_upgrade(item, level)
  if type(item) == "string" and item ~= ":" and item ~= "" then
    local tool = minetest.registered_tools[item]
    if tool then
      local upgrade_name = titanite.get_upgrade_name(item, level)
      local upgrade = copy_table(tool)
      local power = titanite.power(level)
      local diff = false
      upgrade.description = titanite.get_upgrade_description(tool.description, level)
      upgrade.inventory_image = tool.inventory_image.."^"..titanite.get_upgrade_overlay(level)
      upgrade.wield_image = tool.wield_image or tool.inventory_image
      local caps = tool.tool_capabilities
      if caps then
        local upgrade_caps = upgrade.tool_capabilities
        if caps.full_punch_interval and caps.full_punch_interval > 0 then
          diff = true
          upgrade_caps.full_punch_interval = caps.full_punch_interval / ratio(power, 2)
        end
        if caps.groupcaps then
          for groupname, group in pairs(caps.groupcaps) do
            local upgrade_group = upgrade_caps.groupcaps[groupname]
            if group.uses and group.uses > 0 then
              upgrade_group.uses = math.floor(group.uses * ratio(power, 0.1))
            end
            if group.maxlevel and group.maxlevel > 0 then
              diff = true
              upgrade_group.maxlevel = math.floor(group.maxlevel + level/5)
              if group.times and #group.times > 0 then
                local old_level = 1
                for new_level = 1, upgrade_group.maxlevel do
                  if new_level <= #group.times then
                    old_level = new_level
                  end
                  upgrade_group.times[new_level] = 
                    group.times[old_level] / ratio(power, 2)
                end
              end
            end
          end
          if caps.damage_groups then
            local upgrade_damage = upgrade_caps.damage_groups
            for group, damage in pairs(caps.damage_groups) do
              diff = diff or damage > 0
              upgrade_damage[group] = damage * ratio(power)
            end
          end
        end
      end
      upgrade.groups = upgrade.groups or {}
      upgrade.groups.not_in_creative_inventory = 1
      local is_armor = false
      for group, div in pairs(armor_multipliers) do
        if upgrade.groups[group] and upgrade.groups[group] > 0 then
          local value = upgrade.groups[group]
          diff = true
          is_armor = true
          upgrade.groups[group] = floor(value * ratio(power,div),2)
        end
      end
      --Fix armor textures
      if is_armor and not upgrade.texture then
        upgrade.texture = item:gsub("%:", "_")
      end
      -- Only register if we actually changed something.
      if diff then
        native_register_tool(":"..upgrade_name, upgrade)
        upgrade_recipe(item, level)
      end
    end
  end
end

function titanite.split_item_name(item)
  local level = tonumber(string.match(item, "%d+$")) or 0
  local base = string.gsub(item, "_%d*$", "")
  return base, level
end

minetest.register_tool = function(item, ...)
  local item = string.gsub(item, "^:+", "")
  local result = {native_register_tool(":"..item, ...)}
  for level = 1,10 do
    titanite.register_upgrade(item, level)
  end
  return unpack(result)
end

local upgradeable_tools = {}
for item, _ in pairs(minetest.registered_tools) do
  table.insert(upgradeable_tools, item)
end
for _, item in ipairs(upgradeable_tools) do
  for level = 1,10 do
    titanite.register_upgrade(item, level)
  end
end
