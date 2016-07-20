minetest = minetest or {
	get_modpath = function(modname) 
		assert(type(modname) == "string")
		print("minetest.get_modpath called:("..modname..")")
		if (fail_test[modname]) then
			print("assuming "..modname.." isn't loaded due to test parameters.")
			return false
		end
	return modname end,
  register_tool = function(name, stats)
    print("Tool Register:"..name)
    if stats then
      local tool_stats = stats.tool_capabilities
      if tool_stats then
        print ("Punch Interval:"..tool_stats.full_punch_interval)
        local groupcaps = tool_stats.groupcaps
        if groupcaps then
          for group_name, group in pairs(groupcaps) do
            print("Group Cap:"..group_name)
          end
        else
          print("WARNING: No groupcaps received.")
        end
      end
    end
  end,
  register_craftitem = function(name, stats)
    print("Craft Item Register:"..name)
  end,
  register_craft = function()
    print("Craft Register")
  end,
  register_ore = function()
    print("Ore Register")
  end,
  register_node = function()
    print("Node Register")
  end,
  registered_tools = {["default:pick_steel"] = {
    description = "Steel Pickaxe",
    inventory_image = "default_tool_steelpick.png",
    tool_capabilities = {
      full_punch_interval = 1.0,
      max_drop_level=1,
      groupcaps={
        cracky = {times={[1]=4.00, [2]=1.60, [3]=0.80}, uses=20, maxlevel=2},
      },
      damage_groups = {fleshy=4},
    },
  }}
}

default = default or {
  node_sound_stone_defaults = function()end
}