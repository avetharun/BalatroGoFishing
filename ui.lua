FishingMod = FishingMod or {}


local function rectsIntersect(rect1, rect2)
    return rect1.x < rect2.x + rect2.w and
           rect1.x + rect1.w > rect2.x and
           rect1.y < rect2.y + rect2.h and
           rect1.y + rect1.h > rect2.y
end
FishingMod = FishingMod or {}

local getNextId = function ()
	local idx = math.max(2, FishingMod.FishingRod and FishingMod.FishingRod.id or 0)
	for key, value in pairs(FishingMod.FishingRods) do
		idx = math.max(idx, value.id)
	end
	return idx + 1
end
FishingMod.getRodForId = function (id)
	if FishingMod.FishingRod and FishingMod.FishingRod.id == id then
		return -1
	end
	for key, value in ipairs(FishingMod.FishingRods) do
		if value.id == id then
			return key
		end
	end
	return -2
end
local bait_card_moved_func = function (self, card)
	if FishingMod.bait_dropoff.cards[1] then
		local sBait = FishingMod.bait_dropoff.cards[1]
		FishingMod.SelectedBait = {
			key = sBait.config.center_key,
			count = sBait.stack_count,
			linger_seconds = sBait.ability.extra.linger_seconds or 2.5,
			attract_speed = sBait.ability.extra.attract_speed or 1
		}
	end
	FishingMod.Baits = {}
	for index, value in ipairs(FishingMod.bait_area.cards) do
		FishingMod.Baits[index] = {
			key = value.config.center_key,
			count = value.stack_count,
			linger_seconds = value.ability.extra.linger_seconds or 2.5,
			attract_speed = value.ability.extra.attract_speed or 1
		}
	end
	G:save_progress()
	print("Saved")
end
local card_merged = function (self, card)
	bait_card_moved_func(nil, nil)
