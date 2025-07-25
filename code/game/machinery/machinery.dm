
/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	pressure_resistance = 15
	max_integrity = 200
	layer = BELOW_OBJ_LAYER
	armor = list(melee = 25, bullet = 10, laser = 10, energy = 0, bomb = 0, rad = 0, fire = 50, acid = 70)
	atom_say_verb = "beeps"
	flags_ricochet = RICOCHET_HARD
	receive_ricochet_chance_mod = 0.3
	new_attack_chain = TRUE
	var/stat = 0

	/// How is this machine currently passively consuming power?
	var/power_state = IDLE_POWER_USE
	/// How much power does this machine consume when it is idling. This should not be set manually, use the helper procs!
	var/idle_power_consumption = 0
	/// How much power does this machine consume when it is in use. This should not be set manually, use the helper procs!
	var/active_power_consumption = 0
	/// The power channel this machine uses, idle/passive power consumption will pull from this channel and machine won't work if power channel has no power
	var/power_channel = PW_CHANNEL_EQUIPMENT
	/// The powernet this machine is connected to
	var/datum/local_powernet/machine_powernet = null
	/// Has power been initialized on this machine? Set in Initialize(), prevents all power updates to the local powernet until this is TRUE to avoid weird numbers.
	var/power_initialized = FALSE

	/// how badly will it shock you?
	var/siemens_strength = 0.7

	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/panel_open = FALSE
	var/interact_offline = FALSE // Can the machine be interacted with while de-powered.
	/// This is if the machinery is being repaired
	var/being_repaired = FALSE

	new_attack_chain = TRUE

/obj/machinery/Initialize(mapload)
	. = ..()
	SSmachines.register_machine(src)

	var/area/machine_area = get_area(src)
	if(machine_area)
		// areas don't always initialize before machines so we need to check to see if the powernet exists first
		if(machine_area.powernet)
			machine_powernet = machine_area.powernet
		else
			machine_powernet = machine_area.create_powernet()
		machine_powernet.register_machine(src)
		switch(power_state)
			if(IDLE_POWER_USE)
				_add_static_power(power_channel, idle_power_consumption)
			if(ACTIVE_POWER_USE)
				_add_static_power(power_channel, active_power_consumption)
		power_initialized = TRUE

	if(!speed_process)
		START_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSfastprocess, src)

	power_change()

// gotta go fast
/obj/machinery/makeSpeedProcess()
	if(speed_process)
		return
	speed_process = TRUE
	STOP_PROCESSING(SSmachines, src)
	START_PROCESSING(SSfastprocess, src)

// gotta go slow
/obj/machinery/makeNormalProcess()
	if(!speed_process)
		return
	speed_process = FALSE
	STOP_PROCESSING(SSfastprocess, src)
	START_PROCESSING(SSmachines, src)

/obj/machinery/Destroy()
	change_power_mode(NO_POWER_USE) //we want to clear our static power usage on the local powernet
	machine_powernet?.unregister_machine(src)
	SSmachines.unregister_machine(src)
	if(!speed_process)
		STOP_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
	return ..()

// This needs to die
/obj/machinery/proc/locate_machinery()
	return

/obj/machinery/process() // If you dont use process or power why are you here
	return PROCESS_KILL

////POWER RELATED PROCS

// returns true if the area has power on given channel (or doesn't require power).
// defaults to power_channel
/obj/machinery/proc/has_power(channel = power_channel) // defaults to power_channel
	if(interact_offline)
		return TRUE
	if(!machine_powernet)
		return FALSE
	return machine_powernet.has_power(channel)	// return power status of the area

// use active power from the local powernet
/obj/machinery/proc/use_power(amount, channel)
	if(!has_power() || !power_initialized)
		return FALSE
	if(!channel)
		channel = power_channel
	return machine_powernet.use_active_power(channel, amount)

/// Helper proc to positively adjust static power tracking on the machine's powernet, not meant for general use!
/obj/machinery/proc/_add_static_power(channel, amount)
	PRIVATE_PROC(TRUE)
	machine_powernet?.adjust_static_power(channel, amount)

