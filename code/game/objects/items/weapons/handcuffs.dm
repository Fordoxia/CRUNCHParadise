/obj/item/restraints
	name = "bugged restraints" //This item existed before this pr, but had no name or such. Better warn people if it exists
	desc = "Should not exist. Report me to a(n) coder/admin!"
	icon = 'icons/obj/restraints.dmi'
	var/cuffed_state = "handcuff"
	///How long it will take to break out of restraints
	var/breakouttime

/obj/item/restraints/proc/attempt_resist_restraints(mob/living/carbon/user, break_cuffs, effective_breakout_time, silent)
	if(effective_breakout_time)
		if(!silent)
			user.visible_message("<span class='warning'>[user] attempts to [break_cuffs ? "break" : "remove"] [src]!</span>", "<span class='notice'>You attempt to [break_cuffs ? "break" : "remove"] [src]...</span>")
		to_chat(user, "<span class='notice'>(This will take around [DisplayTimeText(effective_breakout_time)] and you need to stand still.)</span>")

	if(!do_after(user, effective_breakout_time, FALSE, user, hidden = TRUE))
		user.remove_status_effect(STATUS_EFFECT_REMOVE_CUFFS)
		to_chat(user, "<span class='warning'>You fail to [break_cuffs ? "break" : "remove"] [src]!</span>")
		return

	user.remove_status_effect(STATUS_EFFECT_REMOVE_CUFFS)
	if(loc != user || user.buckled)
		return

	finish_resist_restraints(user, break_cuffs)

/obj/item/restraints/proc/finish_resist_restraints(mob/living/carbon/user, break_cuffs, silent)
	if(!silent)
		user.visible_message("<span class='danger'>[user] manages to [break_cuffs ? "break" : "remove"] [src]!</span>", "<span class='notice'>You successfully [break_cuffs ? "break" : "remove"] [src].</span>")
	user.unequip(src)

	if(break_cuffs)
		qdel(src)
		return TRUE
	else
		forceMove(user.drop_location())

//////////////////////////////
// MARK: HANDCUFFS
//////////////////////////////
/obj/item/restraints/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon_state = "handcuff"
	belt_icon = "handcuffs"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_range = 5
	materials = list(MAT_METAL=500)
	origin_tech = "engineering=3;combat=3"
	breakouttime = 1 MINUTES
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 50)
	/// Sound made when cuffing someone.
	var/cuffsound = 'sound/weapons/handcuffs.ogg'
	/// Trash item generated when cuffs are broken (for disposable cuffs).
	var/trashtype
	/// If set to TRUE, people with the TRAIT_CLUMSY won't cuff themselves when trying to cuff others.
	var/ignoresClumsy = FALSE

/obj/item/restraints/handcuffs/attack__legacy__attackchain(mob/living/carbon/C, mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(!istype(C))
		return

	if(flags & NODROP)
		to_chat(user, "<span class='warning'>[src] is stuck to your hand!</span>")
		return

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50) && (!ignoresClumsy))
		to_chat(user, "<span class='warning'>Uh... how do those things work?!</span>")
		apply_cuffs(user, user)
		return

	cuff(C, user)

/obj/item/restraints/handcuffs/proc/cuff(mob/living/carbon/C, mob/user, remove_src = TRUE)
	if(!istype(C)) // Shouldn't be able to cuff anything but carbons.
		return

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!(H.has_left_hand() || H.has_right_hand()))
			to_chat(user, "<span class='warning'>How do you suggest handcuffing someone with no hands?</span>")
			return FALSE

	if(!C.handcuffed)
		C.visible_message("<span class='danger'>[user] is trying to put [src.name] on [C]!</span>", \
							"<span class='userdanger'>[user] is trying to put [src.name] on [C]!</span>")

		playsound(loc, cuffsound, 15, TRUE, -10)
		if(do_mob(user, C, 30))
			apply_cuffs(C, user, remove_src)
			to_chat(user, "<span class='notice'>You handcuff [C].</span>")
			SSblackbox.record_feedback("tally", "handcuffs", 1, type)
			if(breakouttime != 0)
				add_attack_logs(user, C, "Handcuffed ([src])")
			else
				add_attack_logs(user, C, "Handcuffed (Fake/Breakable!) ([src])")
		else
			to_chat(user, "<span class='warning'>You fail to handcuff [C].</span>")
			return FALSE

/obj/item/restraints/handcuffs/proc/apply_cuffs(mob/living/carbon/target, mob/user, remove_src = TRUE)
	if(!target.handcuffed)
		if(remove_src)
			user.drop_item()
		if(trashtype)
			target.handcuffed = new trashtype(target)
			if(remove_src)
				qdel(src)
		else
			if(remove_src)
				loc = target
				target.handcuffed =  src
			else
				target.handcuffed = new type(loc)
		target.update_handcuffed()
		return

//////////////////////////////
// MARK: CUFF SKINS
//////////////////////////////
/obj/item/restraints/handcuffs/alien
	icon_state = "handcuffAlien"

/obj/item/restraints/handcuffs/pinkcuffs
	name = "fluffy pink handcuffs"
	desc = "Use this to keep prisoners in line, they are really itchy."
	icon_state = "pinkcuffs"
	cuffed_state = "pinkcuff"

