//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/his_grace
	id = "his_grace"
	tick_interval = 4
	alert_type = /atom/movable/screen/alert/status_effect/his_grace
	var/bloodlust = 0
	/// Attached His Grace toolbox
	var/obj/item/his_grace/toolbox

/atom/movable/screen/alert/status_effect/his_grace
	name = "His Grace"
	desc = "His Grace hungers, and you must feed Him."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/atom/movable/screen/alert/status_effect/his_grace/MouseEntered(location, control, params)
	desc = initial(desc)
	var/datum/status_effect/his_grace/HG = attached_effect
	desc += "<br><font size=3><b>Current Bloodthirst: [HG.bloodlust]</b></font>\
	<br>Becomes undroppable at <b>[HIS_GRACE_FAMISHED]</b>\
	<br>Will consume you at <b>[HIS_GRACE_CONSUME_OWNER]</b>\
	<br>You have offered [HG.toolbox ? HG.toolbox.victims : 0] out of [HG.toolbox.victims_needed] sacrifices needed before ascension."
	..()

/datum/status_effect/his_grace/on_apply()
	add_attack_logs(owner, owner, "gained His Grace's stun immunity", ATKLOG_ALL)
	owner.add_stun_absorption("hisgrace", INFINITY, 3, null, "His Grace protects you from the stun!")
	return ..()

/datum/status_effect/his_grace/tick()
	bloodlust = 0
	var/graces = 0
	var/list/held_items = list()
	held_items += owner.l_hand
	held_items += owner.r_hand
	for(var/obj/item/his_grace/HG in held_items)
		toolbox = HG
		if(HG.bloodthirst > bloodlust)
			bloodlust = HG.bloodthirst
		if(HG.awakened)
			graces++
	if(!graces)
		owner.apply_status_effect(STATUS_EFFECT_HISWRATH)
		qdel(src)
		return
	var/grace_heal = bloodlust * 0.05

	var/mob/living/carbon/human/owner_human = owner
	owner_human.adjustBruteLoss(-grace_heal, robotic = TRUE)
	owner_human.adjustFireLoss(-grace_heal, robotic = TRUE)
	owner_human.adjustToxLoss(-grace_heal)
	owner_human.adjustOxyLoss(-(grace_heal * 2))
	owner_human.adjustCloneLoss(-grace_heal)

/datum/status_effect/his_grace/on_remove()
	add_attack_logs(owner, owner, "lost His Grace's stun immunity", ATKLOG_ALL)
	if(islist(owner.stun_absorption) && owner.stun_absorption["hisgrace"])
		owner.remove_stun_absorption("hisgrace")
	toolbox = null

/datum/status_effect/shadow_mend
	id = "shadow_mend"
	duration = 3 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/shadow_mend
	/// If this is true, the status effect will try to apply the debuff to others, rather than the user
	var/devil = FALSE

/datum/status_effect/shadow_mend/devil
	devil = TRUE

/atom/movable/screen/alert/status_effect/shadow_mend
	name = "Shadow Mend"
	desc = "Shadowy energies wrap around your wounds, sealing them at a price. After healing, you will slowly lose health every three seconds for thirty seconds."
	icon_state = "shadow_mend"

/datum/status_effect/shadow_mend/on_apply()
	owner.visible_message("<span class='notice'>Violet light wraps around [owner]'s body!</span>", "<span class='notice'>Violet light wraps around your body!</span>")
	playsound(owner, 'sound/magic/teleport_app.ogg', 50, 1)
	return ..()

/datum/status_effect/shadow_mend/tick()
	owner.adjustBruteLoss(-15)
	owner.adjustFireLoss(-15)

/datum/status_effect/shadow_mend/on_remove()
	if(!devil)
		owner.visible_message("<span class='warning'>The violet light around [owner] glows black!</span>", "<span class='warning'>The tendrils around you cinch tightly and reap their toll...</span>")
		playsound(owner, 'sound/magic/teleport_diss.ogg', 50, TRUE)
		owner.apply_status_effect(STATUS_EFFECT_VOID_PRICE)
		return

	var/found_someone = FALSE

	for(var/mob/living/L in oview(9, owner))
		playsound(owner, 'sound/magic/teleport_diss.ogg', 50, TRUE)
		L.Beam(owner, "grabber_beam", time = 1 SECONDS, maxdistance = 9)
		if(L.can_block_magic(MAGIC_RESISTANCE))
			to_chat(L, "<span class='warning'>You shake off the tendrils that try to wrap around you!</span>")
			continue
		found_someone = TRUE
		L.apply_status_effect(STATUS_EFFECT_VOID_PRICE)
	if(found_someone)
		owner.visible_message("<span class='warning'>The violet light around [owner] glows black... and shoots off to those around [owner.p_them()]!</span>", "<span class='warning'>The tendrils around you cinch tightly... but then unwravel and fly at others!</span>")
	else
		owner.visible_message("<span class='warning'>The violet light around [owner] glows black!</span>", "<span class='warning'>The tendrils around you cinch tightly and reap their toll...</span>")
		playsound(owner, 'sound/magic/teleport_diss.ogg', 50, TRUE)
		owner.apply_status_effect(STATUS_EFFECT_VOID_PRICE)

/datum/status_effect/void_price
	id = "void_price"
	duration = 30 SECONDS
	tick_interval = 3 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/void_price
	var/price = 3 //This is how much hp you lose per tick. Each time the buff is refreshed, it increased by 1. Healing too much in a short period of time will cause your swift demise

