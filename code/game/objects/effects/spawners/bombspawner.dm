/obj/effect/spawner/newbomb
	name = "bomb"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	var/btype = 0 // 0=radio, 1=prox, 2=time
	var/btemp1 = 1500
	var/btemp2 = 1000	// tank temperatures

/obj/effect/spawner/newbomb/timer
	btype = 2

/obj/effect/spawner/newbomb/timer/syndicate
	btemp1 = 150
	btemp2 = 20

/obj/effect/spawner/newbomb/proximity
	btype = 1

/obj/effect/spawner/newbomb/radio


/obj/effect/spawner/newbomb/New()
	..()

	var/obj/item/transfer_valve/V = new(src.loc)
	var/obj/item/tank/internals/plasma/PT = new(V)
	var/obj/item/tank/internals/oxygen/OT = new(V)

	V.tank_one = PT
	V.tank_two = OT

	PT.master = V
	OT.master = V

	PT.air_contents.set_temperature(btemp1 + T0C)
	OT.air_contents.set_temperature(btemp2 + T0C)

	var/obj/item/assembly/S

	switch(src.btype)
		// radio
		if(0)

			S = new/obj/item/assembly/signaler(V)

		// proximity
		if(1)

			S = new/obj/item/assembly/prox_sensor(V)

		// timer
		if(2)

			S = new/obj/item/assembly/timer(V)


	V.attached_device = S

	S.holder = V
	S.toggle_secure()

	V.update_icon()

	qdel(src)
