/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = MECHA_RANGED
	origin_tech = "materials=3;combat=3"
	var/projectile
	var/fire_sound
	var/size=0
	var/projectiles_per_shot = 1
	var/variance = 0
	var/randomspread = 0 //use random spread for machineguns, instead of shotgun scatter
	var/projectile_delay = 0
	var/projectiles
	var/projectile_energy_cost

/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(obj/mecha/combat/M as obj)
	if(..())
		if(istype(M))
			if(size > M.maxsize)
				return FALSE
			return TRUE
		else if(M.emagged)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/proc/get_shot_amount()
	return projectiles_per_shot

/obj/item/mecha_parts/mecha_equipment/weapon/get_destroy_sound()
	return chassis.weapdestrsound

/obj/item/mecha_parts/mecha_equipment/weapon/action(target, params)
	if(!action_checks(target))
		return

	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if(!targloc || !istype(targloc) || !curloc)
		return
	if(targloc == curloc)
		return

	set_ready_state(0)
	for(var/i=1 to get_shot_amount())
		var/obj/item/projectile/A = new projectile(curloc)
		A.firer = chassis.occupant
		A.firer_source_atom = src
		A.original = target
		A.current = curloc

		var/spread = 0
		if(variance)
			if(randomspread)
				spread = round((rand() - 0.5) * variance)
			else
				spread = round((i / projectiles_per_shot - 0.5) * variance)
		A.preparePixelProjectile(target, chassis.occupant, params2list(params), spread)

		chassis.use_power(energy_drain)
		projectiles--
		A.fire()
		playsound(chassis, fire_sound, 50, 1)

		sleep(max(0, projectile_delay))
	set_ready_state(0)
	log_message("Fired from [name], targeting [target].")
	add_attack_logs(chassis.occupant, target, "fired a [src]")
	do_after_cooldown()
/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "general energy weapon"
	size = 2

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	equip_cooldown = 0.8 SECONDS
	name = "\improper CH-PS \"Firedart\" Laser"
	icon_state = "mecha_firedart"
	origin_tech = "magnets=3;combat=3;engineering=3"
	energy_drain = 30
	projectile = /obj/item/projectile/beam
	fire_sound = 'sound/weapons/laser.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler
	equip_cooldown = 0.8 SECONDS
	name = "\improper CH-DS \"Peacemaker\" disabler"
	desc = "A weapon for combat exosuits. Shoots basic disablers."
	icon_state = "mecha_disabler"
	energy_drain = 30
	projectile = /obj/item/projectile/beam/disabler
	fire_sound = 'sound/weapons/taser2.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	equip_cooldown = 1 SECONDS
	name = "\improper CH-LC \"Solaris\" Laser Cannon"
	icon_state = "mecha_solaris"
	origin_tech = "magnets=4;combat=4;engineering=3"
	energy_drain = 60
	projectile = /obj/item/projectile/beam/laser/heavylaser
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/shotgun_disabler
	equip_cooldown = 2 SECONDS
	name = "MESG-01 Disabler Scattercannon"
	desc = "A large-bore energy shotgun, configured to fire a large blast of disabling pellets."
	icon_state = "mecha_disabler_shotgun"
	origin_tech = "materials=4;combat=5;"
	energy_drain = 30 // This is per shot + 1x cost, so 300 per shot
	projectile = /obj/item/projectile/beam/disabler/pellet
	projectiles_per_shot = 9
	variance = 40
	fire_sound = 'sound/weapons/taser2.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	equip_cooldown = 4 SECONDS
	name = "mkIV Ion Heavy Scatter Cannon"
	desc = "An ion shotgun, that when fired gives the mecha a second of EMP shielding with the excess energy from the discharge."
	icon_state = "mecha_ion"
	origin_tech = "materials=4;combat=5;magnets=4"
	energy_drain = 215 // This is per shot + 1x cost, so ~1500 per shotgun shot
	projectile = /obj/item/projectile/ion/weak
	projectiles_per_shot = 6
	variance = 40
	fire_sound = 'sound/weapons/ionrifle.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion/action()
	chassis.emp_proof = TRUE
	addtimer(VARSET_CALLBACK(chassis, emp_proof, FALSE), 1 SECONDS)
	return ..()

