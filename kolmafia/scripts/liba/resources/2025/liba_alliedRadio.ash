//liba alliedRadio

import <liba_inChoice.ash>
import <liba_incProperty.ash>

/* properties used
_liba_alliedRadio_used = number of requests used with backpack
*/

//returns whether have the Allied Radio Backpack or not
boolean liba_alliedRadio_have();

//requests the given thing or arbitrary string from the Allied Radio Backpack
//returns true on success
boolean liba_alliedRadio(string request);
boolean liba_alliedRadio(item ite);
boolean liba_alliedRadio(effect eff);

//returns number of times backpack has been used
int liba_alliedRadio_used();

//returns number of uses backpack has left
int liba_alliedRadio_left();

/* helper functions */

//returns the request string for given thing
string liba_alliedRadio_toRequest(item ite);
string liba_alliedRadio_toRequest(effect eff);

//enters the choice adventure for the backpack
//returns true on success
boolean liba_alliedRadio_enter();

/* implementations */

boolean liba_alliedRadio_have() {
	return available_amount($item[allied radio backpack]) > 0;
}

boolean liba_alliedRadio(string request) {
	if (!liba_alliedRadio_have())
		return false;
	if (liba_alliedRadio_used() >= 3)
		return false;
	if (!liba_alliedRadio_enter())
		return false;
	run_choice(1,`request={request}`);
	liba_incProperty("_liba_alliedRadio_used");
	return true;
}
boolean liba_alliedRadio(item ite) {
	string request = liba_alliedRadio_toRequest(ite);
	if (request == '')
		return false;
	return liba_alliedRadio(request);
}
boolean liba_alliedRadio(effect eff) {
	string request = liba_alliedRadio_toRequest(eff);
	if (request == '')
		return false;
	return liba_alliedRadio(request);
}
int liba_alliedRadio_used() {
	return get_property("_liba_alliedRadio_used").to_int();
}

int liba_alliedRadio_left() {
	return 3-get_property("_liba_alliedRadio_used").to_int();
}

string liba_alliedRadio_toRequest(item ite) {
	return string[item]{
		$item[chroner]:			"salary",
		//$item[handheld allied radio]:	"radio",
		$item[skeleton war fuel can]:	"fuel",
		$item[skeleton war grenade]:	"ordanance",
		$item[skeleton wars rations]:	"rations",
	}[ite];
}
string liba_alliedRadio_toRequest(effect eff) {
	return string[effect]{
		//$effect[ellipsoidtine]:		"Ellipsoidtine",
		$effect[materiel intel]:	"materiel intel",
	}[eff];
}

boolean liba_alliedRadio_enter() {
	if (!liba_alliedRadio_have())
		return false;

	int choiceId = 1561;
	if (liba_inChoice(choiceId))
		return true;
	if (visit_url(`inventory.php?action=requestdrop&pwd={my_hash()}`,false)
		.contains_text(">Seems like your radio needs some time to recharge.</td>"))
	{
		set_property("_liba_alliedRadio_used",3);
		return false;
	}
	if (liba_inChoice(choiceId))
		return true;
	return false;
}

