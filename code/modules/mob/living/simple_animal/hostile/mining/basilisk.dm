//A beast that fire freezing blasts.
/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	move_to_delay = 20
	projectiletype = /obj/item/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = TRUE
	ranged_message = "stares"
	throw_message = "does nothing against the hard shell of"
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites into"
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	turns_per_move = 5
	gold_core_spawnable = HOSTILE_SPAWN
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/basilisk

	loot = list(/obj/item/stack/ore/diamond{layer = ABOVE_MOB_LAYER},
				/obj/item/stack/ore/diamond{layer = ABOVE_MOB_LAYER})

/obj/item/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	temperature = 50

/obj/item/projectile/temp/basilisk/on_hit(atom/target, blocked)
	..()
	if(isrobot(target))
		var/mob/living/silicon/robot/cyborg = target
		cyborg.apply_damage(35, STAMINA)

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(new_target)
	if(..()) //we have a target
		if(isliving(target) && !target.Adjacent(targets_from) && ranged_cooldown <= world.time)//No more being shot at point blank or spammed with RNG beams
			OpenFire(target)

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity)
	switch(severity)
		if(1)
			gib()
		if(2)
			adjustBruteLoss(140)
		if(3)
			adjustBruteLoss(110)

/mob/living/simple_animal/hostile/asteroid/basilisk/space

/mob/living/simple_animal/hostile/asteroid/basilisk/space/Process_Spacemove(movement_dir, continuous_move)
	return TRUE

//Watcher
/mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	name = "watcher"
	desc = "A levitating, eye-like creature held aloft by winglike formations of sinew. A sharp spine of crystal protrudes from its body."
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_aggro = "watcher"
	icon_dead = "watcher_dead"
	pixel_x = -10
	throw_message = "bounces harmlessly off of"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "impales"
	speak_emote = list("telepathically cries")
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	loot = list()
	butcher_results = list(/obj/item/stack/ore/diamond = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 1)
	initial_traits = list(TRAIT_FLYING)
	surgery_container = /datum/xenobiology_surgery_container/watcher

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing
	name = "magmawing watcher"
	desc = "When raised very close to lava, some watchers adapt to the extreme heat and use lava as both a weapon and wings."
	icon_state = "watcher_magmawing"
	icon_living = "watcher_magmawing"
	icon_aggro = "watcher_magmawing"
	icon_dead = "watcher_magmawing_dead"
	maxHealth = 215 //Compensate for the lack of slowdown on projectiles with a bit of extra health
	health = 215
	light_range = 3
	light_power = 2.5
	light_color = LIGHT_COLOR_LAVA
	projectiletype = /obj/item/projectile/temp/basilisk/magmawing
	crusher_loot = /obj/item/crusher_trophy/blaster_tubes/magma_wing
	crusher_drop_mod = 100 //These things are extremely rare (1/133 per spawner). You shouldn't have to hope for another stroke of luck to get it's trophy after finding it

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing
	name = "icewing watcher"
	desc = "Very rarely, some watchers will eke out an existence far from heat sources. In the absence of warmth, they become icy and fragile but fire much stronger freezing blasts."
	icon_state = "watcher_icewing"
	icon_living = "watcher_icewing"
	icon_aggro = "watcher_icewing"
	icon_dead = "watcher_icewing_dead"
	maxHealth = 170
	health = 170
	projectiletype = /obj/item/projectile/temp/basilisk/icewing
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/bone = 1) //No sinew; the wings are too fragile to be usable
	crusher_loot = /obj/item/crusher_trophy/watcher_wing/ice_wing
	crusher_drop_mod = 100 //These things are extremely rare (1/400 per spawner). You shouldn't have to hope for another stroke of luck to get it's trophy after finding it

/obj/item/projectile/temp/basilisk/magmawing
	name = "scorching blast"
	icon_state = "lava"
	damage = 5
	nodamage = FALSE
	temperature = 500 //Heats you up!
	immolate = 1

/obj/item/projectile/temp/basilisk/icewing
	damage = 5
	nodamage = FALSE

/obj/item/projectile/temp/basilisk/icewing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L))
			L.apply_status_effect(/datum/status_effect/freon/watcher)

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril
	fromtendril = TRUE
