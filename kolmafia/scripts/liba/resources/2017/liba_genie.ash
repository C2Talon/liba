//liba genie

//genie bottle handling

import <liba_inChoice.ash>
import <liba_rawUse.ash>

//returns true if have any genie bottle or pocket wishes
boolean liba_genie_have();

//get an effect with genie bottle
//returns true if effect obtained
boolean liba_genie(effect eff);

//use genie bottle to fight a monster
//will use combat macro if included
//returns true if the monster was fought
boolean liba_genie(monster mon);
boolean liba_genie(monster mon,string macro);

/* helper functions */

//used to pick the item to use
item liba_genie_item();
//enter the choice adventure with item
boolean liba_genie_enter();

/* implementations */

boolean liba_genie(effect eff) {
	if (liba_genie_item() == $item[none])
		return false;

	int start = have_effect(eff);
	cli_execute(`try;genie effect {eff}`);
	return start < have_effect(eff);
}

boolean liba_genie(monster mon,string macro) {
	if (!liba_genie_have())
		return false;
	if (get_property("_genieFightsUsed").to_int() >= 3)
		return false;
	if (my_hp() == 0) {
		print("liba_genie error: fighting a monster at zero health would be an instant loss","red");
		return false;
	}
	if (!liba_genie_enter())
		return false;
	if (!visit_url("choice.php?pwd&whichchoice=1267&option=1&wish=to fight a "+mon.manuel_name,true,true).contains_text("<a href='fight.php'>Fight!</a>"))
		return false;
	visit_url("main.php",false,true);
	run_combat(macro);
	return true;
}
boolean liba_genie(monster mon) {
	return liba_genie(mon,'');
}
boolean liba_genie_have() {
	foreach x in $items[genie bottle,replica genie bottle,pocket wish]
		if (item_amount(x) > 0)
			return true;
	return false;
}
item liba_genie_item() {
	item out;
	boolean wishesLeft = get_property("_genieWishesUsed").to_int() < 3;
	if (item_amount($item[genie bottle]) > 0 && wishesLeft)
		out = $item[genie bottle];
	else if (item_amount($item[replica genie bottle]) > 0 && wishesLeft)
		out = $item[replica genie bottle];
	else if (item_amount($item[pocket wish]) > 0)
		out = $item[pocket wish];
	return out;
}
boolean liba_genie_enter() {
	item thing = liba_genie_item();
	if (thing == $item[none])
		return false;
	if (!liba_inChoice(1267))
		liba_rawUse(thing);
	return liba_inChoice(1267);
}

