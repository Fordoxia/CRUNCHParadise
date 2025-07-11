/mob/living/simple_animal/slime/Life()
	set invisibility = 0
	if(notransform)
		return
	if(..())
		if(buckled)
			handle_feeding()
		if(stat == CONSCIOUS) // Slimes in stasis don't lose nutrition, don't change mood and don't respond to speech
			handle_nutrition()
			handle_organs()
			if(QDELETED(src)) // Stop if the slime split during handle_nutrition()
				return
			reagents.remove_all(0.5 * REAGENTS_METABOLISM * length(reagents.reagent_list)) //Slimes are such snowflakes
			handle_targets()
			if(!ckey)
				handle_mood()
				handle_speech()

// Unlike most of the simple animals, slimes support UNCONSCIOUS
/mob/living/simple_animal/slime/update_stat()
	if(stat == UNCONSCIOUS && health > 0)
		return
	..()

/mob/living/simple_animal/slime/proc/AIprocess()  // the master AI process

	if(AIproc || stat || client)
		return

	var/hungry = 0
	if(nutrition < get_starve_nutrition())
		hungry = 2
	else if(nutrition < get_grow_nutrition() && prob(25) || nutrition < get_hunger_nutrition())
		hungry = 1

	AIproc = TRUE

	while(AIproc && stat != DEAD && (attacked || hungry || rabid))
		if(buckled)
			break

		if(!(mobility_flags & MOBILITY_MOVE))
			break

		if(!Target || client)
			break

		if(Target.health <= -70 || Target.stat == DEAD)
			Target = null
			AIproc = FALSE
			break

		if(Target)
			if(locate(/mob/living/simple_animal/slime) in Target.buckled_mobs)
				Target = null
				AIproc = FALSE
				break
			if(!AIproc)
				break

			if(Target in view(1,src))
				if(!CanFeedon(Target)) //If they're not able to be fed upon, ignore them.
					if(!Atkcool)
						Atkcool = TRUE
						addtimer(VARSET_CALLBACK(src, Atkcool, FALSE), 4.5 SECONDS)

						if(Target.Adjacent(src))
							Target.attack_slime(src)
					break
				if(!(mobility_flags & MOBILITY_MOVE) && prob(80))

					if(Target.client && Target.health >= 20)
						if(!Atkcool)
							Atkcool = TRUE
							addtimer(VARSET_CALLBACK(src, Atkcool, FALSE), 4.5 SECONDS)

							if(Target.Adjacent(src))
								Target.attack_slime(src)

					else
						if(!Atkcool && Target.Adjacent(src))
							Feedon(Target)

				else
					if(!Atkcool && Target.Adjacent(src))
						Feedon(Target)

			else if(Target in view(7, src))
				if(!Target.Adjacent(src))
				// Bug of the month candidate: slimes were attempting to move to target only if it was directly next to them, which caused them to target things, but not approach them
					step_to(src, Target)
			else
				Target = null
				AIproc = FALSE
				break

		var/sleeptime = movement_delay()
		if(sleeptime <= 0)
			sleeptime = 1

		sleep(sleeptime + 2) // this is about as fast as a player slime can go

	AIproc = FALSE

/mob/living/simple_animal/slime/handle_environment(datum/gas_mixture/readonly_environment)
	if(!readonly_environment)
		return

	var/loc_temp = get_temperature(readonly_environment)

	adjust_bodytemperature(adjust_body_temperature(bodytemperature, loc_temp, 1))

	//Account for massive pressure differences

	if(bodytemperature < (T0C + 5)) // start calculating temperature damage etc
		if(bodytemperature <= (T0C - 40)) // stun temperature
			Tempstun = TRUE
			throw_alert("temp", /atom/movable/screen/alert/cold, 3)
			to_chat(src,"<span class='userdanger'>You suddenly freeze up, you cannot move!</span>")

		if(bodytemperature <= (T0C - 50)) // hurt temperature
			if(bodytemperature <= 50) // sqrting negative numbers is bad
				adjustBruteLoss(200)
			else
				adjustBruteLoss(round(sqrt(bodytemperature)) * 2)

	else
		if(Tempstun)
			to_chat(src,"<span class='warning'>You suddenly unthaw!</span>")
		Tempstun = FALSE

	updatehealth("handle environment")


	return //TODO: DEFERRED

