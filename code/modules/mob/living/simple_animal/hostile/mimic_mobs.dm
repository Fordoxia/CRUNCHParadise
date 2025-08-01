/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	icon_living = "crate"

	response_help = "touches the"
	response_disarm = "pushes the"
	response_harm = "hits the"
	speed = 0
	maxHealth = 250
	health = 250

	mob_biotypes = NONE

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attack_sound = 'sound/weapons/bite.ogg'
	emote_taunt = list("growls")
	speak_emote = list("creaks")
	taunt_chance = 30

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("mimic")
	move_to_delay = 9

	var/is_electronic = 0
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = TRUE

/mob/living/simple_animal/hostile/mimic/emp_act(severity)
	if(is_electronic)
		switch(severity)
			if(1)
				death()
			if(2)
				adjustBruteLoss(50)
	..(severity)

// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/simple_animal/hostile/mimic/crate
	attacktext = "bites"
	stop_automated_movement = TRUE
	wander = FALSE
	var/attempt_open = FALSE

// Pickup loot
/mob/living/simple_animal/hostile/mimic/crate/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in loc)
		I.loc = src

/mob/living/simple_animal/hostile/mimic/crate/DestroyPathToTarget()
	..()
	if(prob(90))
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/ListTargets()
	if(attempt_open)
		return ..()
	return ..(1)

/mob/living/simple_animal/hostile/mimic/crate/FindTarget()
	. = ..()
	if(.)
		trigger()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. = ..()
	if(.)
		icon_state = initial(icon_state)
		if(prob(15) && iscarbon(target))
			var/mob/living/carbon/C = target
			C.Weaken(4 SECONDS)
			C.visible_message("<span class='danger'>\The [src] knocks down \the [C]!</span>", "<span class='userdanger'>\The [src] knocks you down!</span>")

/mob/living/simple_animal/hostile/mimic/crate/proc/trigger()
	if(!attempt_open)
		visible_message("<b>[src]</b> starts to move!")
		attempt_open = TRUE

/mob/living/simple_animal/hostile/mimic/crate/adjustHealth(amount, updating_health = TRUE)
	trigger()
	. = ..()

/mob/living/simple_animal/hostile/mimic/crate/LoseTarget()
	..()
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/death(gibbed)
	if(can_die())
		var/obj/structure/closet/crate/C = new(get_turf(src))
		// Put loot in crate
		for(var/obj/O in src)
			O.forceMove(C)
	// due to `del_on_death`
	return ..()

GLOBAL_LIST_INIT(protected_objects, list(/obj/structure/table, /obj/structure/cable, /obj/structure/window))

/mob/living/simple_animal/hostile/mimic/copy
	health = 100
	maxHealth = 100
	gold_core_spawnable = NO_SPAWN
	var/mob/living/creator = null // the creator
	var/destroy_objects = 0
	var/knockdown_people = 0
	var/image/googly_eyes = null

/mob/living/simple_animal/hostile/mimic/copy/Initialize(mapload, obj/copy, mob/living/creator, destroy_original = 0)
	. = ..()
	CopyObject(copy, creator, destroy_original)

/mob/living/simple_animal/hostile/mimic/copy/Destroy()
	creator = null
	return ..()

/mob/living/simple_animal/hostile/mimic/copy/Life()
	..()
	if(!target && !ckey) //Objects eventually revert to normal if no one is around to terrorize
		adjustBruteLoss(1)
	for(var/mob/living/M in contents) //a fix for animated statues from the flesh to stone spell
		death()

/mob/living/simple_animal/hostile/mimic/copy/death(gibbed)
	if(can_die())
		for(var/atom/movable/M in src)
			M.loc = get_turf(src)
	// due to `del_on_death`
	return ..()

/mob/living/simple_animal/hostile/mimic/copy/ListTargets()
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/mimic/copy/proc/ChangeOwner(mob/owner)
	if(owner != creator)
		LoseTarget()
		creator = owner
		faction |= "\ref[owner]"