/atom/movable/screen/alert/status_effect/void_price
	name = "Void Price"
	desc = "Black tendrils cinch tightly against you, digging wicked barbs into your flesh."
	icon_state = "shadow_mend"

/datum/status_effect/void_price/tick()
	playsound(owner, 'sound/weapons/bite.ogg', 50, 1)
	owner.adjustBruteLoss(price)

/datum/status_effect/void_price/refresh()
	price++
	return ..()

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/blooddrunk
	var/blooddrunk_damage_mod_remove = 4 // Damage is multiplied by this at the end of the status effect. Modify this one, it changes the _add
	/// If this is the chariot subtype, which grants pacifism while the effect is active.
	var/chariot = FALSE

/datum/status_effect/blooddrunk/chariot
	duration = 10 SECONDS
	chariot = TRUE
	blooddrunk_damage_mod_remove = 6

/atom/movable/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply()
	. = ..()
	if(.)
		ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "blooddrunk")
		if(chariot)
			ADD_TRAIT(owner, TRAIT_PACIFISM, "blooddrunk")
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/blooddrunk_damage_mod_add = 1 / blooddrunk_damage_mod_remove // Damage is multiplied by this at the start of the status effect. Don't modify this one directly.
			H.physiology.brute_mod *= blooddrunk_damage_mod_add
			H.physiology.burn_mod *= blooddrunk_damage_mod_add
			H.physiology.tox_mod *= blooddrunk_damage_mod_add
			H.physiology.oxy_mod *= blooddrunk_damage_mod_add
			H.physiology.clone_mod *= blooddrunk_damage_mod_add
			H.physiology.stamina_mod *= blooddrunk_damage_mod_add
		add_attack_logs(owner, owner, "gained blood-drunk stun immunity", ATKLOG_ALL)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, TRUE, use_reverb = FALSE)

/datum/status_effect/blooddrunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod *= blooddrunk_damage_mod_remove
		H.physiology.burn_mod *= blooddrunk_damage_mod_remove
		H.physiology.tox_mod *= blooddrunk_damage_mod_remove
		H.physiology.oxy_mod *= blooddrunk_damage_mod_remove
		H.physiology.clone_mod *= blooddrunk_damage_mod_remove
		H.physiology.stamina_mod *= blooddrunk_damage_mod_remove
	add_attack_logs(owner, owner, "lost blood-drunk stun immunity", ATKLOG_ALL)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "blooddrunk")
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "blooddrunk")
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.remove_stun_absorption("blooddrunk")

/atom/movable/screen/alert/status_effect/dash
	name = "Dash"
	desc = "Your have the ability to dash!"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "genetic_jump"

/datum/status_effect/dash
	id = "dash"
	duration = 5 SECONDS
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/dash

/datum/status_effect/bloodswell
	id = "bloodswell"
	duration = 30 SECONDS
	tick_interval = 0
	alert_type = /atom/movable/screen/alert/status_effect/blood_swell
	var/bonus_damage_applied = FALSE

/atom/movable/screen/alert/status_effect/blood_swell
	name = "Blood Swell"
	desc = "Your body has been infused with crimson magics, your resistance to attacks has greatly increased!"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "blood_swell_status"

/datum/status_effect/bloodswell/on_apply()
	. = ..()
	if(!. || !ishuman(owner))
		return FALSE
	ADD_TRAIT(owner, TRAIT_CHUNKYFINGERS, VAMPIRE_TRAIT)
	var/mob/living/carbon/human/H = owner
	H.physiology.brute_mod *= 0.4
	H.physiology.burn_mod *= 0.5
	H.physiology.stamina_mod *= 0.5
	H.physiology.stun_mod *= 0.5
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V?.get_ability(/datum/vampire_passive/blood_swell_upgrade))
		bonus_damage_applied = TRUE
		H.physiology.melee_bonus += 10
		H.dna.species.punchstunthreshold += 8 //higher chance to stun but not 100%

/datum/status_effect/bloodswell/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_CHUNKYFINGERS, VAMPIRE_TRAIT)
	var/mob/living/carbon/human/H = owner
	H.physiology.brute_mod /= 0.4
	H.physiology.burn_mod /= 0.5
	H.physiology.stamina_mod /= 0.5
	H.physiology.stun_mod /= 0.5
	if(bonus_damage_applied)
		bonus_damage_applied = FALSE
		H.physiology.melee_bonus -= 10
		H.dna.species.punchstunthreshold -= 8

/datum/status_effect/vampire_gladiator
	id = "vampire_gladiator"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/vampire_gladiator

/atom/movable/screen/alert/status_effect/vampire_gladiator
	name = "Gladiatorial Resilience"
	desc = "Roused by the thrill of the fight, your body has become more resistant to breaking!"
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "mech_damtype_brute"

/datum/status_effect/vampire_gladiator/on_apply()
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	ADD_TRAIT(H, TRAIT_NO_BONES, GLADIATOR)
	ADD_TRAIT(H, TRAIT_STURDY_LIMBS, GLADIATOR)
	ADD_TRAIT(H, TRAIT_BURN_WOUND_IMMUNE, GLADIATOR)
	ADD_TRAIT(H, TRAIT_IB_IMMUNE, GLADIATOR)
	for(var/obj/item/organ/external/limb in H.bodyparts)
		limb.add_limb_flags()


