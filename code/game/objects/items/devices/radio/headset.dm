/obj/item/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys."
	var/radio_desc = ""
	icon_state = "headset"
	item_state = "headset"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/ears.dmi', //We read you loud and skree-er.
		"Kidan" = 'icons/mob/clothing/species/kidan/ears.dmi'
		)
	materials = list(MAT_METAL = 200)
	canhear_range = 0 // can't hear headsets from very far away

	slot_flags = ITEM_SLOT_BOTH_EARS
	var/translate_binary = FALSE
	var/translate_hive = FALSE
	var/obj/item/encryptionkey/keyslot1 = null
	var/obj/item/encryptionkey/keyslot2 = null

	var/ks1type = null
	var/ks2type = null
	dog_fashion = null
	requires_tcomms = TRUE

/obj/item/radio/headset/New()
	..()
	internal_channels.Cut()

/obj/item/radio/headset/Initialize(mapload)
	. = ..()

	if(ks1type)
		keyslot1 = new ks1type(src)
		if(keyslot1.syndie)
			syndiekey = keyslot1
	if(ks2type)
		keyslot2 = new ks2type(src)
		if(keyslot2.syndie)
			syndiekey = keyslot2

	recalculateChannels(TRUE)

/obj/item/radio/headset/Destroy()
	QDEL_NULL(keyslot1)
	QDEL_NULL(keyslot2)
	QDEL_NULL(syndiekey)
	return ..()

/obj/item/radio/headset/examine(mob/user)
	. = ..()
	if(in_range(src, user) && radio_desc)
		. += "The following channels are available:"
		. += radio_desc

/obj/item/radio/headset/handle_message_mode(mob/living/M as mob, list/message_pieces, channel)
	if(channel == "special")
		if(translate_binary)
			var/datum/language/binary = GLOB.all_languages["Robot Talk"]
			binary.broadcast(M, strip_prefixes(multilingual_to_message(message_pieces)))
			return RADIO_CONNECTION_NON_SUBSPACE
		if(translate_hive)
			var/datum/language/hivemind = GLOB.all_languages["Hivemind"]
			hivemind.broadcast(M, strip_prefixes(multilingual_to_message(message_pieces)))
			return RADIO_CONNECTION_NON_SUBSPACE
		return RADIO_CONNECTION_FAIL

	return ..()

/obj/item/radio/headset/is_listening()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.l_ear == src || H.r_ear == src)
			return ..()
	else if(isanimal_or_basicmob(loc) || is_ai(loc))
		return ..()

	return FALSE

/obj/item/radio/headset/alt
	name = "bowman headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/alt/deathsquad
	name = "Deathsquad headset"
	desc = "Special Operations only. Protects ears from flashbangs."
	requires_tcomms = FALSE
	instant = TRUE
	freqlock = TRUE

/obj/item/radio/headset/alt/deathsquad/Initialize(mapload)
	. = ..()
	set_frequency(DTH_FREQ)

/obj/item/radio/headset/syndicate
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/syndicate/nukeops
	requires_tcomms = FALSE
	instant = TRUE // Work instantly if there are no comms
	freqlock = TRUE

/// undisguised bowman with flash protection
/obj/item/radio/headset/syndicate/alt
	name = "syndicate headset"
	desc = "A syndicate headset that can be used to hear all radio frequencies. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "syndie_headset"
	item_state = "syndie_headset"

/obj/item/radio/headset/syndicate_fake
	name = "syndicate headset"
	desc = "A syndicate headset to set on your head."
	icon_state = "syndie_headset"
	item_state = "syndie_headset"

/obj/item/radio/headset/syndicate/syndteam
	ks1type = /obj/item/encryptionkey/syndteam

/obj/item/radio/headset/syndicate/alt/syndteam
	ks1type = /obj/item/encryptionkey/syndteam

/obj/item/radio/headset/syndicate/alt/nocommon
	name = "syndicate researcher headset"

/obj/item/radio/headset/syndicate/alt/nocommon/New()
	. = ..()
	set_frequency(SYND_FREQ)

/obj/item/radio/headset/soviet
	name = "soviet bowman headset"
	desc = "Used by U.S.S.P forces. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	origin_tech = "syndicate=3"
	icon_state = "soviet_headset"
	item_state = "soviet_headset"
	ks1type = /obj/item/encryptionkey/soviet
	requires_tcomms = FALSE

/obj/item/radio/headset/binary
	origin_tech = "syndicate=3"
	ks1type = /obj/item/encryptionkey/binary

/obj/item/radio/headset/headset_sec
	name = "security radio headset"
	desc = "This is used by your elite security force."
	icon_state = "sec_headset"
	ks2type = /obj/item/encryptionkey/headset_sec

/obj/item/radio/headset/headset_sec/alt
	name = "security bowman headset"
	desc = "This is used by your elite security force. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_iaa
	name = "internal affairs radio headset"
	desc = "This is used by your elite legal team."
	icon_state = "sec_headset"
	item_state = "sec_headset"
	ks2type = /obj/item/encryptionkey/headset_iaa

