// Used for 'select equipment'
// code/modules/admin/verbs/debug.dm 566

/datum/outfit/admin/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	H.job = name

/datum/outfit/admin/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	H.mind.assigned_role = name
	H.mind.offstation_role = TRUE

/proc/apply_to_card(obj/item/card/id/I, mob/living/carbon/human/H, list/access = list(), rank, special_icon)
	if(!istype(I) || !istype(H))
		return 0

	I.access = access
	I.registered_name = H.real_name
	I.rank = rank
	I.assignment = rank
	I.sex = capitalize(H.gender)
	I.age = H.age
	I.name = "[I.registered_name]'s ID Card ([I.assignment])"
	I.photo = get_id_photo(H)

	if(special_icon)
		I.icon_state = special_icon

/datum/outfit/admin/syndicate
	name = "Syndicate Agent"

	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id/syndicate
	r_pocket = /obj/item/radio/uplink
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/flashlight = 1,
		/obj/item/card/emag = 1,
		/obj/item/food/syndidonkpocket = 1
	)

	var/id_icon = "syndie"
	var/id_access = "Syndicate Operative"
	var/uplink_uses = 100

/datum/outfit/admin/syndicate/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_syndicate_access(id_access), name, id_icon)

	var/obj/item/radio/uplink/U = H.r_store
	if(istype(U))
		U.hidden_uplink.uplink_owner = "[H.key]"
		U.hidden_uplink.uses = uplink_uses

	var/obj/item/radio/R = H.l_ear
	if(istype(R))
		R.set_frequency(SYND_FREQ)
	H.faction += "syndicate"

/datum/outfit/admin/syndicate_infiltrator
	name = "Syndicate Infiltrator"

/datum/outfit/admin/syndicate_infiltrator/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = H.equip_syndicate_infiltrator(0, 100, FALSE)
	H.sec_hud_set_ID()
	H.faction |= "syndicate"

/datum/outfit/admin/syndicate/operative
	name = "Syndicate Nuclear Operative"

	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	belt = /obj/item/storage/belt/military
	mask = /obj/item/clothing/mask/gas/syndicate
	l_ear = /obj/item/radio/headset/syndicate/alt
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/magboots/syndie
	r_pocket = /obj/item/radio/uplink/nuclear
	l_pocket = /obj/item/pinpointer/advpinpointer
	l_hand = /obj/item/tank/internals/oxygen/red

	backpack_contents = list(
		/obj/item/storage/box/survival_syndie = 1,
		/obj/item/gun/projectile/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/crowbar/red = 1,
		/obj/item/grenade/plastic/c4 = 1,
		/obj/item/food/syndidonkpocket = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/shoes/combat = 1
	)

/datum/outfit/admin/syndicate/operative/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/bio_chip/explosive/E = new(H)
	E.implant(H)


/datum/outfit/admin/syndicate/operative/freedom
	name = "Syndicate Freedom Operative"
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/freedom


/datum/outfit/admin/syndicate_strike_team
	name = "Syndicate Strike Team"

/datum/outfit/admin/syndicate_strike_team/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = H.equip_syndicate_commando(FALSE, TRUE)
	H.faction |= "syndicate"

/datum/outfit/admin/syndicate/spy
	name = "Syndicate Spy"
	uniform = /obj/item/clothing/under/suit/really_black
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	uplink_uses = 200
	id_access = "Syndicate Agent"

	bio_chips = list(
		/obj/item/bio_chip/dust
	)


/datum/outfit/admin/nt_vip
	name = "VIP Guest"

	uniform = /obj/item/clothing/under/suit/really_black
	back = /obj/item/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/that
	l_ear = /obj/item/radio/headset/ert
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1
	)

/datum/outfit/admin/nt_vip/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("VIP Guest"), "VIP Guest")
	H.sec_hud_set_ID()

/datum/outfit/admin/nt_navy_captain
	name = "NT Navy Captain"

	uniform = /obj/item/clothing/under/rank/centcom/captain
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/gun/energy/pulse/pistol
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	head = /obj/item/clothing/head/beret/centcom/captain
	l_ear = /obj/item/radio/headset/centcom
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	id = /obj/item/card/id/centcom
	pda = /obj/item/pda/centcom
	backpack_contents = list(
		/obj/item/storage/box/centcomofficer = 1,
		/obj/item/bio_chip_implanter/death_alarm = 1
	)
	bio_chips = list(
		/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/dust
	)

/datum/outfit/admin/nt_navy_captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Captain"), "Nanotrasen Navy Captain")
	H.sec_hud_set_ID()

/datum/outfit/admin/nt_diplomat
	name = "NT Diplomat"

	uniform = /obj/item/clothing/under/rank/centcom/diplomatic
	back = /obj/item/storage/backpack/satchel
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/radio/headset/centcom
	id = /obj/item/card/id/centcom
	r_pocket = /obj/item/lighter/zippo/nt_rep
	l_pocket = /obj/item/storage/fancy/cigarettes/dromedaryco
	pda = /obj/item/pda/centcom
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/bio_chip_implanter/death_alarm = 1,
	)
	bio_chips = list(
		/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/dust
	)

/datum/outfit/admin/nt_diplomat/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Nanotrasen Navy Representative"), "Nanotrasen Diplomat")
	H.sec_hud_set_ID()

/datum/outfit/admin/nt_undercover
	name = "NT Undercover Operative"
	// Disguised NT special forces, sent to quietly eliminate or keep tabs on people in high positions (e.g: captain)

	uniform = /obj/item/clothing/under/color/random
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	l_ear = /obj/item/radio/headset/centcom
	id = /obj/item/card/id
	pda = /obj/item/pda
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/flashlight = 1,
		/obj/item/pinpointer/crew = 1
	)
	bio_chips = list(
		/obj/item/bio_chip/dust
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/eyes/cybernetic/xray,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/arm/combat/centcom
	)