/datum/status_effect/vampire_gladiator/on_remove()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return
	REMOVE_TRAIT(H, TRAIT_NO_BONES, GLADIATOR)
	REMOVE_TRAIT(H, TRAIT_STURDY_LIMBS, GLADIATOR)
	REMOVE_TRAIT(H, TRAIT_BURN_WOUND_IMMUNE, GLADIATOR)
	REMOVE_TRAIT(H, TRAIT_IB_IMMUNE, GLADIATOR)
	for(var/obj/item/organ/external/limb in H.bodyparts)
		limb.remove_limb_flags()


/datum/status_effect/vampire_gladiator/tick()
	owner.adjustStaminaLoss(-20)
	owner.adjustBruteLoss(-5)
	owner.adjustFireLoss(-5)

/datum/status_effect/blood_rush
	id = "blood_rush"
	alert_type = null
	duration = 10 SECONDS

/datum/status_effect/blood_rush/on_apply()
	ADD_TRAIT(owner, TRAIT_GOTTAGOFAST, VAMPIRE_TRAIT)
	return TRUE

/datum/status_effect/blood_rush/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GOTTAGOFAST, VAMPIRE_TRAIT)

/datum/status_effect/force_shield
	id = "forceshield"
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	duration = 5 SECONDS
	tick_interval = 0
	var/mutable_appearance/shield

/datum/status_effect/force_shield/on_apply()
	. = ..()
	if(!. || !ishuman(owner))
		return
	var/mutable_appearance/MA = mutable_appearance('icons/effects/effects.dmi', "shield-old", ABOVE_MOB_LAYER)
	var/mob/living/carbon/human/H = owner
	H.add_overlay(MA)
	shield = MA
	H.add_stun_absorption("[id]", INFINITY, 1)
	H.physiology.stamina_mod *= 0.1
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5

/datum/status_effect/force_shield/on_remove()
	. = ..()
	var/mob/living/carbon/human/H = owner
	H.cut_overlay(shield)
	if(islist(owner.stun_absorption) && owner.stun_absorption["[id]"])
		owner.remove_stun_absorption("[id]")
	H.physiology.stamina_mod /= 0.1
	H.physiology.brute_mod /= 0.5
	H.physiology.burn_mod /= 0.5


//Hippocratic Oath: Applied when the Rod of Asclepius is activated.
/datum/status_effect/hippocratic_oath
	id = "Hippocratic Oath"
	tick_interval = 25
	examine_text = "<span class='notice'>They seem to have an aura of healing and helpfulness about them.</span>"
	alert_type = null
	var/deathTick = 0
	/// How many points the rod has to heal with, maxes at 50, or whatever heal_points_max is set to.
	var/heal_points = 50
	/// Max heal points for the rod to spend on healing people
	var/max_heal_points = 50

/datum/status_effect/hippocratic_oath/on_apply()
	//Makes the user passive, it's in their oath not to harm!
	ADD_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(owner)
	owner.permanent_huds |= H
	return ..()

/datum/status_effect/hippocratic_oath/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, "hippocraticOath")
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	owner.permanent_huds ^= H
	H.remove_hud_from(owner)

/datum/status_effect/hippocratic_oath/tick()
	// Death transforms you into a snake after a short grace period
	if(owner.stat == DEAD)
		if(deathTick < 4)
			deathTick++
			return

		owner.visible_message("<span class='notice'>[owner]'s soul is absorbed into the rod, relieving the previous snake of its duty.</span>")
		var/mob/living/simple_animal/hostile/retaliate/poison/snake/healSnake = new(owner.loc)
		var/list/chems = list("bicaridine", "perfluorodecalin", "kelotane")
		healSnake.poison_type = pick(chems)
		healSnake.name = "Asclepius's Snake"
		healSnake.real_name = "Asclepius's Snake"
		healSnake.desc = "A mystical snake previously trapped upon the Rod of Asclepius, now freed of its burden. Unlike the average snake, its bites contain chemicals with minor healing properties."
		new /obj/effect/decal/cleanable/ash(owner.loc)
		new /obj/item/rod_of_asclepius(owner.loc)
		qdel(owner)
		return

	// A servant of medicines stops at nothing to help others, let's give them an additional boost
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss() || H.getBrainLoss() || H.getStaminaLoss() || H.getCloneLoss()) // Avoid counting burn wounds
			H.adjustBruteLoss(-1.5, robotic = TRUE)
			H.adjustFireLoss(-1.5, robotic = TRUE)
			H.adjustOxyLoss(-1.5)
			H.adjustToxLoss(-1.5)
			H.adjustBrainLoss(-1.5)
			H.adjustStaminaLoss(-1.5)
			H.adjustCloneLoss(-0.5)
			new /obj/effect/temp_visual/heal(get_turf(H), COLOR_HEALING_GREEN)

	// Regenerate points passively
	if(heal_points < max_heal_points)
		heal_points = min(heal_points + 3, max_heal_points)

	// The main course: heal everyone around you with the points we just gained!
	for(var/mob/living/L in view(7, owner))
		heal(L)
		if(!heal_points)
			break

/datum/status_effect/hippocratic_oath/proc/heal(mob/living/L)
	var/starting_points = heal_points
	var/force_particle = FALSE

	if(ishuman(L))
		heal_human(L)
	else if(iscarbon(L))
		if(L.health < L.maxHealth || L.getStaminaLoss()) // Carbons have no burn wounds to worry about nor brain damage to heal
			L.adjustBruteLoss(-3.5)
			L.adjustFireLoss(-3.5)
			L.adjustOxyLoss(-3.5)
			L.adjustToxLoss(-3.5)
			L.adjustStaminaLoss(-3.5)
			L.adjustCloneLoss(-1)
			heal_points--
	else if(issilicon(L))
		if(L.health < L.maxHealth)
			L.adjustBruteLoss(-3.5)
			L.adjustFireLoss(-3.5)
			heal_points--
	else if(isanimal_or_basicmob(L))
		var/mob/living/animal = L
		if(animal.health < animal.maxHealth)
			animal.adjustHealth(-3.5)
			force_particle = TRUE
			if(prob(50)) // Animals are simpler
				heal_points--

	if(starting_points < heal_points || force_particle)
		new /obj/effect/temp_visual/heal(get_turf(L), COLOR_HEALING_GREEN)

