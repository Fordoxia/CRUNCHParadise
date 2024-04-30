/*
CONTENTS:
1. BASIC RATIONS
2. MRE MAINS 		// Yes, I made an entire set of menus based on real MREs for this. IMMERSION! - CRUNCH
3. MRE SIDES
4. MRE SNACKS
5. MRE DESSERTS
6. MRE
*/

////////////////////
/// BASIC RATIONS //
////////////////////
/obj/item/food/snacks/rations
	name = "arbitrary ration"
	desc = "If you can see this, make an issue report on GitHub. Something went wrong!"
	icon_state = "liquidfood"
	/// For rations with removable packaging.
	var/opened = FALSE

/obj/item/food/snacks/rations/attack_self(mob/user)
	if(!opened)
		to_chat("<span class = 'notice'>You need to open the packaging before you can eat this.</span>")
		return
	. = ..()

/obj/item/food/snacks/rations/liquidfood
	name = "LiquidFood ration packet"
	desc = "A prepackaged grey slurry containing all the essential vitamins, nutrients, and calories that a hungry spacefarer needs. Guaranteed to cause mental breakdowns after only 2 consecutive days of consumption."
	consume_sound = 'sound/items/drink.ogg'
	trash = /obj/item/trash/liquidfood
	filling_color = "#A8A8A8"
	list_reagents = list("nutriment" = 20, "iron" = 3, "vitamin" = 2)
	tastes = list("chemicals" = 2, "mush" = 2, "artificial vanilla, struggling to reach your tastebuds" = 1)

/obj/item/food/snacks/rations/liquidfood/examine_more(mob/user)
	. = ..()
	. += "LiquidFood rations were created by the startup UltraFood Solutions in response to a call by the Trans-Solar Federation's armed forces to develop an ultra high-performance combat ration for use by elite units.<br><br>\
	Through tireless research, constant re-evaluation, and (some would say) dubious testing methodology, they successfully created what they pitched as the perfect ration: \
	Lightweight, compact, requiring no preperation, able to be consumed on the move, full of nutrition that is fully absorbed by all humanoid species, cheap and easy to mass manufacture.<br><br>\
	Unfortunately, the TSF's trials of the new ration revealed that it was almost universally lothed by anyone that consumed it. Whilst it was ultimately rejected, \
	UltraFood simply turned around and started marketing to penny-pinching megacorporations that didn't care about that particular detail<br><br>\
	Like the one you work for..."

/obj/item/food/snacks/rations/nutrient_prism
	name = "type I survival bar"
	desc = "The standard field ration for the USSP. An ultra-dense bar of compressed nutritional components and essential vitamins. Difficult to chew. It has a shelf life so long that it has not yet been demonstrated to exist."
	bitesize = 5	// It will take a while to get through this thing.
	list_reagents = list("nutriment" = 30, "vitamin" = 20)	// It's PURE, CONCENTRATED NUTRITION! And nothing else!
	tastes = list("malt" = 3, "whey protien" = 2, "expired multivitamins" = 1)

/obj/item/food/snacks/rations/nutrient_prism/examine_more(mob/user)
	. = ..()
	. += "The Type I Survival Bar replaced the USSP's older ramshackle collection of canned rations in 2530, with the dual aim of reducing the carry mass and volume of its soldiers, and massively simplifying the food \
	logistics involved with supplying its vast armies.<br><br>\
	Weighing just 600 grams and small enough to fit into any pocket, it is a testement to the genius minds of the USSP's food scientists. It also takes forever to chew through it thanks to its sheer density and chewy texture \
	and the flavour is quite bland, with no menu variation. Rumors are abound that the Type II may finally be on the horizon, giving a glimmer of hope that something better will come along."

/obj/item/food/snacks/rations/nutrient_prism/attack_self(mob/user)
	if(!opened)
		to_chat("<span class = 'notice'>You need to open the packaging before you can eat this.</span>")
		return
	if(!do_after(3 SECONDS))	// It's VERY VERY chewy. A few months of service and you shall have the most strong, chiseled jaw ever. Like the soldiers on propagana posters have. Also balances out how insanely filling this is.
		return
	. = ..()

////////////////////
///   MRE MAINS  ///
////////////////////
/obj/item/food/snacks/rations/mre/chicken
	name = "fried chicken breast"
	desc = "It's a little tough, but the taste is still fine."
	list_reagents = list("nutriment" = 3, "vitamin" = 5, "protein" = 12, "salt" = 3)
	tastes = list("chicken" = 3, "salt and spices" = 2)

