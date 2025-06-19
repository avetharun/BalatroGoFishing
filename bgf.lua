--- STEAMODDED HEADER
--- MOD_NAME: Balatro Go Fishing!
--- MOD_ID: gofishing
--- MOD_AUTHOR: [feintha]
--- MOD_DESCRIPTION: Fishing, harvesting, oh my!
--- PREFIX: bgf

----------------------------------------------
------------MOD CODE -------------------------

FishingMod = FishingMod or {}
--Creates an atlas for cards to use
FishingMod.MainAtlas = SMODS.Atlas {
	-- Key for code to find it with
	key = "main",
	-- The name of the file, for the code to pull the atlas from
	path = "bgf.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}
FishingMod.FishieAtlas = SMODS.Atlas {
	-- Key for code to find it with
	key = "fishies",
	-- The name of the file, for the code to pull the atlas from
	path = "fishies.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}
FishingMod.FishingRodAtlas = SMODS.Atlas {
	-- Key for code to find it with
	key = "rods",
	-- The name of the file, for the code to pull the atlas from
	path = "rods.png",
	-- Width of each sprite in 1x size
	px = 71,
	-- Height of each sprite in 1x size
	py = 95
}
FishingMod.FishingBaitAtlas = SMODS.Atlas {
	-- Key for code to find it with
	key = "bait",
	-- The name of the file, for the code to pull the atlas from
	path = "bait.png",
	-- Width of each sprite in 1x size
	px = 34,
	-- Height of each sprite in 1x size
	py = 34
}
FishingMod.Main32 = SMODS.Atlas {
	-- Key for code to find it with
	key = "main32",
	-- The name of the file, for the code to pull the atlas from
	path = "bgf.png",
	-- Width of each sprite in 1x size
	px = 32,
	-- Height of each sprite in 1x size
	py = 32
}
FishingMod.Main16 = SMODS.Atlas {
	-- Key for code to find it with
	key = "main16",
	-- The name of the file, for the code to pull the atlas from
	path = "bgf.png",
	-- Width of each sprite in 1x size
	px = 16,
	-- Height of each sprite in 1x size
	py = 16
}
local minigame_atlas_def = function(w, h)
	return SMODS.Atlas {
		-- Key for code to find it with
		key = "minigame"..w.."x"..(h or w),
		-- The name of the file, for the code to pull the atlas from
		path = "minigame_sprites.png",
		-- Width of each sprite in 1x size
		px = w,
		-- Height of each sprite in 1x size
		py = h or w
	}
end
FishingMod.Minigame8 = minigame_atlas_def(8)
FishingMod.Minigame16 = minigame_atlas_def(16)
FishingMod.Minigame32 = minigame_atlas_def(32)
FishingMod.Minigame64 = minigame_atlas_def(64)
FishingMod.Minigame6x9 = minigame_atlas_def(6,9)
FishingMod.Minigame12x8 = minigame_atlas_def(12,8)
FishingMod.Minigame16x8 = minigame_atlas_def(16,8)

assert(SMODS.load_file("ui.lua", "gofishing"))()
SMODS.current_mod.optional_features = function ()
    return {
        cardareas = {deck = true, discard = false, hand = true}
    }
end
FishingMod.FishingRods = FishingMod.FishingRods or {}
FishingMod.Fishies = nil

local FishieType = SMODS.ObjectType {
	key="Fishies",
}
SMODS.ObjectType {
	key="FishingRods",
}
SMODS.ObjectType {
	key="FishingBait",
}

SMODS.Sound:register_global()

--- @class FishingMod.FishRarity
--- @field Common integer
--- @field Uncommon integer
--- @field Rare integer
--- @field Legendary integer
--- @field Exotic integer
FishingMod.FishRarity = FaeLib.Enum[[
	Common=1
	Uncommon
	Rare
	Legendary
	Exotic
]]

FaeLib.Builtin.Events.BlindCompleted:register(function (blind)
	for _, value in ipairs(G.jokers.cards) do
		if value and value.ability.name == "j_bgf_harpy" then
			if (FaeLib.Tags.BossBlinds:contains(FaeLib.Builtin.GetCurrentBlindKey())) then
				FishingMod.fishing_minigame.chances = FishingMod.fishing_minigame.chances + 1
			end
			value.ability.extra.rounds_until_decrement = value.ability.extra.rounds_until_decrement or 0
			local decremented = value.ability.extra.rounds_until_decrement ~= 0
			value.ability.extra.rounds_until_decrement = math.max(0, value.ability.extra.rounds_until_decrement - 1)
			if decremented then
				Moveable.juice_up(value, 0.1, 0.3)
				if value.ability.extra.rounds_until_decrement == 0 then
					FaeLib.Builtin.TextPopupAtCard(value, localize("b_bgf_stat_reset"), G.C.RED)
					play_sound('tarot1')
					value.ability.extra.current_mult = 0.95
				else
					play_sound('tarot1')
					FaeLib.Builtin.TextPopupAtCard(value, tostring(value.ability.extra.rounds_until_decrement), G.C.RED)
				end
			end
		end
	end
	if FishingMod.fishing_minigame.chances > 0 then
		FishingMod.fishing_minigame:start()
	end
end)


FishingMod.FeedButton = new 'FaeLib.CardButton'("feed_harpy_card", FaeLib.Enums.Direction.LEFT, function (self, card)
		if not G.jokers then
			return false
		end
		for _, value in ipairs(G.jokers.cards) do
			if value and value.ability.name == "j_bgf_harpy" and not value.ability.extra.eating then
				value.ability.extra.eating = true
				new 'FaeLib.CardMovement'(
				value,
				card.T.x,
				card.T.y,
				0.25,
				1.3,
				function(a)
				end,nil,
				function (a)
				end,
				true, true, nil, nil, function ()
					local sound_function_and_juice = function ()
						play_sound('bgf_eat'..math.floor(math.random(1, 3)), 1, 0.55)
						card:juice_up()
						value:juice_up()
					end
					local task = new 'FaeLib.Task'(sound_function_and_juice):dont_run_while_delaying()
					
					for i = 1, 6 do
						task = task:dont_run_while_delaying():with_delay(0.175):dont_run_while_delaying():and_then(sound_function_and_juice):dont_run_while_delaying()
					end
					task = task:and_then(function ()
						play_sound('tarot1')
						play_sound('bgf_burp')
						value.ability.extra.rounds_until_decrement = (card.ability.extra and type(card.ability.extra) == "table" and card.ability.extra.harpy_rounds) or 5
						G.E_MANAGER:add_event(Event({
							trigger = 'after',
							delay = 1,
							func = function()
								FaeLib.Builtin.TextPopupAtCard(value, "5", G.C.BLUE)
								return true
							end
						}))
						if card.from_foraging or card.area == G.jokers or card.area == G.consumeables then
							card:start_dissolve(nil, 1)
						end
						if card.ability.name == "m_bgf_fruit" then
							card.ability.extra.debuffed_for = 5
							value.ability.extra.current_mult = math.max(0.95, value.ability.extra.current_mult + card.ability.extra._mult_for_harpy)
						else
							if card.area == G.jokers then
								value.ability.extra.current_mult = value.ability.extra.current_mult + math.max(4, 4 * card.sell_cost)
							end
						end
						value.ability.extra.eating = false
					end)
				end,
				FaeLib.easeInCirc
			)
			break
			end
		end
end,
G.C.GOLD,
function (self, card)
	local has_harpy = false
	if not G.jokers then
		return false
	end
	for _, value in ipairs(G.jokers.cards) do
		if value and value.ability.name == "j_bgf_harpy" and not value.ability.extra.eating then
			has_harpy = true
			break
		end
	end
	return ((card.children and card.ability and card.ability.name == "m_bgf_fruit" and card.ability.extra.debuffed_for == 0) or (FaeLib.Tags.FoodCards:contains(card.config.center_key) and card.ability.name ~= "m_bgf_fruit")) and card.highlighted and has_harpy and not card.bgf_in_inventory
end)


FishingMod.FRUIT_ENHANCEMENT = SMODS.Enhancement {
	key = 'fruit',
	pos = { x = 2, y = 1 },
	atlas = 'main',
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
	area = G.deck,
	config = { extra = {
		eaten = false, eaten_by = nil,
		_addtl_mult = 12, _addtl_chips = 48,
		_mult_for_harpy = 4,
		debuffed_for = 0
	} },
	loc_vars = function(self, info_queue, card)
		local debuffed_text = localize("e_fruit_card_edible")
		if (card.ability.extra.debuffed_for ~= 0) then debuffed_text = string.format(localize("e_fruit_card_inedible"), card.ability.extra.debuffed_for) end
		return {
			vars = {  card.ability.extra._addtl_mult, card.ability.extra._addtl_chips, debuffed_text, card.ability.extra._mult_for_harpy },
		}
	end,
	calculate = function(self, card, context)
		if (context.after and card.ability.extra.debuffed_for > 0) then
			card.ability.extra.debuffed_for = card.ability.extra.debuffed_for - 1
			card:juice_up()
			return {
				debuffed_for = card.ability.extra.debuffed_for,
			}
		end
		if context.main_scoring and context.cardarea == G.play and card.ability.extra.debuffed_for == 0 then
			return {
				mult = card.ability.extra._addtl_mult,
				chips = card.ability.extra._addtl_chips,
			}
		end
	end, 
	draw = function(self, card, layer)
		if (card.ability.extra.debuffed_for ~= 0) then
			card.children.center:draw_shader('debuff', nil, card.ARGS.send_to_shader)
		end
	end
}

SMODS.Booster {
	key = "fishing",
	atlas="main",
	pos = {x=2,y=0},
	group_key="fishing",
	kind="fishing",
	weight = 0.3,
	cost=6,
	config = { extra = 4, choose = 1 },
	create_card = function (self, card, i)
        ease_background_colour(HEX("081d69"))
		local c = nil
		if math.random(1,10) > 8 then
			c = SMODS.create_card({
				set = "FishingRod",
				area = G.pack_cards,
				skip_materialize = true,
				soulable = true,
			})
		else
			c = SMODS.create_card({
				set = "Baits",
				area = G.pack_cards,
				skip_materialize = true,
				soulable = true,
			})
		end
		c.config.can_sell = true
		return c
	end,
	set_card_type_badge= function(self, card, badges)
	end
}
SMODS.Consumable {
    key = 'fruit_tree',
	set="Tarot",
    pos = { x = 1, y = 0 },
    config = { max_highlighted = 2, mod_conv = 'm_bgf_fruit' },
	atlas = 'main',
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = FishingMod.FRUIT_ENHANCEMENT
        return { vars = { card.ability.max_highlighted} }
    end,
    use = function(self, card, area, copier)
		
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.25,
            func = function()
				G.playing_card = (G.playing_card and G.playing_card + 1) or 1
				local cards_changed = 0
				local cards_to_change = {}
				for _, value in ipairs(G.hand.cards) do
					if value.highlighted then
						cards_changed=cards_changed+1
						cards_to_change[#cards_to_change+1] = value
					end
				end
				if #cards_to_change > card.ability.max_highlighted then
					return false
				end
				-- for _, value in ipairs(cards_to_change) do
				-- 	value:set_ability("m_bgf_fruit")
				-- end
				FaeLib.Builtin.SetCardsBulk(cards_to_change, nil, nil, "m_bgf_fruit", nil, nil)
                return true
            end
        }))
    end,
    can_use = function(self, card)
        return G.hand and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.max_highlighted
    end
}
function FishingMod.weightedRandom(min, max)
    local bias = 1.25 -- Adjust this value to control weighting (higher = more bias toward min)
    local rand = math.random() ^ bias -- Apply bias
    return min + (max - min) * rand