/datum/status_effect/hippocratic_oath/proc/heal_human(mob/living/carbon/human/H)
	if(H.getBruteLoss() || H.getFireLoss() || H.getOxyLoss() || H.getToxLoss() || H.getBrainLoss() || H.getStaminaLoss() || H.getCloneLoss()) // Avoid counting burn wounds
		H.adjustBruteLoss(-3.5, robotic = TRUE)
		H.adjustFireLoss(-3.5, robotic = TRUE)
		H.adjustOxyLoss(-3.5)
		H.adjustToxLoss(-3.5)
		H.adjustBrainLoss(-3.5)
		H.adjustStaminaLoss(-3.5)
		H.adjustCloneLoss(-1)
		heal_points--
		if(!heal_points)
			return

	for(var/obj/item/organ/external/E in H.bodyparts)
		if(prob(10) && (E.status & (ORGAN_BROKEN | ORGAN_INT_BLEEDING | ORGAN_BURNT)) && !E.is_robotic())
			E.mend_fracture()
			E.fix_internal_bleeding()
			E.fix_burn_wound()
			heal_points--
			if(!heal_points)
				return

/atom/movable/screen/alert/status_effect/regenerative_core
	name = "Regenerative Core Tendrils"
	desc = "You can move faster than your broken body could normally handle!"
	icon_state = "regenerative_core"

/datum/status_effect/regenerative_core
	id = "Regenerative Core"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/regenerative_core
	var/regen_type_applied

/datum/status_effect/regenerative_core/on_creation(mob/living/new_owner, incoming_type)
	regen_type_applied = incoming_type
	return ..()

/datum/status_effect/regenerative_core/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
	owner.adjustBruteLoss(-25)
	owner.adjustFireLoss(-25)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.bodytemperature = H.dna.species.body_temperature
		if(regen_type_applied == "Legion")
			if(is_mining_level(H.z) || istype(get_area(H), /area/ruin/space/bubblegum_arena))
				owner.remove_CC()
				for(var/obj/item/organ/external/E in H.bodyparts)
					E.fix_internal_bleeding()
					E.fix_burn_wound()
					E.mend_fracture()
			else
				to_chat(owner, "<span class='warning'>...But the core was weakened, it is not close enough to the rest of the legions of the necropolis.</span>")
			return TRUE
		if(regen_type_applied == "Hivelord")
			var/area/A = get_area(H)
			if(isspaceturf(get_turf(H)) || isspacearea(A) || istype(A, /area/syndicate_depot) || istype(A, /area/ruin/space) || istype(A, /area/shuttle))
				for(var/obj/item/organ/external/E in H.bodyparts)
					E.fix_internal_bleeding()
					E.fix_burn_wound()
					E.mend_fracture()
			else
				to_chat(owner, "<span class='warning'>...But the core was weakened, it is not close enough to the stars to absorb solar radiation...</span>")
	else
		owner.bodytemperature = BODYTEMP_NORMAL
	return TRUE

/datum/status_effect/regenerative_core/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)

/datum/status_effect/fleshmend
	id = "fleshmend"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	/// This diminishes the healing of fleshmend the higher it is.
	var/tolerance = 1
	/// This diminishes the healing of fleshmend if the user is cold when it is activated
	var/freezing = FALSE
	var/instance_duration = 10 // in ticks
	/// a list of integers, one for each remaining instance of fleshmend.
	var/list/active_instances = list()
	var/ticks = 0

/datum/status_effect/fleshmend/on_apply()
	apply_new_fleshmend()
	return TRUE

/datum/status_effect/fleshmend/refresh()
	apply_new_fleshmend()
	..()

/datum/status_effect/fleshmend/proc/apply_new_fleshmend()
	tolerance += 1
	freezing = (owner.bodytemperature + 50 <= owner.dna.species.body_temperature)
	if(freezing)
		to_chat(owner, "<span class='warning'>Our healing's effectiveness is reduced \
			by our cold body!</span>")
	active_instances += instance_duration

/datum/status_effect/fleshmend/tick()
	if(length(active_instances) >= 1)
		var/heal_amount = (length(active_instances) / tolerance) * (freezing ? 2 : 10)
		var/blood_restore = 30 * length(active_instances)
		owner.heal_overall_damage(heal_amount, heal_amount, updating_health = FALSE)
		owner.adjustOxyLoss(-heal_amount, FALSE)
		owner.blood_volume = min(owner.blood_volume + blood_restore, BLOOD_VOLUME_NORMAL)
		owner.updatehealth()
		var/list/expired_instances = list()
		for(var/i in 1 to length(active_instances))
			active_instances[i]--
			if(active_instances[i] <= 0)
				expired_instances += active_instances[i]
		active_instances -= expired_instances
	tolerance = max(tolerance - 0.05, 1)
	if(tolerance <= 1 && length(active_instances) == 0)
		qdel(src)

