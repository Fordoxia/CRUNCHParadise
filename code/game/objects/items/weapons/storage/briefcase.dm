/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = CONDUCT
	hitsound = "swing_hit"
	use_sound = 'sound/effects/briefcase.ogg'
	force = 8
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	resistance_flags = FLAMMABLE
	max_integrity = 150

/obj/item/storage/briefcase/sniperbundle
	desc = "Its label reads \"genuine hardened Captain leather\", but suspiciously has no other tags or branding. Smells like L'Air du Temps."
	force = 10

/obj/item/storage/briefcase/sniperbundle/populate_contents()
	new /obj/item/gun/projectile/automatic/sniper_rifle/syndicate(src)
	new /obj/item/clothing/neck/tie/red(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/suppressor/specialoffer(src)

/obj/item/storage/briefcase/false_bottomed
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 10

	var/busy_hunting = FALSE
	var/bottom_open = FALSE //is the false bottom open?
	var/obj/item/stored_item = null //what's in the false bottom. If it's a gun, we can fire it

/obj/item/storage/briefcase/false_bottomed/Destroy()
	if(stored_item)//since the stored_item isn't in the briefcase' contents we gotta remind the game to delete it here.
		QDEL_NULL(stored_item)
	return ..()

/obj/item/storage/briefcase/false_bottomed/afterattack__legacy__attackchain(atom/A, mob/user, flag, params)
	..()
	if(stored_item && isgun(stored_item))
		var/obj/item/gun/stored_gun = stored_item
		stored_gun.afterattack__legacy__attackchain(A, user, flag, params)

/obj/item/storage/briefcase/false_bottomed/attackby__legacy__attackchain(obj/item/I, mob/user)
	if(bottom_open)
		if(stored_item)
			to_chat(user, "<span class='warning'>There's already something in the false bottom!</span>")
			return
		if(I.w_class > WEIGHT_CLASS_NORMAL)
			to_chat(user, "<span class='warning'>[I] is too big to fit in the false bottom!</span>")
			return
		if(!user.drop_item(I))
			to_chat(user, "<span class='warning'>[I] is stuck to your hands!</span>")
			return

		stored_item = I
		max_w_class = WEIGHT_CLASS_NORMAL - stored_item.w_class
		I.moveToNullspace() // to stop it showing up in the briefcase
		to_chat(user, "<span class='notice'>You place [I] into the false bottom of the briefcase.</span>")
	else
		return ..()

/obj/item/storage/briefcase/false_bottomed/screwdriver_act(mob/user, obj/item/I)
	if(!bottom_open && busy_hunting)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!bottom_open)
		to_chat(user, "<span class='notice'>You begin to hunt around the rim of [src]...</span>")
		busy_hunting = TRUE
		if(do_after(user, 20, target = src))
			if(user)
				to_chat(user, "You pry open the false bottom!")
			bottom_open = TRUE
		busy_hunting = FALSE
	else
		to_chat(user, "<span class='notice'>You push the false bottom down and close it with a click[stored_item ? ", with [stored_item] snugly inside." : "."]</span>")
		bottom_open = FALSE

/obj/item/storage/briefcase/false_bottomed/attack_hand(mob/user)
	if(bottom_open && stored_item)
		user.put_in_hands(stored_item)
		to_chat(user, "<span class='notice'>You pull out [stored_item] from [src]'s false bottom.</span>")
		stored_item = null
		max_w_class = initial(max_w_class)
	else
		return ..()