/obj/item/radio/headset/headset_iaa/alt
	name = "internal affairs bowman headset"
	desc = "This is used by your elite legal team. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "sec_headset_alt"
	item_state = "sec_headset_alt"

/obj/item/radio/headset/headset_eng
	name = "engineering radio headset"
	desc = "When the engineers wish to chat like girls."
	icon_state = "eng_headset"
	ks2type = /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_rob
	name = "robotics radio headset"
	desc = "Made specifically for the roboticists who cannot decide between departments."
	icon_state = "rob_headset"
	ks2type = /obj/item/encryptionkey/headset_rob

/obj/item/radio/headset/headset_med
	name = "medical radio headset"
	desc = "A headset for the trained staff of the medbay."
	icon_state = "med_headset"
	ks2type = /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_med/para
	name = "paramedic radio headset"
	desc = "A headset for the trusty paramedic, Nanotrasen search and rescue."
	icon_state = "para_headset"
	ks2type = /obj/item/encryptionkey/headset_med/para

/obj/item/radio/headset/headset_sci
	name = "science radio headset"
	desc = "A sciency headset. Like usual."
	icon_state = "sci_headset"
	ks2type = /obj/item/encryptionkey/headset_sci

/obj/item/radio/headset/headset_medsci
	name = "medical research radio headset"
	desc = "A headset that is a result of the mating between medical and science."
	icon_state = "medsci_headset"
	ks2type = /obj/item/encryptionkey/headset_medsci

/obj/item/radio/headset/headset_com
	name = "command radio headset"
	desc = "A headset with a commanding channel."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/headset_com

/obj/item/radio/headset/heads/captain
	name = "captain's headset"
	desc = "The headset of the boss."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/heads/captain/alt
	name = "captain's bowman headset"
	desc = "The headset of the boss. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/rd
	name = "research director's headset"
	desc = "Headset of the researching God."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/rd

/obj/item/radio/headset/heads/hos
	name = "head of security's headset"
	desc = "The headset of the man who protects your worthless lives."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/hos

/obj/item/radio/headset/heads/hos/alt
	name = "head of security's bowman headset"
	desc = "The headset of the man in charge of keeping order and protecting the station. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/ce
	name = "chief engineer's headset"
	desc = "The headset of the guy who is in charge of morons."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/ce

/obj/item/radio/headset/heads/cmo
	name = "chief medical officer's headset"
	desc = "The headset of the highly trained medical chief."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/cmo

/obj/item/radio/headset/heads/hop
	name = "head of personnel's headset"
	desc = "The headset of the guy who will one day be captain."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/hop

/obj/item/radio/headset/heads/qm
	name = "quartermaster's headset"
	desc = "Smelling of tobacco and gunpowder, this headset has likely seen many backroom deals."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/qm

/obj/item/radio/headset/headset_cargo
	name = "supply radio headset"
	desc = "A headset used by the cargo department."
	icon_state = "cargo_headset"
	ks2type = /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_cargo/mining
	name = "mining radio headset"
	desc = "Headset used by shaft miners."
	icon_state = "mine_headset"

/obj/item/radio/headset/headset_cargo/expedition
	name = "expedition radio headset"
	desc = "Headset used by space explorers."
	icon_state = "mine_headset"

/obj/item/radio/headset/headset_service
	name = "service radio headset"
	desc = "Headset used by the service staff, tasked with keeping the station full, happy and clean."
	icon_state = "srv_headset"
	ks2type = /obj/item/encryptionkey/headset_service

/obj/item/radio/headset/heads/ntrep
	name = "nanotrasen representative's headset"
	desc = "The headset of the Nanotrasen Representative."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/ntrep

/obj/item/radio/headset/headset_nct
	name = "\improper Nanotrasen career trainer radio headset"
	desc = "This is used by your well-taught corporate training team."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/headset_nct

/obj/item/radio/headset/heads/magistrate
	name = "magistrate's headset"
	desc = "The headset of the Magistrate."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/magistrate

/obj/item/radio/headset/heads/magistrate/alt
	name = "magistrate's bowman headset"
	desc = "The headset of the Magistrate. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/heads/blueshield
	name = "blueshield's headset"
	desc = "The headset of the Blueshield."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/heads/blueshield

/obj/item/radio/headset/heads/blueshield/alt
	name = "blueshield's bowman headset"
	desc = "The headset of the Blueshield. Protects ears from flashbangs."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert
	name = "emergency response team headset"
	desc = "The headset of the boss's boss."
	icon_state = "com_headset"
	ks2type = /obj/item/encryptionkey/ert
	freqlock = TRUE

/obj/item/radio/headset/ert/alt
	name = "emergency response team's bowman headset"
	desc = "An ergonomic tactical headset used by Nanotrasen-affiliated PMCs. Protects against loud noises."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"

/obj/item/radio/headset/ert/alt/solgov
	name = "\improper Trans-Solar Marine Corps bowman headset"
	desc = "An ergonomic combat headset used by the TSMC. Protects against loud noises."

