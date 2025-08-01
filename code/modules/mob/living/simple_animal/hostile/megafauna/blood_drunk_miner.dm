#define MINER_DASH_RANGE 4

/*

BLOOD-DRUNK MINER

Effectively a highly aggressive miner, the blood-drunk miner has very few attacks but compensates by being highly aggressive.

The blood-drunk miner's attacks are as follows
- If not in KA range, it will rapidly dash at its target
- If in KA range, it will fire its kinetic accelerator
- If in melee range, will rapidly attack, akin to an actual player
- After any of these attacks, may transform its cleaving saw:
	Untransformed, it attacks very rapidly for smaller amounts of damage
	Transformed, it attacks at normal speed for higher damage and cleaves enemies hit

When the blood-drunk miner dies, it leaves behind the cleaving saw it was using and its kinetic accelerator.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner
	name = "blood-drunk miner"
	desc = "A miner destined to wander forever, engaged in an endless hunt."
	health = 900
	maxHealth = 900
	icon_state = "miner"
	icon_living = "miner"
	icon = 'icons/mob/lavaland/blood_drunk.dmi'
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	light_color = "#E4C7C5"
	speak_emote = list("roars")
	speed = 3
	projectiletype = /obj/item/projectile/kinetic/miner
	projectilesound = 'sound/weapons/kenetic_accel.ogg'
	ranged = TRUE
	ranged_cooldown_time = 16
	pixel_x = -7
	crusher_loot = list(/obj/item/crusher_trophy/miner_eye)
	loot = list(/obj/item/melee/energy/cleaving_saw, /obj/item/gun/energy/kinetic_accelerator)
	wander = FALSE
	del_on_death = TRUE
	blood_volume = BLOOD_VOLUME_NORMAL
	internal_gps = /obj/item/gps/internal/miner
	medal_type = BOSS_MEDAL_MINER
	var/obj/item/melee/energy/cleaving_saw/miner_saw
	var/time_until_next_transform = 0
	var/dashing = FALSE
	var/dash_cooldown = 0
	var/dash_cooldown_to_use = 1.5 SECONDS
	var/guidance = FALSE
	var/transform_stop_attack = FALSE // stops the blood drunk miner from attacking after transforming his weapon until the next attack chain
	deathmessage = "falls to the ground, decaying into glowing particles."
	death_sound = "bodyfall"
	footstep_type = FOOTSTEP_MOB_HEAVY
	enraged_loot = /obj/item/disk/fauna_research/blood_drunk_miner
	attack_action_types = list(/datum/action/innate/megafauna_attack/dash,
							/datum/action/innate/megafauna_attack/kinetic_accelerator,
							/datum/action/innate/megafauna_attack/transform_weapon)

	initial_traits = list() // Don't want to inherit flight from parent type /megafauna/
	var/death_simplemob_representation = /obj/effect/temp_visual/dir_setting/miner_death

/obj/item/gps/internal/miner
	icon_state = null
	gpstag = "Resonant Signal"
	desc = "The sweet blood, oh, it sings to me."

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/Initialize(mapload)
	. = ..()
	miner_saw = new /obj/item/melee/energy/cleaving_saw/miner(src)

/datum/action/innate/megafauna_attack/dash
	name = "Dash To Target"
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = "<span class='colossus'>You are now dashing to your target.</span>"
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/kinetic_accelerator
	name = "Fire Kinetic Accelerator"
	button_icon = 'icons/obj/guns/energy.dmi'
	button_icon_state = "kineticgun"
	chosen_message = "<span class='colossus'>You are now shooting your kinetic accelerator.</span>"
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/transform_weapon
	name = "Transform Weapon"
	button_icon = 'icons/obj/lavaland/artefacts.dmi'
	button_icon_state = "cleaving_saw"
	chosen_message = "<span class='colossus'>You are now transforming your weapon.</span>"
	chosen_attack_num = 3

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/OpenFire()
	if(client)
		switch(chosen_attack)
			if(1)
				dash(target)
			if(2)
				shoot_ka()
			if(3)
				transform_weapon()
		return

	Goto(target, move_to_delay, minimum_distance)
	if(get_dist(src, target) > MINER_DASH_RANGE && dash_cooldown <= world.time)
		dash_attack()
	else
		shoot_ka()
	transform_weapon()

/// nerfed saw because it is very murdery
/obj/item/melee/energy/cleaving_saw/miner
	force = 6
	force_on = 10

/obj/item/melee/energy/cleaving_saw/miner/attack__legacy__attackchain(mob/living/target, mob/living/carbon/human/user)
	target.add_stun_absorption("miner", 10, INFINITY)
	..()
	target.remove_stun_absorption("miner")

/obj/item/projectile/kinetic/miner
	damage = 20
	speed = 0.9
	icon_state = "ka_tracer"
	range = MINER_DASH_RANGE

/obj/item/projectile/kinetic/miner/enraged
	damage = 35

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/adjustHealth(amount, updating_health = TRUE)
	if(!enraged)
		var/adjustment_amount = amount * 0.1
		if(world.time + adjustment_amount > next_move)
			changeNext_move(adjustment_amount) //attacking it interrupts it attacking, but only briefly
	. = ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/death()
	if(health > 0)
		return
	new death_simplemob_representation(loc, dir)
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/Move(atom/newloc)
	if(dashing) //we're not stupid!
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/ex_act(severity)
	if(dash())
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/MeleeAction(patience = TRUE)
	transform_stop_attack = FALSE
	return ..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/butcher(mob/living/L)
	visible_message("<span class='danger'>[src] butchers [L]!</span>",
	"<span class='userdanger'>You butcher [L], restoring your health!</span>")
	if(!is_station_level(z) || client) //NPC monsters won't heal while on station
		if(guidance)
			adjustHealth(-L.maxHealth)
		else
			adjustHealth(-(L.maxHealth * 0.5))
	L.gib()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/AttackingTarget()
	if(client)
		transform_stop_attack = FALSE
	if(QDELETED(target) || transform_stop_attack)
		return
	face_atom(target)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			butcher(L)
			return TRUE
	changeNext_move(CLICK_CD_MELEE)
	miner_saw.melee_attack_chain(src, target)
	if(guidance)
		adjustHealth(enraged ? -6 : -2)
	if(prob(50))
		transform_weapon() //Still follows the normal rules for cooldown between swaps.
	return TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item && !isturf(A))
		used_item = miner_saw
	..()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/GiveTarget(new_target)
	var/targets_the_same = (new_target == target)
	. = ..()
	if(. && target && !targets_the_same)
		wander = TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/enrage()
	. = ..()
	miner_saw = new /obj/item/melee/energy/cleaving_saw(src) //Real saw for real men.
	dash_cooldown_to_use = 0.5 SECONDS //Becomes a teleporting shit.
	ranged_cooldown_time = 5 //They got some cooldown mods.
	projectiletype = /obj/item/projectile/kinetic/miner/enraged
	maxHealth = 1800
	health = 1800 //Bit more of a challenge.

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/unrage()
	. = ..()
	miner_saw = new /obj/item/melee/energy/cleaving_saw/miner(src)
	dash_cooldown_to_use = initial(dash_cooldown_to_use)
	ranged_cooldown_time = initial(ranged_cooldown_time)
	projectiletype = initial(projectiletype)
	maxHealth = initial(maxHealth)
	health = initial(health)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/dash_attack()
	INVOKE_ASYNC(src, PROC_REF(dash), target)
	shoot_ka()

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/shoot_ka()
	if(ranged_cooldown <= world.time && get_dist(src, target) <= MINER_DASH_RANGE && !Adjacent(target))
		ranged_cooldown = world.time + ranged_cooldown_time
		visible_message("<span class='danger'>[src] fires the proto-kinetic accelerator!</span>")
		face_atom(target)
		new /obj/effect/temp_visual/dir_setting/firing_effect(loc, dir)
		Shoot(target)
		changeNext_move(CLICK_CD_RANGE)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/dash(atom/dash_target)
	if(world.time < dash_cooldown)
		return
	var/list/accessable_turfs = list()
	var/self_dist_to_target = 0
	var/turf/own_turf = get_turf(src)
	if(!QDELETED(dash_target))
		self_dist_to_target += get_dist(dash_target, own_turf)
	for(var/turf/O in RANGE_TURFS(MINER_DASH_RANGE, own_turf))
		if(O.density)
			continue
		var/turf_dist_to_target = 0
		if(!QDELETED(dash_target))
			turf_dist_to_target += get_dist(dash_target, O)
		if(get_dist(src, O) >= MINER_DASH_RANGE && turf_dist_to_target <= self_dist_to_target && !islava(O) && !ischasm(O))
			var/valid = TRUE
			for(var/turf/T in get_line(own_turf, O))
				if(T.is_blocked_turf(exclude_mobs = TRUE))
					valid = FALSE
					continue
			if(valid)
				accessable_turfs[O] = turf_dist_to_target
	var/turf/target_turf
	if(!QDELETED(dash_target))
		var/closest_dist = MINER_DASH_RANGE
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] < closest_dist)
				closest_dist = accessable_turfs[t]
		for(var/t in accessable_turfs)
			if(accessable_turfs[t] != closest_dist)
				accessable_turfs -= t
	if(!LAZYLEN(accessable_turfs))
		return
	dash_cooldown = world.time + dash_cooldown_to_use
	target_turf = pick(accessable_turfs)
	var/turf/step_back_turf = get_step(target_turf, get_cardinal_dir(target_turf, own_turf))
	var/turf/step_forward_turf = get_step(own_turf, get_cardinal_dir(own_turf, target_turf))
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_back_turf)
	new /obj/effect/temp_visual/small_smoke/halfsecond(step_forward_turf)
	var/obj/effect/temp_visual/decoy/fading/halfsecond/D = new (own_turf, src)
	forceMove(step_back_turf)
	playsound(own_turf, 'sound/weapons/punchmiss.ogg', 40, TRUE, -1)
	dashing = TRUE
	alpha = 0
	animate(src, alpha = 255, time = 5)
	SLEEP_CHECK_DEATH(2)
	D.forceMove(step_forward_turf)
	forceMove(target_turf)
	playsound(target_turf, 'sound/weapons/punchmiss.ogg', 40, TRUE, -1)
	SLEEP_CHECK_DEATH(1)
	dashing = FALSE
	return TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/proc/transform_weapon()
	if(time_until_next_transform <= world.time)
		miner_saw.transform_cooldown = 0
		miner_saw.transform_weapon(src, TRUE)
		if(!HAS_TRAIT(miner_saw, TRAIT_ITEM_ACTIVE))
			rapid_melee = 5 // 4 deci cooldown before changes, npcpool subsystem wait is 20, 20/4 = 5
		else
			rapid_melee = 3 // same thing but halved (slightly rounded up)
		transform_stop_attack = TRUE
		icon_state = "miner[HAS_TRAIT(miner_saw, TRAIT_ITEM_ACTIVE) ? "_transformed":""]"
		icon_living = "miner[HAS_TRAIT(miner_saw, TRAIT_ITEM_ACTIVE) ? "_transformed":""]"
		time_until_next_transform = world.time + rand(50, 100)

/obj/effect/temp_visual/dir_setting/miner_death
	icon_state = "miner_death"
	duration = 15

/obj/effect/temp_visual/dir_setting/miner_death/Initialize(mapload, set_dir)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(fade_out))

/obj/effect/temp_visual/dir_setting/miner_death/proc/fade_out()
	var/matrix/M = new
	M.Turn(pick(90, 270))
	var/final_dir = dir
	if(dir & (EAST|WEST)) //Facing east or west
		final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass

	animate(src, transform = M, pixel_y = -6, dir = final_dir, time = 2, easing = EASE_IN|EASE_OUT)
	sleep(5)
	animate(src, color = list("#A7A19E", "#A7A19E", "#A7A19E", list(0, 0, 0)), time = 10, easing = EASE_IN, flags = ANIMATION_PARALLEL)
	sleep(4)
	animate(src, alpha = 0, time = 6, easing = EASE_OUT, flags = ANIMATION_PARALLEL)

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/guidance
	guidance = TRUE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/hunter/AttackingTarget()
	. = ..()
	if(. && prob(enraged ? 40 : 12))
		INVOKE_ASYNC(src, PROC_REF(dash))

#undef MINER_DASH_RANGE
