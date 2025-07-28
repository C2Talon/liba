//liba alliedRadio

//functions for use of the allied radio


//returns true if have the Allied Radio Backpack or a handheld version
boolean liba_alliedRadio_have();

//validates and passes input to allied_radio(string), then verifies result for non-string inputs
//returns true on success
boolean liba_alliedRadio(string request);
boolean liba_alliedRadio(item ite);
boolean liba_alliedRadio(effect eff);

//returns number of times backpack has been used
int liba_alliedRadio_used();

//returns 0 if the backpack is not detected
//otherwise returns number of uses backpack has left
int liba_alliedRadio_left();

/* helper functions */

//returns the request string for given thing
string liba_alliedRadio_toRequest(item ite);
string liba_alliedRadio_toRequest(effect eff);

//returns true if string is a known valid input for the allied radio
boolean liba_alliedRadio_isValid(string s);

/* implementations */

boolean liba_alliedRadio_have() {
	return available_amount($item[allied radio backpack]) > 0
		|| item_amount($item[handheld allied radio]) > 0;
}

boolean liba_alliedRadio(string request) {
	if (!liba_alliedRadio_have())
		return false;
	if (!liba_alliedRadio_isValid(request))
		return false;
	return allied_radio(request);
}
boolean liba_alliedRadio(item ite) {
	string request = liba_alliedRadio_toRequest(ite);
	if (request == '')
		return false;
	int start = item_amount(ite);
	liba_alliedRadio(request);
	return start < item_amount(ite);
}
boolean liba_alliedRadio(effect eff) {
	string request = liba_alliedRadio_toRequest(eff);
	if (request == '')
		return false;
	int start = have_effect(eff);
	liba_alliedRadio(request);
	return start < have_effect(eff);
}

int liba_alliedRadio_used() {
	return get_property("_alliedRadioDropsUsed").to_int();
}

int liba_alliedRadio_left() {
	if (available_amount($item[allied radio backpack]) == 0)
		return 0;
	return 3-liba_alliedRadio_used();
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

boolean liba_alliedRadio_isValid(string s) {
	return $strings[
		ellipsoidtine,
		fuel,
		materiel intel,
		ordanance,
		radio,
		rations,
		salary,
		sniper support,
	][s];
}