end
FishingMod.harpy_joker = SMODS.Joker {
	key = "harpy",
	atlas = 'main',
	pos = { x = 4, y = 0 },
	rarity = 1,
	blueprint_compat = false,
	config = {
		extra = {
			mult_per_eaten_card = 2,
			current_mult = 0,
		}
	},
 	set_badges = function(self, card, badges)
 		badges[#badges+1] = FaeLib.Builtin.Badges.Forager()
 	end,
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = FaeLib.Builtin.Tooltips.Forager
		info_queue[#info_queue+1] = {set = "Other", key = "bgf_harpy_forager", vars = {}, colour = G.C.BLUE}
		return {vars = {card.ability.extra.current_mult, card.ability.extra.rounds_until_decrement or 5} }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				mult = math.max(0, card.ability.extra.current_mult),
				card = card
			}
		end
		return {}
	end,
}

new 'FaeLib.Card.ForagerJoker'(FishingMod.harpy_joker, FishingMod.FRUIT_ENHANCEMENT)

FishingMod.HarpyChallenge = SMODS.Challenge{
	key = "m_bgf_harpy_challenge",
	
	rules = {
		custom = {
			{id = 'm_bgf_harpy_challenge1'},
			{id = 'm_bgf_harpy_challenge2'},
			{id = 'm_bgf_harpy_challenge3'},
		},
		modifiers = {
		}
	},
	jokers = {
		{
			id="j_bgf_harpy",
			eternal = true,
			pinned = true
		}
	},
	restrictions = {
		banned_tags = {
			{id = "tag_standard"}
		},
		banned_other = {
			{type="blind",id = "bl_psychic",},
		},
		banned_cards = {
			{id ="c_magician"},
			{id ="c_empress"},
			{id ="c_emperor"},
			{id ="c_heirophant"},
			{id ="c_lovers"},
			{id ="c_chariot"},
			{id ="c_justice"},
			{id ="c_strength"},
			{id ="c_devil"},
			{id ="c_tower"},
			{id ="c_star"},
			{id ="c_moon"},
			{id ="c_sun"},
			{id ="c_world"},
			{id ="c_hime_yuri"},
			{id ="c_bgf_fruit_tree"},
			{id ="c_familiar"},
			{id ="c_sigil"},
			{id ="c_ouija"},
			{id ="c_incantation"},
			{id ="c_grim"},
			{id ="p_standard_normal",},
			{id ="p_standard_normal_1",},
			{id ="p_standard_normal_2",},
			{id ="p_standard_normal_3",},
			{id ="p_standard_normal_4",},
			{id ="p_standard_jumbo",},
			{id ="p_standard_jumbo_1",},
			{id ="p_standard_jumbo_2",},
			{id ="p_standard_jumbo_3",},
			{id ="p_standard_jumbo_4",},
		}
	},
	deck = {
		type = "Challenge Deck",
		cards = {
			{ s = "C", r = "2", e = "m_bgf_fruit"},
			{ s = "C", r = "2", e = "m_bgf_fruit"},
			{ s = "C", r = "2", e = "m_bgf_fruit"},
			{ s = "C", r = "2", e = "m_bgf_fruit"},
			{ s = "C", r = "2", e = "m_bgf_fruit"},
		},
		edition = "holo"
	}
}
-- local minigame_sprites_file = love.image.newImageData( NFS.newFileData( SMODS.current_mod.path .. "assets/minigame_sprites.png" ) )
FishingMod.Files = {
	-- minigame_sprites_file = minigame_sprites_file,
}
-- FishingMod.Files.minigame_sprites_file:mapPixel(function(x,y,r,g,b,a) return r*2, g*2, b*2, a end)
-- FishingMod.Files.minigame_sprites = love.graphics.newImage(FishingMod.Files.minigame_sprites_file)
function easeOutQuint(x)
	return 1 - math.pow(1 - x, 5);
end
FishingMod.fishing_minigame = {
	reset = function (self)
		local fishing_area = FishingMod.fishing_minigame.fishing_area
		fishing_area.offset = {x=0, y=0, rot = 0}
		fishing_area.visible = true
		fishing_area.bobber.can_fish = true
		fishing_area.bobber.has_fish = false
		fishing_area.bobber.can_cast = true
		fishing_area.bobber.visible = false
		FishingMod.fishing_minigame.results_screen.fish = nil
	end,
	chances = -1,
	results_screen = {
		visible = true,
		uibox = {main_area = {}},
		fish = nil
	},
	visible = false,
	--- @class HimeFishingRod
	fishing_rod = {
		bait_rarity = FishingMod.FishRarity.Common,
		size = 1.5,
		reel_speed = 1,
		reel_weight = 1,
		strength = 1,
		max_weight_kg = 12, -- kg
		spawn = function ()end
	},
	catching_area = {
		info = {
			mouse_quad = love.graphics.newQuad(64, 28, 9, 9, 512, 512),
			arrow_quad = love.graphics.newQuad(73, 35, 9, 9, 512, 512),
			spacebar_quad = love.graphics.newQuad(82, 35, 9, 9, 512, 512),
		},
		fish = {
			quad = love.graphics.newQuad( 65, 10, 15, 8, 512, 512 ),
			hook_quad = love.graphics.newQuad( 65, 37, 15, 8, 512, 512 ),
			brain = {
				speed = 1,
				goal = 0, -- 0 : top, 1 : bottom
				horizontal = 0, -- 0 : left, 1 : right
				direction = "left",
			},
			current = 0,
			current_horizontal = 0,
			weight = 1,
			size = 1,
			key = "f_unknown",
			rect = {},
			time_since_move = 0
		},
		visible = false,
		tick = true,
		timeout = 8,
		fishing_state = {
			height = 0.5,
			hovering = false,
		},
		offset = {
			x = 0, y = 0, rot = 0
		}
	},
	fishing_area = {
		offset = {
			x = 0, y = 0, rot = 0
		},
		visible = true,
		scale = 4.88,
		area = {
			w = (128+28)*2,
			h = (128+28)*2
		},
		background_image_quad = love.graphics.newQuad( 0, 0, 64, 64, 512, 512 ),
		
		bobber = {
			randomize_position = function(self)
				local fishing_area = FishingMod.fishing_minigame.fishing_area
				self.x = (fishing_area.area.w - 32) * (math.random(2, 8) / 10)
				self.y = (fishing_area.area.h - 32) * (math.random(2, 8) / 10)
			end,
			cast = function(self)
				self.visible = true
				local fishing_area = FishingMod.fishing_minigame.fishing_area
				local endx = (fishing_area.area.w - 32) * (math.random(2, 8) / 10)
				local from = (fishing_area.area.h - 32) * (math.random(2, 3) / 10)
				self.x = endx
				self.splash_x = self.x
				self.splash_y = from
				self.splash_visible = false
				new 'FaeLib.Tweener'(
					"y",
					self,
					0.2,
					nil,
					from + 300,
					from + 40,
					true
				)
					:and_then(from + 40, from - 32, 0.1)
					:and_then(from - 32, from, 0.1)
					:after(function()
						play_sound("bgf_splash_0"..math.random(1,3), math.random(6,8)/10, 0.3) 
						self.splash_visible = true
						self.land_time = love.timer.getTime()
					end)

			end,
			x = 0, y = 0,
			quad = love.graphics.newQuad( 64, 0, 6, 9, 512, 512 ),
			quad_lower = love.graphics.newQuad( 64, 18, 6, 9, 512, 512 ),
			splash_quad = love.graphics.newQuad( 70, 0, 12, 9, 512, 512 ),
			medium_splash_quad = love.graphics.newQuad( 82, 0, 12, 9, 512, 512 ),
			large_splash_quad = love.graphics.newQuad( 94, 0, 12, 9, 512, 512 ),
			splash_x = 0,
			splash_y = 0,
			splash_visible = false,
			has_fish = false,
			can_fish = true,
			can_cast = true,
			fish_bite_time = -1,
			visible = false
		}
	}
}
G = G or {}
function FishingMod.classifyWeight(weight, medianWeight)
    local ratio = weight / medianWeight

    if ratio < 0.3 then
        return "bgf_w_tiny"
    elseif ratio < 0.7 then
        return "bgf_w_b_average"
    elseif ratio < 1.5 then
        return "bgf_w_average"
    elseif ratio < 2.0 then
        return "bgf_w_big"
    elseif ratio < 2.0 then
        return "bgf_w_large"
	elseif ratio < 3 then
        return "bgf_w_massive"
	else 
		return "bgf_w_colossal"
    end
end
-- Define weight mapping based on the Enum rarity
local rarity_weights = { 50, 30, 20, 2 }
local bait_weights = { 1, 2, 3, 4 } -- Linear scaling for bait rarity


local function rectsIntersect(rect1, rect2)
    return rect1.x < rect2.x + rect2.w and
           rect1.x + rect1.w > rect2.x and
           rect1.y < rect2.y + rect2.h and
           rect1.y + rect1.h > rect2.y
end
FishingMod.create_UIBox_result_screen = function (reason)
	if FishingMod.fishing_minigame.results_screen.fish then
		local area = CardArea(
			G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
			G.CARD_W,
			G.CARD_H, 
			{card_limit = 1, type = 'title', highlight_limit = 1, collection = true, align = "cm"}
		)
		local fishingRod =  FishingMod.FishingRod
		local fishingRodCenter = G.P_CENTERS[fishingRod.key]
		local fishingBaitCenter = G.P_CENTERS[FishingMod.SelectedBait.key]
		local rarityMax = fishingBaitCenter.rarity or 2
		local card = SMODS.create_card({
			set = "Fishies",
			area = area,
			skip_materialize = true,
			soulable = true,
			rarity = rarityMax
		})
		local p_card = card.config.center
		local medianWeight = card.ability.extra.median_weight
		area:emplace(card)
		if card.edition and card.edition.type == "foil" then
			card:set_edition("holo")
		end
		if card.edition and card.edition.type == "negative" then
			card:set_edition("polychrome")
		end
		while medianWeight >= fishingRod.ability.extra.weight do
			medianWeight = medianWeight * 0.3
		end
		card.ability.extra.weight = (medianWeight * math.random(0,10)/10) * (fishingRod.ability.extra.weight_multiplier and ((math.random(10,20) * fishingRod.ability.extra.weight_multiplier ) /10) or 1)

		FishingMod.fishing_minigame.results_screen.fish = card
		return (create_UIBox_generic_options({
			back_func = "bgf_result_screen_exit",
			contents = {
				{n=G.UIT.C, config={align = "tm", colour = HEX("1e2b2d"),minw = 7.5, minh = 6, maxw = 8, maxh = 8, r = 0.1,padding=0.2}, nodes={
					{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({align = "tm", string=localize("bgf_fish_get"),scale=1.25,float=true,shadow=true}), juice = true}}}},
					{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({align = "tm", string="~"..p_card:get_name().."~",scale=1,float=true,shadow=true, colours = {G.C.SECONDARY_SET.Spectral}})}}}},
					{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({align = "tm", string=p_card:get_pun_text(),scale=.65,float=true,shadow=true, colours = {G.C.EDITION}})}}}},
					
					{n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({string=localize("bgf_fish_weight")..(card.ability.extra.weight or "???") .. "kg",scale=.5,float=true,shadow=true, colours = {G.C.WHITE}})}}}},
					{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({string=localize("bgf_fish_size")..
					localize(FishingMod.classifyWeight(card.ability.extra.weight or 0, medianWeight)),scale=.5,float=true,shadow=true, colours = {G.C.WHITE}})}}}},
					{n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.O, config = {align = "cm", object=area, juice = true}}}}
				}},
			}
		}))
	else
		if not reason or reason == "aborted" then
			return (create_UIBox_generic_options({
				back_func = "bgf_result_screen_exit",
				contents = {
					{n=G.UIT.C, config={align = "tm", colour = HEX("1e2b2d"),minw = 12, minh = 8, maxw = 12, maxh = 8, r = 0.1}, nodes={
						{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({align = "tm", string=localize("bgf_fish_aborted"),scale=1.25,float=true,shadow=true}), juice = true, scale = 0.5,padding=0.5}}}},
						{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.B, config={w = 1, h = 1}}}},
						{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({align = "tm", string=localize("bgf_no_fish"),scale=1,float=true,shadow=true, colours = {G.C.RED}})}}}},
					}},
				}
			}))
		end
		if reason == "no_rod" then
			return (create_UIBox_generic_options({
				back_func = "bgf_result_screen_exit",
				contents = {
					{n=G.UIT.C, config={align = "tm", colour = HEX("1e2b2d"),minw = 12, minh = 8, maxw = 12, maxh = 8, r = 0.1}, nodes={
						{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({align = "tm", string=localize("bgf_fish_could_not_start"),scale=1.25,float=true,shadow=true}), juice = true, scale = 0.5,padding=0.5}}}},
						{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.B, config={w = 1, h = 1}}}},
						{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({align = "tm", string=localize("bgf_no_rod"),scale=1,float=true,shadow=true, colours = {G.C.RED}})}}}},
					}},
				}
			}))
		end
		if reason == "no_bait" then
			return (create_UIBox_generic_options({
				back_func = "bgf_result_screen_exit",
				contents = {
					{n=G.UIT.C, config={align = "tm", colour = HEX("1e2b2d"),minw = 12, minh = 8, maxw = 12, maxh = 8, r = 0.1}, nodes={
						{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({align = "tm", string=localize("bgf_fish_could_not_start"),scale=1.25,float=true,shadow=true}), juice = true, scale = 0.5,padding=0.5}}}},
						{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.B, config={w = 1, h = 1}}}},
						{n=G.UIT.R, config={align = "tm"}, nodes={{n=G.UIT.O, config = {align = "tm", object=DynaText({align = "tm", string=localize("bgf_no_bait"),scale=1,float=true,shadow=true, colours = {G.C.RED}})}}}},
					}},
				}
			}))
		end
	end
	FishingMod.fishing_minigame.practice = false
