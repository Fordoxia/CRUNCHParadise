// Corn
/obj/item/seeds/corn
	name = "pack of corn seeds"
	desc = "I don't mean to sound corny..."
	icon_state = "seed-corn"
	species = "corn"
	plantname = "Corn Stalks"
	product = /obj/item/food/grown/corn
	maturation = 8
	potency = 20
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "corn-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "corn-dead" // Same for the dead icon
	mutatelist = list(/obj/item/seeds/corn/snapcorn)
	reagents_add = list("cornoil" = 0.2, "vitamin" = 0.04, "plantmatter" = 0.1)

/obj/item/food/grown/corn
	seed = /obj/item/seeds/corn
	name = "ear of corn"
	desc = "Needs some butter!"
	icon_state = "corn"
	cooked_type = /obj/item/food/popcorn
	filling_color = "#FFFF00"
	trash = /obj/item/grown/corncob
	bitesize_mod = 2
	tastes = list("corn" = 1)
	distill_reagent = "whiskey"
	wine_power = 0.4

/obj/item/grown/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon_state = "corncob"
	item_state = "corncob"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3

/obj/item/grown/corncob/attackby__legacy__attackchain(obj/item/grown/W, mob/user, params)
	if(W.sharp)
		to_chat(user, "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>")
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		qdel(src)
		return
	else
		return ..()

// Snapcorn
/obj/item/seeds/corn/snapcorn
	name = "pack of snapcorn seeds"
	desc = "Oh snap!"
	icon_state = "seed-snapcorn"
	species = "snapcorn"
	plantname = "Snapcorn Stalks"
	product = /obj/item/grown/snapcorn
	mutatelist = list()
	rarity = 10

/obj/item/grown/snapcorn
	seed = /obj/item/seeds/corn/snapcorn
	name = "snap corn"
	desc = "A cob with snap pops."
	icon_state = "snapcorn"
	item_state = "corncob"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	var/snap_pops = 1

/obj/item/grown/snapcorn/add_juice()
	..()
	snap_pops = max(round(seed.potency/8), 1)

/obj/item/grown/snapcorn/attack_self__legacy__attackchain(mob/user)
	..()
	to_chat(user, "<span class='notice'>You pick a snap pop from the cob.</span>")
	var/obj/item/toy/snappop/S = new /obj/item/toy/snappop(user.loc)
	if(ishuman(user))
		user.put_in_hands(S)
	snap_pops -= 1
	if(!snap_pops)
		new /obj/item/grown/corncob(user.loc)
		qdel(src)
