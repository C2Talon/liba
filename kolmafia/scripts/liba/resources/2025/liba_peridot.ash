//liba peridot

//used to fight and keep track of monsters fought with this in each zone
//note: with the way this is implemented, pre-adventure scripts will not automatically run before adventures with this
//current a few aborts in the script, simply because I think it might be a bad idea to let the calling script continue in a state that it probably would not expect

import <liba_inChoice.ash>

//returns true if have the peridot item
boolean liba_peridot_have();

/*
uses the peridot to fight a monster at a location
returns true if monster is fought with the peridot
returns false if:
- the peridot is not equipped
- the monster is not in the zone
- the choice adventure was not encountered
*/
boolean liba_peridot(monster mon,location loc);
boolean liba_peridot(monster mon,location loc,string macro);
boolean liba_peridot(location loc,monster mon);
boolean liba_peridot(location loc,monster mon,string macro);

//reads a mafia preference used to track if the peridot has already been used in a location
//returns true if the peridot has been used in the location
boolean liba_peridot_used(location loc);

/* helper functions */

//check if monster is in the choice or combat
boolean liba_peridot_checkCombat(buffer page);
boolean liba_peridot_checkCombat(buffer page,monster mon);
boolean liba_peridot_checkChoice(buffer page,monster mon);

//standardize messages
boolean liba_peridot_error(string s);
void liba_peridot_print(string s);

/* implementations */

boolean liba_peridot_have() {
	return available_amount($item[peridot of peril]) > 0;
}
boolean liba_peridot(monster mon,location loc,string macro) {
	buffer page;
	item thing = $item[peridot of peril];

	if (!liba_peridot_have())
		return liba_peridot_error(`no {thing} detected`);
	if (equipped_amount(thing) == 0)
		return liba_peridot_error(`{thing} not equipped`);
	if (liba_peridot_used(loc))
		return liba_peridot_error(`already used at {loc}`);

	//get to choice via location with visit_url() to avoid mafia taking over or aborting
	if (liba_inChoice(1557))
		page = visit_url("main.php",false,true);//need page text to check it
	else
		page = loc.to_url().visit_url(false,true);
	if (!liba_inChoice(1557)) {
		if (page.liba_peridot_checkCombat(mon)) {
			liba_peridot_print(`already in combat with {mon} without going to the choice adventure, so running the combat`);
			run_combat(macro);
			return true;
		}
		else if (page.liba_peridot_checkCombat())
			abort("in a combat not expected");
		else if (handling_choice())
			abort("in a choice adventure not expected");
		else
			return liba_peridot_error("something broke; couldn't get into the choice");
	}
	if (!page.liba_peridot_checkChoice(mon))
		abort(`could not find {mon} in the list; still in the {thing} choice adventure`);

	//everything checks out so far; choose the monster
	page = visit_url(`choice.php?pwd&option=1&whichchoice=1557&bandersnatch={mon.id}`,true,true);

	//success
	if (page.liba_peridot_checkCombat(mon)) {
		run_combat(macro);
		return true;
	}
	//error
	else if (page.liba_peridot_checkCombat())
		abort("in a combat not expected");
	else if (liba_inChoice(1557))
		abort(`still stuck in the {thing} choice adventure`);
	else if (liba_inChoice(1435))
		abort("managed to get stuck in a bugged adventure that costs a turn against all attempts to prevent it; please report this, preferrably with logs");
	else
		abort("unknown error; genuinely don't know the state of kol or mafia; please report this, preferrably with logs");
	return false;//no way to get here, but kolmafia complains about missing return value
}
boolean liba_peridot(monster mon,location loc) {
	return liba_peridot(mon,loc,'');
}
boolean liba_peridot(location loc,monster mon,string macro) {
	return liba_peridot(mon,loc,macro);
}
boolean liba_peridot(location loc,monster mon) {
	return liba_peridot(mon,loc,'');
}
boolean liba_peridot_used(location loc) {
	matcher mat = create_matcher(`(?<=(^|,)){loc.id}(?=($|,))`,get_property("_perilLocations"));
	return mat.find();
}
boolean liba_peridot_checkCombat(buffer page) {
	matcher mat = create_matcher("<!-*\\s*MONSTERID:\\s+\\d+\\s*-*>",page);
	return mat.find();
}
boolean liba_peridot_checkCombat(buffer page,monster mon) {
	matcher mat = create_matcher(`<!-*\\s*MONSTERID:\\s+{mon.id}\\s*-*>`,page);
	return mat.find();
}
boolean liba_peridot_checkChoice(buffer page,monster mon) {
	return page.contains_text(`name="bandersnatch" value="{mon.id}"`);
}
boolean liba_peridot_error(string s) {
	print(`liba_peridot error: {s}`,"red");
	return false;
}
void liba_peridot_print(string s) {
	print(`liba_peridot: {s}`);
}

