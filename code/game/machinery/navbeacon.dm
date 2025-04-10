// Navigation beacon for AI robots
// No longer exists on the radio controller, it is managed by a global list.

/obj/machinery/navbeacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0-f"
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	level = 1		// underfloor
	layer = WIRE_LAYER
	plane = FLOOR_PLANE
	anchored = TRUE
	max_integrity = 500
	armor = list(melee = 70, bullet = 70, laser = 70, energy = 70, bomb = 0, rad = 0, fire = 80, acid = 80)
	var/open = FALSE		// true if cover is open
	var/locked = TRUE		// true if controls are locked
	var/location = ""	// location response text
	var/list/codes		// assoc. list of transponder codes
	var/codes_txt = ""	// codes as set on map: "tag1;tag2" or "tag1=value;tag2=value"

	req_access = list(ACCESS_ENGINE, ACCESS_ROBOTICS)

/obj/machinery/navbeacon/Initialize(mapload)
	. = ..()

	set_codes()

	var/turf/T = loc
	if(!T.transparent_floor)
		hide(T.intact)
	if(!length(codes))
		stack_trace("Empty codes datum at ([x],[y],[z]) (codes_txt: [codes_txt])")
	if("patrol" in codes)
		if(!GLOB.navbeacons["[z]"])
			GLOB.navbeacons["[z]"] = list()
		GLOB.navbeacons["[z]"] += src //Register with the patrol list!
	if("delivery" in codes)
		GLOB.deliverybeacons += src
		GLOB.deliverybeacontags += location

/obj/machinery/navbeacon/Destroy()
	GLOB.navbeacons["[z]"] -= src //Remove from beacon list, if in one.
	GLOB.deliverybeacons -= src
	return ..()

/obj/machinery/navbeacon/serialize()
	var/list/data = ..()
	data["codes"] = codes
	return data

/obj/machinery/navbeacon/deserialize(list/data)
	codes = data["codes"]
	..()

// set the transponder codes assoc list from codes_txt
/obj/machinery/navbeacon/proc/set_codes()
	if(!codes_txt)
		return

	codes = new()

	var/list/entries = splittext(codes_txt, ";")	// entries are separated by semicolons

	for(var/e in entries)
		var/index = findtext(e, "=")		// format is "key=value"
		if(index)
			var/key = copytext(e, 1, index)
			var/val = copytext(e, index+1)
			codes[key] = val
		else
			codes[e] = "1"


// called when turf state changes
// hide the object if turf is intact
/obj/machinery/navbeacon/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/navbeacon/update_icon_state()
	icon_state = "navbeacon[open][invisibility ? "-f" : ""]"	// if invisible, set icon to faded version
																// in case revealed by T-scanner

/obj/machinery/navbeacon/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	var/turf/T = loc
	if(T.intact)
		return ITEM_INTERACT_COMPLETE // prevent intraction when T-scanner revealed

	else if(istype(used, /obj/item/card/id) || istype(used, /obj/item/pda))
		if(open)
			if(allowed(user))
				locked = !locked
				to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
			else
				to_chat(user, "<span class='danger'>Access denied.</span>")
			updateDialog()
		else
			to_chat(user, "<span class='warning'>You must open the cover first!</span>")

		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/navbeacon/screwdriver_act(mob/living/user, obj/item/I)
	open = !open
	user.visible_message("[user] [open ? "opens" : "closes"] the beacon's cover.", "<span class='notice'>You [open ? "open" : "close"] the beacon's cover.</span>")
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/navbeacon/attack_ai(mob/user)
	interact(user, 1)

/obj/machinery/navbeacon/attack_hand(mob/user)
	interact(user, 0)

/obj/machinery/navbeacon/interact(mob/user, ai = 0)
	var/turf/T = loc
	if(T.intact)
		return		// prevent intraction when T-scanner revealed

	if(!open && !ai)	// can't alter controls if not open, unless you're an AI
		to_chat(user, "<span class='warning'>The beacon's control cover is closed!</span>")
		return


	var/t

	if(locked && !ai)
		t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to unlock controls)</i><BR>
Location: [location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)
			t += "<LI>[key] ... [codes[key]]"
		t+= "<UL></TT>"

	else

		t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to lock controls)</i><BR>

<HR>
Location: <A href='byond://?src=[UID()];locedit=1'>[location ? location : "None"]</A><BR>
Transponder Codes:<UL>"}

		for(var/key in codes)
			t += "<LI>[key] ... [codes[key]]"
			t += "	<A href='byond://?src=[UID()];edit=1;code=[key]'>Edit</A>"
			t += "	<A href='byond://?src=[UID()];delete=1;code=[key]'>Delete</A><BR>"
		t += "	<A href='byond://?src=[UID()];add=1;'>Add New</A><BR>"
		t+= "<UL></TT>"

	var/datum/browser/popup = new(user, "navbeacon", "Navigation Beacon", 300, 400)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/navbeacon/Topic(href, href_list)
	if(..())
		return
	if(open && !locked)
		usr.set_machine(src)

		if(href_list["locedit"])
			var/newloc = tgui_input_text(usr, "Enter New Location", "Navigation Beacon", location)
			if(!newloc)
				return
			location = newloc
			updateDialog()

		else if(href_list["edit"])
			var/codekey = href_list["code"]

			var/newkey = tgui_input_text(usr, "Enter Transponder Code Key", "Navigation Beacon", codekey)
			if(!newkey)
				return

			var/codeval = codes[codekey]
			var/newval = tgui_input_text(usr, "Enter Transponder Code Value", "Navigation Beacon", codeval)
			if(!newval)
				newval = codekey
				return

			codes.Remove(codekey)
			codes[newkey] = newval

			updateDialog()

		else if(href_list["delete"])
			var/codekey = href_list["code"]
			codes.Remove(codekey)
			updateDialog()

		else if(href_list["add"])

			var/newkey = tgui_input_text(usr, "Enter New Transponder Code Key", "Navigation Beacon")
			if(!newkey)
				return

			var/newval = tgui_input_text(usr, "Enter New Transponder Code Value", "Navigation Beacon")
			if(!newval)
				newval = "1"
				return

			if(!codes)
				codes = new()

			codes[newkey] = newval

			updateDialog()


/obj/machinery/navbeacon/invisible
	invisibility = INVISIBILITY_MAXIMUM

/obj/machinery/navbeacon/invisible/hide(intact)
	invisibility = INVISIBILITY_MAXIMUM
	update_icon(UPDATE_ICON_STATE)
