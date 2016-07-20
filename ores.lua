titanite.small_shard = "titanite:small_shard"
titanite.large_shard = "titanite:large_shard"
titanite.chunk = "titanite:chunk"
titanite.block = "titanite:block"
titanite.ore = "titanite:stone_with_titanite"

local function four_to_one(input, output)
	return {
		output = output,
		recipe = {
			{input,input},
			{input,input}
		}
	}
end

local function nine_to_one(input, output)
	return {
		output = output,
		recipe = {
			{input,input,input},
			{input,input,input},
			{input,input,input}
		}
	}
end

local function one_to_quantity(input, output, quantity)
	return {
		output = output.." "..quantity,
		recipe = {
			{input}
		}
	}
end

if minetest then
  minetest.register_craftitem(titanite.small_shard, {
    description = "Titanite Shard",
    inventory_image = "titanite_shard.png",
  })

  minetest.register_craftitem(titanite.large_shard, {
    description = "Large Titanite Shard",
    inventory_image = "titanite_large_shard.png",
  })

  minetest.register_craft(four_to_one(titanite.small_shard,titanite.large_shard))
  minetest.register_craft(one_to_quantity(titanite.large_shard,titanite.small_shard,4))

  minetest.register_craftitem(titanite.chunk, {
    description = "Titanite Chunk",
    inventory_image = "titanite_chunk.png",
  })

  minetest.register_craft(four_to_one(titanite.large_shard,titanite.chunk))
  minetest.register_craft(one_to_quantity(titanite.chunk,titanite.large_shard,4))

  minetest.register_node(titanite.block, {
    description = "Titanite Block",
    tiles = {"titanite_block_top.png","titanite_block_top.png","titanite_block.png"},
    is_ground_content = false,
    groups = {cracky = 1, level = 3},
    sounds = default.node_sound_stone_defaults(),
  })

  minetest.register_craft(four_to_one(titanite.chunk,titanite.block))
  minetest.register_craft(one_to_quantity(titanite.block,titanite.chunk,4))

  minetest.register_node(titanite.ore, {
    description = "Titanite Ore",
    tiles = {"default_stone.png^mineral_titanite.png"},
    groups = {cracky = 1},
    drop = "titanite:small_shard",
    sounds = default.node_sound_stone_defaults(),
  })

  minetest.register_ore({
    ore_type       = "scatter",
    ore            = titanite.ore,
    wherein        = "default:stone",
    clust_scarcity = 18 * 18 * 18,
    clust_num_ores = 3,
    clust_size     = 2,
    y_min          = -255,
    y_max          = -64,
  })

  minetest.register_ore({
    ore_type       = "scatter",
    ore            = titanite.ore,
    wherein        = "default:stone",
    clust_scarcity = 14 * 14 * 14,
    clust_num_ores = 5,
    clust_size     = 3,
    y_min          = -31000,
    y_max          = -256,
  })

  minetest.register_ore({
    ore_type       = "scatter",
    ore            = titanite.block,
    wherein        = "default:stone",
    clust_scarcity = 36 * 36 * 36,
    clust_num_ores = 3,
    clust_size     = 2,
    y_min          = -31000,
    y_max          = -1024,
  })
end