end 
FishingMod.card_collection_UIBox_rod_inventory = function(_pool, rows, args)
	
	if not FishingMod.FishingRod and #FishingMod.FishingRods == 0 then
		-- As a treat, we'll give the User a free t0 rod!
		-- This should only happen if they manipulate stuff weirdly, or first start up the mod!
		FishingMod.FishingRod = {
			id=1,
			can_sell = false,
			key="j_bgf_rod_basic",
			weight = 8,
			ability = {
				extra = {weight=8},
			}
		}
		
		FishingMod.FishingRod.ability.extra = FishingMod.FishingRod.ability.extra or {}
		FishingMod.FishingRod.ability.extra.gravity = FishingMod.FishingRod.ability.extra.gravity or 1
		FishingMod.FishingRod.ability.extra.speed = FishingMod.FishingRod.ability.extra.speed or 1
		FishingMod.FishingRod.ability.extra.reel_speed = FishingMod.FishingRod.ability.extra.reel_speed or 1
		FishingMod.FishingRod.ability.extra.weight = FishingMod.FishingRod.ability.extra.weight or 8
		FishingMod.FishingRod.ability.extra.weight_multiplier = FishingMod.FishingRod.ability.extra.weight_multiplier or 1
	end
    args = args or {}
    args.w_mod = args.w_mod or 1
    args.h_mod = args.h_mod or 1
    args.card_scale = args.card_scale or 1
    local deck_tables = {}
    local bait_deck_tables = {}
	local pool = {}
	local current_crafting_state = {
		money = "$0",
		weight = "???",
	}
	FishingMod.bait_area = FaeLib.UI.SlidingCardArea(1,1,5,1.25,{type='title'})
	FishingMod.dropoff = nil
    FishingMod.dropoff = CardArea(
		G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
		args.w_mod*G.CARD_W,
		args.h_mod*G.CARD_H,
		{card_limit = 1, type = 'title', highlight_limit = 1, collection = false, minh = args.h_mod*G.CARD_H, minw = args.w_mod*G.CARD_W}
	)
	FishingMod.bait_dropoff = nil
    FishingMod.bait_dropoff = CardArea(
		0,0,
		args.w_mod * 1.2,
		args.h_mod * 1.2,
		{card_limit = 1, type = 'title', highlight_limit = 1, collection = false, maxw = args.h_mod, maxh = args.h_mod}
	)
	if FishingMod.SelectedBait and FishingMod.SelectedBait.key then
		local c = FaeLib.Builtin.CreateCard(FishingMod.SelectedBait.key)
		c.states.collide.can = true
		c.on_merged = card_merged
		c.states.hover.can = true
		c.bgf_index = #(FishingMod.Baits or {})+1
		c.stack_count = FishingMod.SelectedBait.count or 1
		c.edition = nil
		FishingMod.bait_dropoff:emplace(c)
		c.config.transferrable_areas = {FishingMod.bait_area, FishingMod.bait_dropoff}
		
	end
	for index, value in ipairs(FishingMod.Baits) do
		if not G.P_CENTERS[value.key] or not value.key then
			print("Missing card for '"..(value.key or "missingkey").."'!")
		else
			local c = FaeLib.Builtin.CreateCard(value.key)
			c.on_merged = card_merged
			c.states.collide.can = true
			c.states.hover.can = true
			c.bgf_index = index
			c.stack_count = value.count or 1
			c.edition = nil
			c.config.transferrable_areas = {FishingMod.bait_area, FishingMod.bait_dropoff}
			FishingMod.bait_area:emplace(c)
		end
	end
	FishingMod.bait_area.states.collide.can = true
	FishingMod.bait_area.states.hover.can = true
	FishingMod.bait_dropoff.states.collide.can = true
	FishingMod.bait_dropoff.states.hover.can = true
	for key, value in pairs(FishingMod.FishingRods) do
		local pool_obj = G.P_CENTERS[value.key]
		if not pool_obj then goto continue end
		pool_obj.ability = value.ability
		pool_obj.edition = nil
		pool_obj.cost = value.cost
		pool_obj.id = value.id
		pool_obj.uuid = value.uuid
		pool[#pool+1] = pool_obj
		::continue::
	end

	local dropoff = FishingMod.dropoff
    G.your_collection = {}
    FishingMod.bait_collection = {}
    local cards_per_page = 0
    local row_totals = {}
    for j = 1, #rows do
		row_totals[j] = cards_per_page
		cards_per_page = cards_per_page + rows[j]
		G.your_collection[j] = CardArea(
			G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
			(args.w_mod*rows[j]+0.25)*G.CARD_W,
			args.h_mod*G.CARD_H, 
			{card_limit = rows[j], type = 'title', highlight_limit = 1, collection = false, minh = args.h_mod*G.CARD_H, minw = 5 * (args.w_mod*G.CARD_W)}
		)
		
		G.your_collection[j].states.hover.can = true
		G.your_collection[j].states.collide.can = true
		table.insert(deck_tables, 
		{n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
			{n=G.UIT.O, config={object = G.your_collection[j]}}
		}})
    end

	if FishingMod.FishingRod and G.P_CENTERS[FishingMod.FishingRod.key] then
		local fishing_rod_card = FaeLib.Builtin.CreateCard(FishingMod.FishingRod.key)
		FishingMod.dropoff:emplace(fishing_rod_card)
		fishing_rod_card.ability = FishingMod.FishingRod.ability or {}
		fishing_rod_card.id = FishingMod.FishingRod.id
		fishing_rod_card.states.collide.can = true
		fishing_rod_card.states.hover.can = true
		fishing_rod_card.states.drag.can = true
		fishing_rod_card.states.click.can = true
		fishing_rod_card.need_update = true
		fishing_rod_card.edition = {}
		fishing_rod_card.config.can_sell = FishingMod.FishingRod.can_sell
		fishing_rod_card.config.transferrable_areas = {G.your_collection[1], FishingMod.dropoff}
	end
    local options = {}
    for i = 1, 2 do
        table.insert(options, localize('k_page')..' '..tostring(i)..'/'..tostring(2))
    end
    dropoff.states.hover.can = true
    dropoff.states.collide.can = true
    dropoff.states.release_on.can = true
    G.FUNCS.SMODS_card_collection_page = function(e)
		
        if not e or not e.cycle_config then return end
		-- if dropoff.cards[1] then 
		-- 	local c = dropoff:remove_card(dropoff.cards[1])
		-- 	c:remove()
		-- 	c = nil
		-- 	current_crafting_state.weight = "???"
		-- 	current_crafting_state.money = "$0"
		-- end
		
		FishingMod.dropoff.on_card_added = nil
		FishingMod.bait_area.on_card_added = nil
		FishingMod.bait_dropoff.on_card_added = nil
		G.your_collection[1].on_card_added = nil
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards, 1, -1 do
            local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
            c:remove()
            c = nil
            end
        end
		local currently_hovered_card = nil
        for j = 1, #rows do
            for i = 1, rows[j] do
				local center = FishingMod.FishingRods[i+row_totals[j] + (cards_per_page*(e.cycle_config.current_option - 1))]
				local index = i+row_totals[j] + (cards_per_page*(e.cycle_config.current_option - 1))
				-- print(index .. "of" .. #_pool)
				if not center then break end
				local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*args.card_scale, G.CARD_H*args.card_scale, G.P_CARDS.empty, G.P_CENTERS[center.key])
				card.ability = FishingMod.FishingRods[index].ability or {}
				card.edition = FishingMod.FishingRods[index].edition
				card.bgf_index = index
				card.states.collide.can = true
				card.states.hover.can = true
				card.states.drag.can = true
				card.states.click.can = true
				card.config.can_sell = FishingMod.FishingRods[index].can_sell
				card.config.transferrable_areas = {G.your_collection[j], FishingMod.dropoff}
				
				-- if not args.no_materialize then card:start_materialize(nil, i>1 or j>1) end
				G.your_collection[j]:emplace(card)
            end
        end
		
		FishingMod.bait_dropoff.on_card_added = bait_card_moved_func
		FishingMod.bait_area.on_card_added = bait_card_moved_func
		FishingMod.bait_dropoff.align_cards = function (self)
			
			FishingMod.SelectedBait = {}
			if self.cards[1] then
				FishingMod.SelectedBait = {

					key = self.cards[1].config.center_key,
					count = self.cards[1].stack_count
				}
			end
			for k, card in ipairs(self.cards) do
				if not card.states.drag.is then 
					card.T.r = (G.SETTINGS.reduced_motion and 0 or 1)*0.02*math.sin(2*G.TIMERS.REAL+card.T.x)
					card.T.x = self.T.x + 0.1
					card.T.y = self.T.y + 0.1
				end
			end
			
		end
			
		FishingMod.dropoff.on_card_added = function(self, card)
			if self.first_frame then return end
			FishingMod.FishingRod = {
				key = card.config.center_key,
				can_sell = card.config.can_sell,
				ability = card.ability
			}
			FishingMod.FishingRods = {}
			for index, value in ipairs(G.your_collection[1].cards) do
				FishingMod.FishingRods[index] = {
					key = value.config.center_key,
					can_sell = value.config.can_sell,
					ability = value.ability
				}
			end
			G:save_progress()
			print("Saved")
		end
		G.your_collection[1].on_card_added = function(self, card)
			if self.first_frame then return end
			FishingMod.FishingRods = {}
			for index, value in ipairs(G.your_collection[1].cards) do
				FishingMod.FishingRods[index] = {
					key = value.config.center_key,
					can_sell = value.config.can_sell,
					ability = value.ability
				}
			end
			FishingMod.FishingRod = nil
			G:save_progress()
			print("Saved")
		end
    end

	FishingMod.bait_dropoff.can_add_card = function (self, card)
		return self.cards[1] == nil
	end
	FishingMod.dropoff.can_add_card = function (self, card)
		return self.cards[1] == nil
	end
	local in_shop = G.STATE == 5
    G.FUNCS.SMODS_card_collection_page{ cycle_config = { current_option = 1 }}
	dropoff.states.collide.can = true
	dropoff.states.hover.can = true
	
    local t =  create_UIBox_generic_options({ minw=3, minh=2, back_func = (args and args.back_func) or G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or 'your_collection', snap_back = args.snap_back, infotip = args.infotip, contents = {
          {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05,minh = args.h_mod*G.CARD_H}, nodes=deck_tables}, 
          {n=G.UIT.R, config={align = "cm"}, nodes={
            create_option_cycle({options = options, h=0.25, w = 4.5, cycle_shoulders = true, opt_callback = 'SMODS_card_collection_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
          }},
          {n=G.UIT.R, config={align = "cm"}, nodes={
          {n=G.UIT.O, config={align = "cm", object = FishingMod.bait_area}}
		  }},
		  {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05,padding=0.1}, nodes={
			{n=G.UIT.T, config = {align="tm", text=localize("b_bgf_drop_to_equip"), colour = G.C.UI.TEXT_DARK, vert=true, scale = 0.5}},
			{n=G.UIT.T, config = {align="tm", text=localize("b_bgf_fishie_rods"), colour = G.C.UI.TEXT_DARK, vert=true, scale = 0.5}},
			{n=G.UIT.C, config={align = "cm", r = 0.1, colour = HEX("2c2c3c2f"), emboss = 0.05, padding=0.1}, nodes={
				{n=G.UIT.O, config = {align = "lm", object = dropoff, colour = G.C.BLACK},},
			}},
			{n=G.UIT.C, config={align = "cm", r = 0.1, emboss = 0.05, padding=0.1}, nodes={
				{n=G.UIT.R, config={align = "cm"}, nodes={
					{n=G.UIT.T, config = {align="tm", text=localize("b_bgf_fishie_baits"), colour = G.C.UI.TEXT_DARK, vert=false, scale = 0.25}},
				}},
				{n=G.UIT.R, config={align = "cm", r = 0.1, colour = HEX("2c2c3c2f"), emboss = 0.05}, nodes={
					{n=G.UIT.C, config={align = "cm"}, nodes={
						{n=G.UIT.O, config = {align = "cm", object = FishingMod.bait_dropoff, colour = G.C.BLACK}},
					}}
				}},
				{n=G.UIT.R, config={align = "cm"}, nodes={
					{n=G.UIT.T, config = {align="tm", text=" ", colour = G.C.UI.TEXT_DARK, vert=false, scale = 0.25}},
				}},
			}},
			{n=G.UIT.C, config={align = "cm"}, nodes={
				{n=G.UIT.R, config={align = "cl", r = 0.1, colour = HEX("2c2c3c2f"), emboss = 0.05,padding=0.1, minw=7}, nodes={
					{n=G.UIT.C, config={align = "cl", r = 0.1, colour = G.C.BLACK, emboss = 0.05,padding=0.1, minw=4.5, minh = 2.5}, nodes={
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Max Weight: ", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
							{n=G.UIT.T, config = {align="tm", ref_table=current_crafting_state, ref_value="weight", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
						}},
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text=" ", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
						}},
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Sell Price: ", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
							{n=G.UIT.T, config = {align="tm", ref_table=current_crafting_state, ref_value="money", colour = G.C.MONEY, scale = 0.5}},
						}},
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Max Rarity: ", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
							{n=G.UIT.T, config = {align="tm", text="???", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
						}},
					}},
					{n=G.UIT.C, config={align = "cm",padding=0.1}, nodes={
						{n=G.UIT.R, config={align = "cm",padding=0.1, colour = G.C.RED, button="bgf_rod_delete", r=0.1}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Delete", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
						}},
						{n=G.UIT.R, config={align = "cm",padding=0.1, colour = in_shop and G.C.GOLD or HEX("5c5c5c2f"), button=(in_shop and FishingMod.dropoff.cards[1] and FishingMod.dropoff.cards[1].config.can_sell) and "bgf_rod_sell" or nil, r=0.1, tooltip = not in_shop and {title=localize("bgf_shop_required")} or nil}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Sell", colour = in_shop and G.C.UI.INACTIVE or G.C.UI.TEXT_DARK, scale = 0.5}},
						}},
					}},
				}}
			}}
		  }},
      }})
    return t
