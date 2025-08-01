// Teleporter, Gravitational catapult, Armor booster modules,
// Repair droid, Tesla Energy relay, Generators

#define MECH_GRAVCAT_MODE_GRAVSLING 1
#define MECH_GRAVCAT_MODE_GRAVPUSH 2

////////////////////////////////////////////// TELEPORTER ///////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "mounted teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=7"
	equip_cooldown = 150
	energy_drain = 8000
	range = MECHA_RANGED
	var/tele_precision = 4

/obj/item/mecha_parts/mecha_equipment/teleporter/action(atom/target)
	if(!action_checks(target) || !is_teleport_allowed(loc.z))
		return
	var/turf/T = get_turf(target)
	if(T)
		chassis.use_power(energy_drain)
		do_teleport(chassis, T, tele_precision)
		return

/obj/item/mecha_parts/mecha_equipment/teleporter/precise
	name = "upgraded teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view. This is the high-precision, energy-efficient version."
	energy_drain = 1000
	tele_precision = 1

/////////////////////////////////////// GRAVITATIONAL CATAPULT ///////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/gravcatapult
	name = "mounted gravitational catapult"
	desc = "An exosuit mounted Gravitational Catapult."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=3;magnets=3;engineering=4"
	equip_cooldown = 10
	energy_drain = 100
	range = MECHA_MELEE | MECHA_RANGED
	var/atom/movable/locked
	var/cooldown_timer = 0
	var/mode = MECH_GRAVCAT_MODE_GRAVSLING

/obj/item/mecha_parts/mecha_equipment/gravcatapult/action(atom/movable/target)
	if(!action_checks(target))
		return
	if(cooldown_timer > world.time)
		occupant_message("<span class='warning'>[src] is still recharging.</span>")
		return
	switch(mode)
		if(MECH_GRAVCAT_MODE_GRAVSLING)
			if(!locked)
				if(!istype(target) || target.anchored)
					occupant_message("Unable to lock on [target]")
					return
				locked = target
				occupant_message("Locked on [target]")
				send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
			else if(target!=locked)
				if(locked in view(chassis))
					locked.throw_at(target, 14, 1.5)
					locked = null
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
					cooldown_timer = world.time + 3 SECONDS
					return 1
				else
					locked = null
					occupant_message("Lock on [locked] disengaged.")
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
		if(MECH_GRAVCAT_MODE_GRAVPUSH)
			var/list/atoms = list()
			if(isturf(target))
				atoms = range(3, target)
			else
				atoms = orange(3, target)
			for(var/atom/movable/A in atoms)
				if(A.anchored || A.move_resist == INFINITY) continue
				spawn(0)
					var/iter = 5-get_dist(A,target)
					for(var/i=0 to iter)
						step_away(A,target)
						sleep(2)
			var/turf/T = get_turf(target)
			cooldown_timer = world.time + 3 SECONDS
			log_game("[key_name(chassis.occupant)] used a Gravitational Catapult in ([T.x],[T.y],[T.z])")
			return


/obj/item/mecha_parts/mecha_equipment/gravcatapult/get_equip_info()
	return "[..()] [mode==1?"([locked||"Nothing"])":null] \[<a href='byond://?src=[UID()];mode=1'>S</a>|<a href='byond://?src=[UID()];mode=2'>P</a>\]"

/obj/item/mecha_parts/mecha_equipment/gravcatapult/Topic(href, href_list)
	if(..())
		return
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())

//////////////////////////// ARMOR BOOSTER MODULES //////////////////////////////////////////////////////////

/// what is that noise? A BAWWW from TK mutants.
/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	name = "armor booster module (Close combat weaponry)"
	desc = "Boosts exosuit armor against armed melee attacks. Requires energy to operate."
	icon_state = "mecha_abooster_ccw"
	origin_tech = "materials=4;combat=4"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8
	selectable = 0

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/proc/attack_react(mob/user as mob)
	if(action_checks(user))
		start_cooldown()
		return TRUE


/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	name = "armor booster module (Ranged weaponry)"
	desc = "Boosts exosuit armor against ranged attacks. Requires energy to operate."
	icon_state = "mecha_abooster_proj"
	origin_tech = "materials=4;combat=3;engineering=3"
	equip_cooldown = 10
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8
	selectable = 0

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/proc/projectile_react()
	if(action_checks(src))
		start_cooldown()
		return TRUE


////////////////////////////////// REPAIR DROID //////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "repair droid"
	desc = "Automated repair droid. Scans exosuit for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid_item"
	origin_tech ="magnets=3;programming=3;engineering=4"
	equip_cooldown = 20
	energy_drain = 50
	range = 0
	var/health_boost = 1
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)
	selectable = 0

/obj/item/mecha_parts/mecha_equipment/repair_droid/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(chassis)
		chassis.overlays -= droid_overlay
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/attach(obj/mecha/M)
	..()
	droid_overlay = new(icon, icon_state = "repair_droid_off")
	M.overlays += droid_overlay