/datum/status_effect/speedlegs
	id = "speedlegs"
	tick_interval = 4 SECONDS
	alert_type = null
	var/stacks = 0
	/// A reference to the changeling's changeling antag datum.
	var/datum/antagonist/changeling/cling

/datum/status_effect/speedlegs/on_apply()
	cling = owner.mind.has_antag_datum(/datum/antagonist/changeling)
	ADD_TRAIT(owner, TRAIT_GOTTAGOFAST, CHANGELING_TRAIT)
	return TRUE

/datum/status_effect/speedlegs/tick()
	if(owner.stat || owner.getStaminaLoss() >= 90 || cling.chem_charges <= (stacks + 1) * 3)
		to_chat(owner, "<span class='danger'>Our muscles relax without the energy to strengthen them.</span>")
		owner.Weaken(6 SECONDS)
		qdel(src)
	else
		stacks++
		cling.chem_charges -= stacks * 3 //At first the changeling may regenerate chemicals fast enough to nullify fatigue, but it will stack
		if(stacks == 7) //Warning message that the stacks are getting too high
			to_chat(owner, "<span class='warning'>Our legs are really starting to hurt...</span>")

/datum/status_effect/speedlegs/before_remove()
	if(stacks < 3 && !(owner.stat || owner.getStaminaLoss() >= 90 || cling.chem_charges <= (stacks + 1) * 3)) //We don't want people to turn it on and off fast, however, we need it forced off if the 3 later conditions are met.
		to_chat(owner, "<span class='notice'>Our muscles just tensed up, they will not relax so fast.</span>")
		return FALSE
	return TRUE

/datum/status_effect/speedlegs/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GOTTAGOFAST, CHANGELING_TRAIT)
	if(!owner.IsWeakened())
		to_chat(owner, "<span class='notice'>Our muscles relax.</span>")
		if(stacks >= 7)
			to_chat(owner, "<span class='danger'>We collapse in exhaustion.</span>")
			owner.Weaken(6 SECONDS)
			owner.emote("gasp")
	cling = null

/datum/status_effect/panacea
	id = "panacea"
	duration = 20 SECONDS
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/panacea/tick()
	owner.adjustToxLoss(-5) //Has the same healing as 20 charcoal, but happens faster
	owner.radiation = max(0, owner.radiation - 70) //Same radiation healing as pentetic
	owner.adjustBrainLoss(-5)
	owner.AdjustDrunk(-12 SECONDS) //50% stronger than antihol
	owner.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 10)
	for(var/datum/reagent/R in owner.reagents.reagent_list)
		if(!R.harmless)
			owner.reagents.remove_reagent(R.id, 2)

/datum/status_effect/chainsaw_slaying
	id = "chainsaw_slaying"
	duration = 5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/chainsaw

/atom/movable/screen/alert/status_effect/chainsaw
	name = "Revved up!"
	desc = "<span class='danger'>... guts, huge guts! Kill them... must kill them all!</span>"
	icon_state = "chainsaw"

/datum/status_effect/chainsaw_slaying/on_apply()
	. = ..()
	if(.)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.physiology.brute_mod *= 0.8
			H.physiology.burn_mod *= 0.8
			H.physiology.stamina_mod *= 0.8
		owner.status_flags &= ~CANPUSH
		add_attack_logs(owner, owner, "gained chainsaw stun immunity", ATKLOG_ALL)
		owner.add_stun_absorption("chainsaw", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, TRUE, use_reverb = FALSE)

/datum/status_effect/chainsaw_slaying/on_remove()
	add_attack_logs(owner, owner, "lost chainsaw stun immunity", ATKLOG_ALL)
	owner.status_flags |= CANPUSH
	if(islist(owner.stun_absorption) && owner.stun_absorption["chainsaw"])
		owner.remove_stun_absorption("chainsaw")
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.brute_mod /= 0.8
		H.physiology.burn_mod /=0.8
		H.physiology.stamina_mod /= 0.8

/datum/status_effect/breaching_and_cleaving
	id = "breaching_and_cleaving"
	alert_type = /atom/movable/screen/alert/status_effect/breaching_and_cleaving
	var/datum/armor/cleaving_armor_boost = new /datum/armor(0, 30, 30, 30, 0, 0, 50, 0, 0)

/atom/movable/screen/alert/status_effect/breaching_and_cleaving
	name = "Breaching and Cleaving!"
	desc = "<span class='danger'>Doors, people, machines... nothing will stand before your martial prowess!</span>"
	icon_state = "breachcleaver"