/// Helper proc to negatively adjust static power tracking on the machine's powernet, not meant for general use!
/obj/machinery/proc/_remove_static_power(channel, amount)
	PRIVATE_PROC(TRUE)
	machine_powernet?.adjust_static_power(channel, -amount)

/*
	* # power_change()
	*
	* Checks to see if the machines set power channel is powered and updates stat accordingly
	* returns TRUE if machine's stat changes, returns FALSE if it does not, this is to make sure machines dont
	* update their icon/overlays/lighting uneccesarily if it's contigent on NOPOWER
	*
	* NOTE:Subtypes of machinery should call parent here unless they change this proc's behaviour regarding NOPOWER
*/
/obj/machinery/proc/power_change()
	var/old_stat = stat
	if(has_power(power_channel) || interact_offline) //if we don't require power, we don't give a shit about the power channel!
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	return old_stat != stat //performance saving for machines that use power_change() to update icons!

/obj/machinery/proc/reregister_machine()
	if(machine_powernet?.powernet_area != get_area(src))
		var/area/machine_area = get_area(src)
		if(machine_area)
			var/old_power_mode = power_state
			change_power_mode(NO_POWER_USE) // Take away our current power from the old network
			machine_powernet?.unregister_machine(src)
			machine_powernet = machine_area.powernet
			machine_powernet.register_machine(src)
			change_power_mode(old_power_mode) // add it to the new network

/// Helper proc to change the machines power usage mode, automatically adjusts static power usage to maintain perfect parity
/obj/machinery/proc/change_power_mode(use_type = IDLE_POWER_USE)
	if(isnull(use_type) || use_type == power_state || !machine_powernet || !power_channel) //if there is no powernet/channel, just end it here
		return
	if(!power_initialized)
		return FALSE // we set static power values in Initialize(), do not update static consumption until after initialization or you will get weird values on powernet
	switch(power_state)
		if(IDLE_POWER_USE)
			_remove_static_power(power_channel, idle_power_consumption)
		if(ACTIVE_POWER_USE)
			_remove_static_power(power_channel, active_power_consumption)

	switch(use_type)
		if(IDLE_POWER_USE)
			_add_static_power(power_channel, idle_power_consumption)
		if(ACTIVE_POWER_USE)
			_add_static_power(power_channel, active_power_consumption)

	power_state = use_type

/// Safely changes the static power on the local powernet based on an adjustment in idle power
/obj/machinery/proc/update_idle_power_consumption(channel = power_channel, amount)
	if(!power_initialized)
		return FALSE // we set static power values in Initialize(), do not update static consumption until after initialization or you will get weird values on powernet
	if(power_state == IDLE_POWER_USE)
		machine_powernet.adjust_static_power(power_channel, amount - idle_power_consumption)
	idle_power_consumption = amount

/// Safely changes the static power on the local powernet based on an adjustment in active power
/obj/machinery/proc/update_active_power_consumption(channel = power_channel, amount)
	if(!power_initialized)
		return FALSE // we set static power values in Initialize(), do not update static consumption until after initialization or you will get weird values on powernet
	if(power_state == ACTIVE_POWER_USE)
		machine_powernet.adjust_static_power(power_channel, amount - active_power_consumption)
	active_power_consumption = amount

/obj/machinery/default_welder_repair(mob/user, obj/item/I)
	. = ..()
	if(.)
		stat &= ~BROKEN

// This proc is only staying because of the fingerprint adding
// IT NEEDS TO DIE
/obj/machinery/Topic(href, href_list, nowindow = 0, datum/ui_state/state = GLOB.default_state)
	if(..(href, href_list, nowindow, state))
		return 1

	add_fingerprint(usr)
	return 0

/obj/machinery/proc/operable(additional_flags = 0)
	return !inoperable(additional_flags)

/obj/machinery/proc/inoperable(additional_flags = 0)
	return ((!interact_offline && (stat & NOPOWER)) || (stat & (BROKEN|additional_flags)))

/obj/machinery/ui_status(mob/user, datum/ui_state/state)
	if(!is_operational())
		return UI_CLOSE

	return ..()

/obj/machinery/proc/dropContents()//putting for swarmers, occupent code commented out, someone can use later.
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(T)