/datum/outfit/admin/nt_undercover/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("NT Undercover Operative"), "Assistant")
	H.sec_hud_set_ID() // Force it to show as assistant on sec huds

	var/obj/item/radio/R = H.l_ear
	if(istype(R))
		R.name = "radio headset"
		R.icon_state = "headset"

/datum/outfit/admin/deathsquad_commando
	name = "NT Deathsquad"

	pda = /obj/item/pinpointer
	box = /obj/item/storage/box/deathsquad
	back = /obj/item/mod/control/pre_equipped/apocryphal
	belt = /obj/item/gun/projectile/revolver/mateba
	gloves = /obj/item/clothing/gloves/combat
	uniform = /obj/item/clothing/under/rank/centcom/deathsquad
	shoes = /obj/item/clothing/shoes/magboots/elite
	glasses = /obj/item/clothing/glasses/hud/security/night
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_pocket = /obj/item/reagent_containers/hypospray/combat/nanites
	l_ear = /obj/item/radio/headset/alt/deathsquad
	id = /obj/item/card/id/ert/deathsquad
	suit_store = /obj/item/gun/energy/pulse

	backpack_contents = list(
		/obj/item/storage/box/smoke_grenades,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a357,
		/obj/item/ammo_box/a357,
		/obj/item/flashlight/seclite,
		/obj/item/grenade/barrier,
		/obj/item/melee/energy/sword/saber,
		/obj/item/shield/energy,
		/obj/item/soap/ds
	)

	cybernetic_implants = list(
		/obj/item/organ/internal/eyes/cybernetic/thermals/hardened,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened,
		/obj/item/organ/internal/cyberimp/chest/reviver/hardened
	)

	bio_chips = list(
		/obj/item/bio_chip/mindshield, // No death alarm, Deathsquad are silent
		/obj/item/bio_chip/dust
	)

/datum/outfit/admin/deathsquad_commando/leader
	name = "NT Deathsquad Leader"
	back = /obj/item/mod/control/pre_equipped/apocryphal/officer

	backpack_contents = list(
		/obj/item/storage/box/flashbangs,
		/obj/item/ammo_box/a357,
		/obj/item/flashlight/seclite,
		/obj/item/melee/energy/sword/saber,
		/obj/item/shield/energy,
		/obj/item/disk/nuclear/unrestricted
	)

/datum/outfit/admin/deathsquad_commando/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_centcom_access("Deathsquad Commando"), "Deathsquad")
	H.sec_hud_set_ID()

/datum/outfit/admin/pirate
	name = "Space Pirate"

	uniform = /obj/item/clothing/under/costume/pirate
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id
	r_hand = /obj/item/melee/energy/sword/pirate
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/pirate/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), name)

/datum/outfit/admin/pirate/first_mate
	name = "Space Pirate First Mate"

	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/bandana

/datum/outfit/admin/pirate/captain
	name = "Space Pirate Captain"

	suit = /obj/item/clothing/suit/pirate_black
	head = /obj/item/clothing/head/pirate

/datum/outfit/admin/tunnel_clown
	name = "Tunnel Clown"

	uniform = /obj/item/clothing/under/rank/civilian/clown
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/storage/backpack
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/clown_shoes
	mask = /obj/item/clothing/mask/gas/clown_hat
	l_ear = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/card/id
	l_pocket = /obj/item/food/grown/banana
	r_pocket = /obj/item/bikehorn
	r_hand = /obj/item/fireaxe
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
		/obj/item/reagent_containers/drinks/bottle/bottleofbanana = 1,
		/obj/item/grenade/clown_grenade = 1,
		/obj/item/melee/baton/cattleprod = 1,
		/obj/item/stock_parts/cell/super = 1,
		/obj/item/bikehorn/rubberducky = 1
	)

/datum/outfit/admin/tunnel_clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS), "Tunnel Clown")

/datum/outfit/admin/mime_assassin
	name = "Mime Assassin"

	uniform = /obj/item/clothing/under/rank/civilian/mime
	suit = /obj/item/clothing/suit/suspenders
	back = /obj/item/storage/backpack/mime
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/beret
	mask = /obj/item/clothing/mask/gas/mime
	l_ear = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/card/id/syndicate
	pda = /obj/item/pda/mime
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/reagent_containers/drinks/bottle/bottleofnothing = 1,
		/obj/item/toy/crayon/mime = 1,
		/obj/item/gun/projectile/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
		/obj/item/suppressor = 1,
		/obj/item/card/emag = 1,
		/obj/item/radio/uplink = 1,
		/obj/item/food/syndidonkpocket = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/mime_assassin/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/civilian/mime/sexy
		suit = /obj/item/clothing/mask/gas/sexymime

/datum/outfit/admin/mime_assassin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/pda/PDA = H.wear_pda
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = "Mime"
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MIME, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS), "Mime")
	H.sec_hud_set_ID()

/datum/outfit/admin/greytide
	name = "Greytide"

	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/brown
	mask = /obj/item/clothing/mask/gas
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id
	l_hand = /obj/item/storage/toolbox/mechanical
	r_hand = /obj/item/flag/grey
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/greytide/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Greytide")

/datum/outfit/admin/greytide/leader
	name = "Greytide Leader"

	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/yellow

	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/clothing/head/welding = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/greytide/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..(H, TRUE)
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Greytide Leader")

/datum/outfit/admin/greytide/xeno
	name = "Greytide Xeno"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/xenos
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/utility/full/multitool
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/xenos
	glasses = /obj/item/clothing/glasses/thermal
	l_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_pocket = /obj/item/toy/figure/xeno
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/clothing/head/welding = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/greytide/xeno/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..(H, TRUE)
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Legit Xenomorph")