/datum/status_effect/breaching_and_cleaving/on_apply()
	. = ..()
	if(!. || !ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.physiology.armor = H.physiology.armor.attachArmor(cleaving_armor_boost)
	H.physiology.stamina_mod *= 0.8

/datum/status_effect/breaching_and_cleaving/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.armor = H.physiology.armor.detachArmor(cleaving_armor_boost)
		H.physiology.stamina_mod /= 0.8
	QDEL_NULL(cleaving_armor_boost)

/datum/status_effect/hope
	id = "hope"
	tick_interval = 2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/hope

/atom/movable/screen/alert/status_effect/hope
	name = "Hope."
	desc = "A ray of hope beyond dispair."
	icon_state = "hope"

/datum/status_effect/hope/tick()
	if(owner.stat == DEAD || owner.health <= HEALTH_THRESHOLD_DEAD) // No dead healing, or healing in dead crit
		return
	var/heal_multiplier = 0
	switch(owner.health)
		if(50 to INFINITY)
			heal_multiplier = 1
		if(0 to 50)
			heal_multiplier = 2
		if(-50 to 0)
			heal_multiplier = 3
		if(-100 to -50)
			heal_multiplier = 4
	owner.adjustBruteLoss(-heal_multiplier)
	owner.adjustFireLoss(-heal_multiplier)
	owner.adjustOxyLoss(-heal_multiplier)
	if(owner.health > 50)
		if(prob(0.5))
			hope_message()
		return
	if(prob(heal_multiplier * 2))
		hope_message()

/datum/status_effect/hope/proc/hope_message()
	var/list/hope_messages = list("You are filled with [pick("hope", "determination", "strength", "peace", "confidence", "robustness")].",
							"Don't give up!",
							"You see your [pick("friends", "family", "coworkers", "self")] [pick("rooting for you", "cheering you on", "worrying about you")].",
							"You can't give up now, keep going!",
							"But you refused to die!",
							"You have been through worse, you can do this!",
							"People need you, do not [pick("give up", "stop", "rest", "pass away", "falter", "lose hope")] yet!",
							"This person is not nearly as robust as you!",
							"You ARE robust, don't let anyone tell you otherwise!",
							"[owner], don't lose hope, the future of the station depends on you!",
							"Do not follow the light yet!")
	var/list/un_hopeful_messages = list("DON'T FUCKING DIE NOW COWARD!",
							"Git Gud, [owner]",
							"I bet a [pick("vox", "vulp", "nian", "tajaran", "baldie")] could do better than you!",
							"You hear people making fun of you for getting robusted.")
	if(prob(99))
		to_chat(owner, "<span class='notice'>[pick(hope_messages)]</span>")
	else
		to_chat(owner, "<span class='cultitalic'>[pick(un_hopeful_messages)]</span>")

/datum/status_effect/drill_payback
	id = "drill_payback"
	alert_type = null
	var/drilled_successfully = FALSE
	var/times_warned = 0
	var/obj/structure/safe/drilled

/datum/status_effect/drill_payback/on_creation(mob/living/new_owner, obj/structure/safe/S)
	drilled = S
	return ..()

/datum/status_effect/drill_payback/on_apply()
	owner.overlay_fullscreen("payback", /atom/movable/screen/fullscreen/stretch/payback, 0)
	addtimer(CALLBACK(src, PROC_REF(payback_phase_2)), 2.7 SECONDS)
	return TRUE

/datum/status_effect/drill_payback/proc/payback_phase_2()
	owner.clear_fullscreen("payback")
	owner.overlay_fullscreen("payback", /atom/movable/screen/fullscreen/stretch/payback, 1)

/datum/status_effect/drill_payback/tick() // They are not staying down. This will be a fight.
	if(!drilled_successfully && (get_dist(owner, drilled) >= 9)) // We don't want someone drilling the safe at arrivals then raiding bridge with the buff
		to_chat(owner, "<span class='userdanger'>Get back to the safe, they are going to get the drill!</span>")
		times_warned++
		if(times_warned >= 6)
			owner.remove_status_effect(STATUS_EFFECT_DRILL_PAYBACK)
			return
	if(owner.stat != DEAD)
		var/mob/living/carbon/human/H = owner // The Brute and Burn heal doesn't work if it doesn't do it at the human level
		H.adjustBruteLoss(-3, FALSE, robotic = TRUE)
		H.adjustFireLoss(-3, FALSE, robotic = TRUE)
		owner.adjustStaminaLoss(-25)

/datum/status_effect/drill_payback/on_remove()
	. = ..()
	owner.clear_fullscreen("payback")

/datum/status_effect/thrall_net
	id = "thrall_net"
	tick_interval = 2 SECONDS
	alert_type = null
	var/blood_cost_per_tick = 5
	var/list/target_UIDs = list()
	var/datum/antagonist/vampire/vamp

/datum/status_effect/thrall_net/on_creation(mob/living/new_owner, datum/antagonist/vampire/V, ...)
	. = ..()
	vamp = V
	START_PROCESSING(SSfastprocess, src)
	target_UIDs += owner.UID()
	var/list/view_cache = view(7, owner)
	for(var/datum/mind/M in owner.mind.som.serv)
		if(!M.has_antag_datum(/datum/antagonist/mindslave/thrall))
			continue
		if(!(M.current in view_cache))
			continue
		if(M.current.stat == DEAD)
			continue
		target_UIDs += M.current.UID()
		M.current.Beam(owner, "sendbeam", time = 2 SECONDS, maxdistance = 7)

/datum/status_effect/thrall_net/tick()
	var/total_damage = 0
	var/list/view_cache = view(7, owner)
	for(var/uid in target_UIDs)
		var/mob/living/L = locateUID(uid)
		if(!(L in view_cache) || L.stat == DEAD)
			target_UIDs -= uid
			continue
		total_damage += (L.maxHealth - L.health)
		L.Beam(owner, "sendbeam", time = 2 SECONDS, maxdistance = 7)

	var/average_damage = total_damage / length(target_UIDs)

	for(var/uid in target_UIDs)
		var/mob/living/L = locateUID(uid)
		var/current_damage = L.maxHealth - L.health
		if(current_damage == average_damage)
			continue
		if(current_damage > average_damage)
			var/heal_amount = current_damage - average_damage
			L.heal_ordered_damage(heal_amount, list(BRUTE, BURN, TOX, OXY, CLONE))
		else
			var/damage_amount = average_damage - current_damage
			L.adjustFireLoss(damage_amount)

	vamp.bloodusable = max(vamp.bloodusable - blood_cost_per_tick, 0)
	if(!vamp.bloodusable || length(target_UIDs) <= 1) // if there is one left in the list, its only the vampire.
		qdel(src)

/datum/status_effect/thrall_net/on_remove()
	. = ..()
	vamp = null

/datum/status_effect/rev_protection
	id = "rev_protection"
	// revs are paralyzed for 10 seconds when they're deconverted, same duration
	duration = 10 SECONDS
	alert_type = null

/datum/status_effect/rev_protection/on_apply()
	RegisterSignal(owner, COMSIG_HUMAN_ATTACKED, PROC_REF(on_human_attackby))
	return ..()

/datum/status_effect/rev_protection/proc/on_human_attackby(mob/living/carbon/human/victim, mob/living/carbon/human/attacker)
	SIGNAL_HANDLER
	if(!(attacker.a_intent in list(INTENT_DISARM, INTENT_HARM)))
		return
	if(!victim.AmountParalyzed())
		stack_trace("/datum/status_effect/rev_protection was on [victim] despite them not being paralyzed. This status effect should last the same amount of time as them being paralyzed.")
		qdel(src)
		return
	if(!is_any_revolutionary(attacker)) // protect from non-revs. Revs dont care about deconverted people
		to_chat(attacker, "<span class='biggerdanger'>[owner] was just deconverted! You don't feel like harming them!</span>")
		attacker.changeNext_move(CLICK_CD_MELEE)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/status_effect/rev_protection/on_remove()
	UnregisterSignal(owner, COMSIG_HUMAN_ATTACKED)
	. = ..()

/datum/status_effect/bookwyrm
	id = "bookwyrm"
	duration = BRAIN_DAMAGE_MOB_TIME
	alert_type = null

/datum/status_effect/bearserker_rage
	id = "bearserker rage"
	duration = 5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/bearserker_rage

/atom/movable/screen/alert/status_effect/bearserker_rage
	name = "Bearserker Rage"
	desc = "<span class='danger'>Blood flows between your fingers, and Foh'Sie roars; \"MORE BLOOD!\"</span>"
	icon_state = "bearserker"

/datum/status_effect/bearserker_rage/on_apply()
	. = ..()
	if(. && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.stamina_mod *= 0.75
		add_attack_logs(owner, owner, "gained bearserker rage resistances", ATKLOG_ALL)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, TRUE, use_reverb = FALSE)

/datum/status_effect/bearserker_rage/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.physiology.stamina_mod /= 0.75
		add_attack_logs(owner, owner, "lost bearserker rage resistances", ATKLOG_ALL)

/datum/status_effect/xray
	id = "xray"
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	duration = 2 MINUTES
	tick_interval = 0

/datum/status_effect/xray/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, "XRAY_BUFF")
	ADD_TRAIT(owner, TRAIT_NIGHT_VISION, "XRAY_BUFF")
	owner.update_sight()

