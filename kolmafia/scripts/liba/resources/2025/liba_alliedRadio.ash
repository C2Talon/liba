//liba alliedRadio

import <liba_inChoice.ash>
import <liba_rawUse.ash>

record liba_alliedRadio_data {
	item thing;
	int choiceId;
};

/* properties used
_liba_alliedRadio_used = number of requests used with backpack
*/

//returns true if have the Allied Radio Backpack or a handheld version
boolean liba_alliedRadio_have();

//requests the given thing or arbitrary string from an allied radio
//prioritizes using the backpack first, but will use the handheld if available and backpack fully used up
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

//picks item to be used
//returns record of item that will be used and its corresponding choiceId
liba_alliedRadio_data liba_alliedRadio_pick();

//enters the choice adventure for the allied radio
//returns true on success
boolean liba_alliedRadio_enter();

/* implementations */

boolean liba_alliedRadio_have() {
	return available_amount($item[allied radio backpack]) > 0
		|| item_amount($item[handheld allied radio]) > 0;
}

boolean liba_alliedRadio(string request) {
	if (!liba_alliedRadio_enter())
		return false;

	buffer page = run_choice(1,`request={request}`);

	if (last_choice() == 1561) {
		matcher m = create_matcher("enough battery left to make (\\d) call",page);
		if (m.find())
			set_property("_liba_alliedRadio_used",3-m.group(1).to_int());
		else
			set_property("_liba_alliedRadio_used",3);
	}
	else
		cli_execute("refresh inv");

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
	if (available_amount($item[allied radio backpack]) == 0)
		return 0;
	return 3-get_property("_liba_alliedRadio_used").to_int();
}

string liba_alliedRadio_toRequest(item ite) {
	return string[item]{
		$item[chroner]:			"salary",
		$item[handheld allied radio]:	"radio",
		$item[skeleton war fuel can]:	"fuel",
		$item[skeleton war grenade]:	"ordanance",
		$item[skeleton wars rations]:	"rations",
	}[ite];
}
string liba_alliedRadio_toRequest(effect eff) {
	return string[effect]{
		$effect[ellipsoidtined]:	"ellipsoidtine",
		$effect[materiel intel]:	"materiel intel",
	}[eff];
}

liba_alliedRadio_data liba_alliedRadio_pick() {
	liba_alliedRadio_data out;
	if (available_amount($item[allied radio backpack]) > 0 && liba_alliedRadio_left() > 0)
		out = new liba_alliedRadio_data($item[allied radio backpack],1561);
	else if (item_amount($item[handheld allied radio]) > 0)
		out = new liba_alliedRadio_data($item[handheld allied radio],1563);
	return out;
}

boolean liba_alliedRadio_enter() {
	liba_alliedRadio_data it = liba_alliedRadio_pick();
	if (it.choiceId == 0)
		return false;
	if (liba_inChoice(it.choiceId))
		return true;
	if (liba_rawUse(it.thing).contains_text(">Seems like your radio needs some time to recharge.</td>")) {
		set_property("_liba_alliedRadio_used",3);
		return liba_alliedRadio_enter();
	}
	return liba_inChoice(it.choiceId);
}