end
FishingMod.fishing_minigame.start = function (self)
	if FishingMod.FishingRod and FishingMod.SelectedBait then
		FishingMod.fishing_minigame.uibox = FishingMod.create_UIBox_fishing_minigame_screen_casting_area()
		G.FUNCS.overlay_menu({
			definition = FishingMod.fishing_minigame.uibox
		})
		-- FishingMod.fishing_minigame.visible = true
		-- FishingMod.fishing_minigame.results_screen.visible = false
		-- FishingMod.fishing_minigame.catching_area.visible = false

		new 'FaeLib.Tweener'(
			{"x", "y"},
			FishingMod.fishing_minigame.fishing_area.offset,
			0.3,
			FaeLib.easeInCirc,
			{x=0, y=1024},
			{x=0, y=0},
			true
		):after(function ()
			FishingMod.fishing_minigame.fishing_area.bobber.can_fish = true
			FishingMod.fishing_minigame.fishing_area.bobber.can_cast = true
			FishingMod.fishing_minigame.fishing_area.offset = {x=0, y=0, rot = 0}
		end)
	else
		if not FishingMod.SelectedBait then FishingMod.fishing_minigame.results_screen.uibox = FishingMod.create_UIBox_result_screen("no_bait") end
		if not FishingMod.FishingRod then FishingMod.fishing_minigame.results_screen.uibox = FishingMod.create_UIBox_result_screen("no_rod") end
		G.FUNCS.overlay_menu({
			definition = FishingMod.fishing_minigame.results_screen.uibox
		})
	end