/datum/status_effect/xray/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, "XRAY_BUFF")
	REMOVE_TRAIT(owner, TRAIT_NIGHT_VISION, "XRAY_BUFF")
	owner.update_sight()

/datum/status_effect/badass
	id = "badass"
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	duration = 2 MINUTES
	tick_interval = 0

/datum/status_effect/badass/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_BADASS, "BADDASS_BUFF")

/datum/status_effect/badass/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_BADASS, "BADDASS_BUFF")

/datum/status_effect/reversed_sun
	id = "reversed_sun"
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	duration = 1 MINUTES
	tick_interval = 0.2 SECONDS

/datum/status_effect/reversed_sun/on_apply()
	. = ..()
	owner.become_nearsighted("REVERSED_SUN")
	ADD_TRAIT(owner, TRAIT_NIGHT_VISION, "REVERSED_SUN")
	owner.update_sight()
	owner.set_light(7, -5, "#ddd6cf")

/datum/status_effect/reversed_sun/on_remove()
	. = ..()
	owner.remove_light()
	owner.cure_nearsighted("REVERSED_SUN")
	REMOVE_TRAIT(owner, TRAIT_NIGHT_VISION, "REVERSED_SUN")
	owner.update_sight()

/datum/status_effect/reversed_sun/tick()
	for(var/atom/movable/AM in oview(8, owner))
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.affects_vampire(owner))
				L.adjust_bodytemperature(-1.5 * TEMPERATURE_DAMAGE_COEFFICIENT)
			continue
		if(istype(AM, /obj/item/projectile))
			var/obj/item/projectile/P = AM
			if(P.flag == ENERGY || P.flag == LASER)
				P.damage *= 0.85

/datum/status_effect/flayer_rejuv
	id = "rejuvination"
	duration = 5 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/flayer_rejuv
	var/heal_amount = 5 // 25 total healing of both brute and burn at base

/atom/movable/screen/alert/status_effect/flayer_rejuv
	name = "Regenerating"
	desc = "You are regenerating."
	icon_state = "drunk2"

/datum/status_effect/flayer_rejuv/on_creation(mob/living/new_owner, extra_duration, extra_heal_amount)
	if(isnum(extra_duration))
		duration += extra_duration
	if(isnum(extra_heal_amount))
		heal_amount += extra_heal_amount
	return ..()

/datum/status_effect/flayer_rejuv/on_apply()
	owner.SetWeakened(0)
	owner.SetStunned(0)
	owner.SetKnockDown(0)
	owner.SetParalysis(0)
	owner.SetSleeping(0)
	owner.SetConfused(0)
	owner.setStaminaLoss(0)
	owner.stand_up(TRUE)
	SEND_SIGNAL(owner, COMSIG_LIVING_CLEAR_STUNS)
	return ..()