end
G.FUNCS.bgf_rod_move = function(e, where, card)
	if where == "dropoff" then
		local index = FishingMod.getRodForId(card.id)
		if index > 0 then
			table.remove(FishingMod.FishingRods, index)
		end
		FishingMod.FishingRod = FishingMod.FishingRod or {}
		FishingMod.FishingRod.key = card.config.center_key
		FishingMod.FishingRod.weight = card.ability.extra.weight
		FishingMod.FishingRod.ability = card.ability
		FishingMod.FishingRod.can_sell = card.can_sell
		FishingMod.FishingRod.id = card.id
	elseif where == "inventory" then
		FishingMod.FishingRods[#FishingMod.FishingRods+1] = FishingMod.FishingRod
		FishingMod.FishingRod = nil
	end
	G:save_progress()
	
end
G.FUNCS.bgf_rod_sell = function (e)
	if FishingMod.dropoff and FishingMod.dropoff.cards[1] and FishingMod.dropoff.cards[1].config.can_sell then
		if (FishingMod.dropoff.cards[1] and not FishingMod.dropoff.cards[1].is_being_removed) then
			local value, _ = FishingMod.dropoff.cards[1].config.center:calculate_sell_value(FishingMod.dropoff.cards[1])
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function()
				play_sound('coin2')
				ease_dollars(value)
				FishingMod.dropoff.cards[1]:juice_up(0.3, 0.4)
				inc_career_stat('c_cards_sold', 1)
				return true
			end}))
			G.FUNCS.bgf_rod_delete(e)
		end
	end
end
G.FUNCS.bgf_rod_delete = function (e)
	if FishingMod.dropoff and FishingMod.dropoff.cards[1] and FishingMod.dropoff.cards[1].config.can_sell then
		local card = FishingMod.dropoff.cards[1]
		card.is_being_removed = true
		table.remove(FishingMod.FishingRods, card.bgf_index)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function()
			card:start_dissolve()
			return true
		end}))
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = .3,
			func = function()
				FishingMod.dropoff:remove_card(card)
				card:remove()
				return true
			end
		}))
		FishingMod.FishingRod = nil
		G:save_progress()
        -- Hacky method to update the indices for the savefile. TODO: MAKE THIS FUCKING BETTER???? LIKE HELLO???
		for key, value in ipairs(G.your_collection[1].cards) do
			if value.bgf_index >= card.bgf_index then
				value.bgf_index = value.bgf_index - 1
			end
		end
		
	end
