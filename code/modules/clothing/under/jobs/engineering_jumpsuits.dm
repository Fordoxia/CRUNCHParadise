/obj/item/clothing/under/rank/engineering
	icon = 'icons/obj/clothing/under/engineering.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/engineering.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/engineering.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/engineering.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/engineering.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/engineering.dmi'
		)

/obj/item/clothing/under/rank/engineering/chief_engineer
	name = "chief engineer's uniform"
	desc = "It's a yellow dress shirt and black slacks given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	icon_state = "ce"
	item_state = "ce"
	item_color = "ce"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 200, ACID = 35)
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/chief_engineer/skirt
	name = "chief engineer's skirt"
	desc = "It's a yellow dress shirt and black skirt given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	icon_state = "ce_skirt"
	item_color = "ce_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/engineering/atmospheric_technician
	name = "atmospheric technician's jumpsuit"
	desc = "It's a jumpsuit worn by atmospheric technicians."
	icon_state = "atmos"
	item_state = "atmos"
	item_color = "atmos"
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist
	desc = "A light jumpsuit useful for squeezing through narrow vents."
	resistance_flags = FIRE_PROOF

/obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_JUMPSUIT)
		return
	if(!user.ventcrawler)
		user.ventcrawler = VENTCRAWLER_ALWAYS

/obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist/dropped(mob/living/carbon/human/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_JUMPSUIT) != src)
		return
	if(!user.get_int_organ(/obj/item/organ/internal/heart/gland/ventcrawling)) // This is such a snowflaky check
		user.ventcrawler = VENTCRAWLER_NONE

/obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist/proc/check_clothing(mob/user as mob)
	//Allowed to wear: glasses, shoes, gloves, pockets, mask, and jumpsuit (obviously)
	var/list/slot_must_be_empty = list(ITEM_SLOT_BACK,ITEM_SLOT_HANDCUFFED,ITEM_SLOT_LEGCUFFED,ITEM_SLOT_LEFT_HAND,ITEM_SLOT_RIGHT_HAND,ITEM_SLOT_BELT,ITEM_SLOT_HEAD,ITEM_SLOT_OUTER_SUIT)
	for(var/slot_id in slot_must_be_empty)
		if(user.get_item_by_slot(slot_id))
			to_chat(user,"<span class='warning'>You can't fit inside while wearing \the [user.get_item_by_slot(slot_id)].</span>")
			return 0
	return 1

/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt
	name = "atmospheric technician's jumpskirt"
	desc = "It's a jumpskirt worn by atmospheric technicians."
	icon_state = "atmos_skirt"
	item_color = "atmos_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineering/engineer
	name = "engineer's jumpsuit"
	desc = "It's an orange high visibility jumpsuit worn by engineers. It has minor radiation shielding."
	icon_state = "engineer"
	item_state = "engineer"
	item_color = "engineer"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 75, ACID = 10)
	resistance_flags = NONE

/obj/item/clothing/under/rank/engineering/engineer/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/engineering/engineer/skirt
	name = "engineer's jumpskirt"
	desc = "It's an orange high visibility jumpskirt worn by engineers. It has minor radiation shielding."
	icon_state = "engineer_skirt"
	item_color = "engineer_skirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