////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/attack_ai(mob/user)
	if(isrobot(user))// For some reason attack_robot doesn't work
		var/mob/living/silicon/robot/R = user
		if(R.client && R.client.eye == R && !R.low_power_mode)// This is to stop robots from using cameras to remotely control machines; and from using machines when the borg has no power.
			return attack_hand(user)
	else
		return attack_hand(user)

/obj/machinery/attack_hand(mob/user as mob)
	if(try_attack_hand(user))
		return TRUE

	add_fingerprint(user)

	return ..()

/**
  * Preprocess machinery interaction.
  *
  * If overriding and extending interaction limitations, better call this with ..()
  * unless you really know what you are doing.
  *
  * Returns TRUE when interaction is done due to different limitations and nothing should be done next.
  * Returns FALSE when interaction can be continued.
  * Arguments:
  * * user - the mob interacting with this machinery
  */
/obj/machinery/proc/try_attack_hand(mob/user)
	if(user.incapacitated() && !isobserver(user))
		return TRUE

	if(!user.IsAdvancedToolUser() && !isobserver(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60)
			visible_message("<span class='warning'>[H] stares cluelessly at [src].</span>")
			return TRUE
		else if(prob(H.getBrainLoss()))
			to_chat(user, "<span class='warning'>You momentarily forget how to use [src].</span>")
			return TRUE

	if(panel_open)
		if(!isobserver(user))
			add_fingerprint(user)
		return FALSE

	if(!is_operational())
		return TRUE

	return FALSE

/obj/machinery/proc/is_operational()
	return !inoperable(MAINT)

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshParts()

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		on_deconstruction()
		if(component_parts && length(component_parts))
			spawn_frame(disassembled)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
			component_parts.Cut()
	qdel(src)

/obj/machinery/proc/spawn_frame(disassembled)
	var/obj/structure/machine_frame/M = new /obj/structure/machine_frame(loc)
	. = M
	M.anchored = anchored
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)
	M.state = 2
	M.icon_state = "box_1"

/obj/machinery/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		stat |= BROKEN

