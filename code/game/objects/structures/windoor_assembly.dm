/* Windoor (window door) assembly -Nodrak //I hope you step on a plug
 * Step 1: Create a windoor out of rglass
 * Step 2: Add plasteel to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Crowbar the door to complete
 */

#define EMPTY_ASSEMBLY "01"
#define WIRED_ASSEMBLY "02"

/obj/structure/windoor_assembly
	icon = 'icons/obj/doors/windoor.dmi'
	name = "windoor assembly"
	icon_state = "l_windoor_assembly01"
	desc = "A small glass and wire assembly for windoors."
	dir = NORTH
	var/ini_dir
	var/obj/item/airlock_electronics/electronics
	var/created_name
	var/polarized_glass = FALSE

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = FALSE		//Whether or not this creates a secure windoor
	var/state = EMPTY_ASSEMBLY	//How far the door assembly has progressed

/obj/structure/windoor_assembly/examine(mob/user)
	. = ..()
	switch(state)
		if(EMPTY_ASSEMBLY)
			if(anchored)
				. += "<span class='notice'>The anchoring bolts are <b>wrenched</b> in place, but the maintenance panel lacks <i>wiring</i>.</span>"
			else
				. += "<span class='notice'>The assembly is <b>welded together</b>, but the anchoring bolts are <i>unwrenched</i>.</span>"
			if(!secure)
				. += "<span class='notice'>The frame has <i>empty</i> slots for <i>plasteel reinforcements</i>.</span>"
		if(WIRED_ASSEMBLY)
			if(electronics)
				. += "<span class='notice'>The circuit is <b>connected</b> to its slot, but the windoor is not <i>lifted into the frame</i>.</span>"
				. += "<span class='notice'>The assembly has its electrochromic panel <b>[polarized_glass ? "enabled" : "disabled"]</b> and can be <i>configured</i>.</span>"
			else
				. += "<span class='notice'>The maintenance panel is <b>wired</b>, but the circuit slot is <i>empty</i>.</span>"

	. += "<span class='notice'><b>Alt-Click</b> to rotate it.</span>"
	. += "<span class='notice'><b>Alt-Shift-Click</b> to flip it.</span>"

/obj/structure/windoor_assembly/Initialize(mapload, set_dir)
	. = ..()
	if(set_dir)
		dir = set_dir
	ini_dir = dir
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_atom_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

	recalculate_atmos_connectivity()

/obj/structure/windoor_assembly/Destroy()
	density = FALSE
	QDEL_NULL(electronics)
	recalculate_atmos_connectivity()
	return ..()

/obj/structure/windoor_assembly/Move()
	var/turf/T = loc
	. = ..()
	setDir(ini_dir)
	move_update_air(T)

/obj/structure/windoor_assembly/update_icon_state()
	icon_state = "[facing]_[secure ? "secure_" : ""]windoor_assembly[state]"

/obj/structure/windoor_assembly/CanPass(atom/movable/mover, border_dir)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(border_dir == dir) //Make sure looking at appropriate border
		return !density
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/machinery/door/window) && !valid_window_location(loc, mover.dir))
		return FALSE
	return TRUE

/obj/structure/windoor_assembly/CanAtmosPass(direction)
	if(direction == dir)
		return !density
	else
		return TRUE