/obj/item/food/snacks/rations/mre/pork
	name = "BBQ Pork"
	desc = "Smokey, meaty, delicous. The sauce is a little dry."
	list_reagents = list("nutriment" = 3, "vitamin" = 5, "protein" = 12, "bbqsauce" = 10, "salt" = 3)
	tastes = list("pork" = 2, "BBQ sauce" = 3, "salt" = 1)

/obj/item/food/snacks/rations/mre/pizza
	name = "pepperoni pizza square"
	desc = "Unfortunately, you can go wrong with pizza."
	list_reagents = list("nutriment" = 10, "protein" = 5, "tomatojuice" = 6)
	tastes = list("cheese" = 2, "cardboard" = 3, "bread" = 1)

/obj/item/food/snacks/rations/mre/sushi
	name = "suishi bites"
	desc = "Multiple bits of assorted sushi. The fish is cooked..."
	list_reagents = list("vitamin" = 8, "protein" = 8, "plantmatter" = 8)
	tastes = list("rice" = 3, "fish" = 2, "egg" = 2, "seaweed" = 1)

/obj/item/food/snacks/rations/mre/spaghetti
	name = "spaghetti bolognese"
	desc = "A mass of overcooked spaghetti in tomato purée."
	list_reagents = list("vitamin" = 10, "plantmatter" = 12, "tomatojuice" = 6, "salt" = 3)
	tastes = list("spaghetti" = 2, "tomato" = 3)

/obj/item/food/snacks/rations/mre/fettuccini
	name = "spinach fettuccini"
	desc = "A mixture of pasta and spinach in a creamy sauce. Doesn't smell inviting."
	list_reagents = list("nutriment" = 4, "vitamin" = 10, "plantmatter" = 12, "salt" = 3)
	tastes = list("pasta" = 2, "spinach" = 2, "cream sauce" = 3, "herbs" = 1, "salt" = 1)

/obj/item/food/snacks/rations/mre/vomlette
	name = "cheese and vegetable omlette"
	desc = "Also kown as the \"Vomlette\". It doesn't look like an omlette, it doesn't taste like an omlette, and it sure as hell doesn't <b>smell</b> like an omlette! No redeeming qualities."
	list_reagents = list("nutriment" = 10, "plantmatter" = 15)
	tastes = list("very artifical cheese" = 3, "chemicals" = 2 , "artificial preservatives" = 1, "something resembling a vegetable" = 2)

////////////////////
///   MRE SIDES  ///
////////////////////
/obj/item/food/snacks/rations/mre/cavatelli
	name = "cavatelli pasta"
	desc = "Lots of bits of cavatelli. Some of them are still hard and crunchy."
	list_reagents = list("nutriment" = 5, "vitamin" = 3, "salt" = 3)
	tastes = list("pasta" = 3, "salt" = 1)

/obj/item/food/snacks/rations/mre/rice
	name = "fried rice"
	desc = "A portion of dry fried rice."
	list_reagents = list("nutriment" = 5, "plantmatter" = 5, "salt" = 1)
	tastes = list("rice" = 3, "salt" = 1)

/obj/item/food/snacks/rations/mre/cheese_crackers
	name = "cheese crackers"
	desc = "Crackers injected with imitation cheese product."
	list_reagents = list("nutriment" = 5, "plantmatter" = 5, "salt" = 3)
	tastes = list("cracker" = 2, "artificial cheese" = 2, "salt" = 1)

/obj/item/food/snacks/rations/mre/onigiri
	name = "rice onigiri"
	desc = "A ball of sticky white rice with a strip of seaweed wrapped around the base. This one is actually okay."
	list_reagents = list("nutriment" = 3, "vitamin" = 3, "plantmatter" = 4)
	tastes = list("rice" = 2, "sweetness" = 3, "seaweed" = 1)

/obj/item/food/snacks/rations/mre/meatballs
	name = "meatballs"
	desc = "A collection of small meatballs. Some of them are charred."
	list_reagents = list("nutriment" = 1, "vitamin" = 4, "protein" = 4)
	tastes = list("meat" = 3)

/obj/item/food/snacks/rations/mre/pretzel_nugget
	name = "pretzel nuggets"
	desc = "A collection of crunchy treats, flavoured with honey mustard and big salt crystals."
	list_reagents = list("nutriment" = 8, "plantmatter" = 1, "salt" = 5)
	tastes = list("mustard" = 2, "tangy sweetness" = 2, "salt" = 2)