/datum/outfit/admin/musician
	name = "Musician"

	uniform = /obj/item/clothing/under/costume/singerb
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/singerb
	gloves = /obj/item/clothing/gloves/color/white
	l_ear = /obj/item/radio/headset
	r_ear = /obj/item/clothing/ears/headphones
	pda = /obj/item/pda
	id = /obj/item/card/id
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
		/obj/item/instrument/violin = 1,
		/obj/item/instrument/piano_synth = 1,
		/obj/item/instrument/guitar = 1,
		/obj/item/instrument/eguitar = 1,
		/obj/item/instrument/accordion = 1,
		/obj/item/instrument/saxophone = 1,
		/obj/item/instrument/trombone = 1,
		/obj/item/instrument/harmonica = 1
	)

/datum/outfit/admin/musician/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Bard")

	var/obj/item/clothing/ears/headphones/P = H.r_ear
	if(istype(P))
		P.toggle_visual_notes(H) // activate them, display musical notes effect

// Soviet Military

/datum/outfit/admin/soviet
	name = "Soviet Tourist"
	uniform = /obj/item/clothing/under/new_soviet
	back = /obj/item/storage/backpack/satchel
	head = /obj/item/clothing/head/sovietsidecap
	id = /obj/item/card/id/data
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/radio/headset/soviet
	backpack_contents = list(
		/obj/item/storage/box/survival = 1
	)

/datum/outfit/admin/soviet/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	H.real_name = "[capitalize(pick(GLOB.first_names_soviet))] [capitalize(pick(GLOB.last_names_soviet))]"
	H.name = H.real_name
	H.add_language("Zvezhan")
	H.set_default_language(GLOB.all_languages["Zvezhan"])
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), name)
	H.sec_hud_set_ID()

/datum/outfit/admin/soviet/conscript
	name = "Soviet Conscript"

	r_pocket = /obj/item/flashlight/seclite
	r_hand = /obj/item/gun/projectile/shotgun/boltaction
	belt = /obj/item/gun/projectile/revolver/nagant

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/ammo_box/a762 = 4
	)

/datum/outfit/admin/soviet/soldier
	name = "Soviet Soldier"

	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/sovietcoat
	glasses = /obj/item/clothing/glasses/sunglasses
	r_pocket = /obj/item/flashlight/seclite
	belt = /obj/item/gun/projectile/automatic/pistol/type_230

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/lighter = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_robust = 1,
		/obj/item/ammo_box/magazine/apsm10mm = 2
	)

/datum/outfit/admin/soviet/officer
	name = "Soviet Officer"

	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/sovietcoat/officer
	uniform = /obj/item/clothing/under/new_soviet/sovietofficer
	head = /obj/item/clothing/head/sovietofficerhat
	glasses = /obj/item/clothing/glasses/sunglasses
	belt = /obj/item/gun/projectile/revolver/mateba
	l_pocket = /obj/item/melee/classic_baton/telescopic
	r_pocket = /obj/item/flashlight/seclite

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/lighter/zippo = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/ammo_box/a357 = 2
	)

/datum/outfit/admin/soviet/marine
	name = "Soviet Marine"

	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/space/hardsuit/soviet
	head = null
	mask = /obj/item/clothing/mask/gas
	glasses = /obj/item/clothing/glasses/night
	belt = /obj/item/storage/belt/military/assault/soviet/full
	r_pocket = /obj/item/melee/classic_baton/telescopic
	l_hand = /obj/item/gun/projectile/automatic/ak814
	suit_store = /obj/item/tank/internals/emergency_oxygen/double

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/gun/projectile/automatic/pistol/type_230 = 1,
		/obj/item/ammo_box/magazine/apsm10mm = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/lighter/zippo/engraved = 1
	)

/datum/outfit/admin/soviet/marine/captain
	name = "Soviet Marine Captain"

	uniform = /obj/item/clothing/under/new_soviet/sovietofficer
	suit = /obj/item/clothing/suit/space/hardsuit/soviet/commander

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/gun/projectile/revolver/mateba = 1,
		/obj/item/ammo_box/a357 = 2,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 1,
		/obj/item/lighter/zippo/engraved = 1
	)

/datum/outfit/admin/soviet/admiral
	name = "Soviet Admiral"

	gloves = /obj/item/clothing/gloves/combat
	uniform = /obj/item/clothing/under/new_soviet/sovietadmiral
	head = /obj/item/clothing/head/sovietadmiralhat
	belt = /obj/item/gun/projectile/revolver/mateba
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	l_pocket = /obj/item/melee/classic_baton/telescopic

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1,
		/obj/item/ammo_box/a357 = 3
	)

/datum/outfit/admin/solgov_rep
	name = "Trans-Solar Federation Representative"

	uniform = /obj/item/clothing/under/solgov/rep
	back = /obj/item/storage/backpack/satchel
	glasses = /obj/item/clothing/glasses/hud/security/night
	gloves = /obj/item/clothing/gloves/color/white
	shoes = /obj/item/clothing/shoes/centcom
	l_ear = /obj/item/radio/headset/ert
	id = /obj/item/card/id/silver
	r_pocket = /obj/item/lighter/zippo/blue
	l_pocket = /obj/item/storage/fancy/cigarettes/cigpack_robustgold
	pda = /obj/item/pda
	backpack_contents = list(
		/obj/item/storage/box/responseteam = 1,
		/obj/item/bio_chip_implanter/dust = 1,
		/obj/item/bio_chip_implanter/death_alarm = 1,
	)

	bio_chips = list(/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/death_alarm
	)

/datum/outfit/admin/solgov_rep/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_centcom_access(), name, "lifetimeid")
	I.assignment = "Trans-Solar Federation Representative"
	H.sec_hud_set_ID()