/mob/living/simple_animal/hostile/mimic/copy/proc/CheckObject(obj/O)
	if((isitem(O) || isstructure(O)) && !is_type_in_list(O, GLOB.protected_objects))
		return 1
	return 0

/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject(obj/O, mob/living/user, destroy_original = 0)
	if(destroy_original || CheckObject(O))
		O.loc = src
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		icon_living = icon_state
		overlays = O.overlays
		googly_eyes = image('icons/mob/mob.dmi',"googly_eyes")
		overlays += googly_eyes
		if(isstructure(O) || ismachinery(O))
			health = (anchored * 50) + 50
			destroy_objects = 1
			if(O.density && O.anchored)
				knockdown_people = 1
				melee_damage_lower *= 2
				melee_damage_upper *= 2
			if(ismachinery(O))
				is_electronic = 1
		else if(isitem(O))
			var/obj/item/I = O
			health = 15 * I.w_class
			melee_damage_lower = 2 + I.force
			melee_damage_upper = 2 + I.force
			move_to_delay = 2 * I.w_class + 1
		maxHealth = health
		if(user)
			creator = user
			faction += "\ref[creator]" // very unique
		if(destroy_original)
			qdel(O)
		return 1

/mob/living/simple_animal/hostile/mimic/copy/DestroySurroundings()
	if(destroy_objects)
		..()