/obj/item/radio/headset/ert/alt/solgovviper
	name = "\improper 3rd SOD bowman headset"
	desc = "A custom-fitted headset used by the commandos of the Federal Army's renowned 3rd Special Operations Detachment, more commonly known as the Vipers."

/obj/item/radio/headset/ert/alt/commander
	name = "ERT commander's bowman headset"
	desc = "The headset of the boss. Protects ears from flashbangs. Can transmit even if telecomms are down."
	requires_tcomms = FALSE
	instant = TRUE

/obj/item/radio/headset/ert/alt/commander/solgov
	name = "\improper Trans-Solar Marine Corps officer's bowman headset"
	desc = "An ergonomic combat headset used by the TSMC. This model is equipped with an extra-strength transmitter for barking orders."

/obj/item/radio/headset/centcom
	name = "centcom officer's bowman headset"
	desc = "The headset of final authority. Protects ears from flashbangs. Can transmit even if telecomms are down."
	flags = EARBANGPROTECT
	icon_state = "com_headset_alt"
	item_state = "com_headset_alt"
	ks2type = /obj/item/encryptionkey/centcom
	requires_tcomms = FALSE
	instant = TRUE

/// No need to care about icons, it should be hidden inside the AI anyway.
/obj/item/radio/headset/heads/ai_integrated
	name = "\improper AI subspace transceiver"
	desc = "Integrated AI radio transceiver."
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "radio"
	ks2type = /obj/item/encryptionkey/heads/ai_integrated
	var/myAi = null    // Atlantis: Reference back to the AI which has this radio.
	var/disabledAi = FALSE // Atlantis: Used to manually disable AI's integrated radio via intellicard menu.

/obj/item/radio/headset/heads/ai_integrated/is_listening()
	if(disabledAi)
		return FALSE
	return ..()

/obj/item/radio/headset/attackby__legacy__attackchain(obj/item/key, mob/user)
	if(istype(key, /obj/item/encryptionkey/))

		if(keyslot1 && keyslot2)
			to_chat(user, "The headset can't hold another key!")
			return

		if(!user.transfer_item_to(key, src, FALSE, FALSE))
			to_chat(user, "<span class='warning'>[key] is stuck to your hand, you can't insert it in [src].</span>")
			return

		if(!keyslot1)
			keyslot1 = key
		else
			keyslot2 = key

		recalculateChannels()
		return

	return ..()

/obj/item/radio/headset/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return

	if(keyslot1 || keyslot2)

		for(var/ch_name in channels)
			SSradio.remove_object(src, SSradio.radiochannels[ch_name])
			secure_radio_connections[ch_name] = null

		if(keyslot1)
			var/turf/T = get_turf(user)
			if(T)
				keyslot1.loc = T
				keyslot1 = null
		if(keyslot2)
			var/turf/T = get_turf(user)
			if(T)
				keyslot2.loc = T
				keyslot2 = null

		recalculateChannels()
		to_chat(user, "You pop out the encryption keys in the headset!")
		I.play_tool_sound(user, I.tool_volume)
	else
		to_chat(user, "This headset doesn't have any encryption keys!  How useless...")

/obj/item/radio/headset/recalculateChannels(setDescription = FALSE)
	channels = list()
	translate_binary = FALSE
	translate_hive = FALSE
	syndiekey = null

	if(keyslot1)
		for(var/ch_name in keyslot1.channels)
			if(ch_name in channels)
				continue
			channels += ch_name
			channels[ch_name] = keyslot1.channels[ch_name]

		if(keyslot1.translate_binary)
			translate_binary = TRUE

		if(keyslot1.translate_hive)
			translate_hive = TRUE

		if(keyslot1.syndie)
			syndiekey = keyslot1

	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(ch_name in channels)
				continue
			channels += ch_name
			channels[ch_name] = keyslot2.channels[ch_name]

		if(keyslot2.translate_binary)
			translate_binary = TRUE

		if(keyslot2.translate_hive)
			translate_hive = TRUE

		if(keyslot2.syndie)
			syndiekey = keyslot2


	for(var/ch_name in channels)
		if(!SSradio)
			name = "broken radio headset"
			return

		secure_radio_connections[ch_name] = SSradio.add_object(src, SSradio.radiochannels[ch_name],  RADIO_CHAT)

	if(setDescription)
		setupRadioDescription()

	return

/obj/item/radio/headset/proc/setupRadioDescription()
	var/radio_text = ""
	for(var/i = 1 to length(channels))
		var/channel = channels[i]
		var/key = get_radio_key_from_channel(channel)
		radio_text += "[key] - [channel]"
		if(i != length(channels))
			radio_text += ", "

	radio_desc = radio_text

/obj/item/radio/headset/proc/make_syndie() // Turns normal radios into Syndicate radios!
	qdel(keyslot1)
	keyslot1 = new /obj/item/encryptionkey/syndicate
	syndiekey = keyslot1
	recalculateChannels()