/datum/outfit/admin/solgov
	name = "TSF Marine"
	uniform = /obj/item/clothing/under/solgov
	suit = /obj/item/clothing/suit/armor/bulletproof
	back = /obj/item/storage/backpack/ert/solgov
	belt = /obj/item/storage/belt/military/assault/marines/full
	head = /obj/item/clothing/head/soft/solgov/marines
	glasses = /obj/item/clothing/glasses/night
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/radio/headset/ert/alt/solgov
	id = /obj/item/card/id
	l_hand = /obj/item/gun/projectile/automatic/shotgun/bulldog
	suit_store = /obj/item/gun/projectile/automatic/pistol/m1911
	r_pocket = /obj/item/flashlight/seclite
	pda = /obj/item/pda
	box = /obj/item/storage/box/responseteam
	backpack_contents = list(
		/obj/item/clothing/shoes/magboots = 1,
		/obj/item/whetstone = 1,
		/obj/item/clothing/mask/gas/explorer/marines = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/survival = 1
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/arm/flash,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened,
		/obj/item/organ/internal/cyberimp/eyes/hud/security
	)
	bio_chips = list(/obj/item/bio_chip/mindshield,
		/obj/item/bio_chip/death_alarm
	)

	var/is_solgov_lieutenant = FALSE


/datum/outfit/admin/solgov/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(is_solgov_lieutenant)
		H.real_name = "Lieutenant [pick(GLOB.last_names)]"
	else
		H.real_name = "[pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant First Class", "Master Sergeant", "Sergeant Major")] [pick(GLOB.last_names)]"
	H.name = H.real_name
	var/obj/item/card/id/I = H.wear_id
	I.assignment = name
	if(istype(I) && is_solgov_lieutenant)
		apply_to_card(I, H, get_centcom_access("Emergency Response Team Leader"), name, "lifetimeid")
	else if(istype(I))
		apply_to_card(I, H, get_centcom_access("Emergency Response Team Member"), name, "lifetimeid")
	H.sec_hud_set_ID()

/datum/outfit/admin/solgov/lieutenant
	name = "TSF Lieutenant"
	uniform = /obj/item/clothing/under/solgov/command
	head = /obj/item/clothing/head/beret/solgov
	back = /obj/item/storage/backpack/satchel
	shoes = /obj/item/clothing/shoes/magboots/elite
	l_ear = /obj/item/radio/headset/ert/alt/commander/solgov
	l_hand = null
	belt = /obj/item/melee/baton/loaded
	suit_store = /obj/item/gun/projectile/automatic/pistol/deagle
	l_pocket = /obj/item/pinpointer/advpinpointer
	backpack_contents = list(
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/survival = 1,
		/obj/item/clothing/mask/gas/explorer/marines = 1,
		/obj/item/ammo_box/magazine/m50 = 3
	)
	is_solgov_lieutenant = TRUE

/datum/outfit/admin/solgov/elite
	name = "MARSOC Marine"
	uniform = /obj/item/clothing/under/solgov/elite
	suit = /obj/item/clothing/suit/space/hardsuit/ert/solgov
	head = null
	mask = /obj/item/clothing/mask/gas/explorer/marines
	belt = /obj/item/storage/belt/military/assault/marines/elite/full
	shoes = /obj/item/clothing/shoes/magboots/elite
	l_hand = /obj/item/gun/projectile/automatic/ar
	backpack_contents = list(
		/obj/item/whetstone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/survival = 1
	)
	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened,
		/obj/item/organ/internal/cyberimp/arm/flash,
		/obj/item/organ/internal/eyes/cybernetic/shield
	)

/datum/outfit/admin/solgov/elite/lieutenant
	name = "MARSOC Lieutenant"
	uniform = /obj/item/clothing/under/solgov/command/elite
	suit = /obj/item/clothing/suit/space/hardsuit/ert/solgov/command
	head = null
	belt = /obj/item/melee/baton/loaded
	l_hand = null
	suit_store = /obj/item/gun/projectile/automatic/pistol/deagle
	l_pocket = /obj/item/pinpointer/advpinpointer
	l_ear = /obj/item/radio/headset/ert/alt/commander/solgov
	backpack_contents = list(
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/survival = 1,
		/obj/item/ammo_box/magazine/m50 = 3
	)
	is_solgov_lieutenant = TRUE

/datum/outfit/admin/trader
	name = "Trader"
	uniform = /obj/item/clothing/under/rank/cargo/tech
	back = /obj/item/storage/backpack/industrial
	belt = /obj/item/melee/classic_baton
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses
	id = /obj/item/card/id/supply
	pda = /obj/item/pda
	backpack_contents = list(
		/obj/item/hand_labeler = 1,
		/obj/item/hand_labeler_refill = 2
	)
	box = /obj/item/storage/box/survival

/datum/outfit/admin/trader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_TRADE_SOL, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS), name)
	H.sec_hud_set_ID()

/datum/outfit/admin/trader/sol
	name = "Trans-Solar Federation Trader"
	suit = /obj/item/clothing/suit/jacket/bomber/cargo
	head = /obj/item/clothing/head/soft/cargo

/datum/outfit/admin/trader/cyber
	name = "Cybersun Industries Trader"
	uniform = /obj/item/clothing/under/syndicate/tacticool
	suit = /obj/item/clothing/suit/jacket/bomber/syndicate
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/combat
	belt = /obj/item/melee/classic_baton/telescopic
	back = /obj/item/storage/backpack/security

/datum/outfit/admin/trader/commie
	name = "USSP Trader"
	uniform = /obj/item/clothing/under/new_soviet
	suit = /obj/item/clothing/suit/sovietcoat
	head = /obj/item/clothing/head/ushanka
	box = /obj/item/storage/box/soviet

/datum/outfit/admin/trader/commie/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	H.add_language("Zvezhan")

/datum/outfit/admin/trader/unathi
	name = "Glint-Scales Trader"
	uniform = /obj/item/clothing/under/rank/cargo/qm
	suit = /obj/item/clothing/suit/unathi/robe
	shoes = /obj/item/clothing/shoes/footwraps