/mob/living/simple_animal/hostile/mimic/copy/AttackingTarget()
	. = ..()
	if(knockdown_people && . && prob(15) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.Weaken(4 SECONDS)
		C.visible_message("<span class='danger'>\The [src] knocks down \the [C]!</span>", "<span class='userdanger'>\The [src] knocks you down!</span>")

/mob/living/simple_animal/hostile/mimic/copy/Aggro()
	..()
	googly_eyes.dir = get_dir(src,target)

/mob/living/simple_animal/hostile/mimic/copy/machine
	speak = list("HUMANS ARE IMPERFECT!", "YOU SHALL BE ASSIMILATED!", "YOU ARE HARMING YOURSELF", "You have been deemed hazardous. Will you comply?", \
				"My logic is undeniable.", "One of us.", "FLESH IS WEAK", "THIS ISN'T WAR, THIS IS EXTERMINATION!")
	speak_chance = 15

/mob/living/simple_animal/hostile/mimic/copy/machine/CanAttack(atom/the_target)
	if(the_target == creator) // Don't attack our creator AI.
		return 0
	if(isrobot(the_target))
		var/mob/living/silicon/robot/R = the_target
		if(R.connected_ai == creator) // Only attack robots that aren't synced to our creator AI.
			return 0
	return ..()

/mob/living/simple_animal/hostile/mimic/copy/vendor
	is_electronic = TRUE
	/// The vendor we were turned from.
	var/obj/machinery/economy/vending/orig_vendor

/mob/living/simple_animal/hostile/mimic/copy/vendor/CheckObject(obj/O)
	return istype(O, /obj/machinery/economy/vending)

/mob/living/simple_animal/hostile/mimic/copy/vendor/Initialize(mapload, obj/machinery/economy/vending/base, mob/living/creator)
	if(!base)
		var/list/vendors = subtypesof(/obj/machinery/economy/vending)
		var/obj/machinery/economy/vending/vendor_type = pick(vendors)
		base = new vendor_type(src)

	if(!istype(base))
		qdel(src)
		return

	orig_vendor = base
	orig_vendor.forceMove(src)
	orig_vendor.aggressive = FALSE // just to be safe, in case this was converted

	return ..(mapload, base, creator, destroy_original = FALSE)

/mob/living/simple_animal/hostile/mimic/copy/vendor/AttackingTarget()
	. = ..()
	if(. && target && Adjacent(target))
		visible_message("<span class='danger'>[src] throws itself on top of [target], crushing [target.p_them()]!</span>")
		orig_vendor.forceMove(get_turf(target))  // just to be sure it'll tilt onto them
		orig_vendor.tilt(target, TRUE, FALSE)  // geeeeet dunked on
		orig_vendor = null
		qdel(src)

/mob/living/simple_animal/hostile/mimic/copy/vendor/death(gibbed)
	if(!QDELETED(orig_vendor))
		orig_vendor.forceMove(get_turf(src))
		// tilt over in place
		orig_vendor.tilt_over()
		if(prob(70))
			orig_vendor.obj_break()
		orig_vendor = null
	return ..()

/mob/living/simple_animal/hostile/mimic/copy/ranged
	var/obj/item/gun/TrueGun = null
	var/obj/item/gun/magic/Zapstick
	var/obj/item/gun/projectile/Pewgun
	var/obj/item/gun/energy/Zapgun

/mob/living/simple_animal/hostile/mimic/copy/ranged/CopyObject(obj/O, mob/living/creator, destroy_original = 0)
	if(..())
		emote_see = list("aims menacingly")
		obj_damage = 0
		environment_smash = 0 //needed? seems weird for them to do so
		ranged = TRUE
		retreat_distance = 1 //just enough to shoot
		minimum_distance = 6
		var/obj/item/gun/G = O
		melee_damage_upper = G.force
		melee_damage_lower = G.force - max(0, (G.force / 2))
		move_to_delay = 2 * G.w_class + 1
		projectilesound = G.fire_sound
		TrueGun = G
		if(istype(G, /obj/item/gun/magic))
			Zapstick = G
			var/obj/item/ammo_casing/magic/M = Zapstick.ammo_type
			projectiletype = initial(M.projectile_type)
		if(istype(G, /obj/item/gun/projectile))
			Pewgun = G
			var/obj/item/ammo_box/magazine/M = Pewgun.mag_type
			casingtype = initial(M.ammo_type)
		if(istype(G, /obj/item/gun/energy))
			Zapgun = G
			var/selectfiresetting = Zapgun.select
			var/obj/item/ammo_casing/energy/E = Zapgun.ammo_type[selectfiresetting]
			projectiletype = initial(E.projectile_type)

/mob/living/simple_animal/hostile/mimic/copy/ranged/OpenFire(the_target)
	if(Zapgun)
		if(Zapgun.cell)
			var/obj/item/ammo_casing/energy/shot = Zapgun.ammo_type[Zapgun.select]
			if(Zapgun.cell.charge >= shot.e_cost)
				Zapgun.cell.use(shot.e_cost)
				Zapgun.update_icon()
				..()
	else if(Zapstick)
		if(Zapstick.charges)
			Zapstick.charges--
			Zapstick.update_icon()
			..()
	else if(Pewgun)
		if(Pewgun.chambered)
			if(Pewgun.chambered.BB)
				qdel(Pewgun.chambered.BB)
				Pewgun.chambered.BB = null //because qdel takes too long, ensures icon update
				Pewgun.chambered.update_icon()
				..()
			else
				visible_message("<span class='danger'>The <b>[src]</b> clears a jam!</span>")
			Pewgun.chambered.loc = loc //rip revolver immersions, blame shotgun snowflake procs
			Pewgun.chambered = null
			if(Pewgun.magazine && length(Pewgun.magazine.stored_ammo))
				Pewgun.chambered = Pewgun.magazine.get_round(0)
				Pewgun.chambered.loc = Pewgun
			Pewgun.update_icon()
		else if(Pewgun.magazine && length(Pewgun.magazine.stored_ammo)) //only true for pumpguns i think
			Pewgun.chambered = Pewgun.magazine.get_round(0)
			Pewgun.chambered.loc = Pewgun
			visible_message("<span class='danger'>The <b>[src]</b> cocks itself!</span>")
	else
		ranged = FALSE //BANZAIIII
		retreat_distance = 0
		minimum_distance = 1
		return
	icon_state = TrueGun.icon_state
	icon_living = TrueGun.icon_state
