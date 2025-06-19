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

FishingMod.card_collection_UIBox_rod_inventory = function(_pool, rows, args)
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
		c.states.hover.can = true
		c.bgf_index = #(FishingMod.Baits or {})+1
		c.stack_count = FishingMod.SelectedBait.count or 1
		-- local oldcard_update = c.update
		-- c.update = function (self, dt)
		-- 	oldcard_update(self,dt)
		-- 	FishingMod.bait_dropoff.cards = FishingMod.bait_dropoff.cards or {}
		-- 	if c.states.drag.was_2f then
		-- 		-- small edge case where the baits don't properly stack
		-- 		if FishingMod.bait_dropoff.cards[1] and FishingMod.bait_dropoff.cards[1].states.hover.is and c.area == bait_area and FishingMod.bait_dropoff.cards[1].config.center_key == c.config.center_key then
		-- 			FishingMod.bait_dropoff.cards[1].stack_count = (FishingMod.bait_dropoff.cards[1].stack_count or 1) + (c.stack_count or 1)
		-- 			FishingMod.bait_dropoff.cards[1]:juice_up()
		-- 			c:remove()
					
		-- 			for index, value in ipairs(bait_area.cards) do
		-- 				FishingMod.Baits[index] = {
		-- 					key = value.config.center_key,
		-- 					count = value.stack_count
		-- 				}
		-- 			end
		-- 			G:save_progress()
		-- 		end
		-- 		if FishingMod.bait_dropoff.states.hover.is and c.area == bait_area and #FishingMod.bait_dropoff.cards == 0 then
		-- 			FishingMod.bait_dropoff:emplace(c)
		-- 			FishingMod.Baits = {}
		-- 			for index, value in ipairs(bait_area.cards) do
		-- 				FishingMod.Baits[index] = {
		-- 					key = value.config.center_key,
		-- 					count = value.stack_count
		-- 				}
		-- 			end
		-- 			G:save_progress()
					
		-- 		end
		-- 	end
		-- 	::continue::
		-- end
		FishingMod.bait_dropoff:emplace(c)
		
	end
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
	-- local oldhover = bait_area.update
	-- local area_frame = 0
	-- bait_area.update = function (self, dt)
	-- 	oldhover(self, dt)
	-- 	if FishingMod.bait_dropoff.cards[1] and self.states.collide.is and FishingMod.bait_dropoff.cards[1].states.drag.is then
	-- 		local card = FishingMod.bait_dropoff.cards[1]
	-- 		FishingMod.bait_dropoff:remove_card(card)
	-- 		self:emplace(card)
	-- 		if area_frame > 1 then
	-- 			FishingMod.Baits = {}
	-- 			for index, value in ipairs(bait_area.cards) do
	-- 				FishingMod.Baits[index] = {
	-- 					key = value.config.center_key,
	-- 					count = value.stack_count
	-- 				}
	-- 			end
	-- 		end
	-- 	end
	-- 	area_frame = area_frame+1
	-- end
	for index, value in ipairs(FishingMod.Baits) do
		if not G.P_CENTERS[value.key] or not value.key then
			print("Missing card for '"..(value.key or "missingkey").."'!")
		else
			local c = FaeLib.Builtin.CreateCard(value.key)
			c.states.collide.can = true
			c.states.hover.can = true
			c.bgf_index = index
			c.stack_count = value.count or 1
			local oldcard_update = c.update
			-- c.update = function (self, dt)
			-- 	oldcard_update(self,dt)
			-- 	FishingMod.bait_dropoff.cards = FishingMod.bait_dropoff.cards or {}
			-- 	if c.states.drag.was_2f then
			-- 		-- small edge case where the baits don't properly stack
			-- 		if FishingMod.bait_dropoff.cards[1] and FishingMod.bait_dropoff.cards[1].states.hover.is and c.area == bait_area and FishingMod.bait_dropoff.cards[1].config.center_key == c.config.center_key then
			-- 			FishingMod.bait_dropoff.cards[1].stack_count = (FishingMod.bait_dropoff.cards[1].stack_count or 1) + (c.stack_count or 1)
			-- 			FishingMod.bait_dropoff.cards[1]:juice_up()
			-- 			c:remove()
			-- 			FishingMod.Baits = {}
			-- 			for index, value in ipairs(bait_area.cards) do
			-- 				FishingMod.Baits[index] = {
			-- 					key = value.config.center_key,
			-- 					count = value.stack_count
			-- 				}
			-- 			end
			-- 			G:save_progress()
			-- 			goto continue
			-- 		end
			-- 		if FishingMod.bait_dropoff.states.hover.is and c.area == bait_area and #FishingMod.bait_dropoff.cards == 0 then
			-- 			FishingMod.bait_dropoff:emplace(c)
			-- 			bait_area:remove_card(c)
			-- 			FishingMod.Baits = {}
			-- 			for index, value in ipairs(bait_area.cards) do
			-- 				FishingMod.Baits[index] = {
			-- 					key = value.config.center_key,
			-- 					count = value.stack_count
			-- 				}
			-- 			end
			-- 			G:save_progress()
			-- 		end
			-- 	end
			-- 	::continue::
			-- end
			-- bait_area:emplace(c)
		end
	end
	FishingMod.bait_area.states.collide.can = true
	FishingMod.bait_dropoff.states.collide.can = true
	FishingMod.bait_dropoff.states.hover.can = true
	if FishingMod.FishingRod and G.P_CENTERS[FishingMod.FishingRod.key] then
		local fishing_rod_card = FaeLib.Builtin.CreateCard(FishingMod.FishingRod.key)
		FishingMod.dropoff:emplace(fishing_rod_card)
		fishing_rod_card.ability = FishingMod.FishingRod.ability or fishing_rod_card.ability
		fishing_rod_card.id = FishingMod.FishingRod.id
		fishing_rod_card.states.collide.can = true
		fishing_rod_card.states.hover.can = true
		fishing_rod_card.states.drag.can = true
		fishing_rod_card.states.click.can = true
		fishing_rod_card.need_update = true
		fishing_rod_card.edition = nil
	end
	for key, value in pairs(FishingMod.FishingRods) do
		local pool_obj = G.P_CENTERS[value.key]
		if not pool_obj then goto continue end
		pool_obj.ability = value.ability
		pool_obj.edition = nil
		pool_obj.cost = value.cost
		pool_obj.id = value.id
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
		local oldhover = G.your_collection[j].update
		-- G.your_collection[j].update = function (self, dt)
		-- 	oldhover(self, dt)
		-- 	if dropoff.cards[1] and self.states.collide.is and dropoff.cards[1].states.drag.is then
		-- 		local card = dropoff.cards[1]
		-- 		dropoff:remove_card(card)
		-- 		self:emplace(card)
		-- 		current_crafting_state.weight = "???"
		-- 		current_crafting_state.money = "$0"
		-- 		G.FUNCS.bgf_rod_move(nil, "inventory", card)
		-- 	end
		-- end
		table.insert(deck_tables, 
		{n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
			{n=G.UIT.O, config={object = G.your_collection[j]}}
		}})
    end

    local options = {}
    for i = 1, 2 do
        table.insert(options, localize('k_page')..' '..tostring(i)..'/'..tostring(2))
    end
    dropoff.states.hover.can = true
    dropoff.states.collide.can = true
    dropoff.states.release_on.can = true
	local olddropoff_update = dropoff.update
	dropoff.update = function (self, dt)
		olddropoff_update(self, dt)
	end
	
    G.FUNCS.SMODS_card_collection_page = function(e)
		pool = FishingMod.Fishies
        if not e or not e.cycle_config then return end
		-- if dropoff.cards[1] then 
		-- 	local c = dropoff:remove_card(dropoff.cards[1])
		-- 	c:remove()
		-- 	c = nil
		-- 	current_crafting_state.weight = "???"
		-- 	current_crafting_state.money = "$0"
		-- end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards, 1, -1 do
            local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
            c:remove()
            c = nil
            end
        end
		local currently_hovered_card = nil
        for j = 1, #rows do
			-- Pre-generated card from the dropoff needs to be changed!
			if dropoff.cards and dropoff.cards[1] and dropoff.cards[1].need_update then
				local dropoff_card = dropoff.cards[1]
				local doldcard_update = dropoff_card.update
				-- dropoff_card.update = function (self, dt)
				-- 	doldcard_update(self,dt)
				-- 	dropoff.cards = dropoff.cards or {}
				-- 	if self.states.drag.was_2f then
				-- 		if dropoff.states.hover.is and self.area == G.your_collection[j] and #dropoff.cards == 0 then
				-- 			print("Dropoff using oldcard.update")
				-- 			dropoff:emplace(self)
				-- 			G.your_collection[j]:remove_card(self)
				-- 			local weight = self.ability.weight
				-- 			current_crafting_state.weight = self.ability.weight
				-- 			current_crafting_state.money = "$"..4
				-- 			G.FUNCS.bgf_rod_move(nil, "dropoff", self)
				-- 		end
				-- 	end
				-- end
			end
            for i = 1, rows[j] do
				local center = FishingMod.FishingRods[i+row_totals[j] + (cards_per_page*(e.cycle_config.current_option - 1))]
				local index = i+row_totals[j] + (cards_per_page*(e.cycle_config.current_option - 1))
				-- print(index .. "of" .. #_pool)
				if not center then break end
				local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*args.card_scale, G.CARD_H*args.card_scale, G.P_CARDS.empty, G.P_CENTERS[center.key])
				card.ability = FishingMod.FishingRods[index].ability
				card.edition = FishingMod.FishingRods[index].edition
				card.bgf_index = index
				card.states.collide.can = true
				card.states.hover.can = true
				card.states.drag.can = true
				card.states.click.can = true
				local oldcard_update = card.update
				-- card.update = function (self, dt)
				-- 	oldcard_update(self,dt)
				-- 	dropoff.cards = dropoff.cards or {}
				-- 	if card.states.drag.was_2f then
				-- 		if dropoff.states.hover.is and card.area == G.your_collection[j] and #dropoff.cards == 0 then
				-- 			print("Dropoff using card.update")
				-- 			dropoff:emplace(card)
				-- 			G.your_collection[j]:remove_card(card)
				-- 			local weight = card.ability.weight
				-- 			current_crafting_state.weight = card.ability.weight
				-- 			current_crafting_state.money = "$"..4
				-- 			G.FUNCS.bgf_rod_move(nil, "dropoff", card)
				-- 		end
				-- 	end
				-- end
				if not args.no_materialize then card:start_materialize(nil, i>1 or j>1) end
				G.your_collection[j]:emplace(card)
            end
        end
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
						{n=G.UIT.R, config={align = "cm",padding=0.1, colour = in_shop and G.C.GOLD or HEX("5c5c5c2f"), button=(in_shop and FishingMod.dropoff.cards[1] and FishingMod.dropoff.cards[1].can_sell) and "bgf_rod_sell" or nil, r=0.1, tooltip = not in_shop and {title=localize("bgf_shop_required")} or nil}, nodes={
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
		FishingMod.FishingRod.id = card.id
	elseif where == "inventory" then
		FishingMod.FishingRods[#FishingMod.FishingRods+1] = FishingMod.FishingRod
		FishingMod.FishingRod = nil
	end
	G:save_progress()
	
end
G.FUNCS.bgf_rod_sell = function (e)
	if FishingMod.dropoff and FishingMod.dropoff.cards[1] and FishingMod.dropoff.cards[1].can_sell then
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
	if FishingMod.dropoff and FishingMod.dropoff.cards[1] and FishingMod.dropoff.cards[1].can_sell then
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
				return true
			end
		}))
		
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
                {card_limit = rows[j], type = 'title', highlight_limit = 1, collection = false, minh = args.h_mod*G.CARD_H, minw = 5 * args.w_mod*G.CARD_W}
            )
			G.your_collection[j].states.hover.can = true
			G.your_collection[j].states.collide.can = true
			local oldhover = G.your_collection[j].update
			G.your_collection[j].update = function (self, dt)
				oldhover(self, dt)
				if dropoff.cards[1] and self.states.collide.is and dropoff.cards[1].states.drag.is then
					local card = dropoff.cards[1]
					dropoff:remove_card(card)
					self:emplace(card)
					current_crafting_state.weight = "???"
					current_crafting_state.size = "???"
					current_crafting_state.money = "$0"
					current_crafting_state.R = "???"
					current_crafting_state.W = "???"
					current_crafting_state.M = "???"
				end
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
	local olddropoff_update = dropoff.update
	dropoff.update = function (self, dt)
		olddropoff_update(self, dt)
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
            c:remove()
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
				card.ability = FishingMod.Fishies[index].ability
				card.edition = FishingMod.Fishies[index].edition
				card.bgf_index = index
				card.states.collide.can = true
				card.states.hover.can = true
				card.states.drag.can = true
				card.states.click.can = true
				
				local oldcard_update = card.update
				card.update = function (self, dt)
					oldcard_update(self,dt)
					dropoff.cards = dropoff.cards or {}
					if card.states.drag.was_2f then
						if dropoff.states.hover.is and card.area == G.your_collection[j] and #dropoff.cards == 0 then
							-- print("Dropoff using card.update")
							dropoff:emplace(card)
							G.your_collection[j]:remove_card(card)
							local weight = card.ability.weight
							local medianWeight = G.P_CENTERS[card.config.center_key].config.extra.median_weight
    						local ratio = (weight / medianWeight) * 100
							local value = card.config.center:calculate_sell_value(card)
							current_crafting_state.weight = card.ability.weight
							current_crafting_state.size = localize(FishingMod.classifyWeight(weight, medianWeight))
							current_crafting_state.money = "$"..value
							current_crafting_state.R = card.config.center.rarity
							current_crafting_state.W = current_crafting_state.weight
							current_crafting_state.M = medianWeight
						end
					end
				end
				if not args.no_materialize then card:start_materialize(nil, i>1 or j>1) end
				G.your_collection[j]:emplace(card)
            end
        end
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