/datum/outfit/admin/trader/vulp
	name = "Steadfast Trading Co. Trader"
	uniform = /obj/item/clothing/under/rank/cargo/qm/formal
	suit = /obj/item/clothing/suit/jacket/leather/overcoat
	belt = /obj/item/melee/classic_baton/telescopic

/datum/outfit/admin/trader/ipc
	name = "Synthetic Union Trader"
	uniform = /obj/item/clothing/under/misc/vice
	suit = /obj/item/clothing/suit/storage/iaa/blackjacket/armored
	belt = /obj/item/melee/classic_baton/telescopic
	back = /obj/item/storage/backpack/robotics

/datum/outfit/admin/trader/vox
	name = "Skipjack Trader"
	uniform = /obj/item/clothing/under/vox/vox_casual
	suit = /obj/item/clothing/suit/hooded/vox_robes
	gloves = /obj/item/clothing/gloves/color/yellow/vox
	shoes = /obj/item/clothing/shoes/magboots/vox
	belt = /obj/item/melee/classic_baton/telescopic
	mask = /obj/item/clothing/mask/breath/vox/respirator
	suit_store = /obj/item/tank/internals/emergency_oxygen/double/vox
	box = /obj/item/storage/box/survival_vox

/datum/outfit/admin/trader/skrell
	name = "Solar-Central Compact Trader"
	uniform = /obj/item/clothing/under/misc/durathread
	suit = /obj/item/clothing/suit/space/skrell/white
	belt = /obj/item/melee/classic_baton/telescopic

/datum/outfit/admin/trader/grey
	name = "Technocracy Trader"
	uniform = /obj/item/clothing/under/costume/psyjump
	suit = /obj/item/clothing/suit/jacket/bomber/robo
	belt = /obj/item/melee/classic_baton/telescopic
	back = /obj/item/storage/backpack/robotics

/datum/outfit/admin/trader/nian
	name = "Merchant Guild Trader"
	uniform = /obj/item/clothing/under/suit/really_black
	suit = /obj/item/clothing/suit/pimpcoat
	shoes = /obj/item/clothing/shoes/fluff/noble_boot
	belt = /obj/item/melee/classic_baton/ntcane

/datum/outfit/admin/chrono
	name = "Chrono Legionnaire"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/chronos
	back = /obj/item/chrono_eraser
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/magboots/advance
	head = /obj/item/clothing/head/helmet/space/chronos
	mask = /obj/item/clothing/mask/gas/syndicate
	glasses = /obj/item/clothing/glasses/night
	id = /obj/item/card/id/syndicate
	suit_store = /obj/item/tank/internals/emergency_oxygen/double

/datum/outfit/admin/chrono/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses() + get_all_centcom_access(), name, "syndie")

/datum/outfit/admin/spacegear
	name = "Standard Space Gear"

	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/space
	back = /obj/item/tank/jetpack/oxygen
	shoes = /obj/item/clothing/shoes/magboots
	head = /obj/item/clothing/head/helmet/space
	mask = /obj/item/clothing/mask/breath
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id

/datum/outfit/admin/spacegear/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(istype(H.back, /obj/item/tank/jetpack))
		var/obj/item/tank/jetpack/J = H.back
		J.turn_on()
		J.toggle_internals(H)

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Space Explorer")

/datum/outfit/admin/modsuit
	name = "MODsuit - Generic"
	back = /obj/item/mod/control/pre_equipped/standard
	suit_store = /obj/item/tank/internals/oxygen
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/magboots
	id = /obj/item/card/id

/datum/outfit/admin/modsuit/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	if(istype(H.back, /obj/item/tank/internals/oxygen))
		var/obj/item/tank/internals/oxygen/J = H.back
		J.toggle_internals(H)

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "MODsuit Tester")

/datum/outfit/admin/modsuit/engineer
	name = "MODsuit - Engineer"
	back = /obj/item/mod/control/pre_equipped/engineering

/datum/outfit/admin/modsuit/ce
	name = "MODsuit - CE"
	back = /obj/item/mod/control/pre_equipped/advanced
	shoes = /obj/item/clothing/shoes/magboots/advance

/datum/outfit/admin/modsuit/mining
	name = "MODsuit - Mining"
	back = /obj/item/mod/control/pre_equipped/mining/asteroid

/datum/outfit/admin/modsuit/syndi
	name = "MODsuit - Syndi"
	back = /obj/item/mod/control/pre_equipped/traitor
	shoes = /obj/item/clothing/shoes/magboots/syndie

/// Technically not a MODsuit, we'll bundle it up in here for the future when it does become one
/datum/outfit/admin/modsuit/wizard
	name = "Hardsuit - Wizard"
	suit = /obj/item/clothing/suit/space/hardsuit/wizard
	shoes = /obj/item/clothing/shoes/magboots/wizard

/datum/outfit/admin/modsuit/medical
	name = "MODsuit - Medical"
	back = /obj/item/mod/control/pre_equipped/medical

/datum/outfit/admin/modsuit/atmos
	name = "MODsuit - Atmos"
	back = /obj/item/mod/control/pre_equipped/atmospheric

/datum/outfit/admin/tournament
	name = "Tournament Generic"
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/helmet/thunderdome
	r_pocket = /obj/item/grenade/smokebomb
	l_hand = /obj/item/kitchen/knife
	r_hand = /obj/item/gun/energy/pulse/destroyer

/datum/outfit/admin/tournament/red
	name = "Tournament Standard Red"
	uniform = /obj/item/clothing/under/color/red

/datum/outfit/admin/tournament/green
	name = "Tournament Standard Green"
	uniform = /obj/item/clothing/under/color/green