/obj/machinery/proc/default_deconstruction_crowbar(user, obj/item/I, ignore_panel = 0)
	if(I.tool_behaviour != TOOL_CROWBAR)
		return FALSE
	if(!I.use_tool(src, user, 0, volume = 0))
		return FALSE
	if((panel_open || ignore_panel) && !(flags & NODECONSTRUCT))
		deconstruct(TRUE)
		to_chat(user, "<span class='notice'>You disassemble [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
		return TRUE
	return FALSE

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(I.tool_behaviour != TOOL_SCREWDRIVER)
		return FALSE
	if(!I.use_tool(src, user, 0, volume = 0))
		return FALSE
	if(!(flags & NODECONSTRUCT))
		if(!panel_open)
			panel_open = TRUE
			icon_state = icon_state_open
			to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
		else
			panel_open = FALSE
			icon_state = icon_state_closed
			to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
		return 1
	return 0

/obj/machinery/proc/default_change_direction_wrench(mob/user, obj/item/I)
	if(I.tool_behaviour != TOOL_WRENCH)
		return FALSE
	if(!I.use_tool(src, user, 0, volume = 0))
		return FALSE
	if(panel_open)
		dir = turn(dir,-90)
		to_chat(user, "<span class='notice'>You rotate [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
		return TRUE
	return FALSE

/obj/machinery/default_unfasten_wrench(mob/user, obj/item/I, time)
	. = ..()
	if(.)
		reregister_machine()
		power_change()

/obj/machinery/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(exchange_parts(user, used))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/N = used
		if(stat & BROKEN)
			to_chat(user, "<span class='notice'>[src] is too damaged to be fixed with nanopaste!</span>")
			return ITEM_INTERACT_COMPLETE

		if(obj_integrity == max_integrity)
			to_chat(user, "<span class='notice'>[src] is fully intact.</span>")
			return ITEM_INTERACT_COMPLETE

		if(being_repaired)
			return ITEM_INTERACT_COMPLETE

		if(N.get_amount() < 1)
			to_chat(user, "<span class='warning'>You don't have enough to complete this task!</span>")
			return ITEM_INTERACT_COMPLETE

		to_chat(user, "<span class='notice'>You start applying [used] to [src].</span>")
		being_repaired = TRUE
		var/result = do_after(user, 3 SECONDS, target = src)
		being_repaired = FALSE
		if(!result)
			return ITEM_INTERACT_COMPLETE

		if(!N.use(1))
			to_chat(user, "<span class='warning'>You don't have enough to complete this task!</span>") // this is here, as we don't want to use nanopaste until you finish applying
			return ITEM_INTERACT_COMPLETE

		obj_integrity = min(obj_integrity + 50, max_integrity)
		user.visible_message("<span class='notice'>[user] applied some [used] at [src]'s damaged areas.</span>",\
			"<span class='notice'>You apply some [used] at [src]'s damaged areas.</span>")

		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/proc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	var/shouldplaysound = 0
	if(flags & NODECONSTRUCT)
		return FALSE

	if(!istype(W) || !component_parts)
		return FALSE

	if(panel_open || W.works_from_distance)
		var/obj/item/circuitboard/CB = locate(/obj/item/circuitboard) in component_parts
		var/P
		if(W.works_from_distance)
			to_chat(user, display_parts(user))
		for(var/obj/item/stock_parts/A in component_parts)
			for(var/D in CB.req_components)
				if(ispath(A.type, D))
					P = D
					break
			for(var/obj/item/stock_parts/B in W.contents)
				if(istype(B, P) && istype(A, P))
					//If it's cell - check: 1) Max charge is better? 2) Max charge same but current charge better? - If both NO -> next content
					if(ispath(B.type, /obj/item/stock_parts/cell))
						var/obj/item/stock_parts/cell/tA = A
						var/obj/item/stock_parts/cell/tB = B
						if(!(tB.maxcharge > tA.maxcharge) && !((tB.maxcharge == tA.maxcharge) && (tB.charge > tA.charge)))
							continue
					//If it's not cell and not better -> next content
					else if(B.rating <= A.rating)
						continue
					W.remove_from_storage(B, src)
					W.handle_item_insertion(A, user, TRUE)
					component_parts -= A
					component_parts += B
					B.loc = null
					to_chat(user, "<span class='notice'>[A.name] replaced with [B.name].</span>")
					shouldplaysound = TRUE
					break
		for(var/obj/item/reagent_containers/glass/beaker/A in component_parts)
			for(var/obj/item/reagent_containers/glass/beaker/B in W.contents)
				// If it's not better -> next content
				if(B.reagents.maximum_volume <= A.reagents.maximum_volume)
					continue
				W.remove_from_storage(B, src)
				W.handle_item_insertion(A, user, TRUE)
				component_parts -= A
				component_parts += B
				B.loc = null
				to_chat(user, "<span class='notice'>[A.name] replaced with [B.name].</span>")
				shouldplaysound = TRUE
				break
		RefreshParts()
	else
		to_chat(user, display_parts(user))
	if(shouldplaysound)
		W.play_rped_sound()
	return TRUE

/obj/machinery/proc/display_parts(mob/user)
	. = list("<span class='notice'>Following parts detected in the machine:</span>")
	for(var/obj/item/C in component_parts)
		. += "<span class='notice'>[bicon(C)] [C.name]</span>"
	. = jointext(., "\n")

/obj/machinery/examine(mob/user)
	. = ..()
	if(stat & BROKEN)
		. += "<span class='notice'>It looks broken and non-functional.</span>"
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(resistance_flags & ON_FIRE)
			. += "<span class='warning'>It's on fire!</span>"
		var/healthpercent = (obj_integrity/max_integrity) * 100
		switch(healthpercent)
			if(50 to 99)
				. +=  "It looks slightly damaged."
			if(25 to 50)
				. +=  "It appears heavily damaged."
			if(0 to 25)
				. +=  "<span class='warning'>It's falling apart!</span>"
	if(user.research_scanner && component_parts)
		. += display_parts(user)

/obj/machinery/proc/on_assess_perp(mob/living/carbon/human/perp)
	return 0

/obj/machinery/proc/is_assess_emagged()
	return emagged

/obj/machinery/proc/assess_perp(mob/living/carbon/human/perp, check_access, auth_weapons, check_records, check_arrest)
	var/threatcount = 0	//the integer returned

	if(is_assess_emagged())
		return 10	//if emagged, always return 10.

	threatcount += on_assess_perp(perp)
	if(threatcount >= 10)
		return threatcount

	//Agent cards lower threatlevel.
	var/obj/item/card/id/id = perp.get_id_card()
	if(id && istype(id, /obj/item/card/id/syndicate))
		threatcount -= 2
	// A proper	CentCom id is hard currency.
	else if(id && istype(id, /obj/item/card/id/centcom))
		threatcount -= 2

	if(check_access && !allowed(perp))
		threatcount += 4

	if(auth_weapons && (!id || !(ACCESS_WEAPONS in id.access)))
		if(isitem(perp.l_hand) && perp.l_hand.needs_permit)
			threatcount += 4
		if(isitem(perp.r_hand) && perp.r_hand.needs_permit)
			threatcount += 4
		if(isitem(perp.belt) && perp.belt.needs_permit)
			threatcount += 4

	if(check_records || check_arrest)
		var/perpname = perp.get_visible_name(TRUE)

		var/datum/data/record/R = find_security_record("name", perpname)
		if(check_records && !R)
			threatcount += 4

		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if(SEC_RECORD_STATUS_EXECUTE)
					threatcount += 7
				if(SEC_RECORD_STATUS_ARREST)
					threatcount += 5

	return threatcount


/obj/machinery/proc/shock(mob/living/user, prb)
	if(!istype(user) || inoperable())
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, 1, src)
	if(electrocute_mob(user, get_area(src), src, siemens_strength, TRUE))
		return TRUE
	return FALSE

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/on_construction()
	return

/obj/machinery/proc/on_deconstruction()
	return

/obj/machinery/emp_act(severity)
	if(power_state && !stat)
		use_power(7500/severity)
		. = TRUE
	..()

/obj/machinery/zap_act(power, zap_flags)
	if(prob(85) && (zap_flags & ZAP_MACHINE_EXPLOSIVE) && !(resistance_flags & INDESTRUCTIBLE))
		explosion(src, 1, 2, 4, flame_range = 2, adminlog = FALSE, smoke = FALSE, cause = "Random Zap Explosion")
	else if(zap_flags & ZAP_OBJ_DAMAGE)
		take_damage(power * 0.0005, BURN, ENERGY)
		if(prob(40))
			emp_act(EMP_LIGHT)
		power -= power * 0.0005
	return ..()

/obj/machinery/proc/adjust_item_drop_location(atom/movable/AM)	// Adjust item drop location to a 3x3 grid inside the tile, returns slot id from 0 to 8
	var/md5 = md5(AM.name)										// Oh, and it's deterministic too. A specific item will always drop from the same slot.
	for(var/i in 1 to 32)
		. += hex2num(md5[i])
	. = . % 9
	AM.pixel_x = -8 + ((.%3)*8)
	AM.pixel_y = -8 + (round( . / 3)*8)

/**
 * Makes sure the user is allowed to interact with the machine when they use a shortcut, like Control or Alt-clicking.
 *
 * Arguments:
 * * user - the mob who is trying to interact with the machine.
 */
/obj/machinery/proc/can_use_shortcut(mob/living/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(ishuman(user) && in_range(src, user))
		return TRUE
	if(issilicon(user))
		return TRUE
	return FALSE


/*
 * reimp, attempts to flicker this machinery if the behavior is supported.
 */
/obj/machinery/get_spooked()
	return flicker()

/*
 * Base class, attempt to flicker. Returns TRUE if we complete our 'flicker
 * behavior', false otherwise.
 */
/obj/machinery/proc/flicker()
	return FALSE

/obj/machinery/fall_and_crush(turf/target_turf, crush_damage, should_crit, crit_damage_factor, datum/tilt_crit/forced_crit, weaken_time, knockdown_time, ignore_gravity, should_rotate, angle, rightable, block_interactions)
	. = ..(target_turf, crush_damage, should_crit, crit_damage_factor, forced_crit, weaken_time, knockdown_time, ignore_gravity = FALSE, should_rotate = TRUE, rightable = TRUE, block_interactions_until_righted = TRUE)