////////////////////
///  MRE SNACKS  ///
////////////////////
/obj/item/food/snacks/rations/mre/peanut_crackers
	name = "peanut butter crackers"
	desc = "Crackers injected with peanut butter. The crackers are liable to crumble before you can get them to your mouth."
	list_reagents = list("nutriment" = 5, "peanutbutter" = 5, "salt" = 3)
	tastes = list("peanut butter" = 3, "cracker" = 2, "salt" = 1)

/obj/item/food/snacks/rations/mre/fighting_fuel	// Powerful ration bar, can also be found on its own.
	name = "fighting fuel"
	desc = "A nutritious, calorie-dense energy bar that is also found in the pre-emptive strike ration - manufactured by SolGov. Makes you want to scream \"OORAH!\". \
	People are known to save the label to affix it to various items."
	list_reagents = list("vitamin" = 10, "chocolate" = 5)
	tastes = list("chocolate" = 2, "fruits and nuts" = 2, "<b>FREEDOM</b>" = 3)

/obj/item/food/snacks/rations/mre/bun
	name = "cinnamon bun"
	desc = "Despite alledgedly being a bun, it's more like cake. Contains so much sugar that your teeth are getting cavities just from looking at this thing."
	list_reagents = list("nutriment" = 5, "sugar" = 15)
	tastes = list("overwhelming sweetness" = 3, "cinnamon" = 2, "cake" = 3, "bread" = 1)

/obj/item/food/snacks/rations/mre/trail_mix
	name = "recovery trail mix"
	desc = "A healthy mix of dried fruit and nuts, helps keep hunger at bay."
	list_reagents = list("vitamin" = 6)
	tastes = list("fruits" = 2, "nuts" = 2)

////////////////////
/// MRE DESSERTS ///
////////////////////
/obj/item/food/snacks/rations/mre/brownie
	name = "chocolate brownie"
	desc = "The flavour is so good, you don't really mind that it's dry and crumbly."
	list_reagents = list("nutriment" = 6, "chocolate" = 5, "sugar" = 3)
	tastes = list("chocolate" = 3, "sweetness" = 2)

/obj/item/food/snacks/rations/mre/flan
	name = "honey flan"
	desc = "A sweet dessert made from condensed milk, caramel sauce, and honey. This jackpot item has high value in ration trading."
	list_reagents = list("nutriment" = 5, "honey" = 2, "cream" = 2, "milk" = 2, "sugar" = 3)
	tastes = list("honey" = 3, "caramel" = 2, "sweetness" = 2)
/obj/item/food/snacks/rations/mre/pbj
	name = "peanut butter & jelly cracker"
	desc = "A large cracker filled with a PB&J mix. Takes the edge off."
	list_reagents = list("nutriment" = 6, "peanutbutter" = 3, "cherryjelly" = 3, "sugar" = 2)
	tastes = list("peanut butter" = 2, "jelly" = 2, "cracker" = 1)

/obj/item/food/snacks/rations/mre/spiced_apple
	name = "spiced apple"
	desc = "An apple, sliced into sections, drenched in a spiced cinnamon sauce."
	list_reagents = list("nutriment" = 6, "sugar" = 4)
	tastes = list("cinnamon" = 2, "apple" = 2, "spices" = 1)

/obj/item/food/snacks/rations/mre/smores
	name = "military-grade smores bar"
	desc = "A bunch of marshmallows and chocolate bits stuck together with sticky granola. Surprisingly tastes better than any smores bar you can find in stores."
	list_reagents = list("nutriment" = 6, "chocolate" = 3, "sugar" = 8)
	tastes = list("chocolate" = 2, "marshmallow" = 2, "sweet sticky granola" = 3)

/obj/item/food/snacks/rations/mre/pancake
	name = "maple syrup pancake"
	desc = "A pancake fortified with maple syrup and butter. A wonder of modern food technology."
	list_reagents = list("nutriment" = 5, "sugar" = 12)
	tastes = list("pancake" = 2, "maple syrup" = 3, "butter" = 1)

/obj/item/food/snacks/rations/mre/granola
	name = "blueberry granola"
	desc = "Blueberry granola suspended in milk. It's less bad than it sounds."
	list_reagents = list("vitamin" = 3, "milk" = 5, "sugar" = 5)
	tastes = list("blueberry" = 3, "granola" = 2, "milk" = 3)

////////////////////
//////	MRE	 ///////
////////////////////
#define MAIN_FOOD 1
#define SIDE_FOOD 2
#define SNACK_FOOD 3
#define DESSERT_FOOD 4