/mob/living/simple_animal/slime/proc/adjust_body_temperature(current, loc_temp, boost)
	var/temperature = current
	var/difference = abs(current - loc_temp)	//get difference
	var/increments// = difference/10			//find how many increments apart they are
	if(difference > 50)
		increments = difference / 5
	else
		increments = difference / 10
	var/change = increments * boost	// Get the amount to change by (x per increment)
	var/temp_change
	if(current < loc_temp)
		temperature = min(loc_temp, temperature+change)
	else if(current > loc_temp)
		temperature = max(loc_temp, temperature-change)
	temp_change = (temperature - current)
	return temp_change

/mob/living/simple_animal/slime/handle_status_effects()
	..()
	if(prob(30) && stat == CONSCIOUS)
		adjustBruteLoss(-1)

// This is where slime feeding is handled.
/mob/living/simple_animal/slime/proc/handle_feeding()
	if(!ismob(buckled))
		return
	var/mob/M = buckled

	if(stat)
		Feedstop(silent = TRUE)

	if(M.stat == DEAD) // our victim died
		if(client)
			to_chat(src, "<i>This subject does not have a strong enough life energy anymore...</i>")

		if(M.client && ishuman(M))
			if(prob(85))
				rabid = TRUE //we go rabid after finishing to feed on a human with a client.

		Feedstop()
		return

	// This is where damage dealt by slime feeding is handled.
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjustCloneLoss(rand(2, 4))
		C.adjustToxLoss(rand(1, 2))

		if(prob(10) && C.client)
			to_chat(C, "<span class='userdanger'>[pick("You can feel your body becoming weak!", \
			"You feel like you're about to die!", \
			"You feel every part of your body screaming in agony!", \
			"A low, rolling pain passes through your body!", \
			"Your body feels as if it's falling apart!", \
			"You feel extremely weak!", \
			"A sharp, deep pain bathes every inch of your body!")]</span>")

	else if(isanimal(M))
		var/mob/living/simple_animal/SA = M

		var/totaldamage = 0 //total damage done to this unfortunate animal
		totaldamage += SA.adjustCloneLoss(rand(2, 4))
		totaldamage += SA.adjustToxLoss(rand(1, 2))

		if(totaldamage <= 0) //if we did no(or negative!) damage to it, stop
			Feedstop(0, 0)
			return

	else
		Feedstop(0, 0)
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.dna.species.tox_mod && !H.dna.species.clone_mod)
			Feedstop(0, 0)
			return

	add_nutrition(rand(7, 15))
	//Heal yourself.
	adjustBruteLoss(-3)

/mob/living/simple_animal/slime/proc/handle_nutrition()
	if(docile) //God as my witness, I will never go hungry again
		set_nutrition(700) //fuck you for using the base nutrition var
		return

	if(prob(15))
		adjust_nutrition(-(1 + is_adult))

	if(nutrition <= 0)
		set_nutrition(0)
		if(prob(75))
			adjustBruteLoss(rand(0, 5))

	else if(nutrition >= get_grow_nutrition() && amount_grown < SLIME_EVOLUTION_THRESHOLD)
		adjust_nutrition(-20)
		amount_grown++
		update_action_buttons_icon()

	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD && !buckled && !Target && !ckey)
		if(is_adult)
			Reproduce()
		else
			Evolve()

/mob/living/simple_animal/slime/proc/add_nutrition(nutrition_to_add = 0)
	set_nutrition(min((nutrition + nutrition_to_add), get_max_nutrition()))
	if(nutrition >= get_grow_nutrition())
		if(powerlevel<10)
			if(prob(30-powerlevel*2))
				powerlevel++
	else if(nutrition >= get_hunger_nutrition() + 100) //can't get power levels unless you're a bit above hunger level.
		if(powerlevel<5)
			if(prob(25-powerlevel*5))
				powerlevel++

