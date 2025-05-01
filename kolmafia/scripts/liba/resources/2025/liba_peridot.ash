//liba peridot

//used to fight monsters in their respective locations with the peridot of peril
//will try to gracefully handle unexpected things it encounters and then try again after, but will quit trying to get a peridot encounter if it ends up using a turn with the unexpected things
//warning: if you try to use this with a monster and location combination that isn't valid, bad things(TM) may happen
//note: with the way this is implemented, pre-adventure scripts will not automatically run before adventures with this

import <liba_inChoice.ash>
import <liba_inCombat.ash>

//returns true if have the peridot item
boolean liba_peridot_have();

//uses the peridot to fight a monster at a location
//returns true if monster is fought
//returns false on any error with a message
boolean liba_peridot(monster mon,location loc);
boolean liba_peridot(monster mon,location loc,string macro);
boolean liba_peridot(location loc,monster mon);
boolean liba_peridot(location loc,monster mon,string macro);

//reads a mafia preference used to track if the peridot has already been used in a location
//returns true if the peridot has been used in the location
boolean liba_peridot_used(location loc);

/* helper functions */

//check if monster is in the choice
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
	item peridot = $item[peridot of peril];
	int start = turns_played();
	int tries = 0,max = 5;

	//pre-flight checks
	if (!liba_peridot_have())
		return liba_peridot_error(`no {peridot} detected`);
	if (equipped_amount(peridot) == 0)
		return liba_peridot_error(`{peridot} not equipped`);
	if (!loc.to_url().starts_with("adventure.php"))
		return liba_peridot_error(`{loc} is not a valid location`);
	if (liba_peridot_used(loc) && !liba_inChoice(1557))
		return liba_peridot_error(`already used at {loc}`);

	repeat {
		page = loc.to_url().visit_url(false,true);
		//encountered something unexpected
		if (!liba_inChoice(1557) && !page.liba_inCombat(mon)) {
			liba_peridot_print("encountered something unexpected, trying to gracefully handle it");
			run_turn();
			continue;
		}
		//the choice adventure
		if (liba_inChoice(1557)) {
			if (!page.liba_peridot_checkChoice(mon)) {
				run_choice(2);
				return liba_peridot_error(`{mon} not found at {loc}; choice adventure was exited and the {peridot} charge has been used`);
			}
			page = visit_url(`choice.php?pwd&option=1&whichchoice=1557&bandersnatch={mon.id}`,true,true);
		}
		//the combat
		if (page.liba_inCombat(mon)) {
			run_combat(macro);
			return true;
		}
	} until (turns_played() > start || ++tries >= max);

	//errors
	if (turns_played() > start)
		return liba_peridot_error(`a turn was used up before even trying to fight a {mon} at {loc}, so giving up`);
	if (tries >= max)
		return liba_peridot_error(`too many attempts were made trying to fight a {mon} at {loc}, so giving up`);

	return liba_peridot_error("no idea how this got to the end, but it did");
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