/obj/item/storage/box/mre
	name = "Meal, Ready-to-Eat"
	desc = "A compact SolGov-produced field ration designed to feed a soldier in active combat. Contains self-heating food packets that require no prior preperation. Meets all of the legal and technical requirements to be considered real food!"
	storage_slots = 8
	can_hold = list(
		/obj/item/food/snacks/rations,
		/obj/item/reagent_containers/glass/beaker/waterbottle,
		/obj/item/clothing/mask/cigarette,
		/obj/item/storage/fancy/cigarettes/,
		/obj/item/storage/fancy/matches,
		/obj/item/match,
		/obj/item/kitchen/utensil/spoon
	)
	var/list/menu_option
	var/main_food
	var/side_food
	var/snack_food
	var/dessert_food

/obj/item/storage/box/mre/Initialize()
	menu_option = pick("Chicken & Cavatelli", "BBQ Pork & Rice", "Pepperoni Pizza & Cheese-Filled Crackers", "Sushi & Rice Onigiri", "Spaghetti & Meatballs", "Creamy Spinach Fettuccini", "Cheese & Veggie Omlette")
	var/new_name = "[menu_option] [name]"
	name = new_name
	get_menu_items(menu_option)
	. = ..()

/obj/item/storage/box/mre/examine()
	. = ..()
	. += "<span class = 'notice'>This one contains the [menu_option] menu.</span>"
	if(menu_option == "Cheese & Veggie Omlette")
		. += "<span class = 'warning'>Looks like you'll be going hungry tonight...</span>"

/obj/item/storage/box/mre/populate_contents()
	new main_food(src)
	new side_food(src)
	new snack_food(src)
	new dessert_food(src)
	new /obj/item/kitchen/utensil/spoon(src)
	new /obj/item/reagent_containers/glass/beaker/waterbottle(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_robust(src)
	new /obj/item/storage/fancy/matches(src)

/obj/item/storage/box/mre/proc/get_menu_items()
	var/static/list/menu_item_list = list(
		"Chicken & Cavatelli" = list(
			/obj/item/food/snacks/rations/mre/chicken,
			/obj/item/food/snacks/rations/mre/cavatelli,
			/obj/item/food/snacks/rations/mre/trail_mix,
			/obj/item/food/snacks/rations/mre/brownie
		),
		"BBQ Pork & Rice" = list(
			/obj/item/food/snacks/rations/mre/pork,
			/obj/item/food/snacks/rations/mre/rice,
			/obj/item/food/snacks/rations/mre/fighting_fuel,
			/obj/item/food/snacks/rations/mre/pancake
		),
		"Pepperoni Pizza & Cheese-Filled Crackers" = list(
			/obj/item/food/snacks/rations/mre/pizza,
			/obj/item/food/snacks/rations/mre/cheese_crackers,
			/obj/item/food/snacks/rations/mre/trail_mix,
			/obj/item/food/snacks/rations/mre/smores
		),
		"Sushi & Rice Onigiri" = list(
			/obj/item/food/snacks/rations/mre/sushi,
			/obj/item/food/snacks/rations/mre/onigiri,
			/obj/item/food/snacks/rations/mre/bun,
			/obj/item/food/snacks/rations/mre/spiced_apple
		),
		"Spaghetti & Meatballs" = list(
			/obj/item/food/snacks/rations/mre/spaghetti,
			/obj/item/food/snacks/rations/mre/meatballs,
			/obj/item/food/snacks/rations/mre/peanut_crackers,
			/obj/item/food/snacks/rations/mre/flan
		),
		"Creamy Spinach Fettuccini" = list(,
			/obj/item/food/snacks/rations/mre/fettuccini,
			/obj/item/food/snacks/rations/mre/pretzel_nugget,
			/obj/item/food/snacks/rations/mre/fighting_fuel,
			/obj/item/food/snacks/rations/mre/pbj

		),
		"Cheese & Veggie Omlette" = list(	// The Vomlette. The worst MRE in history.
			/obj/item/food/snacks/rations/mre/vomlette,
			/obj/item/food/snacks/rations/mre/cheese_crackers,
			/obj/item/food/snacks/rations/mre/bun,
			/obj/item/food/snacks/rations/mre/granola
		)
	)
	main_food = menu_item_list[menu_option][MAIN_FOOD]
	side_food = menu_item_list[menu_option][SIDE_FOOD]
	snack_food = menu_item_list[menu_option][SNACK_FOOD]
	dessert_food = menu_item_list[menu_option][DESSERT_FOOD]

#undef MAIN_FOOD
#undef SIDE_FOOD
#undef SNACK_FOOD
#undef DESSERT_FOOD
