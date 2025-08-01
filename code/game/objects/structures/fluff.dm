//Fluff structures serve no purpose and exist only for enriching the environment. They can be destroyed with a wrench.

/obj/structure/fluff
	name = "fluff structure"
	desc = "Fluffier than a sheep. This shouldn't exist."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "minibar"
	anchored = TRUE
	var/deconstructible = TRUE

/obj/structure/fluff/wrench_act(mob/living/user, obj/item/I)
	if(!deconstructible)
		return FALSE

	user.visible_message("<span class='notice'>[user] starts disassembling [src]...</span>", "<span class='notice'>You start disassembling [src]...</span>")
	playsound(loc, I.usesound, 50, TRUE)
	if(I.use_tool(src, user, 5 SECONDS, 0, 50))
		user.visible_message("<span class='notice'>[user] disassembles [src]!</span>", "<span class='notice'>You break down [src] into scrap metal.</span>")
		playsound(user, 'sound/items/deconstruct.ogg', 50, TRUE)
		new /obj/item/stack/sheet/metal(drop_location())
		qdel(src)
	return TRUE

/// Empty terrariums are created when a preserved terrarium in a lavaland seed vault is activated.
/obj/structure/fluff/empty_terrarium
	name = "empty terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. Its hatch is ajar."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium_open"
	density = TRUE

/// Empty sleepers are created by a good few ghost roles in lavaland.
/obj/structure/fluff/empty_sleeper
	name = "empty sleeper"
	desc = "An open sleeper. It looks as though it would be awaiting another patient, were it not broken."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper-open"

/obj/structure/fluff/empty_sleeper/nanotrasen
	name = "broken hypersleep chamber"
	desc = "A Nanotrasen hypersleep chamber - this one appears broken. \
		There are exposed bolts for easy disassembly using a wrench."
	icon_state = "sleeper-o"

/obj/structure/fluff/empty_sleeper/syndicate
	icon_state = "sleeper_s-open"

/// Empty cryostasis sleepers are created when a malfunctioning cryostasis sleeper in a lavaland shelter is activated
/obj/structure/fluff/empty_cryostasis_sleeper
	name = "empty cryostasis sleeper"
	desc = "Although comfortable, this sleeper won't function as anything but a bed ever again."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper_open"

/// Ash drake status spawn on either side of the necropolis gate in lavaland.
/obj/structure/fluff/drake_statue
	name = "drake statue"
	desc = "A towering basalt sculpture of a proud and regal drake. Its eyes are six glowing gemstones."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "drake_statue"
	pixel_x = -16
	density = TRUE
	deconstructible = FALSE
	layer = EDGED_TURF_LAYER

/// A variety of statue in disrepair; parts are broken off and a gemstone is missing
/obj/structure/fluff/drake_statue/falling
	desc = "A towering basalt sculpture of a drake. Cracks run down its surface and parts of it have fallen off."
	icon_state = "drake_statue_falling"

/obj/structure/fluff/divine
	name = "Miracle"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = null
	density = TRUE

/obj/structure/fluff/divine/nexus
	name = "nexus"
	desc = "It anchors a deity to this world. It radiates an unusual aura. It looks well protected from explosive shock."
	icon_state = "nexus"

/obj/structure/fluff/divine/conduit
	name = "conduit"
	desc = "It allows a deity to extend their reach. Their powers are just as potent near a conduit as a nexus."
	icon_state = "conduit"
