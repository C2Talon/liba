//liba alliedRadioBackpack

import <liba_inChoice.ash>
import <liba_incProperty.ash>

/* properties used
_liba_alliedRadioBackpack_used = number of requests used with backpack
*/

//returns whether have the Allied Radio Backpack or not
boolean liba_alliedRadioBackpack_have();

//requests the given thing or arbitrary string from the Allied Radio Backpack
//returns true on success
boolean liba_alliedRadioBackpack(string request);
boolean liba_alliedRadioBackpack(item ite);
boolean liba_alliedRadioBackpack(effect eff);

//returns number of times backpack has been used
int liba_alliedRadioBackpack_used();

//returns number of uses backpack has left
int liba_alliedRadioBackpack_left();

/* helper functions */

//returns the request string for given thing
string liba_alliedRadioBackpack_toRequest(item ite);
string liba_alliedRadioBackpack_toRequest(effect eff);

//enters the choice adventure for the backpack
//returns true on success
boolean liba_alliedRadioBackpack_enter();

/* implementations */

boolean liba_alliedRadioBackpack_have() {
	return available_amount($item[allied radio backpack]) > 0;
}

boolean liba_alliedRadioBackpack(string request) {
	if (!liba_alliedRadioBackpack_have())
		return false;
	if (liba_alliedRadioBackpack_used() >= 3)
		return false;
	if (!liba_alliedRadioBackpack_enter())
		return false;
	if (!run_choice(1,`request={request.url_encode()}`).contains_text(">You acquire "))
		return false;
	liba_incProperty("_liba_alliedRadioBackpack_used");
	return true;
}
boolean liba_alliedRadioBackpack(item ite) {
	return liba_alliedRadioBackpack(liba_alliedRadioBackpack_toRequest(ite));
}
boolean liba_alliedRadioBackpack(effect eff) {
	return liba_alliedRadioBackpack(liba_alliedRadioBackpack_toRequest(eff));
}

int liba_alliedRadioBackpack_used() {
	return get_property("_liba_alliedRadioBackpack_used").to_int();
}

int liba_alliedRadioBackpack_left() {
	return 3-get_property("_liba_alliedRadioBackpack_used").to_int();
}

string liba_alliedRadioBackpack_toRequest(item ite) {
	return string[item]{
		$item[skeleton war fuel can]:	"fuel",
		$item[skeleton war grenade]:	"ordanance",
		$item[skeleton wars rations]:	"rations",
		$item[chroner]:			"salary",
	}[ite];
}
string liba_alliedRadioBackpack_toRequest(effect eff) {
	return string[effect]{
		$effect[materiel intel]:	"materiel intel",
	}[eff];
}

boolean liba_alliedRadioBackpack_enter() {
	if (!liba_alliedRadioBackpack_have())
		return false;

	int choiceId = 1561;
	if (liba_inChoice(choiceId))
		return true;
	if (visit_url(`inventory.php?action=requestdrop&pwd={my_hash()}`,false)
		.contains_text(">Seems like your radio needs some time to recharge.</td>"))
	{
		set_property("_liba_alliedRadioBackpack_used",3);
		return false;
	}
	if (liba_inChoice(choiceId))
		return true;
	return false;
}