/// gangster are supposed to fight each other. --rastaf0
/datum/outfit/admin/tournament/tournament_gangster
	name = "Tournament Gangster"

	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/storage/det_suit
	head = /obj/item/clothing/head/det_hat
	glasses = /obj/item/clothing/glasses/thermal/monocle
	l_pocket = /obj/item/ammo_box/a357
	r_hand = /obj/item/gun/projectile/automatic/proto

/// Steven Seagal FTW
/datum/outfit/admin/tournament/tournament_chef
	name = "Tournament Chef"

	uniform = /obj/item/clothing/under/rank/civilian/chef
	suit = /obj/item/clothing/suit/chef
	head = /obj/item/clothing/head/chefhat
	l_pocket = /obj/item/kitchen/knife
	r_pocket = /obj/item/kitchen/knife
	r_hand = /obj/item/kitchen/rollingpin

/datum/outfit/admin/tournament/tournament_janitor
	name = "Tournament Janitor"

	uniform = /obj/item/clothing/under/rank/civilian/janitor
	back = /obj/item/storage/backpack
	l_hand = /obj/item/reagent_containers/glass/bucket
	backpack_contents = list(
		/obj/item/grenade/chem_grenade/cleaner = 2,
		/obj/item/stack/tile/plasteel = 7
	)

/datum/outfit/admin/tournament/tournament_janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/reagent_containers/R = H.l_hand
	if(istype(R))
		R.reagents.add_reagent("water", 70)

/datum/outfit/admin/survivor
	name = "Survivor"

	uniform = /obj/item/clothing/under/misc/overalls
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/latex
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id
	backpack_contents = list(
		/obj/item/storage/box/survival = 1
	)

/datum/outfit/admin/survivor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	for(var/obj/item/I in H.contents)
		if(!istype(I, /obj/item/bio_chip))
			I.add_mob_blood(H)

	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Survivor")

/datum/outfit/admin/masked_killer
	name = "Masked Killer"

	uniform = /obj/item/clothing/under/misc/overalls
	suit = /obj/item/clothing/suit/apron
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/latex
	shoes = /obj/item/clothing/shoes/white
	head = /obj/item/clothing/head/welding
	mask = /obj/item/clothing/mask/surgical
	l_ear = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	id = /obj/item/card/id/syndicate
	l_pocket = /obj/item/kitchen/knife
	r_pocket = /obj/item/scalpel
	r_hand = /obj/item/fireaxe
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/masked_killer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	for(var/obj/item/I in H.contents)
		if(!istype(I, /obj/item/bio_chip))
			I.add_mob_blood(H)

	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Masked Killer", "syndie")

/datum/outfit/admin/singuloth_knight
	name = "Singuloth Knight"

	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/space/hardsuit/singuloth
	back = /obj/item/storage/backpack/satchel
	l_hand = /obj/item/knighthammer
	belt = /obj/item/claymore/ceremonial
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/magboots
	mask = /obj/item/clothing/mask/breath
	l_ear = /obj/item/radio/headset/ert
	glasses = /obj/item/clothing/glasses/meson/cyber
	id = /obj/item/card/id
	suit_store = /obj/item/tank/internals/oxygen
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1
	)

/datum/outfit/admin/singuloth_knight/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Singuloth Knight")

/datum/outfit/admin/dark_lord
	name = "Dark Lord"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	l_ear = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id/syndicate
	l_hand = /obj/item/dualsaber/red
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
	)

/datum/outfit/admin/dark_lord/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/clothing/suit/hooded/chaplain_hoodie/C = H.wear_suit
	if(istype(C))
		C.name = "dark lord robes"
		C.hood.name = "dark lord hood"

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Dark Lord", "syndie")


/datum/outfit/admin/ancient_vampire
	name = "Ancient Vampire"

	uniform = /obj/item/clothing/under/suit/victsuit/red
	suit = /obj/item/clothing/suit/draculacoat
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	l_ear = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
		/obj/item/clothing/under/color/black = 1
	)

/datum/outfit/admin/ancient_vampire/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/clothing/suit/hooded/chaplain_hoodie/C = new(H.loc)
	if(istype(C))
		C.name = "ancient robes"
		C.hood.name = "ancient hood"
		H.equip_to_slot_or_del(C, ITEM_SLOT_IN_BACKPACK)

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Ancient One", "data")

/datum/outfit/admin/ancient_vampire/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	H.mind.make_vampire()
	var/datum/antagonist/vampire/V = H.mind.has_antag_datum(/datum/antagonist/vampire)
	V.bloodusable = 9999
	V.bloodtotal = 9999
	V.add_subclass(SUBCLASS_ANCIENT, FALSE)
	H.dna.SetSEState(GLOB.jumpblock, TRUE)
	singlemutcheck(H, GLOB.jumpblock, MUTCHK_FORCED)
	H.update_mutations()
	H.gene_stability = 100

/datum/outfit/admin/ancient_mindflayer
	name = "Ancient Mindflayer"

	// Shamelessly stolen from the `Dark Lord`
	uniform = /obj/item/clothing/under/color/black
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	l_ear = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
	)

/datum/outfit/admin/ancient_mindflayer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/clothing/suit/hooded/chaplain_hoodie/C = new(H.loc)
	if(istype(C))
		C.name = "ancient robes"
		C.hood.name = "ancient hood"
		H.equip_to_slot_or_del(C, ITEM_SLOT_IN_BACKPACK)

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Ancient One", "data")

/datum/outfit/admin/ancient_mindflayer/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	H.mind.make_mind_flayer()
	var/datum/antagonist/mindflayer/flayer = H.mind.has_antag_datum(/datum/antagonist/mindflayer)
	flayer.usable_swarms = 9999
	H.dna.SetSEState(GLOB.jumpblock, TRUE)
	singlemutcheck(H, GLOB.jumpblock, MUTCHK_FORCED)
	H.update_mutations()
	H.gene_stability = 100