end
FishingMod.card_collection_UIBox_fish_inventory = function(_pool, rows, args)
    args = args or {}
    args.w_mod = args.w_mod or 1
    args.h_mod = args.h_mod or 1
    args.card_scale = args.card_scale or 1
    local deck_tables = {}
	local pool = {}
	local current_crafting_state = {
		money = "$0",
		weight = "???",
		size = "???",
		equation = "(R + ((W / M) * 4) + mult ) * 4(xmult))",
		R = "???",
		W = "???",
		M = "???"
	}
	local money_calc_tooltip = {
		title="Insert a Fish to calculate!",
		text = {
			"Standard Weight: #1#kg",
			"Edition: #2#",
			"+Weight%: #3#%",
		}
	}
	FishingMod.dropoff = nil
    FishingMod.dropoff = CardArea(
		G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
		args.w_mod*G.CARD_W,
		args.h_mod*G.CARD_H, 
		{card_limit = 1, type = 'title', highlight_limit = 1, collection = false, minh = args.h_mod*G.CARD_H, minw = args.w_mod*G.CARD_W}
	)
	for key, value in pairs(FishingMod.Fishies) do
		local pool_obj = G.P_CENTERS[value.key]
		if not pool_obj then goto continue end
		pool_obj.ability = value.ability
		pool_obj.edition = value.edition
		pool_obj.cost = value.cost
		pool_obj.uuid = value.uuid
		if pool_obj.in_crafting then
			-- SMODS.add_card({center = pool_obj, area = FishingMod.dropoff})
		else
			pool[#pool+1] = pool_obj
		end
		::continue::
	end

	local dropoff = FishingMod.dropoff
    G.your_collection = {}
    local cards_per_page = 0
    local row_totals = {}
    for j = 1, math.min(1,#rows) do
        if cards_per_page >= #pool and args.collapse_single_page then
            rows[j] = nil
        else
            row_totals[j] = cards_per_page
            cards_per_page = cards_per_page + rows[j]
            G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                (args.w_mod*rows[j]+0.25)*G.CARD_W,
                args.h_mod*G.CARD_H, 
                {card_limit = rows[j], type = 'title', highlight_limit = 1, collection = false, minh = args.h_mod*G.CARD_H, minw = 5 * args.w_mod*G.CARD_W}
            )
			G.your_collection[j].states.hover.can = true
			G.your_collection[j].states.collide.can = true
			local oldhover = G.your_collection[j].update
			G.your_collection[j].on_card_removed = function (self, card)
				current_crafting_state.weight = "???"
				current_crafting_state.size = "???"
				current_crafting_state.money = "$0"
				current_crafting_state.R = "???"
				current_crafting_state.W = "???"
				current_crafting_state.M = "???"
			end
            table.insert(deck_tables, 
            {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
                {n=G.UIT.O, config={object = G.your_collection[j]}}
            }})
        end
    end

    local options = {}
    for i = 1, 20 do
        table.insert(options, localize('k_page')..' '..tostring(i)..'/'..tostring(20))
    end
    dropoff.states.hover.can = true
    dropoff.states.collide.can = true
    dropoff.states.release_on.can = true

	FishingMod.dropoff.on_card_added = function (self, card)
		local weight = card.ability.extra.weight
		local medianWeight = G.P_CENTERS[card.config.center_key].config.extra.median_weight
		local ratio = (weight / medianWeight) * 100
		local value = card.config.center:calculate_sell_value(card)
		current_crafting_state.weight = card.ability.extra.weight or 1
		current_crafting_state.size = localize(FishingMod.classifyWeight(weight, medianWeight))
		current_crafting_state.money = "$"..value
		current_crafting_state.R = card.config.center.rarity
		current_crafting_state.W = current_crafting_state.weight
		current_crafting_state.M = medianWeight
	end
	FishingMod.dropoff.on_card_removed = function (self, card)
		current_crafting_state.weight = "???"
		current_crafting_state.size = "???"
		current_crafting_state.money = "$0"
		current_crafting_state.R = "???"
		current_crafting_state.W = "???"
		current_crafting_state.M = "???"
	end
    G.FUNCS.SMODS_card_collection_page = function(e)
		pool = FishingMod.Fishies
        if not e or not e.cycle_config then return end
		if dropoff.cards[1] then 
			local c = dropoff:remove_card(dropoff.cards[1])
			c:remove()
			c = nil
			current_crafting_state.weight = "???"
			current_crafting_state.size = "???"
			current_crafting_state.money = "$0"
			current_crafting_state.R = "???"
			current_crafting_state.W = "???"
			current_crafting_state.M = "???"
		end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards, 1, -1 do
				local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
				if c then
					c:remove()
				end
				c = nil
            end
        end
		local currently_hovered_card = nil
        for j = 1, #rows do
            for i = 1, rows[j] do
				local center = FishingMod.Fishies[i+row_totals[j] + (cards_per_page*(e.cycle_config.current_option - 1))]
				local index = i+row_totals[j] + (cards_per_page*(e.cycle_config.current_option - 1))
				-- print(index .. "of" .. #_pool)
				if not center then break end
				local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*args.card_scale, G.CARD_H*args.card_scale, G.P_CARDS.empty, G.P_CENTERS[center.key])
				card.ability = FishingMod.Fishies[index].ability or {}
				card.edition = FishingMod.Fishies[index].edition
				card.bgf_index = index
				card.states.collide.can = true
				card.states.hover.can = true
				card.states.drag.can = true
				card.states.click.can = true
				if not args.no_materialize then card:start_materialize(nil, i>1 or j>1) end
				G.your_collection[j]:emplace(card)
				card.config.transferrable_areas = {
					FishingMod.dropoff, G.your_collection[j]
				}
            end
        end
    end
	
	FishingMod.dropoff.can_add_card = function (self, card)
		return self.cards[1] == nil
	end
	local in_shop = G.STATE == 5
    G.FUNCS.SMODS_card_collection_page{ cycle_config = { current_option = 1 }}
	dropoff.states.collide.can = true
	dropoff.states.hover.can = true
    local t =  create_UIBox_generic_options({ minw=3, minh=2, back_func = (args and args.back_func) or G.ACTIVE_MOD_UI and "openModUI_"..G.ACTIVE_MOD_UI.id or 'your_collection', snap_back = args.snap_back, infotip = args.infotip, contents = {
          {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables}, 
          {n=G.UIT.R, config={align = "cm"}, nodes={
            create_option_cycle({options = options, w = 4.5, cycle_shoulders = true, opt_callback = 'SMODS_card_collection_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
          }},
		  {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05,padding=0.1}, nodes={
			{n=G.UIT.T, config = {align="tm", text=localize("b_bgf_fishies"), colour = G.C.UI.TEXT_DARK, vert=true, scale = 0.5}},
			{n=G.UIT.C, config={align = "cm", r = 0.1, colour = HEX("2c2c3c2f"), emboss = 0.05, padding=0.1}, nodes={
				{n=G.UIT.O, config = {align = "lm", object = dropoff, colour = G.C.BLACK},},
			}},
			{n=G.UIT.C, config={align = "cm"}, nodes={
				{n=G.UIT.R, config={align = "cl", r = 0.1, colour = HEX("2c2c3c2f"), emboss = 0.05,padding=0.1, minw=7}, nodes={
					{n=G.UIT.C, config={align = "cl", r = 0.1, colour = G.C.BLACK, emboss = 0.05,padding=0.1, minw=4.5, minh = 2.5}, nodes={
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Weight: ", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
							{n=G.UIT.T, config = {align="tm", ref_table=current_crafting_state, ref_value="weight", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
						}},
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Size: ", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
							{n=G.UIT.T, config = {align="tm", ref_table=current_crafting_state, ref_value="size", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
						}},
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Sell Price: ", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
							{n=G.UIT.T, config = {align="tm", ref_table=current_crafting_state, ref_value="money", colour = G.C.MONEY, scale = 0.5}},
						}},
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Equation: ⌈", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
							{n=G.UIT.T, config = {align="tm", text="(R + ((W / M) * 4) + mult ) * 4(xmult))", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
							{n=G.UIT.T, config = {align="tm", text="⌉", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
						}},
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="M=", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
							{n=G.UIT.T, config = {align="tm", ref_table=current_crafting_state, ref_value="M", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
						}},
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="R=", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
							{n=G.UIT.T, config = {align="tm", ref_table=current_crafting_state, ref_value="R", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
						}},
						{n=G.UIT.R, config={align = "cl"}, nodes={
							{n=G.UIT.T, config = {align="tm", text="W=", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
							{n=G.UIT.T, config = {align="tm", ref_table=current_crafting_state, ref_value="W", colour = G.C.UI.TEXT_DARK, scale = 0.25}},
						}},
					}},
					{n=G.UIT.C, config={align = "cm",padding=0.1}, nodes={
						{n=G.UIT.R, config={align = "cm",padding=0.1, colour = G.C.RED, button="bgf_fish_delete", r=0.1}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Delete", colour = G.C.UI.TEXT_LIGHT, scale = 0.5}},
						}},
						{n=G.UIT.R, config={align = "cm",padding=0.1, colour = in_shop and G.C.GOLD or HEX("5c5c5c2f"), button=in_shop and "bgf_fish_sell" or nil, r=0.1, tooltip = not in_shop and {title=localize("bgf_shop_required")} or nil}, nodes={
							{n=G.UIT.T, config = {align="tm", text="Sell", colour = in_shop and G.C.UI.INACTIVE or G.C.UI.TEXT_DARK, scale = 0.5}},
						}},
					}},
				}}
			}}
		  }},
      }})
    return t
end



local waveParticleAt = function(x, y, speed)
	speed = speed or 1
	-- local wave_sprites = {
	-- 	Sprite(0,0,16/20,16/20, FishingMod.Minigame16, {x=8,y=0}), -- s
	-- 	Sprite(0,0,16/20,16/20, FishingMod.Minigame16, {x=9,y=0}), -- m
	-- 	Sprite(0,0,16/20,16/20, FishingMod.Minigame16, {x=10,y=0}), -- l
	-- 	Sprite(0,0,16/20,16/20, FishingMod.Minigame16, {x=11,y=0}),-- b
	-- }
	local wave_sprite_pos_l = {
		{x=8, y=0},
		{x=9, y=0},
		{x=10, y=0},
		{x=11, y=0},
	}
	local wave_sprite = Sprite(0,0,16/20,16/20, FishingMod.Minigame16, {x=8,y=0})
	wave_sprite.T.x = x - 5/20
	wave_sprite.T.y = y - 1/20
	wave_sprite.VT.x = x - 5/20
	wave_sprite.VT.y = y - 1/20
	new 'FaeLib.Task'(function(self)
		wave_sprite:set_sprite_pos(wave_sprite_pos_l[1])
	end, false, 0.1 * speed):and_then(function (self)
		wave_sprite:set_sprite_pos(wave_sprite_pos_l[2])
	end, false, 0.2 * speed):and_then(function (self)
		wave_sprite:set_sprite_pos(wave_sprite_pos_l[3])
	end, false, 0.3 * speed):and_then(function (self)
		wave_sprite:set_sprite_pos(wave_sprite_pos_l[4])
	end, false, 0.4 * speed):manual_run():with_id("bgf_fa_wave_particle"):with_data(wave_sprite)
end
function randomSign()
    return math.random(0, 1) == 0 and -1 or 1
end


local casting_area_definition = function (casting_area_objects)
	local ORIGIN = FaeLib.scaleXY(G.ROOM.T.x,G.ROOM.T.y)
	local UNIT = FaeLib.scaleXY(1,1)
	local fish = Sprite(0,0,1,1, FishingMod.Minigame16, {x=4,y=0})
	fish.visible = false
	local backg_sprite = Sprite(0, 0, 4, 4, FishingMod.Minigame64, {x=0,y=0})
	local backg_sprite_over = Sprite(0, 0, 4, 4, FishingMod.Minigame64, {x=0,y=1})
	local bobber_sprite_upper = Sprite(0,0,6/20,9/20, FishingMod.Minigame6x9, {x=19,y=0})
	local bobber_sprite_lower = Sprite(0,0,6/20,9/20, FishingMod.Minigame6x9, {x=20,y=0})
	local can_bob = false
	local bobber_sprite = bobber_sprite_upper
	local holder = Moveable{
		T={
			x = 0,
			y = 0,
			w = 4,
			h = 4
		}
	}
	holder.Translation = {x=0,y=0}
    holder.jiggle = 0
    holder.states.drag.can = false
    holder:set_container(holder)
	local bgDraw = holder.draw
	holder.states.hover.can = true
	holder.states.collide.can = true
	local bobber = FishingMod.fishing_minigame.fishing_area.bobber
	local time_until_bob = 0
	local bob_state = false
	local bob_tries = 0
	local time_since_last_peep = 0
	local fishie_bob_tries = 0
	bobber.can_cast = true
	bobber.has_fish = false
	FaeLib.V.TaskClearForId("bgf_fa_wave_particle")
	holder.draw = function(self)
		-- G.CONTROLLER.focused.target = self
		local d = love.timer.getDelta()
		time_since_last_peep = time_since_last_peep + d
		bgDraw(self)
		-- cast_tooltip_text:draw()
		love.graphics.push()
		love.graphics.setColor(1,1,1,1)
		self.VT.x = self.T.x
		self.VT.y = self.T.y
		-- self.VT.r = love.timer.getTime()
		local xo = FaeLib.scaleXY(self.T.x+self.VT.x,0).x
		local yo = FaeLib.scaleXY(self.T.y+self.VT.y,0).x
		local bgs = FaeLib.scaleXY(4,0).x
		local bobber_size = FaeLib.unScaleXY(6,9)
		local bounds = {x=xo,y=yo,w=bgs, h=bgs}
		local mx,my = love.mouse.getPosition()
		love.graphics.pop()
		love.graphics.push()
		
		local hovering_area = false
		for i, k in ipairs(G.CONTROLLER.collision_list) do
			if k == G.OVERLAY_MENU then
				hovering_area = true
				break
			end
		end
		backg_sprite.T = self.T
		backg_sprite.VT = self.VT
		backg_sprite_over.T = self.T
		backg_sprite_over.VT = self.VT
		backg_sprite:draw({1,1,1,1})
		local maxDistance = 1.25
		local fishDstToBobber = FaeLib.Distance(bobber_sprite.T.x, bobber_sprite.T.y, fish.T.x + (1/4), fish.T.y + (1/4))
		if fishDstToBobber < maxDistance and not fish.override_a then
			local t = fishDstToBobber / maxDistance
			fish.a = FaeLib.lerp(0.5, 0, t)
		end
		local isFishLeftOfBobber = fish.T.x + (3/20) < bobber_sprite.T.x
		fish:set_sprite_pos(isFishLeftOfBobber and {x=5,y=0} or {x=4,y=0})
		if fish.visible then 
			fish:draw({1,1,1,fish.a or 0})
			fish.dt = math.min(1.1, (fish.dt or 0) + (d / 1.25 * (FishingMod.SelectedBait.attract_speed or 1)))
			fish.T.x = FaeLib.smoothstep((fish.T.ox or 0), bobber_sprite.T.x, (fish.dt or 0))
			fish.T.y = FaeLib.smoothstep((fish.T.oy or 0), bobber_sprite.T.y, (fish.dt or 0))
			fish.VT.x = fish.T.x
			fish.VT.y = fish.T.y
			if bobber.has_fish and time_since_last_peep > (FishingMod.SelectedBait.linger_seconds or 2.5) then
				fish.override_a = true
				fish.can_be_fished = false
				bobber.can_cast = true
				bobber.has_fish = false
				time_since_last_peep = 0
				new 'FaeLib.Task'(function (task)
					fish.a = FaeLib.lerp(fish.a, 0, d * 8)
					fish.override_a = true
					if fish.a <= 0.1 then
						fish.visible = false
						fish.dt = 0
						fish.override_a = false
					end
				end, false, 2):start()
			end

		end
		backg_sprite:draw({1,1,1,0.3})
		FaeLib.Builtin.ExecTasksForId("bgf_fa_wave_particle", d)
		for key, value in pairs(FaeLib.Builtin.GetTasksForId("bgf_fa_wave_particle")) do
			value.data:draw()
		end
		bobber_sprite.T.x = self.T.x + 2 - bobber_sprite.T.w/2 + bobber.x
		bobber_sprite.T.y = self.T.y + 2 - bobber_sprite.T.h/2 + bobber.y
		bobber_sprite.VT.x = self.T.x + 2 - bobber_sprite.T.w/2+ bobber.x
		bobber_sprite.VT.y = self.T.y + 2 - bobber_sprite.T.h/2+ bobber.y
		if bobber.visible then bobber_sprite:draw({1,1,1,1}) end
		bobber.x = bobber.x or 0
		bobber.y = bobber.y or 0
		bobber.vx = bobber.vx or 0
		bobber.vy = bobber.vy or 0
		bobber.x = FaeLib.smoothstep(bobber.x, (bobber.x + (bobber.vx or 0) * 200) / 20, d)
		bobber.y = FaeLib.smoothstep(bobber.y, (bobber.y + (bobber.vy or 0)* 200) / 20, d)
		bobber.vx = FaeLib.smoothstep(bobber.vx, 0, d)
		bobber.vy = FaeLib.smoothstep(bobber.vy, 0, d)
		bobber.has_fish = (fishDstToBobber < 0.5) and fish.visible and fish.a > 0.3
		if not bobber.has_fish then
			time_since_last_peep = 0
		end
		if time_until_bob < 0 and can_bob then
			if bob_state then
				bobber_sprite = bobber_sprite_upper
			else
				bobber_sprite = bobber_sprite_lower
				waveParticleAt(bobber_sprite.T.x, bobber_sprite.T.y)
			end
			
			-- if bobber.has_fish then
			-- 	bobber.x = bobber.x + math.random(-10,10)/200
			-- 	bobber.y = bobber.y + math.random(-10,10)/200
			-- end
			
			if not bobber.has_fish then
				bobber.vx = 0
				bobber.vy = 0
			end
			bob_state = not bob_state
			time_until_bob = math.random(20,35) * 0.05
			bob_tries = bob_tries + 1
			if bobber.has_fish then
				bob_state = false
				time_until_bob = math.random(1,3) * 0.2
			end
		end
		if bobber.x ~= bobber.x then
			bobber.x = 0
		end
		if bobber.y ~= bobber.y then
			bobber.y = 0
		end
		time_until_bob = time_until_bob - love.timer.getDelta()
		-- if hovering_area then
		if FaeLib.Mouse.was_pressed(1) or (G.CONTROLLER.held_buttons["a"] and bobber.can_cast) then
			can_bob = false
			if bobber.has_fish then
				bobber.can_cast = true
				bobber.has_fish = false
				G.FUNCS.exit_overlay_menu()
				-- FishingMod.fishing_minigame.uibox:remove()
				FishingMod.fishing_minigame.uibox = nil
				FishingMod.fishing_minigame.uibox = FishingMod.create_UIBox_fishing_minigame_screen_reeling_area()
				G.FUNCS.overlay_menu({
					definition = FishingMod.fishing_minigame.uibox
				})
				FaeLib.V.TaskClearForId("bgf_fa_wave_particle")
			elseif bobber.can_cast then
				bobber.can_cast = false
				bobber.splash_visible = false
				bobber.visible = true
				can_bob = false
				time_until_bob = 9999
				bobber.can_cast = false
				fish.override_a = false
				fish.visible = false
				local cst_x = math.random() * 4 - 2
				local cst_y = math.random() * 4 - 2
				cst_x = math.min(1, math.max(-1, cst_x))
				cst_y = math.min(1, math.max(-1, cst_y))
				new 'FaeLib.Tweener'(
					{"x", "y"},
					bobber,
					0.4,
					FaeLib.Interpolation.easeOutBack,
					{x=0, y=3},
					{x=cst_x, y=cst_y - 2/10},
					true
				):after(function ()
					print("A?")
					bobber.can_cast = true
					play_sound("bgf_splash_0"..math.random(1,3), math.random(6,8)/10, 0.3)
					self.splash_visible = true
					self.land_time = love.timer.getTime()
					time_until_bob = 0.1
					can_bob = true
					fishie_bob_tries = 0
					bob_tries = 0
					bobber.has_fish = false
					bobber.visible = true
					bob_state= true
					fish.visible = true
					fish.a = 0
					fish.track_time = math.random(10/20) * 0.1
					local minDistance = 1.1
					local maxDistance = 2.5 -- Adjust if needed
					local distance = math.random(minDistance, maxDistance)
					local dx = randomSign() * math.random(minDistance, maxDistance)
					local dy = randomSign() * math.random(minDistance, maxDistance)
					fish.T.x = self.T.x + dx + 2
					fish.T.y = self.T.y + dy + 2
					fish.T.ox = self.T.x + dx + 2
					fish.T.oy = self.T.y + dy + 2
					fish.VT.x = self.T.x + dx + 2
					fish.VT.y = self.T.y + dy + 2
					waveParticleAt(bobber_sprite.T.x, bobber_sprite.T.y)
				end):run()
			end
		end
			love.graphics.setColor(1,0,0,1)
		-- end
		love.graphics.pop()
	end
	return {n = G.UIT.ROOT, config = {r = 0.1, align = "cm", padding = 0.2, colour = G.C.BLACK, focus_args = {button = 'a', orientation = 'bm'}}, nodes = {
		{n=G.UIT.C, config={colour=G.C.CLEAR, padding=0}, nodes = {{n=G.UIT.O, config={object = holder, colour=G.C.CLEAR}}}},
	}}
end
FaeLib.UI.DrawLine = function(from, to, colour, width)
	local sc1 = FaeLib.scaleXY(from.x, from.y)
	local sc2 = FaeLib.scaleXY(to.x, to.y)
	love.graphics.setLineWidth(width or 2)
	love.graphics.setColor(colour[1], colour[2], colour[3], colour[4])
	love.graphics.line(sc1.x, sc1.y, sc2.x, sc2.y)
end
local reeling_area_definition = function(reeling_area_objects)
	
	local holder = Moveable{
		T={
			x = 0,
			y = 0,
			w = 3,
			h = 7
		}
	}
	local bar_holder = Moveable{
		T={
			x = 0,
			y = 0,
			w = 1,
			h = 7
		}
	}
	local progress_holder = Moveable{
		T={
			x = 0,
			y = 0,
			w = 1,
			h = 7
		}
	}
	holder.Translation = {x=0,y=0}
    holder.jiggle = 0
    holder.states.drag.can = false
    holder:set_container(holder)
	local bgDraw = holder.draw
	holder.states.hover.can = true
	holder.states.collide.can = true
	local fish = Sprite(0,0,1,1, FishingMod.Minigame16, {x=4,y=0})
	local hook = Sprite(0,0,1,1, FishingMod.Minigame16, {x=5,y=1})
	local mini_bobber = Sprite(0,0,1,1, FishingMod.Minigame16, {x=4,y=1})
	
	fish:set_sprite_pos(fish.facing_left and {x=5,y=0} or {x=4,y=0})
	local water_fg = Sprite(0,0,4,4, FishingMod.Minigame64, {x=0,y=1})
	local water_fg2 = Sprite(0,0,4,4, FishingMod.Minigame64, {x=0,y=2})
	local bar_upper = Sprite(0,0,1,1, FishingMod.Minigame16, {x=5,y=2})
	local bar_lower = Sprite(0,0,1,1, FishingMod.Minigame16, {x=5,y=3})
	local target_bar = Sprite(0,0,1,1, FishingMod.Minigame16, {x=4,y=2})
	local time_since_move = 999999
	local barColour = HEX("c6cfd6")
	local bar_offset = 0
	local progress = 0
	local coyote = 0
	fish.facing_left = true
	holder.draw = function(self)
		local dt = love.timer.getDelta()
		time_since_move = time_since_move + dt
		love.graphics.push()
		water_fg.T.x = self.T.x
		water_fg.T.y = self.T.y
		water_fg2.T.x = self.T.x
		water_fg2.T.y = self.T.y + 4
		water_fg2.STATIONARY = true
		water_fg.STATIONARY = true
		water_fg.VT.x = self.T.x
		water_fg.VT.y = self.T.y
		water_fg2.VT.x = self.T.x
		water_fg2.VT.y = self.T.y + 4
		bgDraw(self)
		mini_bobber.VT = mini_bobber.T
		mini_bobber.T.x = self.T.x + 1
		mini_bobber.T.y = self.T.y + (math.floor((math.sin(love.timer.getTime()) +(math.cos((love.timer.getTime() + 0.333) * 0.1) * 2)) * 5) / 5 / 20) - (2/20)
		if time_since_move > 1.5 then
			if math.random(0,10) < 6 then
				time_since_move = time_since_move - 0.25
			else
				local oldoff = fish.offset.x
				fish.offset.x = (math.random() * 2 - 1)
				fish.offset.y = (math.random() * 2 - 1) * 2.5 + (3/20)
				time_since_move = 0
				
				local lft = oldoff >= fish.offset.x
				fish.facing_left = lft
				fish:set_sprite_pos(fish.facing_left and {x=4,y=0} or {x=5,y=0})
				hook:set_sprite_pos(fish.facing_left and {x=5,y=1} or {x=6,y=0})
			end

		end
		if fish.T.x == 0 then
			fish.T.x = self.T.x + 1
			fish.T.y = self.T.y+ 3
		end
		fish.T.x = FaeLib.Interpolation.easeOutBack(fish.T.x, math.floor((self.T.x + 1 + math.max(-0.9, math.min(0.9, fish.offset.x))) * 20) / 20, dt * 0.3)
		fish.T.y = FaeLib.Interpolation.easeOutBack(fish.T.y, math.floor((self.T.y + 3 + fish.offset.y) * 20) / 20, dt * 0.3)
		fish.VT = fish.T
		hook.T.y = fish.T.y + 5/20
		hook.VT = hook.T
		local lineEndPos = {x=fish.facing_left and (fish.VT.x + (1/20)) or (fish.VT.x + 1 - (2/20)), y=fish.VT.y + (6/20)}
		
		hook.T.x = fish.facing_left and (lineEndPos.x - (1/20)) or (lineEndPos.x - (2/20))
		love.graphics.setLineWidth(2)
		FaeLib.UI.DrawLine({x=self.T.x+1.5, y = self.T.y + (2/20)}, lineEndPos, {0.75,0.75,0.75,1})
		hook:draw({1,1,1,1})
		fish:draw({1,1,1,1})
		water_fg:draw({1,1,1,1})
		water_fg2:draw({1,1,1,1})
		mini_bobber:draw({1,1,1,1})
		love.graphics.pop()
	end
	local oldbardraw = bar_holder.draw
	bar_holder.draw = function (self)
		local dt = love.timer.getDelta()
		oldbardraw(self)
		local bar_width = 0.25 -- atm, no rods give a larger bar width. TODO: change this lol
		if G.CONTROLLER.held_buttons["a"] or love.mouse.isDown(1) or love.keyboard.isDown("space") then
			bar_offset = bar_offset + (FishingMod.FishingRod.ability.extra.speed or 1) * (dt * 0.85)
		else
			-- print("G:"..FishingMod.FishingRod.ability.extra.gravity)
			bar_offset = bar_offset - (FishingMod.FishingRod.ability.extra.gravity or 1) * dt
		end
		bar_offset = math.min(1, math.max(0, bar_offset))
		bar_upper.T.x = self.T.x
		bar_upper.T.y = self.T.y  + (math.min((19.5/20 - (bar_width / 8)), math.max((0.25/20), FaeLib.lerp(1, 0, bar_offset))) * 7) - 1
		bar_lower.T.x = bar_upper.T.x
		bar_lower.T.y = bar_upper.T.y + bar_width + 1
		bar_lower.T.y = bar_upper.T.y + bar_width + 1
		bar_lower.VT = bar_lower.T
		bar_upper.VT = bar_upper.T


		target_bar.T.x = bar_upper.T.x
		target_bar.VT = target_bar.T
		target_bar.T.y = fish.T.y
		target_bar:draw({1,1,1,1})
	
		love.graphics.push()
		love.graphics.setColor(barColour[1],barColour[2],barColour[3],1)
		love.graphics.rectangle("fill", (bar_upper.VT.x)* G.TILESIZE*G.TILESCALE, (bar_upper.VT.y+ 1) * G.TILESIZE*G.TILESCALE, G.TILESIZE*G.TILESCALE, bar_width * G.TILESIZE*G.TILESCALE)
		love.graphics.pop()
		bar_upper:draw({1,1,1,1})
		bar_lower:draw({1,1,1,1})
		if target_bar.T.y > (bar_upper.T.y + (5/20)) and target_bar.T.y < (bar_lower.T.y - (5/20)) then
			-- print("Reeling..")
			coyote = 0.075
			progress = progress + (dt / 1.25) * (FishingMod.FishingRod.ability.extra.reel_speed or 1)
		elseif coyote > 0 then
			coyote = coyote - dt
			progress = progress + (dt / 1.25) * (FishingMod.FishingRod.ability.extra.reel_speed or 1)
		else
			progress = progress - (dt * 0.75)
		end
		progress = math.max(0, math.min(1,progress))
	end
	local oldprogdraw = progress_holder.draw
	local progbar_upper = Sprite(0,0,1,1, FishingMod.Minigame16, {x=5,y=2})
	local progbar_lower = Sprite(0,0,1,1, FishingMod.Minigame16, {x=5,y=3})
	local progress_filled_time = 0
	progress_holder.draw = function(self)
		oldprogdraw(self)
		local dt = love.timer.getDelta()
		progbar_upper.T.x = self.T.x
		progbar_lower.T.y = self.T.y + self.T.h
		progbar_lower.T.x = progbar_upper.T.x
		progress = math.min(progress, 1)
		progbar_upper.T.y = self.T.y + (self.T.h - 1) - (progress * 7)
		progbar_lower.VT = progbar_lower.T
		progbar_upper.VT = progbar_upper.T
		progbar_upper:draw({0.75,0.75,0.75,1})
		progbar_lower:draw({0.75,0.75,0.75,1})
		love.graphics.push()
		love.graphics.setColor(barColour[1] * 0.75,barColour[2] * 0.75,barColour[3] * 0.75,1)
		love.graphics.rectangle("fill", (progbar_lower.VT.x)* G.TILESIZE*G.TILESCALE, (progbar_lower.VT.y) * G.TILESIZE*G.TILESCALE, G.TILESIZE*G.TILESCALE, progress * -7 * G.TILESIZE*G.TILESCALE)
		love.graphics.pop()

		if progress >= 1 then
			progress_filled_time = progress_filled_time + dt
			if progress_filled_time > 0.1 then
				play_sound("tarot1", 1, 2)
				G.FUNCS.exit_overlay_menu()
				print("exited")
				FishingMod.fishing_minigame.results_screen.has_fish = true
				-- Minigame finished
				if FishingMod.fishing_minigame.results_screen.uibox and FishingMod.fishing_minigame.results_screen.uibox.remove then
					FishingMod.fishing_minigame.results_screen.uibox:remove()
					FishingMod.fishing_minigame.results_screen.uibox = nil
				end
				print("creating result screen")
				print("created result screen")
				G.FUNCS.overlay_menu({
					definition = FishingMod.create_UIBox_result_screen("could_be_error")
				})
			end
		end
	end


	return {n = G.UIT.ROOT, config = {r = 0.1, align = "cm", padding = 0.2, colour = G.C.CLEAR, focus_args = {button = 'a', orientation = 'bm'}}, nodes = {
		{n=G.UIT.R, config={align="bm",colour=G.C.CLEAR, padding=0.1}, nodes = {
			{n=G.UIT.C, config={emboss = 0.05, colour=G.C.BLACK, padding=0,minw=1,minh=7, r=0.1}, nodes = {
				{n=G.UIT.O, config={object = progress_holder, colour=G.C.GREEN}}
			}},
			{n=G.UIT.C, config={colour=HEX("005da4"), padding=0, r=0.1,minh=7}, nodes = {
				{n=G.UIT.O, config={object = holder, colour=G.C.CLEAR}}
			}},
			{n=G.UIT.C, config={emboss = 0.05, colour=G.C.BLACK, padding=0,minw=1,minh=7, r=0.1}, nodes = {
				{n=G.UIT.O, config={object = bar_holder, colour=G.C.CLEAR}}
			}}
		}},
	}}
end

FishingMod.initFishingMinigameSprites = function ()
	
	FishingMod.MinigameSprites = FishingMod.MinigameSprites or {}
	FishingMod.MinigameSprites.FISH_L = Sprite(0,0,1,1, FishingMod.Minigame16, {x=4,y=0})
	FishingMod.MinigameSprites.FISH_R = Sprite(0,0,1,1, FishingMod.Minigame16, {x=5,y=0})
	FishingMod.MinigameSprites.HOOK = Sprite(0,0,1,1, FishingMod.Minigame16, {x=5,y=1})
	FishingMod.MinigameSprites.MBL = Sprite(0,0,1,1, FishingMod.Minigame16, {x=6,y=1})
	FishingMod.MinigameSprites.SPC = Sprite(0,0,1,1, FishingMod.Minigame16, {x=7,y=1})
	FishingMod.MinigameSprites.UPARROW = Sprite(0,0,1,1, FishingMod.Minigame16, {x=8,y=1})
end
FishingMod.create_UIBox_fishing_minigame_screen_casting_area = function ()
	FishingMod.initFishingMinigameSprites()
	local casting_area_objects = {}
	local casting_area = UIBox{
		definition=casting_area_definition(casting_area_objects),
		config = {
			type="cm"
		}
	}
    local uibox= (create_UIBox_generic_options({
		back_func = "bgf_fishing_screen_exit",
        contents = {
			{n=G.UIT.R, config={align="cm"}, nodes = {
				{n=G.UIT.C, config={colour=G.C.CLEAR, padding=0.1}, nodes = {
					{n=G.UIT.O, config={object=casting_area, colour = G.C.CLEAR}}
				}}
			}}
		}
	}))
	return uibox
end
FishingMod.create_UIBox_fishing_minigame_screen_reeling_area = function ()
	FishingMod.initFishingMinigameSprites()
	local casting_area_objects = {}
	local casting_area = UIBox{
		definition=reeling_area_definition(casting_area_objects),
		config = {
			type="cm"
		}
	}
    local uibox= (create_UIBox_generic_options({
		back_func = "bgf_fishing_screen_exit",
        contents = {
			{n=G.UIT.R, config={align="cm"}, nodes = {
				{n=G.UIT.C, config={colour=G.C.CLEAR, padding=0.1}, nodes = {
					{n=G.UIT.O, config={object=casting_area, colour = G.C.CLEAR}}
				}}
			}}
		}
	}))
	return uibox
end