//////////////////////////////
// MARK: SINEW CUFFS
//////////////////////////////
/obj/item/restraints/handcuffs/sinew
	name = "sinew restraints"
	desc = "A pair of restraints fashioned from long strands of flesh."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sinewcuff"
	item_state = "sinewcuff"
	belt_icon = null
	breakouttime = 30 SECONDS
	cuffsound = 'sound/weapons/cablecuff.ogg'

//////////////////////////////
// MARK: CABLE CUFFS
//////////////////////////////
/obj/item/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cablecuff"
	item_state = "cablecuff"
	cuffed_state = "cablecuff"
	belt_icon = "cablecuff"
	origin_tech = "engineering=2"
	materials = list(MAT_METAL=150, MAT_GLASS=75)
	breakouttime = 30 SECONDS
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/cable/red
	color = COLOR_RED

/obj/item/restraints/handcuffs/cable/yellow
	color = COLOR_YELLOW

/obj/item/restraints/handcuffs/cable/blue
	color = COLOR_BLUE

/obj/item/restraints/handcuffs/cable/green
	color = COLOR_GREEN

/obj/item/restraints/handcuffs/cable/pink
	color = COLOR_PINK

/obj/item/restraints/handcuffs/cable/orange
	color = COLOR_ORANGE

/obj/item/restraints/handcuffs/cable/cyan
	color = COLOR_CYAN

/obj/item/restraints/handcuffs/cable/white
	color = COLOR_WHITE

/obj/item/restraints/handcuffs/cable/random/New()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN, COLOR_ORANGE)
	..()

/obj/item/restraints/handcuffs/cable/proc/cable_color(colorC)
	if(!colorC)
		color = COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = COLOR_ORANGE
	else
		color = colorC

/obj/item/restraints/handcuffs/cable/proc/color_rainbow()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	return color

//////////////////////////////
// MARK: ZIPTIES
//////////////////////////////
/obj/item/restraints/handcuffs/cable/zipties
	name = "zipties"
	desc = "Plastic, disposable zipties that can be used to restrain temporarily but are destroyed after use."
	breakouttime = 45 SECONDS
	materials = list()
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/used

/obj/item/restraints/handcuffs/cable/zipties/used
	desc = "A pair of broken zipties."
	icon_state = "cablecuff_used"

/obj/item/restraints/handcuffs/cable/zipties/used/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(isdrone(user))
		C.stored_comms["glass"] += 1
		qdel(src)
		return TRUE
	return ..()

/obj/item/restraints/handcuffs/cable/zipties/used/attack__legacy__attackchain()
	return

//////////////////////////////
// MARK: TWIMSTS
//////////////////////////////
/obj/item/restraints/handcuffs/twimsts
	name = "twimsts cuffs"
	desc = "Liquorice twist candy made into cable cuffs, tasty but it can't actually hold anyone."
	icon_state = "cablecuff"
	item_state = "cablecuff"
	cuffed_state = "cablecuff"
	belt_icon = "cablecuff"
	color = "#E31818"
	throwforce = 0
	breakouttime = 0
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/twimsts/finish_resist_restraints(mob/living/carbon/user, break_cuffs)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(!human_user.check_has_mouth()) // I have no mouth but I must eat twimsts
			break_cuffs = TRUE
			return ..()

	visible_message("<span class='danger'>[user] manages to eat through [src]!</span>", "<span class='notice'>You successfully eat through [src].</span>")

	playsound(loc, 'sound/items/eatfood.ogg', 50, FALSE)
	if(reagents && length(reagents.reagent_list))
		user.taste(reagents)
		reagents.reaction(user, REAGENT_INGEST)
		reagents.trans_to(user, reagents.total_volume)
	qdel(src)

//////////////////////////////
// MARK: CRAFTING
//////////////////////////////
/obj/item/restraints/handcuffs/cable/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	..()

	handle_attack_construction(I, user)

/obj/item/restraints/handcuffs/cable/proc/handle_attack_construction(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(!R.use(1))
			to_chat(user, "<span class='warning'>[R.amount > 1 ? "These rods" : "This rod"] somehow can't be used for crafting!</span>")
			return
		if(!user.unequip(src))
			return
		var/obj/item/wirerod/W = new /obj/item/wirerod(get_turf(src))
		if(!remove_item_from_storage(user))
			user.put_in_hands(W)
		to_chat(user, "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>")
		qdel(src)
		return

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.amount < 6)
			to_chat(user, "<span class='warning'>You need at least six metal sheets to make good enough weights!</span>")
			return

		to_chat(user, "<span class='notice'>You begin to apply [I] to [src]...</span>")
		if(do_after(user, 3.5 SECONDS * M.toolspeed, target = src))
			if(!M.use(6) || !user.unequip(src))
				return
			var/obj/item/restraints/legcuffs/bola/S = new /obj/item/restraints/legcuffs/bola(get_turf(src))
			to_chat(user, "<span class='notice'>You make some weights out of [I] and tie them to [src].</span>")
			if(!remove_item_from_storage(user))
				user.put_in_hands(S)
			qdel(src)
		return

	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		cable_color(C.dye_color)

/obj/item/restraints/handcuffs/cable/zipties/cyborg/attack__legacy__attackchain(mob/living/carbon/C, mob/user)
	if(isrobot(user))
		cuff(C, user, FALSE)

/obj/item/restraints/handcuffs/cable/zipties/cyborg/handle_attack_construction(obj/item/I, mob/user)
	// Don't allow borgs to send their their ziptie module to the shadow realm.
	return