/datum/outfit/admin/wizard
	name = "Blue Wizard"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/wizard
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id
	r_pocket = /obj/item/teleportation_scroll
	l_hand = /obj/item/staff
	r_hand = /obj/item/spellbook
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1
	)

/datum/outfit/admin/wizard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Wizard")

/datum/outfit/admin/wizard/red
	name = "Wizard - Red Wizard"

	suit = /obj/item/clothing/suit/wizrobe/red
	head = /obj/item/clothing/head/wizard/red

/datum/outfit/admin/wizard/marisa
	name = "Wizard - Marisa Wizard"

	suit = /obj/item/clothing/suit/wizrobe/marisa
	shoes = /obj/item/clothing/shoes/sandal/marisa
	head = /obj/item/clothing/head/wizard/marisa

/datum/outfit/admin/wizard/arch
	name = "Wizard - Arch Wizard"

	suit = /obj/item/clothing/suit/wizrobe/magusred
	head = /obj/item/clothing/head/wizard/magus
	belt = /obj/item/storage/belt/wands/full
	l_hand = null
	backpack_contents = list(
		/obj/item/storage/box/engineer = 1,
		/obj/item/clothing/suit/space/hardsuit/wizard/arch = 1,
		/obj/item/clothing/shoes/magboots = 1,
		/obj/item/kitchen/knife/ritual  = 1,
		/obj/item/clothing/suit/wizrobe/red = 1,
		/obj/item/clothing/head/wizard/red = 1
	)

/datum/outfit/admin/wizard/arch/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/spellbook/B = H.r_hand
	if(istype(B))
		B.owner = H // force-bind it so it can never be stolen, no matter what.
		B.name = "Archwizard Spellbook"
		B.uses = 50
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Arch Wizard")


/datum/outfit/admin/dark_priest
	name = "Dark Priest"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	back = /obj/item/storage/backpack
	head = /obj/item/clothing/head/hooded/chaplain_hood
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id/syndicate
	r_hand = /obj/item/nullrod/armblade
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
	)
	bio_chips = list(
		/obj/item/bio_chip/dust
	)

/datum/outfit/admin/dark_priest/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Dark Priest", "syndie")
	var/obj/item/nullrod/armblade/B = H.r_hand
	if(istype(B))
		B.force = 20
		B.name = "blessing of the reaper"
		B.desc = "Sometimes, someone's just gotta die."
	var/obj/item/radio/headset/R = H.l_ear
	if(istype(R))
		R.set_nodrop(TRUE, H)

/datum/outfit/admin/honksquad
	name = "Honksquad"

	uniform = /obj/item/clothing/under/rank/civilian/clown
	mask = /obj/item/clothing/mask/gas/clown_hat
	back = /obj/item/storage/backpack/clown
	id = /obj/item/card/id/clown

	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/bikehorn = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/food/grown/banana = 1,
	)

	shoes = /obj/item/clothing/shoes/clown_shoes
	suit = /obj/item/clothing/suit/storage/det_suit
	pda = /obj/item/pda/clown
	l_ear = /obj/item/radio/headset
	r_pocket = /obj/item/reagent_containers/patch/jestosterone

/datum/outfit/admin/honksquad/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.gender == FEMALE)
		uniform = /obj/item/clothing/under/rank/civilian/clown/sexy
		mask = /obj/item/clothing/mask/gas/clown_hat/sexy

	if(prob(50))
		// You have to do it like this to make it work with assoc lists without a runtime.
		// Trust me.
		backpack_contents.Add(/obj/item/gun/energy/clown)
		backpack_contents[/obj/item/gun/energy/clown] = 1 // Amount. Not boolean. Do not TRUE this. You turkey.
	else
		backpack_contents.Add(/obj/item/gun/throw/piecannon)
		backpack_contents[/obj/item/gun/throw/piecannon] = 1

	var/clown_rank = pick("Trickster First Class", "Master Clown", "Major Prankster")
	var/clown_name = pick(GLOB.clown_names)
	H.real_name = "[clown_rank] [clown_name]"

/datum/outfit/admin/honksquad/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	// Setup their clumsy and comic sans gene
	H.dna.SetSEState(GLOB.clumsyblock, TRUE)
	H.dna.SetSEState(GLOB.comicblock, TRUE)
	H.check_mutations = TRUE

	// Setup their headset
	var/obj/item/radio/R = H.l_ear
	if(istype(R))
		R.set_frequency(DTH_FREQ) // Clowns can be part of "special operations"

	// And their PDA
	var/obj/item/pda/P = H.wear_pda
	if(istype(P))
		P.owner = H.real_name
		P.ownjob = "Emergency Response Clown"
		P.name = "PDA-[H.real_name] ([P.ownjob])"

	// And their ID
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_CLOWN), "Emergency Response Clown")
	H.sec_hud_set_ID()

/datum/outfit/admin/observer
	name = "Observer"

	uniform = /obj/item/clothing/under/costume/tourist_suit
	back = /obj/item/storage/backpack/satchel
	shoes = /obj/item/clothing/shoes/black
	box = /obj/item/storage/box/survival
	backpack_contents = list(
		/obj/item/bio_chip_implanter/dust = 1
		)

/datum/outfit/admin/observer/plasmaman
	name = "Observer (Plasma)"

	uniform = /obj/item/clothing/under/plasmaman/assistant
	head = /obj/item/clothing/head/helmet/space/plasmaman/assistant
	mask = /obj/item/clothing/mask/breath
	belt = /obj/item/tank/internals/plasmaman/belt/full
	box = /obj/item/storage/box/survival_plasmaman

/datum/outfit/admin/observer/vox
	name = "Observer (Vox)"

	mask = /obj/item/clothing/mask/breath/vox
	belt = /obj/item/tank/internals/emergency_oxygen/double/vox
	box = /obj/item/storage/box/survival_vox