end

-- FishingMod.Files.minigame_sprites:setFilter('nearest', 'nearest')
G.P_CENTER_POOLS.Fishies= {}
G.P_CENTER_POOLS.Baits= {}
G.P_CENTER_POOLS.FishingRod= {}
FishingMod.BGF_Fishes = {}
FishingMod.BGF_FishingRods = {}
FishingMod.BGF_FishingBaits = {}

local get_rarity_badge = function(self, rarity)
	local vanilla_rarity_keys = {localize('k_common'), localize('k_uncommon'), localize('k_rare'), localize('k_legendary')}
	if (vanilla_rarity_keys)[rarity] then
		return vanilla_rarity_keys[rarity] --compat layer in case function gets the int of the rarity
	else
		return localize("k_"..rarity:lower())
	end
end

G.FUNCS.your_collection_fishies = function(e)
	
  G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
      definition = create_UIBox_your_collection_fishies(),
    }
	G:save_progress()
end
G.FUNCS.your_collection_fishie_inventory = function(e)
	
  G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
      definition = create_UIBox_your_collection_fishie_inventory(),
    }
end
G.FUNCS.your_collection_rod_inventory = function(e)
	
  G.SETTINGS.paused = true
    G.FUNCS.overlay_menu{
      definition = create_UIBox_your_collection_rod_inventory(),
    }
end
G.FUNCS.bgf_fishie_button = function(e)
    
end

G.FUNCS.bgf_fish_start = function(e)
	FishingMod.fishing_minigame:start()
end