/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	equip_cooldown = 3.5 SECONDS
	name = "\improper P-X Tesla Cannon"
	desc = "A weapon for combat exosuits. Fires bolts of electricity similar to the experimental tesla engine."
	icon_state = "mecha_teslacannon"
	origin_tech = "materials=4;engineering=4;combat=6;magnets=6"
	energy_drain = 500
	projectile = /obj/item/projectile/energy/tesla_bolt
	fire_sound = 'sound/magic/lightningbolt.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray
	equip_cooldown = 3.5 SECONDS
	name = "\improper S-1 X-Ray Projector"
	desc = "A weapon for combat exosuits. Fires beams of X-Rays that pass through solid matter."
	icon_state = "mecha_xray"
	origin_tech = "materials=3;combat=5;magnets=2;syndicate=2"
	energy_drain = 80
	projectile = /obj/item/projectile/beam/xray
	fire_sound = 'sound/weapons/laser3.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray/triple
	name = "\improper X-XR Triple-barrel X-Ray Stream Projector"
	projectiles_per_shot = 3
	projectile_delay = 1

/obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator
	equip_cooldown = 3.5 SECONDS
	name = "\improper ZFI Immolation Beam Gun"
	desc = "A weapon for combat exosuits. Fires beams of extreme heat that set targets on fire."
	icon_state = "mecha_immolator"
	origin_tech = "materials=4;engineering=4;combat=6;magnets=6"
	energy_drain = 80
	projectile = /obj/item/projectile/beam/immolator
	fire_sound = 'sound/weapons/laser3.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	equip_cooldown = 3 SECONDS
	name = "eZ-13 mk2 Heavy Pulse Rifle"
	icon_state = "mecha_pulse"
	energy_drain = 120
	origin_tech = "materials=3;combat=6;powerstorage=4"
	projectile = /obj/item/projectile/beam/pulse/hitscan/heavy
	fire_sound = 'sound/weapons/marauder.ogg'
	harmful = TRUE


/obj/item/projectile/beam/pulse/hitscan/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20


/obj/item/projectile/beam/pulse/hitscan/heavy/Bump(atom/A)
	A.bullet_act(src, def_zone)
	life -= 10
	if(ismob(A))
		var/mob/M = A
		if(ismob(firer))
			add_attack_logs(firer, M, "Mecha-shot with <b>[src]</b>")
		else
			add_attack_logs(src, M, "Mecha-shot with <b>[src]</b> (no firer)")
	if(life <= 0)
		qdel(src)


/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	equip_cooldown = 0.8 SECONDS
	name = "\improper PBT \"Pacifier\" Mounted Taser"
	icon_state = "mecha_taser"
	origin_tech = "combat=3"
	energy_drain = 20
	projectile = /obj/item/projectile/energy/electrode
	fire_sound = 'sound/weapons/taser.ogg'
	size = 1