/datum/status_effect/flayer_rejuv/tick()
	if(!ishuman(owner) || owner.stat == DEAD)
		return

	var/mob/living/carbon/human/flayer = owner
	flayer.adjustBruteLoss(-heal_amount, robotic = TRUE)
	flayer.adjustFireLoss(-heal_amount, robotic = TRUE)
	flayer.updatehealth()
	if(flayer.has_status_effect(STATUS_EFFECT_TERMINATOR_FORM))
		// Massive healing when in terminator mode
		flayer.adjustStaminaLoss(-60)

/datum/status_effect/quicksilver_form
	id = "quicksilver_form"
	duration = 10 SECONDS
	tick_interval = 0
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/quicksilver_form
	/// Temporary storage of the owner's flags to restore them properly after the ability is over
	var/temporary_flag_storage
	/// Do we also reflect projectiles
	var/should_deflect = FALSE

/atom/movable/screen/alert/status_effect/quicksilver_form
	name = "Quicksilver body"
	desc = "Your body is much less solid."
	icon_state = "high"

/datum/status_effect/quicksilver_form/on_creation(mob/living/new_owner, extra_duration, reflect_projectiles)
	if(isnum(extra_duration))
		duration += extra_duration
	should_deflect = reflect_projectiles
	return ..()

/datum/status_effect/quicksilver_form/on_apply()
	var/obj/item/item_one = owner.get_active_hand()
	if(item_one)
		item_one.equip_to_best_slot(owner)
	var/obj/item/item_two = owner.get_inactive_hand()
	if(item_two)
		// Equip to best slot only works for the item in the active hand. As such, if we detect an item, we swap, equip, then swap back
		owner.swap_hand()
		item_two.equip_to_best_slot(owner)
		owner.swap_hand()
	if(should_deflect)
		ADD_TRAIT(owner, TRAIT_DEFLECTS_PROJECTILES, UNIQUE_TRAIT_SOURCE(src))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, "[id]")
	temporary_flag_storage = owner.pass_flags
	owner.pass_flags |= (PASSTABLE | PASSGRILLE | PASSMOB | PASSFENCE | PASSGIRDER | PASSGLASS | PASSTAKE | PASSBARRICADE)
	owner.add_atom_colour(COLOR_ALUMINIUM, TEMPORARY_COLOUR_PRIORITY)
	return TRUE

/datum/status_effect/quicksilver_form/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DEFLECTS_PROJECTILES, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, "[id]")
	owner.pass_flags = temporary_flag_storage
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_ALUMINIUM)

/datum/status_effect/terminator_form
	id = "terminator_form"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/terminator_form
	var/mutable_appearance/eye

/datum/status_effect/terminator_form/on_apply()
	owner.status_flags |= TERMINATOR_FORM
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, UNIQUE_TRAIT_SOURCE(src))
	var/mutable_appearance/overlay = mutable_appearance('icons/mob/clothing/eyes.dmi', "terminator", ABOVE_MOB_LAYER)
	owner.add_overlay(overlay)
	eye = overlay
	return TRUE

/datum/status_effect/terminator_form/on_remove()
	owner.status_flags &= ~TERMINATOR_FORM
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, UNIQUE_TRAIT_SOURCE(src))
	owner.cut_overlay(eye)

/atom/movable/screen/alert/status_effect/terminator_form
	name = "Terminator form"
	desc = "Your body can surpass its limits briefly. You have to repair yourself before it ends, however."
	icon_state = "high"

#define COMBUSTION_TEMPERATURE 500
/datum/status_effect/overclock
	id = "overclock"
	alert_type = /atom/movable/screen/alert/status_effect/overclock
	/// How much do we heat up per tick?
	var/heat_per_tick = 5
	/// How many ticks has the ability been turned on?
	var/stacks = 0
	/// How many stacks until we start heating up even more?
	var/danger_stack_amount = 20

/datum/status_effect/overclock/on_creation(mob/living/new_owner, new_heating)
	if(isnum(new_heating))
		heat_per_tick = new_heating
	..()

/datum/status_effect/overclock/on_apply()
	ADD_TRAIT(owner, TRAIT_GOTTAGOFAST, UNIQUE_TRAIT_SOURCE(src))
	owner.next_move_modifier -= 0.3 // Same attack speed buff as mephedrone
	return TRUE

/datum/status_effect/overclock/on_remove()
	REMOVE_TRAIT(owner, TRAIT_GOTTAGOFAST, UNIQUE_TRAIT_SOURCE(src))
	owner.next_move_modifier += 0.3

/datum/status_effect/overclock/tick()
	owner.bodytemperature += heat_per_tick * ((stacks >= danger_stack_amount) ? 2 : 1) // After 20 seconds the heat penalty doubles
	if(owner.bodytemperature >= COMBUSTION_TEMPERATURE)
		owner.adjust_fire_stacks(5)
		owner.IgniteMob()
		to_chat(owner, "<span class='userdanger'>Your components can't handle the heat and combust!</span>")
		qdel(src)
	stacks += 1
	if(stacks == danger_stack_amount)
		to_chat(owner, "<span class='userdanger'>Your components are being dangerously overworked!</span>")

/atom/movable/screen/alert/status_effect/overclock
	name = "Overclocked"
	desc = "You feel energized, and hot."
	icon_state = "high"

#undef COMBUSTION_TEMPERATURE