card_collection_UIBox_with_fish_start = function(_pool, rows, args)
    args = args or {}
    args.w_mod = args.w_mod or 1
    args.h_mod = args.h_mod or 1
    args.card_scale = args.card_scale or 1
    local deck_tables = {}
    local pool = SMODS.collection_pool(_pool)

    G.your_collection = {}
    local cards_per_page = 0
    local row_totals = {}
    for j = 1, #rows do
        if cards_per_page >= #pool and args.collapse_single_page then
            rows[j] = nil
        else
            row_totals[j] = cards_per_page
            cards_per_page = cards_per_page + rows[j]
            G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                (args.w_mod*rows[j]+0.25)*G.CARD_W,
                args.h_mod*G.CARD_H, 
                {card_limit = rows[j], type = args.area_type or 'title', highlight_limit = 0, collection = true}
            )
            table.insert(deck_tables, 
            {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
                {n=G.UIT.O, config={object = G.your_collection[j]}}
            }})
        end
    end

    local options = {}
    for i = 1, math.ceil(#pool/cards_per_page) do
        table.insert(options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#pool/cards_per_page)))
    end

    G.FUNCS.SMODS_card_collection_page = function(e)
        if not e or not e.cycle_config then return end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards, 1, -1 do
            local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
            c:remove()
            c = nil
            end
        end
        for j = 1, #rows do
            for i = 1, rows[j] do
            local center = pool[i+row_totals[j] + (cards_per_page*(e.cycle_config.current_option - 1))]
            if not center then break end
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*args.card_scale, G.CARD_H*args.card_scale, G.P_CARDS.empty, (args.center and G.P_CENTERS[args.center]) or center)
            if args.modify_card then args.modify_card(card, center, i, j) end
            if not args.no_materialize then card:start_materialize(nil, i>1 or j>1) end
            G.your_collection[j]:emplace(card)
            end
        end
        INIT_COLLECTION_CARD_ALERTS()
    end

    G.FUNCS.SMODS_card_collection_page{ cycle_config = { current_option = 1 }}
    local t =  create_UIBox_generic_options({ back_func = (args and args.back_func) or G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or 'your_collection', snap_back = args.snap_back, infotip = args.infotip, contents = {
          {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables}, 
          
          (not args.hide_single_page or cards_per_page < #pool) and {n=G.UIT.R, config={align = "cm"}, nodes={
            create_option_cycle({options = options, w = 4.5, cycle_shoulders = true, opt_callback = 'SMODS_card_collection_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
          }} or nil,
		  {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05,padding=0.1}, nodes={
			{n=G.UIT.C, config={align = "cm"}, nodes={
				UIBox_button({ label = {"Fish Inventory"}, button = "your_collection_fishie_inventory", colour = G.C.GREEN, minw = 2, minh = 1}),
			}},
			{n=G.UIT.C, config={align = "cm"}, nodes={
				UIBox_button({ label = {"Rod Inventory"}, button = "your_collection_rod_inventory", colour = G.C.GREEN, minw = 2, minh = 1}),
			}},
			{n=G.UIT.C, config={align = "cm"}, nodes={
				UIBox_button({ label = {"Practice!"}, button = "bgf_fish_start", colour = G.C.GREEN, minw = 2, minh = 1}),
			}}
		  }}, 
      }})
    return t
end

G.FUNCS.bgf_fish_sell = function (e)
	if FishingMod.dropoff and FishingMod.dropoff.cards[1] then
		if (FishingMod.dropoff.cards[1] and not FishingMod.dropoff.cards[1].is_being_removed) then
			local value, _ = FishingMod.dropoff.cards[1].config.center:calculate_sell_value(FishingMod.dropoff.cards[1])
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function()
				play_sound('coin2')
				ease_dollars(value)
				FishingMod.dropoff.cards[1]:juice_up(0.3, 0.4)
				inc_career_stat('c_cards_sold', 1)
				return true
			end}))
			G.FUNCS.bgf_fish_delete(e)
		end
	end
end
G.FUNCS.bgf_fish_delete = function (e)
	if FishingMod.dropoff and FishingMod.dropoff.cards[1] then
		local card = FishingMod.dropoff.cards[1]
		card.is_being_removed = true
		table.remove(FishingMod.Fishies, card.bgf_index)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function()
			card:start_dissolve()
			return true
		end}))
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = .3,
			func = function()
				FishingMod.dropoff:remove_card(card)
				return true
			end
		}))
		
		G:save_progress()
		for key, value in ipairs(G.your_collection[1].cards) do
			if value.bgf_index >= card.bgf_index then
				value.bgf_index = value.bgf_index - 1
			end
		end
		
	end
end
create_UIBox_your_collection_fishies = function(from_ingame)
    return card_collection_UIBox_with_fish_start(FaeLib.JoinTable(FaeLib.JoinTable(FishingMod.BGF_Fishes, FishingMod.BGF_FishingRods), FishingMod.BGF_FishingBaits), {5,5}, {
        snap_back = true,
        hide_single_page = true,
        collapse_single_page = true,
        h_mod = 1.03,
        back_func =  (not from_ingame) and 'your_collection_other_gameobjects' or nil,
        modify_card = function(card, center)
        end,
    })
end 

G.FUNCS.bgf_fish_button = function(e)
	G:save_progress()
end
create_UIBox_your_collection_rod_inventory = function(from_ingame)
    return FishingMod.card_collection_UIBox_rod_inventory(FishingMod.Fishies, {5}, {
        snap_back = true,
        hide_single_page = true,
        collapse_single_page = true,
        h_mod = 1.03,
        back_func = from_ingame and 'bgf_fish_button' or 'your_collection_fishies',
        modify_card = function(card, center)end,
    })
end
create_UIBox_your_collection_fishie_inventory = function(from_ingame)
    return FishingMod.card_collection_UIBox_fish_inventory(FishingMod.Fishies, {5}, {
        snap_back = true,
        hide_single_page = true,
        collapse_single_page = true,
        h_mod = 1.03,
        back_func = from_ingame and 'bgf_fish_button' or 'your_collection_fishies',
        modify_card = function(card, center)end,
    })