/obj/structure/windoor_assembly/proc/on_atom_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER // COMSIG_ATOM_EXIT

	if(istype(leaving) && leaving.checkpass(PASSGLASS))
		return
	if(direction == dir && density)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/windoor_assembly/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	//I really should have spread this out across more states but thin little windoors are hard to sprite.
	add_fingerprint(user)
	switch(state)
		if(EMPTY_ASSEMBLY)
			//Adding plasteel makes the assembly a secure windoor assembly. Step 2 (optional) complete.
			if(istype(W, /obj/item/stack/sheet/plasteel) && !secure)
				var/obj/item/stack/sheet/plasteel/P = W
				if(P.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need more plasteel to do this!</span>")
					return
				to_chat(user, "<span class='notice'>You start to reinforce the windoor with plasteel...</span>")

				if(do_after(user, 40 * P.toolspeed, target = src))
					if(!src || secure || P.get_amount() < 2)
						return
					playsound(loc, P.usesound, 100, 1)

					P.use(2)
					to_chat(user, "<span class='notice'>You reinforce the windoor.</span>")
					secure = TRUE
					if(anchored)
						name = "secure anchored windoor assembly"
					else
						name = "secure windoor assembly"

			//Adding cable to the assembly. Step 5 complete.
			else if(iscoil(W) && anchored)
				user.visible_message("[user] wires the windoor assembly.", "You start to wire the windoor assembly...")

				if(do_after(user, 40 * W.toolspeed, target = src))
					if(!src || !anchored || state != EMPTY_ASSEMBLY)
						return
					var/obj/item/stack/cable_coil/CC = W
					CC.use(1)
					to_chat(user, "<span class='notice'>You wire the windoor.</span>")
					playsound(loc, CC.usesound, 100, 1)
					state = WIRED_ASSEMBLY
					if(secure)
						name = "secure wired windoor assembly"
					else
						name = "wired windoor assembly"
			else
				return ..()

		if(WIRED_ASSEMBLY)
			//Adding airlock electronics for access. Step 6 complete.
			if(istype(W, /obj/item/airlock_electronics) && !istype(W, /obj/item/airlock_electronics/destroyed))
				playsound(loc, W.usesound, 100, 1)
				user.visible_message("[user] installs the electronics into the windoor assembly.", "You start to install electronics into the windoor assembly...")
				user.drop_item()
				W.forceMove(src)
				var/obj/item/airlock_electronics/new_electronics = W

				if(do_after(user, 40 * new_electronics.toolspeed, target = src) && !new_electronics.is_installed)
					if(!src || electronics)
						new_electronics.forceMove(loc)
						return
					to_chat(user, "<span class='notice'>You install the windoor electronics.</span>")
					name = "near finished windoor assembly"
					electronics = new_electronics
					electronics.is_installed = TRUE
				else
					new_electronics.forceMove(loc)

			else if(is_pen(W))
				var/t = rename_interactive(user, W)
				if(!isnull(t))
					created_name = t
				return
			else
				return ..()

	//Update to reflect changes(if applicable)
	update_icon(UPDATE_ICON_STATE)

/obj/structure/windoor_assembly/crowbar_act(mob/user, obj/item/I)	//Crowbar to complete the assembly, Step 7 complete.
	if(state != WIRED_ASSEMBLY)
		return
	. = TRUE
	if(!electronics)
		to_chat(user, "<span class='warning'>[src] is missing electronics!</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	user << browse(null, "window=windoor_access")
	user.visible_message("[user] pries the windoor into the frame.", "You start prying the windoor into the frame...")

	if(!I.use_tool(src, user, 40, volume = I.tool_volume))
		return
	if(loc && electronics)
		for(var/obj/machinery/door/window/WD in loc)
			if(WD.dir == dir)
				return

		density = TRUE //Shouldn't matter but just incase
		to_chat(user, "<span class='notice'>You finish the windoor.</span>")
		var/obj/machinery/door/window/windoor
		if(secure)
			windoor = new /obj/machinery/door/window/brigdoor(src.loc)
			if(facing == "l")
				windoor.icon_state = "leftsecureopen"
				windoor.base_state = "leftsecure"
			else
				windoor.icon_state = "rightsecureopen"
				windoor.base_state = "rightsecure"
		else
			windoor = new /obj/machinery/door/window(loc)
			if(facing == "l")
				windoor.icon_state = "leftopen"
				windoor.base_state = "left"
			else
				windoor.icon_state = "rightopen"
				windoor.base_state = "right"
		windoor.setDir(dir)
		windoor.density = FALSE
		windoor.polarized_glass = polarized_glass

		if(electronics.one_access)
			windoor.req_one_access = electronics.selected_accesses
		else
			windoor.req_access = electronics.selected_accesses
		windoor.unres_sides = electronics.unres_access_from
		windoor.electronics = src.electronics
		electronics.forceMove(windoor)
		electronics = null
		if(created_name)
			windoor.name = created_name
		qdel(src)
		windoor.close()

/obj/structure/windoor_assembly/screwdriver_act(mob/user, obj/item/I)
	if(state != WIRED_ASSEMBLY || !electronics)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("[user] removes the electronics from the windoor assembly.", "You start to uninstall the electronics from the windoor assembly...")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")
	name = "wired windoor assembly"
	var/obj/item/airlock_electronics/ae
	ae = electronics
	electronics = null
	ae.forceMove(loc)
	ae.is_installed = FALSE

/obj/structure/windoor_assembly/wirecutter_act(mob/user, obj/item/I)
	if(state != WIRED_ASSEMBLY)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("[user] cuts the wires from the windoor assembly.", "You start to cut the wires from windoor assembly...")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != WIRED_ASSEMBLY)
		return
	to_chat(user, "<span class='notice'>You cut the windoor wires.</span>")
	new/obj/item/stack/cable_coil(get_turf(user), 1)
	state = EMPTY_ASSEMBLY
	if(secure)
		name = "secure anchored windoor assembly"
	else
		name = "anchored windoor assembly"
	update_icon(UPDATE_ICON_STATE)

/obj/structure/windoor_assembly/wrench_act(mob/user, obj/item/I)
	if(state != EMPTY_ASSEMBLY)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!anchored)	//Wrenching an unsecure assembly anchors it in place. Step 4 complete
		for(var/obj/machinery/door/window/WD in loc)
			if(WD.dir == dir)
				to_chat(user, "<span class='warning'>There is already a windoor in that location!</span>")
				return
		user.visible_message("[user] secures the windoor assembly to the floor.", "You start to secure the windoor assembly to the floor...")

		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || anchored || state != EMPTY_ASSEMBLY)
			return
		for(var/obj/machinery/door/window/WD in loc)
			if(WD.dir == dir)
				to_chat(user, "<span class='warning'>There is already a windoor in that location!</span>")
				return
		to_chat(user, "<span class='notice'>You secure the windoor assembly.</span>")
		anchored = TRUE
		if(secure)
			name = "secure anchored windoor assembly"
		else
			name = "anchored windoor assembly"

	else	//Unwrenching an unsecure assembly un-anchors it. Step 4 undone
		user.visible_message("[user] unsecures the windoor assembly from the floor.", "You start to unsecure the windoor assembly from the floor...")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || !anchored || state != EMPTY_ASSEMBLY)
			return
		to_chat(user, "<span class='notice'>You unsecure the windoor assembly.</span>")
		anchored = FALSE
		if(secure)
			name = "secure windoor assembly"
		else
			name = "windoor assembly"
	update_icon(UPDATE_ICON_STATE)

