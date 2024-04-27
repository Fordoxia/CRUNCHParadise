/obj/item/food/snacks/rations/liquidfood
	name = "\improper LiquidFood ration"
	desc = "A prepackaged grey slurry of all the essential nutrients for a spacefarer on the go... Should this be crunchy?"
	icon_state = "liquidfood"
	trash = /obj/item/trash/liquidfood
	filling_color = "#A8A8A8"
	bitesize = 4
	list_reagents = list("nutriment" = 20, "iron" = 3, "vitamin" = 2)
	tastes = list("chemicals" = 1, "artificial vanilla" = 1, "mush" = 1)

/obj/item/storage/box/mre
	name = "Meal, Ready-to-Eat"
	desc = "A SolGov-produced field ration designed to feed a soldier in active combat. Contains self-heating food packets that require no prior preperation. Meets all of the legal and technical requirements to be considered real food!"
	w_class = SIZE_SMALL
	storage_slots = 7
	can_hold = list(
		/obj/item/food/snacks/rations
		/obj/item/reagent_containers/glass/beaker/waterbottle
		/obj/item/clothing/mask/cigarette
		/obj/item/storage/fancy/matches
		/obj/item/match
		/obj/item/kitchen/utensil/spoon
	)

/obj/item/storage/box/mre/populate_contents()
	var/menu_option
	