/obj/item/mecha_parts/mecha_equipment/weapon/honker
	equip_cooldown = 15 SECONDS
	name = "\improper HoNkER BlAsT 5000"
	icon_state = "mecha_honker"
	energy_drain = 200
	range = MECHA_MELEE | MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/weapon/honker/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/honker/action(target, params)
	if(!chassis)
		return
	if(energy_drain && chassis.get_charge() < energy_drain)
		return
	if(!equip_ready)
		return

	playsound(chassis, 'sound/items/airhorn.ogg', 100, 1)
	chassis.occupant_message("<font color='red' size='5'>HONK</font>")
	for(var/mob/living/carbon/M in ohearers(6, chassis))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
				continue
		to_chat(M, "<font color='red' size='7'>HONK</font>")
		M.SetSleeping(0)
		M.Stuttering(40 SECONDS)
		M.Deaf(30 SECONDS)
		M.KnockDown(6 SECONDS)
		M.Jitter(40 SECONDS)
		///else the mousetraps are useless
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(isobj(H.shoes) && !(H.shoes.flags & NODROP))
				var/thingy = H.shoes
				H.drop_item_to_ground(thingy)
				GLOB.move_manager.move_away(thingy, chassis, 15, 2, timeout=20)
	for(var/obj/mecha/combat/reticence/R in oview(6, chassis))
		R.occupant_message("\The [R] has protected you from [chassis]'s HONK at the cost of some power.")
		R.use_power(R.get_charge() / 4)

	chassis.use_power(energy_drain)
	log_message("Honked from [name]. HONK!")
	var/turf/T = get_turf(src)
	add_attack_logs(chassis.occupant, target, "used a Mecha Honker", ATKLOG_MOST)
	log_game("[key_name(chassis.occupant)] used a Mecha Honker in [T.x], [T.y], [T.z]")
	do_after_cooldown()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "general ballistic weapon"
	size = 2
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(atom/target)
	if(..())
		if(projectiles > 0)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_equip_info()
	return "[..()]\[[projectiles]\][(projectiles < initial(projectiles))?" - <a href='byond://?src=[UID()];rearm=1'>Rearm</a>":null]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/rearm()
	if(projectiles < initial(projectiles))
		var/projectiles_to_add = initial(projectiles) - projectiles
		while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
			projectiles++
			projectiles_to_add--
			chassis.use_power(projectile_energy_cost)
	send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
	log_message("Rearmed [name].")
	playsound(src, 'sound/weapons/gun_interactions/rearm.ogg', 50, 1)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Topic(href, href_list)
	if(..())
		return
	if(href_list["rearm"])
		rearm()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	equip_cooldown = 0.5 SECONDS
	name = "\improper FNX-66 Carbine"
	icon_state = "mecha_carbine"
	origin_tech = "materials=4;combat=4"
	projectile = /obj/item/projectile/bullet/incendiary/shell/dragonsbreath
	fire_sound = 'sound/weapons/gunshots/gunshot_rifle.ogg'
	projectiles = 24
	projectile_energy_cost = 15
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	equip_cooldown = 1.5 SECONDS
	name = "\improper S.H.H. \"Quietus\" Carbine"
	fire_sound = 'sound/weapons/gunshots/gunshot_silenced.ogg'
	icon_state = "mecha_mime"
	projectile = /obj/item/projectile/bullet/mime/nonlethal
	projectiles = 20
	projectile_energy_cost = 50

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced/can_attach(obj/mecha/combat/reticence/M as obj)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "\improper LBX AC 10 \"Scattershot\""
	icon_state = "mecha_scatter"
	origin_tech = "combat=4"
	projectile = /obj/item/projectile/bullet/midbullet2
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	projectiles = 40
	projectile_energy_cost = 25
	projectiles_per_shot = 4
	variance = 25
	harmful = TRUE
	equip_cooldown = 2 SECONDS

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/syndie //Version used for Dark Gygax
	name = "\improper LBX AC 20-r \"Scattershot .45\""
	origin_tech = "combat=4;syndicate=2" //Crew is not going to get it normally anyways
	projectile = /obj/item/projectile/bullet/midbullet

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	equip_cooldown = 1 SECONDS
	name = "\improper Ultra AC 2"
	icon_state = "mecha_uac2"
	origin_tech = "combat=4"
	projectile = /obj/item/projectile/bullet/weakbullet3
	fire_sound = 'sound/weapons/gunshots/gunshot_mg.ogg'
	projectiles = 300
	projectile_energy_cost = 20
	projectiles_per_shot = 3
	variance = 6
	projectile_delay = 2
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/dual
	name = "\improper XMG-9 Autocannon"
	projectiles_per_shot = 6

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	equip_cooldown = 6 SECONDS
	name = "\improper SRM-8 Light Missile Rack"
	icon_state = "mecha_missilerack_six"
	origin_tech = "combat=5;materials=4;engineering=4"
	projectile = /obj/item/projectile/missile/light
	fire_sound = 'sound/effects/bang.ogg'
	projectiles = 6
	projectile_energy_cost = 1000
	var/missile_speed = 2
	var/missile_range = 30
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy
	name = "\improper SRX-13 Heavy Missile Launcher"
	icon_state = "mecha_missilerack"
	projectile = /obj/item/projectile/missile
	projectiles = 9

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	name = "\improper SGL-6 Flashbang Launcher"
	icon_state = "mecha_grenadelnchr"
	origin_tech = "combat=4;engineering=4"
	projectile = /obj/item/grenade/flashbang
	missile_speed = 1.5
	projectile_energy_cost = 800
	var/det_time = 20
	size=1
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/grenade/flashbang/F = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	F.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [name], targeting [target].")
	spawn(det_time)
		F.prime()
	do_after_cooldown()

