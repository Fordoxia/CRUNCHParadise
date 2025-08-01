/mob/living/simple_animal/mouse
	name = "mouse"
	real_name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	icon_resting = "mouse_gray_sleep"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeaks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	var/squeak_sound = 'sound/creatures/mousesqueak.ogg'
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	butcher_results = list(/obj/item/food/meat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	mob_size = MOB_SIZE_TINY
	var/mouse_color //brown, gray and white, leave blank for random
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	holder_type = /obj/item/holder/mouse
	gold_core_spawnable = FRIENDLY_SPAWN
	var/chew_probability = 1

/mob/living/simple_animal/mouse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddComponent(/datum/component/squeak, list('sound/creatures/mousesqueak.ogg' = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever

/mob/living/simple_animal/mouse/handle_automated_action()
#if defined(GAME_TESTS) || defined(MAP_TESTS) // DO NOT EAT MY CABLES DURING TESTS
	return
#endif
	if(!prob(chew_probability) || !isfloorturf(loc))
		return
	var/turf/simulated/floor/F = get_turf(src)
	if(F.intact || F.transparent_floor)
		return
	var/obj/structure/cable/C = locate() in F
	if(!C || !prob(15))
		return
	if(C.get_available_power() && !HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		visible_message("<span class='warning'>[src] chews through [C]. It's toast!</span>")
		playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
		toast() // mmmm toasty.
	else
		visible_message("<span class='warning'>[src] chews through [C].</span>")
	investigate_log("was chewed through by a mouse in [get_area(F)]([F.x], [F.y], [F.z] - [ADMIN_JMP(F)])",INVESTIGATE_WIRES)
	C.deconstruct()

/mob/living/simple_animal/mouse/handle_automated_speech()
	..()
	if(prob(speak_chance) && !incapacitated())
		playsound(src, squeak_sound, 100, 1)

/mob/living/simple_animal/mouse/handle_automated_movement()
	. = ..()
	if(IS_HORIZONTAL(src))
		if(prob(1))
			stand_up()
		else if(prob(5))
			custom_emote(EMOTE_AUDIBLE, "snuffles")
	else if(prob(0.5))
		lay_down()

/mob/living/simple_animal/mouse/Initialize(mapload)
	. = ..()

	if(!mouse_color)
		mouse_color = pick("brown", "gray", "white")
	icon_state = "mouse_[mouse_color]"
	icon_living = "mouse_[mouse_color]"
	icon_dead = "mouse_[mouse_color]_dead"
	icon_resting = "mouse_[mouse_color]_sleep"
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/mouse/update_desc()
	. = ..()
	desc = "It's a small [mouse_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."

/mob/living/simple_animal/mouse/attack_hand(mob/living/carbon/human/M as mob)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M, TRUE)
	..()

/mob/living/simple_animal/mouse/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)//Prevents mouse from pulling things
	if(istype(AM, /obj/item/food/sliced/cheesewedge))
		return ..() // Get dem
	if(show_message)
		to_chat(src, "<span class='warning'>You are too small to pull anything except cheese.</span>")
	return

/mob/living/simple_animal/mouse/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(ishuman(entered))
		if(stat == CONSCIOUS)
			var/mob/M = entered
			to_chat(M, "<span class='notice'>[bicon(src)] Squeek!</span>")

/mob/living/simple_animal/mouse/proc/toast()
	add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
	desc = "It's toast."
	death()

/mob/living/simple_animal/mouse/proc/splat()
	icon_dead = "mouse_[mouse_color]_splat"
	icon_state = "mouse_[mouse_color]_splat"

/mob/living/simple_animal/mouse/death(gibbed)
	// Only execute the below if we successfully died
	playsound(src, squeak_sound, 40, 1)
	. = ..(gibbed)
	if(!.)
		return FALSE
	layer = MOB_LAYER
	if(client)
		client.time_died_as_mouse = world.time

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	mouse_color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/white/linter
	name = "Linter"

/mob/living/simple_animal/mouse/white/linter/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, ROUNDSTART_TRAIT)

/mob/living/simple_animal/mouse/gray
	mouse_color = "gray"

/mob/living/simple_animal/mouse/brown
	mouse_color = "brown"
	icon_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/tom
	name = "Tom"
	real_name = "Tom"
	response_harm   = "splats"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/mouse/brown/tom/update_desc()
	. = ..()
	desc = "Jerry the cat is not amused."

/mob/living/simple_animal/mouse/brown/tom/Initialize(mapload)
	. = ..()
	// Tom fears no cable.
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, SPECIES_TRAIT)

/mob/living/simple_animal/mouse/white/brain
	name = "Brain"
	real_name = "Brain"
	response_harm = "splats"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/mouse/white/brain/update_desc()
	. = ..()
	desc = "Gee Virology, what are we going to do tonight? The same thing we do every night, try to take over the world!"

/mob/living/simple_animal/mouse/blobinfected
	maxHealth = 100
	health = 100
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	gold_core_spawnable = NO_SPAWN
	var/bursted = FALSE

/mob/living/simple_animal/mouse/blobinfected/Initialize(mapload)
	. = ..()
	apply_status_effect(STATUS_EFFECT_BLOB_BURST, 120 SECONDS, CALLBACK(src, PROC_REF(burst), FALSE))

/mob/living/simple_animal/mouse/blobinfected/Life()
	if(ismob(loc)) // if someone ate it, burst immediately
		burst(FALSE)
	return ..()

/mob/living/simple_animal/mouse/blobinfected/death(gibbed)
	. = ..(gibbed)
	if(.) // Only burst if they actually died
		burst(gibbed)

/mob/living/simple_animal/mouse/blobinfected/proc/burst(gibbed)
	if(bursted)
		return // Avoids double bursting in some situations
	bursted = TRUE
	var/turf/T = get_turf(src)
	if(!is_station_level(T.z) || isspaceturf(T))
		to_chat(src, "<span class='userdanger'>You feel ready to burst, but this isn't an appropriate place!  You must return to the station!</span>")
		apply_status_effect(STATUS_EFFECT_BLOB_BURST, 5 SECONDS, CALLBACK(src, PROC_REF(burst), FALSE))
		return FALSE
	var/datum/mind/blobmind = mind
	var/client/C = client
	var/obj/structure/blob/core/core
	if(istype(blobmind) && istype(C))
		core = new(T, C, 3)
		core.lateblobtimer()
		qdel(blobmind) // Delete the old mind. THe blob will make a new one
	else
		core = new(T) // Ghosts will be prompted to control it.
	if(ismob(loc)) // in case some taj/etc ate the mouse.
		var/mob/M = loc
		M.gib()
	if(!gibbed)
		gib()

	if(core)
		core.admin_spawned = admin_spawned

	SSticker.record_biohazard_start(BIOHAZARD_BLOB)

/mob/living/simple_animal/mouse/blobinfected/get_scooped(mob/living/carbon/grabber)
	to_chat(grabber, "<span class='warning'>You try to pick up [src], but they slip out of your grasp!</span>")
	to_chat(src, "<span class='warning'>[src] tries to pick you up, but you wriggle free of their grasp!</span>")

/mob/living/simple_animal/mouse/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!isdrone(user))
		user.visible_message("<span class='notice'>[user] sucks [src] into its decompiler. There's a horrible crunching noise.</span>", \
		"<span class='warning'>It's a bit of a struggle, but you manage to suck [src] into your decompiler. It makes a series of visceral crunching noises.</span>")
		new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
		C.stored_comms["metal"] += 2
		C.stored_comms["glass"] += 1
		qdel(src)
		return TRUE
	return ..()