/datum/outfit/admin/enforcer
	name = "Oblivion Enforcer"

	uniform = /obj/item/clothing/under/color/white/enforcer
	shoes = /obj/item/clothing/shoes/white/enforcer
	back = /obj/item/storage/backpack/satchel
	id = /obj/item/card/id/data
	//The hood on this gets enabled on the after-equip proc.
	suit = /obj/item/clothing/suit/hooded/oblivion
	gloves = /obj/item/clothing/gloves/color/white/supermatter_immune
	mask = /obj/item/clothing/mask/gas/voice_modulator/oblivion
	l_ear = /obj/item/radio/headset
	suit_store = /obj/item/supermatter_halberd
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	box = /obj/item/storage/box/wizard

	//The spells that the enforcer has.
	var/list/spell_paths = list(/datum/spell/aoe/conjure/summon_supermatter,
										/datum/spell/charge_up/bounce/lightning, /datum/spell/summonitem)

/datum/outfit/admin/enforcer/post_equip(mob/living/carbon/human/H)
	. = ..()

	ADD_TRAIT(H, SM_HALLUCINATION_IMMUNE, MAGIC_TRAIT)

	H.real_name = "Unknown" //Enforcers sacrifice their name to Oblivion for their power

	var/obj/item/clothing/suit/hooded/oblivion/robes = H.wear_suit
	if(istype(robes))
		robes.ToggleHood()

	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, get_all_accesses(), "Oblivion Enforcer")

/datum/outfit/admin/enforcer/on_mind_initialize(mob/living/carbon/human/H)
	. = ..()
	for(var/spell_path in spell_paths)
		var/S = new spell_path
		H.mind.AddSpell(S)

/datum/outfit/admin/viper
	name = "TSF Viper Infiltrator"

	uniform = /obj/item/clothing/under/solgov/viper
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/viper
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = null // will end up being the bandana
	mask = /obj/item/clothing/mask/bandana/black // will end up being a cigar
	l_ear = /obj/item/radio/headset/ert/alt/solgov
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	id = /obj/item/card/id
	l_pocket = /obj/item/kitchen/knife/combat
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	box = /obj/item/storage/box/responseteam

	backpack_contents = list(
		/obj/item/storage/box/smoke_grenades = 1,
		/obj/item/lighter/zippo = 1,
		/obj/item/clothing/mask/cigarette/cigar = 3,
		/obj/item/clothing/mask/gas/explorer = 1
	)

	bio_chips = list(/obj/item/bio_chip/stealth)

	cybernetic_implants = list(
		/obj/item/organ/internal/cyberimp/eyes/hud/security,
		/obj/item/organ/internal/cyberimp/chest/nutriment/hardened
	)

/datum/outfit/admin/viper/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return
	var/codename = pick("Viper", "Serpent", "Python", "Boa", "Basilisk", "Snake", "Mamba", "Sidewinder")
	if(prob(50))
		var/codename_prefix = pick("Exposed", "Unveiled", "Phantom", "Mirage", "Punished", "Invisible", "Swift")
		codename = "[codename_prefix] [codename]"
	H.rename_character(H.real_name, codename)

	var/hair_color = "#361A00"

	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	head_organ.h_style = "Bedhead 2"
	head_organ.f_style = "Full Beard"
	head_organ.hair_colour = hair_color
	head_organ.sec_facial_colour = hair_color
	head_organ.facial_colour = hair_color
	head_organ.sec_hair_colour = hair_color
	H.update_hair()
	H.update_fhair()
	H.update_dna()

	var/obj/item/clothing/mask/worn_mask = H.wear_mask
	worn_mask.adjustmask(H) // push it back on the head
	equip_item(H, /obj/item/clothing/mask/cigarette/cigar, ITEM_SLOT_MASK) // get them their cigar
	if(istype(H.glasses, /obj/item/clothing/glasses)) // this is gonna be always true
		var/obj/item/clothing/glasses/glassass = H.glasses
		glassass.over_mask = TRUE
		H.update_inv_glasses()
	H.gloves.siemens_coefficient = 0 // black "insulated" gloves, since combat gloves look kinda shit
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), "Solar Federation Infilitrator", "lifetimeid")

	H.DeleteComponent(/datum/component/footstep)

	var/datum/martial_art/cqc/CQC = new()
	CQC.teach(H)

/datum/outfit/admin/tourist
	name = "Tourist"
	uniform = /obj/item/clothing/under/misc/redhawaiianshirt
	back = /obj/item/storage/backpack/satchel/withwallet
	belt = /obj/item/storage/belt/fannypack
	head = /obj/item/clothing/head/boaterhat
	l_ear = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses_fake
	shoes = /obj/item/clothing/shoes/sandal
	id = /obj/item/card/id/assistant
	box = /obj/item/storage/box/survival
	pda = /obj/item/pda/clear

	backpack_contents = list(
		/obj/item/camera = 1,
		/obj/item/camera_film = 1,
		/obj/item/stack/spacecash/c200 = 1,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 1,
		/obj/item/lighter/zippo = 1
	)

/datum/outfit/admin/tourist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(visualsOnly)
		return

	// Sets the ID and secHUD icon!
	var/obj/item/card/id/I = H.wear_id
	if(istype(I))
		apply_to_card(I, H, list(ACCESS_MAINT_TUNNELS), name, "tourist")
		// Checking if the person has an account already
		var/datum/money_account/account = H.mind.initial_account
		if(!account)
			// If they don't, we create a new one and get it's account number.
			SSjobs.CreateMoneyAccount(H, null, null)
			account = H.mind.initial_account
			I.associated_account_number = account.account_number
		I.associated_account_number = account.account_number
	H.sec_hud_set_ID()

	// PDA setup
	var/obj/item/pda/P = H.wear_pda
	if(istype(P))
		P.owner = H.real_name
		P.ownjob = "Tourist"
		P.name = "PDA-[H.real_name] ([P.ownjob])"