//Because I am a heartless bastard -Sieve
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang
	equip_cooldown = 9 SECONDS
	name = "\improper SOB-3 Clusterbang Launcher"
	desc = "A weapon for combat exosuits. Launches primed clusterbangs. You monster."
	origin_tech = "combat=4;materials=4"
	projectiles = 3
	projectile = /obj/item/grenade/clusterbuster
	projectile_energy_cost = 1600 //getting off cheap seeing as this is 3 times the flashbangs held in the grenade launcher.

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/get_equip_info()//Limited version of the clusterbang launcher that can't reload
	return "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;[chassis.selected==src?"<b>":"<a href='byond://?src=[chassis.UID()];select_equip=\ref[src]'>"][name][chassis.selected==src?"</b>":"</a>"]\[[projectiles]\]"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang/limited/rearm()
	return//Extra bit of security

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/cleaner
	name = "\improper N23 Rotary Janitation Launcher"
	desc = "A tool of mass cleaning. Launches primed cleaning foam grenades. Major slipping hazard."
	icon_state = "mecha_grenadelnchr"
	origin_tech = "combat=4;engineering=4"
	projectile = /obj/item/grenade/chem_grenade/cleaner
	missile_speed = 1.5
	size = 1
	/// Time until grenade detonates
	var/det_time = 2 SECONDS

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/cleaner/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/grenade/chem_grenade/cleaner/grenade = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, TRUE)
	grenade.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [name], targeting [target].")
	log_attack(chassis.occupant, target, "Cleaning grenade fired from [name], targeting [target].")
	addtimer(CALLBACK(grenade, TYPE_PROC_REF(/obj/item/grenade/chem_grenade/cleaner, prime)), det_time)
	do_after_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/cleaner/can_attach(obj/mecha/nkarrdem/M as obj)
	return istype(M) && length(M.equipment) < M.max_equip

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	equip_cooldown = 2 SECONDS
	name = "banana mortar"
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/grown/bananapeel
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/grown/bananapeel/B = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 60, 1)
	B.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Bananed from [name], targeting [target]. HONK!")
	do_after_cooldown()


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	equip_cooldown = 1 SECONDS
	name = "mousetrap mortar"
	icon_state = "mecha_mousetrapmrtr"
	projectile = /obj/item/assembly/mousetrap/armed
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/can_attach(obj/mecha/combat/honker/M as obj)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/assembly/mousetrap/armed/M = new projectile(chassis.loc)
	M.secured = TRUE
	playsound(chassis, fire_sound, 60, TRUE)
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Launched a mouse-trap from [name], targeting [target]. HONK!")
	do_after_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola
	equip_cooldown = 1 SECONDS
	name = "\improper PCMK-6 Bola Launcher"
	icon_state = "mecha_bola"
	origin_tech = "combat=4;engineering=4"
	projectile = /obj/item/restraints/legcuffs/bola
	fire_sound = 'sound/weapons/whip.ogg'
	projectiles = 10
	missile_speed = 1
	projectile_energy_cost = 50
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola/can_attach(obj/mecha/combat/gygax/M as obj)
	if(..())
		if(istype(M))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola/action(target, params)
	if(!action_checks(target))
		return
	set_ready_state(0)
	var/obj/item/restraints/legcuffs/bola/M = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	M.throw_at(target, missile_range, missile_speed)
	projectiles--
	log_message("Fired from [name], targeting [target].")
	do_after_cooldown()

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	equip_cooldown = 1 SECONDS
	name = "\improper 217-D Heavy Plasma Cutter"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demolishing solid obstacles."
	icon_state = "mecha_plasmacutter"
	item_state = "plasmacutter"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	energy_drain = 30
	origin_tech = "materials=3;plasmatech=4;engineering=3"
	projectile = /obj/item/projectile/plasma/adv/mech
	fire_sound = 'sound/weapons/laser.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/can_attach(obj/mecha/M)
	if(istype(M, /obj/mecha/working))
		if(length(M.equipment)<M.max_equip)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/mining_grenade
	name = "\improper \"Little boy\" Mining Grenade Launcher"
	icon_state = "mining_launcher"
	origin_tech = "combat=5;materials=4;engineering=4"
	projectile = /obj/item/projectile/bullet/reusable/mining_bomb/mecha
	fire_sound = 'sound/effects/bang.ogg'
	energy_drain = 150 // cost a lot, but powerful miner tool
	equip_cooldown = 2 SECONDS

/obj/item/mecha_parts/mecha_equipment/weapon/energy/mining_grenade/action()
	if(!lavaland_equipment_pressure_check(get_turf(chassis)))
		to_chat(chassis.occupant, "<span class='warning'>ERROR, OVER PRESSURE!</span>") // no station terror(yet)
		playsound(chassis.occupant, 'sound/weapons/gun_interactions/dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/weapon/energy/mining_grenade/can_attach(obj/mecha/M)
	if(istype(M, /obj/mecha/working))
		if(length(M.equipment) < M.max_equip)
			return TRUE
	return FALSE