end 
function create_UIBox_Other_GameObjects()
    local custom_gameobject_tabs = {{}}
    local curr_height = 0
    local curr_col = 1
    local other_collections_tabs = {}
    local smods_uibox_buttons = {
        {
            count = G.ACTIVE_MOD_UI and modsCollectionTally(SMODS.Stickers), --Returns nil outside of G.ACTIVE_MOD_UI but we don't use it anyways
            button = UIBox_button({button = 'your_collection_stickers', label = {localize('b_stickers')}, count = G.ACTIVE_MOD_UI and modsCollectionTally(SMODS.Stickers), minw = 5, id = 'your_collection_stickers'})
        },
        {
            count = G.ACTIVE_MOD_UI and modsCollectionTally(FishingMod.BGF_Fishes), --Returns nil outside of G.ACTIVE_MOD_UI but we don't use it anyways
            button = UIBox_button({button = 'your_collection_fishies', label = {localize('b_bgf_fishies')}, count = G.ACTIVE_MOD_UI and modsCollectionTally(FishingMod.BGF_Fishes), minw = 5, id = 'your_collection_fishies'})
        }
    }

    if G.ACTIVE_MOD_UI then
        for _, tab in pairs(smods_uibox_buttons) do
            if tab.count.of > 0 then other_collections_tabs[#other_collections_tabs+1] = tab.button end
        end
        if G.ACTIVE_MOD_UI and G.ACTIVE_MOD_UI.custom_collection_tabs then
            object_tabs = G.ACTIVE_MOD_UI.custom_collection_tabs()
            for _, tab in ipairs(object_tabs) do
                other_collections_tabs[#other_collections_tabs+1] = tab
            end
        end
    else
        for _, tab in pairs(smods_uibox_buttons) do
            other_collections_tabs[#other_collections_tabs+1] = tab.button
        end
        for _, mod in pairs(SMODS.Mods) do
            if mod.custom_collection_tabs and type(mod.custom_collection_tabs) == "function" then
                object_tabs = mod.custom_collection_tabs()
                for _, tab in ipairs(object_tabs) do
                    other_collections_tabs[#other_collections_tabs+1] = tab
                end
            end
        end
    end

    local custom_gameobject_rows = {}
    if #other_collections_tabs > 0 then
        for _, gameobject_tabs in ipairs(other_collections_tabs) do
            table.insert(custom_gameobject_tabs[curr_col], gameobject_tabs)
            curr_height = curr_height + gameobject_tabs.nodes[1].config.minh
            if curr_height > 6 then --TODO: Verify that this is the ideal number
                curr_height = 0
                curr_col = curr_col + 1
                custom_gameobject_tabs[curr_col] = {}
            end
        end
        for _, v in ipairs(custom_gameobject_tabs) do
            table.insert(custom_gameobject_rows, {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes = v})
        end

        local t = {n=G.UIT.C, config={align = "cm", r = 0.1, colour = G.C.BLACK, padding = 0.1, emboss = 0.05, minw = 7}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0.15}, nodes = custom_gameobject_rows}
        }}
    
        return create_UIBox_generic_options({ back_func = G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or 'your_collection', contents = {t}})
    else
        return nil
    end
end

FaeLib.Tags.AmogusCards:add(FishingMod.harpy_joker)

local dp_loaded, dpAPI = pcall(require, "debugplus-api")

if dp_loaded and dpAPI.isVersionCompatible(1) then -- Make sure DebugPlus is available and compatible
	FaeLib.Ext.DebugPlus = dpAPI.registerID("bgf")
	FaeLib.Ext.DebugPlus.addCommand({
		name = "fish",
		shortDesc = "Fish.",
		desc = "Allows managing the fishing minigame!",
		exec = function (args, rawArgs, dp)
			if #args > 0 then
				if args[1] == "start" then
					FishingMod.fishing_minigame:start()
					return "Fishing started, have fun~"
				end
				if args[1] == "list" then
					for index, value in ipairs(G.P_bgf_FISH) do
						print(index .. " \t\t abd")
					end
				end
				if args[1] == "give" then
					if args[2] then

					else
						
						return("Gives a fish of type.")
					end
				end
			else
			end
			return "Unknown command!"
		end
	})
end


G.FUNCS.bgf_result_screen_exit = function (e)
	if not FishingMod.fishing_minigame.practice and FishingMod.fishing_minigame.results_screen.fish then
		local fish = FishingMod.fishing_minigame.results_screen.fish
		local fishie_obj = {}
		fishie_obj.key = fish.config.center_key
		fishie_obj.cost = fish.cost
		fishie_obj.ability = fish.ability
		fishie_obj.edition = fish.edition
		FishingMod.Fishies[#FishingMod.Fishies+1] = fishie_obj
	end
	G.FUNCS.exit_overlay_menu(e)
	FishingMod.fishing_minigame.chances = math.max(0,FishingMod.fishing_minigame.chances - 1)
	if FishingMod.fishing_minigame.chances > 0 then
		FishingMod.fishing_minigame:start()
	end
end
G.FUNCS.bgf_fishing_screen_exit = function (e)
	FishingMod.fishing_minigame.visible = false
	G.FUNCS.exit_overlay_menu(e)
	FishingMod.fishing_minigame:reset()
	FishingMod.fishing_minigame.results_screen.fish = nil
	FishingMod.fishing_minigame.results_screen.uibox = FishingMod.create_UIBox_result_screen()
	G.FUNCS.overlay_menu({
		definition = FishingMod.fishing_minigame.results_screen.uibox
	})
end



FishingMod.Base = SMODS.Center:extend{}

FishingMod.Fish = SMODS.Joker:extend{
	-- unlocked = true,1\
	in_pool = function (self, args)
		return true, { allow_duplicates = true }
	end,
	set="Fishies",
	allow_duplicates = true,
    pools = { ["Fishies"] = true },
	bgf_is_fish = true,
	inject = function(self)
		
		-- call the parent function to ensure all pools are set
		SMODS.Joker.inject(self)
		FishingMod.BGF_Fishes[#FishingMod.BGF_Fishes+1] = self
		FishieType:inject_card(self)
	end,
	get_name = function(self) return localize{type="name_text", key=self.key, set="Fishies"} end,
	get_pun_text = function (self) return localize{type="raw_descriptions", key=self.key, set="Fishies", vars = {"???", localize("bgf_uncaught")}}[1] end,
	loc_vars = function(self, info_queue, card)
		return {
            vars = {
                card.ability.extra.weight or "???",
                (card.ability.extra.weight and localize(FishingMod.classifyWeight(card.ability.extra.weight, card.ability.extra.median_weight))) or localize("bgf_uncaught"),
            }
        }
    end,
	
	set_card_type_badge = function(self, card, badges)
 		badges[#badges+1] = create_badge(get_rarity_badge(self, self.rarity or 1) .. ' ' .. localize("bgf_fish"), G.C.RARITY[self.rarity or 1], G.C.WHITE, 1.2 )
	end,
	calculate_sell_value = function (self, card)
		local rarity_modifier = card.ability.extra.rarity_modifier or 1
		local mult = card.edition and (card.edition.mult and card.edition.mult) or 0
		local xmult = (card.edition and (card.edition.x_mult and card.edition.x_mult * 4)) or 1
		local ratio = (card.ability.weight / card.ability.extra.median_weight) * 4
		return tonumber(string.format("%.0f", ((card.config.center.rarity * rarity_modifier + ratio) + mult) * xmult))
	end,
	---comment
	---@param self any
	---@param fishing_rod HimeFishingRod
	spawn_fish = function (self, fishing_rod)
		if self.config.extra.median_weight > fishing_rod.max_weight_kg then
			return nil
		end
		local weight_range = {min=0.01, max=fishing_rod.max_weight_kg}
		local desired_weight = (((math.random() - 0.5) * ((self.config.extra.median_weight/2) + fishing_rod.bait_rarity + ((1 / fishing_rod.max_weight_kg) * 4)))) + self.config.extra.median_weight
		while desired_weight >= weight_range.max do
			desired_weight = math.random() * desired_weight
		end
		local weight = math.min(weight_range.max, math.max(weight_range.min, desired_weight))
		
		local card = self:create_fake_card()
		card.key = self.key
		card.ability = card.ability or {}
		card.ability.weight = tonumber(string.format("%.2f", weight))
		card.fake_card = nil
		
		card.loc_vars = function(self, info_queue, card)
			return {
				vars = {
					card.ability.weight or "???",
					localize("bgf_uncaught"),
				}
			}
		end
		card.vars = {
			card.ability.weight or "???",
			localize("bgf_uncaught"),
		}
		print(card.ability.weight)
		return card
	end
}

local function calculate_percentage_change(current, base)
    current = current or 1
	base = base or 1
    local percentage = ((current / base) - 1) * 100
	local sign = "+"
    return string.format("(%.1f%%)", percentage+100), percentage+100
end


FishingMod.FishingRodClass = SMODS.Joker:extend{
	can_sell = true,
	set="FishingRod",
    pools = { ["FishingRods"] = true, Joker=false},
	weight_multiplier = 1,
	bgf_is_fishing_rod = true,
	inject = function(self)
		self.config.extra = self.config.extra or {}
		self.config.extra.gravity = self.config.extra.gravity or 1
		self.config.extra.speed = self.config.extra.speed or 1
		self.config.extra.reel_speed = self.config.extra.reel_speed or 1
		self.config.extra.weight = self.config.extra.weight or 8
		self.config.extra.weight_multiplier = self.config.extra.weight_multiplier or 1
		-- call the parent function to ensure all pools are set
		SMODS.Joker.inject(self)
		-- SMODS.insert_pool(G.P_CENTER_POOLS.BGF_FishingRods[self.rarity], self, false)
		FishingMod.BGF_FishingRods[#FishingMod.BGF_FishingRods+1] = self
	end,
	get_name = function(self) return localize{type="name_text", key=self.key, set="FishingRods"} end,
	get_pun_text = function (self) return localize{type="raw_descriptions", key=self.key, set="Joker", vars = {"???", localize("bgf_uncaught")}}[1] end,
	loc_vars = function(self, info_queue, card)
		return {
            vars = {
                card.ability.weight or "???",
            }
        }
    end,
	post_create = function(self, card)
		card.edition = nil
		if card.area == G.pack_cards then
			card.on_added_to_area = function(self, area)
				FishingMod.FishingRods[#FishingMod.FishingRods+1] = {
					key = self.config.center_key,
					ability = self.ability,
					edition = self.edition
				}
			end
		end

		card.ability.extra = card.ability.extra or {}
		card.ability.extra.gravity = card.ability.extra.gravity or 1
		card.ability.extra.speed = card.ability.extra.speed or 1
		card.ability.extra.reel_speed = card.ability.extra.reel_speed or 1
		card.ability.extra.weight = card.ability.extra.weight or 8
		card.ability.extra.weight_multiplier = card.ability.extra.weight_multiplier or 1
	end,
	set_card_type_badge = function(self, card, badges)
 		badges[#badges+1] = create_badge(get_rarity_badge(self, self.rarity or 1) .. ' ' .. localize("bgf_rod"), G.C.RARITY[self.rarity or 1], G.C.WHITE, 1.2 )
		if not card.config.can_sell then
			badges[#badges+1] = create_badge(localize("bgf_cannot_sell"), G.C.RED, G.C.WHITE, 1.2 )
		end
		if FishingMod.FishingRod then
			local txtWeightPer, weightPer = calculate_percentage_change(card.ability.extra.weight, FishingMod.FishingRod.ability.extra.weight)
			local txtWeightMultPer, weightMultPer = calculate_percentage_change(card.ability.extra.weight_multiplier, FishingMod.FishingRod.ability.extra.weight_multiplier)
			local txtGravPer, gravPer = calculate_percentage_change(card.ability.extra.gravity, FishingMod.FishingRod.ability.extra.gravity)
			local txtSpdPer, spdPer = calculate_percentage_change(card.ability.extra.speed, FishingMod.FishingRod.ability.extra.speed)
			badges[#badges+1] = create_badge(localize("bgf_rod_tooltip_weight_max"):format(
				tostring(card.ability.extra.weight) ..
				txtWeightPer
			), G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9)

			badges[#badges+1] = create_badge(localize("bgf_rod_tooltip_fish_weight_addtl"):format(
				tostring((card.ability.extra.weight_multiplier or 1) * 100) .. "%"..
				txtWeightMultPer
			), G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9)

			badges[#badges+1] = create_badge(localize("bgf_rod_tooltip_heaviness"):format(
				tostring((card.ability.extra.gravity or 1) * 100) ..
				txtGravPer
			), G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9)

			badges[#badges+1] = create_badge(localize("bgf_rod_tooltip_speed"):format(
				tostring((card.ability.extra.speed or 1) * 100) ..
				txtSpdPer
			), G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9)

		else
			badges[#badges+1] = create_badge(localize("bgf_rod_tooltip_weight_max"):format(tostring(card.ability.extra.weight) or "???"), G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9 )
			badges[#badges+1] = create_badge(localize("bgf_rod_tooltip_fish_weight_addtl"):format(tostring((card.ability.extra.weight_multiplier or 1) * 100) ).."%", G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9 )
			badges[#badges+1] = create_badge(localize("bgf_rod_tooltip_heaviness"):format(tostring((card.ability.extra.gravity or 1) * 100) ), G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9 )
			badges[#badges+1] = create_badge(localize("bgf_rod_tooltip_speed"):format(tostring((card.ability.extra.speed or 1) * 100) ), G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9 )
		end
	end,
}

FishingMod.FishingBait = SMODS.Joker:extend{
	set="Baits",
	edition = nil,
	stackable = true,
	pools = { ["FishingBait"] = true, Joker=false},
	can_sell = true,
	inject = function(self)
		-- call the parent function to ensure all pools are set
		SMODS.Joker.inject(self)
		-- SMODS.insert_pool(G.P_CENTER_POOLS.BGF_Baits[self.rarity], self, false)
		FishingMod.BGF_FishingBaits[#FishingMod.BGF_FishingBaits+1] = self
	end,
	get_name = function(self) return localize{type="name_text", key=self.key, set="FishingBaits"} end,
	get_pun_text = function (self) return localize{type="raw_descriptions", key=self.key, set="Joker", vars = {"???", localize("bgf_uncaught")}}[1] end,
	loc_vars = function(self, info_queue, card)
		return {
            vars = {
                card.ability.weight or "???",
            }
        }
    end,
	
	post_create = function(self, card)
		card.edition = nil
		if card.area == G.pack_cards then
			self.stack_count = math.random(1,3)
			
			-- local c2 = FaeLib.Builtin.GenCardForPool("FishingRods")
			-- G.pack_cards:emplace(c2)

			card.can_stack = function() return false end
			card.on_added_to_area = function(self, area)
				FishingMod.Baits[#FishingMod.Baits+1] = {
					key = self.config.center_key,
					count = self.stack_count or 1
				}
			end
		end
		card.ability.extra = card.ability.extra or {}
		card.ability.extra.attract_speed = card.ability.extra.attract_speed or 1
		card.ability.extra.linger_seconds = card.ability.extra.linger_seconds or 2

	end,
	set_card_type_badge = function(self, card, badges)
 		badges[#badges+1] = create_badge(get_rarity_badge(self, self.rarity or 1) .. ' ' .. localize("bgf_bait"), G.C.RARITY[self.rarity or 1], G.C.WHITE, 1.2 )
		badges[#badges+1] = create_badge(localize("bgf_bait_tooltip_attraction"):format(tostring((card.ability.extra.attract_speed or 1) * 100).."%" ), G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9 )
		badges[#badges+1] = create_badge(localize("bgf_bait_tooltip_linger_time"):format(tostring((((card.ability.extra.linger_seconds) or 2.5) - 1) * 100).."%" ), G.C.CLEAR, G.C.UI.TEXT_LIGHT, 0.9 )
	end,
}


FishingMod.Fish {
    pools = { ["Fishie"] = true},
	rarity = FishingMod.FishRarity.Legendary,
	key = "bgf_shark",
	atlas = "fishies",
	pos = {x = 0, y = 0},
	config = {extra={weight = 8}},
}
FishingMod.Fish {
    pools = { ["Fishie"] = true},
	rarity = FishingMod.FishRarity.Uncommon,
	key = "bgf_tuna",
	atlas = "fishies",
	pos = {x = 1, y = 0},
	config = {extra={median_weight = 8}},
}
FishingMod.Fish {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_salmon",
	atlas = "fishies",
	pos = {x = 2, y = 0},
	config = {extra={median_weight = 3}},
}
FishingMod.Fish {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_bass",
	atlas = "fishies",
	pos = {x = 3, y = 0},
	config = {extra={median_weight = 1.5}},
}
FishingMod.Fish {
	rarity = FishingMod.FishRarity.Uncommon,
	key = "bgf_shrimp",
	atlas = "fishies",
	pos = {x = 4, y = 0},
	config = {extra={median_weight = 0.1}},
}
FishingMod.Fish {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_cod",
	atlas = "fishies",
	pos = {x = 5, y = 0},
	config = {extra={median_weight = 2}},
}
FishingMod.Fish {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_catfish",
	atlas = "fishies",
	pos = {x = 6, y = 0},
	config = {extra={median_weight = 2.5}},
}
FishingMod.Fish {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_trout",
	atlas = "fishies",
	pos = {x = 7, y = 0},
	config = {extra={median_weight = 1.3}},
}
FishingMod.Fish {
	rarity = FishingMod.FishRarity.Rare,
	key = "bgf_pike",
	atlas = "fishies",
	pos = {x = 8, y = 0},
	config = {extra={median_weight = 4}},
}
FishingMod.Fish {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_perch",
	atlas = "fishies",
	pos = {x = 9, y = 0},
	config = {extra={median_weight = 1.2}},
}
FishingMod.Fish {
	in_pool = function() return false end,
	rarity = FishingMod.FishRarity.Legendary,
	key = "bgf_size2",
	atlas = "fishies",
	pos = {x = 0, y = 1},
	config = {extra={median_weight = 32}},
}
FishingMod.FishingRodClass {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_rod_basic",
	atlas="rods",
	pos = {x=0,y=0},
	config = {extra={weight = 16}},
}
FishingMod.FishingRodClass {
	rarity = FishingMod.FishRarity.Uncommon,
	key = "bgf_rod_reinforced",
	atlas="rods",
	pos = {x=1,y=0},
	can_sell = true,
	config = {extra={weight = 30,speed=0.8,gravity = 1.25}},
}
FishingMod.FishingRodClass {
	rarity = FishingMod.FishRarity.Rare,
	key = "bgf_rod_fiberglass",
	atlas="rods",
	pos = {x=2,y=0},
	can_sell = true,
	config = {extra={weight = 25,speed=2,gravity=2,reel_speed = 1.25}},
}
FishingMod.FishingRodClass {
	rarity = FishingMod.FishRarity.Rare,
	key = "bgf_rod_carbon",
	atlas="rods",
	pos = {x=3,y=0},
	can_sell = true,
	config = {extra={weight = 84,weight_multiplier = 2.5,gravity=2}},
	
}
FishingMod.FishingRodClass {
	rarity = FishingMod.FishRarity.Rare,
	key = "bgf_rod_steel",
	atlas="rods",
	pos = {x=5,y=0},
	can_sell = true,
	config = {extra={weight = 64, weight_multiplier = 1.5, gravity = 1.6}},
}
FishingMod.FishingRodClass {
	rarity = FishingMod.FishRarity.Legendary,
	key = "bgf_rod_hypersteel",
	atlas="rods",
	pos = {x=4,y=0},
	can_sell = true,
	config = {extra={weight = 100, weight_multiplier=1.5, gravity=3, speed=0.75}},
	weight_multiplier = 1.8
}
FishingMod.FishingBait {
	rarity = FishingMod.FishRarity.Legendary,
	key = "bgf_bait_legendary",
	atlas="bait",
	pos = {x=0,y=0},
	can_sell = true,
    display_size = { w = 34, h = 34 },
}

FishingMod.FishingBait {
	rarity = FishingMod.FishRarity.Uncommon,
	key = "bgf_bait_strawberry",
	atlas="bait",
	pos = {x=1,y=0},
	can_sell = true,
    display_size = { w = 34, h = 34 },
}
FishingMod.FishingBait {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_bait_forbidden",
	atlas="bait",
	pos = {x=2,y=0},
	can_sell = true,
    display_size = { w = 34, h = 34 },
}

FishingMod.FishingBait {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_bait_cheese",
	atlas="bait",
	pos = {x=3,y=0},
	can_sell = true,
	config= {extra = {
		linger_seconds = 3
	}},
    display_size = { w = 34, h = 34 },
}
FishingMod.FishingBait {
	rarity = FishingMod.FishRarity.Common,
	key = "bgf_bait_worm",
	atlas="bait",
	pos = {x=0,y=1},
	can_sell = true,
    display_size = { w = 34, h = 34 },
}
FishingMod.FishingBait {
	rarity = FishingMod.FishRarity.Legendary,
	key = "bgf_bait_stellaron",
	atlas="bait",
	pos = {x=0,y=2},
	can_sell = true,
	config= {extra = {
		attract_speed = 0.75,
		linger_seconds = 5
	}},
    display_size = { w = 34, h = 34 },
}


FishingMod.fishie_button = nil
FaeLib.Builtin.Events.RenderPre:register(function()
	if FishingMod.fishie_button and FishingMod.fishie_button.REMOVED then
		FishingMod.fishie_button:remove()
		FishingMod.fishie_button = nil
		FishingMod.FishieButtonSprite = FishingMod.FishieButtonSprite or Sprite(0,0,1,1,FishingMod.Main16, {x=1, y=0})
    	FishingMod.FishieButtonSprite.states.drag.can = false
	end
	if not FishingMod.fishie_button then
		FishingMod.FishieButtonSprite = FishingMod.FishieButtonSprite or Sprite(0,0,1,1,FishingMod.Main16, {x=1, y=0})
    	FishingMod.FishieButtonSprite.states.drag.can = false
		FishingMod.fishie_button = UIBox({
			definition = {
				n=G.UIT.ROOT, config = {align = "cl",colour = G.C.BLACK, minw = 8, emboss = 0.1, r=0.1, padding=0.1, button='your_collection_fishies'}, nodes={
					{n=G.UIT.O, config={object = FishingMod.FishieButtonSprite, colour=G.C.BLACK}},
				}
			},
			config = {
				align = "cr",
				bond = "Weak",
				offset = {
					x = (5/20),
					y = 0
				},
				major = G.ROOM_ATTACH
			}
		})
	end
	
	FishingMod.fishie_button:recalculate()
end)
FaeLib.Builtin.Events.MainMenuOpened:register(function()
	if not FishingMod.FishingRod and #FishingMod.FishingRods == 0 then
		-- As a treat, we'll give the User a free t0 rod!
		-- This should only happen if they manipulate stuff weirdly, or first start up the mod!
		FishingMod.FishingRod = {
			id=1,
			can_sell = false,
			key="j_bgf_rod_basic",
			weight = 8,
			ability = {
				weight = 8,
				extra = {weight=8},


			}
		}
	end
end)


FishingMod.AddFishingRodFromCard = function(card)
	FishingMod.FishingRods[#FishingMod.FishingRods+1] = {
		key=card.config.center_key,
		weight = card.ability.extra.weight or 8,
		ability = card.ability,
		can_sell = card.config.can_sell
	}
	G:save_progress()
end
FishingMod.AddFishingBaitFromCard = function(card)
	FishingMod.Baits[#FishingMod.Baits+1] = {
		key=card.config.center_key,
		count=card.stack_count or 1
	}
	G:save_progress()
end



FishingMod.save_data = new 'FaeLib.SaveData'("bgf")
	:profile_load(function (data)
		FishingMod.Fishies = data.fishies or {}
		FishingMod.FishingRods = data.fishie_rods or {}
		FishingMod.FishingRod = data.rod
		FishingMod.Baits = data.baits or {}
		FishingMod.SelectedBait = data.bait or {}
	end)
	:profile_save(function (data)
		data.fishies = FishingMod.Fishies or {}
		data.fishie_rods = FishingMod.FishingRods or {}
		data.rod = FishingMod.FishingRod
		data.baits = FishingMod.Baits or {}
		data.bait = FishingMod.SelectedBait or {}
	end)

local usecardfunc = G.FUNCS.use_card
G.FUNCS.use_card = function (e, mute, nosave)
	local card = e.config.ref_table
	print(card.config.center.set)
	if card.config.center.set == "Baits" then
		FishingMod.AddFishingBaitFromCard(card)
		card:remove()
	end
	if card.config.center.set == "FishingRod" then
		FishingMod.AddFishingRodFromCard(card)
		card:remove()
	end

	return usecardfunc(e, mute, nosave)
	
end