/obj/structure/windoor_assembly/welder_act(mob/user, obj/item/I)
	if(state != EMPTY_ASSEMBLY)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume) && state == EMPTY_ASSEMBLY)
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		var/obj/item/stack/sheet/rglass/RG = new (get_turf(src), 5)
		RG.add_fingerprint(user)
		if(secure)
			var/obj/item/stack/rods/R = new (get_turf(src), 4)
			R.add_fingerprint(user)
		qdel(src)


/obj/structure/windoor_assembly/multitool_act(mob/user, obj/item/I)
	if(state != WIRED_ASSEMBLY)
		return
	. = TRUE
	if(!electronics)
		to_chat(user, "<span class='warning'>[src] is missing electronics!</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("[user] is configuring the glass panel in the windoor assembly...", "You start to configure the glass panel in the airlock assembly...")
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || !electronics)
		return

	polarized_glass = !polarized_glass

	to_chat(user, "<span class='notice'>You [polarized_glass ? "enable" : "disable"] the electrochromic panel in the windoor assembly.</span>")


/obj/structure/windoor_assembly/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(anchored)
		to_chat(user, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return
	var/target_dir = turn(dir, 90)

	if(!valid_window_location(loc, target_dir))
		to_chat(user, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return

	setDir(target_dir)

	ini_dir = dir
	update_icon(UPDATE_ICON_STATE)

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/AltShiftClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(facing == "l")
		to_chat(user, "The windoor will now slide to the right.")
		facing = "r"
	else
		facing = "l"
		to_chat(user, "The windoor will now slide to the left.")

	update_icon(UPDATE_ICON_STATE)

#undef EMPTY_ASSEMBLY
#undef WIRED_ASSEMBLY