/mob/living/simple_animal/slime/proc/handle_targets()
	if(Tempstun)
		if(!buckled) // not while they're eating!
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_TRAIT)

	if(attacked > 50)
		attacked = 50

	if(attacked > 0)
		attacked--

	if(Discipline > 0)

		if(Discipline >= 5 && rabid)
			if(prob(60))
				rabid = FALSE

		if(prob(10) && !trained)
			Discipline--

	if(!client && !stop_automated_movement)
		if(!(mobility_flags & MOBILITY_MOVE))
			return

		if(buckled)
			return // if it's eating someone already, continue eating!

		if(Target)
			--target_patience
			if(target_patience <= 0 || SStun > world.time || Discipline || attacked || docile) // Tired of chasing or something draws out attention
				target_patience = 0
				Target = null

		if(AIproc && SStun > world.time)
			return

		var/hungry = 0 // determines if the slime is hungry

		if(nutrition < get_starve_nutrition())
			hungry = 2
		else if(nutrition < get_grow_nutrition() && prob(25) || nutrition < get_hunger_nutrition())
			hungry = 1

		if(!Target)
			if(will_hunt() && hungry || attacked || rabid) // Only add to the list if we need to
				var/list/targets = list()

				for(var/mob/living/L in view(7,src))

					if(L.stat == DEAD) // Ignore dead mobs
						continue

					var/ally = FALSE
					for(var/F in faction)
						if(F == "neutral") //slimes are neutral so other mobs not target them, but they can target neutral mobs
							continue
						if(F in L.faction)
							ally = TRUE
							break
					if(ally)
						continue

					if(issilicon(L) && (rabid || attacked)) // They can't eat silicons, but they can glomp them in defence
						targets += L // Possible target found!

					if(locate(/mob/living/simple_animal/slime) in L.buckled_mobs) // Only one slime can latch on at a time.
						continue

					targets += L // Possible target found!

				if(length(targets) > 0)
					if(attacked || rabid || hungry == 2)
						Target = targets[1] // I am attacked and am fighting back or so hungry I don't even care
					else
						for(var/mob/living/carbon/C in targets)
							if(!Discipline && prob(5))
								if(ishuman(C) || isalienadult(C))
									Target = C
									break

							if(islarva(C) || issmall(C))
								Target = C
								break

			if(Target)
				target_patience = rand(5, 7)
				if(is_adult)
					target_patience += 3

		if(!Target) // If we have no target, we are wandering
			if(hungry && isturf(loc) && prob(50))
				step(src, pick(GLOB.cardinal))
		else if(!AIproc)
			INVOKE_ASYNC(src, PROC_REF(AIprocess))

/mob/living/simple_animal/slime/handle_automated_movement()
	return //slime random movement is currently handled in handle_targets()

/mob/living/simple_animal/slime/handle_automated_speech()
	return //slime random speech is currently handled in handle_speech()

/mob/living/simple_animal/slime/proc/handle_mood()
	var/newmood = ""
	if(rabid || attacked)
		newmood = "angry"
	else if(docile)
		newmood = ":3"
	else if(Target)
		newmood = "mischievous"
	else if(trained)
		newmood = ":33"

	if(!newmood)
		if(Discipline && prob(25))
			newmood = "pout"
		else if(prob(1))
			newmood = pick("sad", ":3", "pout")

	if((mood == "sad" || mood == ":3" || mood == "pout") && !newmood)
		if(prob(75))
			newmood = mood

	if(newmood != mood) // This is so we don't redraw them every time
		mood = newmood
		regenerate_icons()