/obj/item/mecha_parts/mecha_equipment/repair_droid/detach()
	chassis.overlays -= droid_overlay
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/get_equip_info()
	if(!chassis) return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp; [name] - <a href='byond://?src=[UID()];toggle_repairs=1'>[equip_ready?"A":"Dea"]ctivate</a>"


/obj/item/mecha_parts/mecha_equipment/repair_droid/Topic(href, href_list)
	if(..())
		return
	if(href_list["toggle_repairs"])
		chassis.overlays -= droid_overlay
		if(equip_ready)
			START_PROCESSING(SSobj, src)
			droid_overlay = new(icon, icon_state = "repair_droid_on")
			log_message("Activated.")
			set_ready_state(0)
		else
			STOP_PROCESSING(SSobj, src)
			droid_overlay = new(icon, icon_state = "repair_droid_off")
			log_message("Deactivated.")
			set_ready_state(1)
		chassis.overlays += droid_overlay
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())


/obj/item/mecha_parts/mecha_equipment/repair_droid/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
		set_ready_state(1)
		return
	var/h_boost = health_boost
	var/repaired = FALSE
	if(chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		h_boost = 0
		chassis.take_damage(2, BURN) //short circuiting droids do damage
		repaired = TRUE
	else if(chassis.internal_damage && prob(15))
		for(var/int_dam_flag in repairable_damage)
			if(chassis.internal_damage & int_dam_flag)
				chassis.clearInternalDamage(int_dam_flag)
				repaired = TRUE
				break
	if(chassis.obj_integrity < chassis.max_integrity && h_boost > 0)
		chassis.obj_integrity += min(h_boost, chassis.max_integrity-chassis.obj_integrity)
		repaired = TRUE
	if(repaired)
		if(!chassis.use_power(energy_drain))
			STOP_PROCESSING(SSobj, src)
			set_ready_state(1)
	else //no repair needed, we turn off
		STOP_PROCESSING(SSobj, src)
		set_ready_state(1)
		chassis.overlays -= droid_overlay
		droid_overlay = new(icon, icon_state = "repair_droid_off")
		chassis.overlays += droid_overlay

/////////////////////////////////// TESLA ENERGY RELAY ////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	name = "exosuit energy relay"
	desc = "An exosuit module that wirelessly drains energy from any available power channel in an area. The performance index barely compensates for movement costs."
	icon_state = "tesla"
	origin_tech = "magnets=4;powerstorage=4;engineering=4"
	range = 0
	var/coeff = 100
	var/list/use_channels = list(PW_CHANNEL_EQUIPMENT, PW_CHANNEL_ENVIRONMENT, PW_CHANNEL_LIGHTING)
	selectable = 0

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/detach()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_charge()
	if(equip_ready) //disabled
		return 0
	var/area/A = get_area(chassis)
	var/pow_chan = get_power_channel(A)
	if(pow_chan)
		return 1000 //making magic


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_power_channel(area/A)
	var/pow_chan
	if(A)
		for(var/c in use_channels)
			if(A.powernet.has_power(c))
				pow_chan = c
				break
	return pow_chan

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Topic(href, href_list)
	if(..())
		return
	if(href_list["toggle_relay"])
		if(equip_ready) //inactive
			START_PROCESSING(SSobj, src)
			set_ready_state(0)
			log_message("Activated.")
		else
			STOP_PROCESSING(SSobj, src)
			set_ready_state(1)
			log_message("Deactivated.")

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/get_equip_info()
	if(!chassis) return
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp; [name] - <a href='byond://?src=[UID()];toggle_relay=1'>[equip_ready?"A":"Dea"]ctivate</a>"


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/process()
	if(!chassis || chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		STOP_PROCESSING(SSobj, src)
		set_ready_state(1)
		return
	var/cur_charge = chassis.get_charge()
	if(isnull(cur_charge) || !chassis.cell)
		STOP_PROCESSING(SSobj, src)
		set_ready_state(1)
		occupant_message("No powercell detected.")
		return
	if(cur_charge < chassis.cell.maxcharge)
		var/area/A = get_area(chassis)
		if(A)
			var/pow_chan
			for(var/c in use_channels)
				if(A.powernet.has_power(c))
					pow_chan = c
					break
			if(pow_chan)
				var/delta = min(60, chassis.cell.maxcharge - cur_charge)
				chassis.give_power(delta)
				A.powernet.use_active_power(pow_chan, delta * coeff)

/////////////////////////////////////////// GENERATOR /////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/generator
	name = "exosuit plasma converter"
	desc = "An exosuit module that generates power using solid plasma as fuel. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = "plasmatech=2;powerstorage=2;engineering=2"
	var/coeff = 100
	var/fuel_type = MAT_PLASMA
	var/max_fuel = 150000 // 45k energy for 75 plasma/ 375 cr.
	var/fuel_name = "plasma" // Our fuel name as a string
	var/fuel_amount = 0
	var/fuel_per_cycle_idle = 10
	var/fuel_per_cycle_active = 500
	var/power_per_cycle = 150


/obj/item/mecha_parts/mecha_equipment/generator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/detach()
	STOP_PROCESSING(SSobj, src)
	..()

/obj/item/mecha_parts/mecha_equipment/generator/Topic(href, href_list)
	if(..())
		return
	if(href_list["toggle"])
		if(equip_ready) //inactive
			set_ready_state(0)
			START_PROCESSING(SSobj, src)
			log_message("Activated.")
		else
			set_ready_state(1)
			STOP_PROCESSING(SSobj, src)
			log_message("Deactivated.")

/obj/item/mecha_parts/mecha_equipment/generator/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[[fuel_name]: [round(fuel_amount,0.1)] cm<sup>3</sup>\] - <a href='byond://?src=[UID()];toggle=1'>[equip_ready?"A":"Dea"]ctivate</a>"

/obj/item/mecha_parts/mecha_equipment/generator/action(target)
	if(chassis)
		var/result = load_fuel(target)
		if(result)
			send_byjax(chassis.occupant,"exosuit.browser", "\ref[src]", get_equip_info())

/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(obj/item/I)
	if(istype(I) && (fuel_type in I.materials))
		if(!istype(I, /obj/item/stack/sheet)) // Some other object containing our fuel's type, so we just eat it (ores mainly)
			var/to_load = clamp(I.materials[fuel_type], 0, max_fuel - fuel_amount)
			if(to_load == 0)
				return FALSE
			fuel_amount += to_load
			qdel(I)
			return 0

		if(fuel_amount >= max_fuel)
			occupant_message("Unit is full.")
			return 0

		var/obj/item/stack/sheet/P = I
		var/to_load = max_fuel - fuel_amount

		var/units = clamp(round(to_load / P.perunit), 1, P.amount)
		if(units)
			var/added_fuel = units * P.perunit
			fuel_amount += added_fuel
			P.use(units)
			occupant_message("[units] unit\s of [fuel_name] successfully loaded.")
			return added_fuel

	else if(istype(I, /obj/structure/ore_box))
		var/fuel_added = 0
		for(var/obj/item/O as anything in I.contents)
			if(fuel_type in O.materials)
				fuel_added = load_fuel(O)
				break
		return fuel_added

	else
		occupant_message("<span class='warning'>[fuel_name] traces in target minimal! [I] cannot be used as fuel.</span>")
		return 0

/obj/item/mecha_parts/mecha_equipment/generator/attackby__legacy__attackchain(weapon,mob/user, params)
	load_fuel(weapon)

/obj/item/mecha_parts/mecha_equipment/generator/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
		set_ready_state(1)
		return
	if(fuel_amount<=0)
		STOP_PROCESSING(SSobj, src)
		log_message("Deactivated - no fuel.")
		set_ready_state(1)
		return
	var/cur_charge = chassis.get_charge()
	if(isnull(cur_charge))
		set_ready_state(1)
		occupant_message("No powercell detected.")
		log_message("Deactivated.")
		STOP_PROCESSING(SSobj, src)
		return
	var/use_fuel = fuel_per_cycle_idle
	if(cur_charge < chassis.cell.maxcharge)
		use_fuel = fuel_per_cycle_active
		chassis.give_power(power_per_cycle)
	fuel_amount -= min(use_fuel, fuel_amount)
	update_equip_info()


/obj/item/mecha_parts/mecha_equipment/generator/nuclear
	name = "exonuclear reactor"
	desc = "An exosuit module that generates power using uranium as fuel. Pollutes the environment."
	origin_tech = "powerstorage=4;engineering=4"
	fuel_name = "uranium" // Our fuel name as a string
	fuel_type = MAT_URANIUM
	max_fuel = 50000 // around 83k energy for 25 uranium/ 0 cr.
	fuel_per_cycle_active = 150
	power_per_cycle = 250
	var/rad_per_cycle = 120

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/process()
	if(..())
		radiation_pulse(get_turf(src), rad_per_cycle, BETA_RAD)

/obj/item/mecha_parts/mecha_equipment/thrusters
	name = "exosuit ion thrusters"
	desc = "Ion thrusters to be attached to an exosuit. Drains power even while not in flight."
	icon_state = "tesla"
	origin_tech = "powerstorage=4;engineering=4"
	range = 0
	energy_drain = 20
	selectable = FALSE

/obj/item/mecha_parts/mecha_equipment/thrusters/attach(obj/mecha/M)
	. = ..()
	START_PROCESSING(SSobj, src)
	M.add_thrusters()
	M.thruster_count++

/obj/item/mecha_parts/mecha_equipment/thrusters/detach(atom/moveto)
	chassis.thruster_count--
	chassis.remove_thrusters()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/thrusters/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
	if(!energy_drain || !chassis.thrusters_active)
		return
	chassis.use_power(energy_drain)

/obj/mecha/proc/add_thrusters()
	if(occupant)
		thrusters_action.Grant(occupant, src)

/obj/mecha/proc/remove_thrusters()
	if(occupant && !thruster_count)
		thrusters_action.Remove(occupant)

#undef MECH_GRAVCAT_MODE_GRAVSLING
#undef MECH_GRAVCAT_MODE_GRAVPUSH