/mob/living/simple_animal/slime/proc/handle_speech()
	if(prob(1))
		emote(pick("bounce", "sway", "light", "vibrate", "jiggle"))
	else
		var/t = 10
		var/slimes_near = 0
		var/dead_slimes = 0
		for(var/mob/living/L in view(7,src))
			if(isslime(L) && L != src)
				++slimes_near
				if(L.stat == DEAD)
					++dead_slimes
		if(nutrition < get_hunger_nutrition())
			t += 10
		if(nutrition < get_starve_nutrition())
			t += 10
		if(prob(2) && prob(t))
			var/phrases = list()
			if(Target)
				phrases += "[Target]... look yummy..."
			if(nutrition < get_starve_nutrition())
				phrases += "So... hungry..."
				phrases += "Very... hungry..."
				phrases += "Need... food..."
				phrases += "Must... eat..."
			else if(nutrition < get_hunger_nutrition())
				phrases += "Hungry..."
				phrases += "Where food?"
				phrases += "I want to eat..."
			phrases += "Rawr..."
			phrases += "Blop..."
			phrases += "Blorble..."
			if(rabid || attacked)
				phrases += "Hrr..."
				phrases += "Nhuu..."
				phrases += "Unn..."
			if(mood == ":3")
				phrases += "Purr..."
			if(attacked)
				phrases += "Grrr..."
			if(bodytemperature < T0C)
				phrases += "Cold..."
			if(bodytemperature < T0C - 30)
				phrases += "So... cold..."
				phrases += "Very... cold..."
			if(bodytemperature < T0C - 50)
				phrases += "..."
				phrases += "C... c..."
			if(buckled)
				phrases += "Nom..."
				phrases += "Yummy..."
			if(powerlevel > 3)
				phrases += "Bzzz..."
			if(powerlevel > 5)
				phrases += "Zap..."
			if(powerlevel > 8)
				phrases += "Zap... Bzz..."
			if(mood == "sad")
				phrases += "Bored..."
			if(slimes_near)
				phrases += "Slime friend..."
			if(slimes_near > 1)
				phrases += "Slime friends..."
			if(dead_slimes)
				phrases += "What happened?"
			if(!slimes_near)
				phrases += "Lonely..."
			if(stat == CONSCIOUS)
				say (pick(phrases))

/mob/living/simple_animal/slime/proc/get_max_nutrition() // Can't go above it
	if(is_adult)
		return 1200
	else
		return 1000

/mob/living/simple_animal/slime/proc/get_grow_nutrition() // Above it we grow, below it we can eat
	if(is_adult)
		return 1000
	else
		return 800

/mob/living/simple_animal/slime/proc/get_hunger_nutrition() // Below it we will always eat
	if(is_adult)
		return 600
	else
		return 500

/mob/living/simple_animal/slime/proc/get_starve_nutrition() // Below it we will eat before everything else
	if(is_adult)
		return 300
	else
		return 200

/mob/living/simple_animal/slime/proc/will_hunt(hunger = -1) // Check for being stopped from feeding and chasing
	if(docile)
		return FALSE
	if(hunger == 2 || rabid || attacked)
		return TRUE
	return TRUE

// Handles xeno organ processing, and turns the unidentified organs into the true organ type.
/mob/living/simple_animal/slime/proc/handle_organs()
	if(!holding_organ)
		return
	if(istype(loc, /obj/machinery/computer/camera_advanced/xenobio))
		return // no processing while in the computer
	if(!trained) // if we somehow untrain mid process
		say("BLECK!!", pick(speak_emote))
		eject_organ()
	if(organ_progress < 50)
		organ_progress += 1
		return
	organ_progress = 1
	say("All done!", pick(speak_emote))
	var/obj/item/organ/internal/finished_organ = new holding_organ.true_organ_type(src.loc)
	finished_organ.organ_quality = holding_organ.unknown_quality
	finished_organ.icon_state = holding_organ.icon_state
	finished_organ.name = "[quality_to_string(finished_organ.organ_quality, FALSE)] [finished_organ.name]"
	underlays.Cut()
	QDEL_NULL(holding_organ)
