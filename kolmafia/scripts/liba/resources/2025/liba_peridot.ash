//liba peridot

//used to fight monsters in their respective locations with the peridot of peril
//will try to gracefully handle unexpected things it encounters and then try again after, but will quit trying to get a peridot encounter if it ends up using a turn with the unexpected things
//warning: if trying to use this with a monster and location combination that isn't valid, bad things(TM) may happen
//note: with the way this is implemented, pre-adventure scripts will not automatically run before adventures with this

import <liba_inChoice.ash>
import <liba_inCombat.ash>

//returns true if have the peridot item
boolean liba_peridot_have();

//tries to fight a monster at a location with optional combat macro with the peridot of peril choice adventure
//make sure to have the peridot of peril equipped first, as well as do any other pre-adventure preparation since mafia's automated ones will not trigger with this
//this will also work if you happen to already be in the choice adventure to choose a monster
//returns true if monster is fought
//returns false on any error with a message
boolean liba_peridot(monster mon,location loc);
boolean liba_peridot(monster mon,location loc,string macro);
boolean liba_peridot(location loc,monster mon);
boolean liba_peridot(location loc,monster mon,string macro);

//same as above, but use a map of monsters as a priority list to choose from; useful for locations that might not always have the same monster every time for everyone (e.g. Junkyard)
boolean liba_peridot(monster[int] monsterPriority,location loc);
boolean liba_peridot(monster[int] monsterPriority,location loc,string macro);
boolean liba_peridot(location loc,monster[int] monsterPriority);
boolean liba_peridot(location loc,monster[int] monsterPriority,string macro);

//already in the choice adventure so location isn't necessary
boolean liba_peridot(monster mon);
boolean liba_peridot(monster mon,string macro);
boolean liba_peridot(monster[int] monsterPriority);
boolean liba_peridot(monster[int] monsterPriority,string macro);

//already in the choice adventure so location isn't necessary, but also can also feed it the page if using something like a choice adventure script to avoid an extra hit on the server
boolean liba_peridot(buffer page,monster mon);
boolean liba_peridot(buffer page,monster mon,string macro);
boolean liba_peridot(buffer page,monster[int] monsterPriority);
boolean liba_peridot(buffer page,monster[int] monsterPriority,string macro);

//all the above feed into this; handles everything
boolean liba_peridot(buffer page,monster[int] monsterPriority,location loc,string macro);


//send fruit, in part, to another player with foresee peril
//returns true if sent or false if not
boolean liba_peridot(string player_name_or_id);
boolean liba_peridot(int player_id);


/* helper functions */

//reads a mafia preference used to track if the peridot has already been used in a location
//returns true if the peridot has been used in the location
boolean liba_peridot_used(location loc);

//returns map of all the monsters in the choice adventure from the given page
boolean[monster] liba_peridot_monstersInChoice(buffer page);

//check if monster is in the choice from the given page
boolean liba_peridot_checkChoice(buffer page,monster mon);

//finds the first monster in monsterPriority that is also in the choice
//returns $monster[none] if no monster match
//otherwise returns the first monster that matches
monster liba_peridot_checkChoicePriority(buffer page,monster[int] monsterPriority);

//returns true if in combat with one of the monsters in monsterPriority
boolean liba_peridot_inCombat(buffer page,monster[int] monsterPriority);

//string that is a comma-delimited list of monsters in given map
string liba_peridot_monList(monster[int] monsterPriority);
string liba_peridot_monList(boolean[monster] monstersInChoice);

//standardize messages
boolean liba_peridot_error(string s);
void liba_peridot_print(string s);


/* implementations */

boolean liba_peridot_have() {
	return available_amount($item[peridot of peril]) > 0;
}
boolean liba_peridot(buffer page,monster[int] monsterPriority,location loc,string macro) {
	buffer blank;
	item peridot = $item[peridot of peril];
	int start = turns_played();
	monster target;
	string monList = liba_peridot_monList(monsterPriority);

	//pre-flight checks
	if (!liba_inChoice(1557)) {//if already in the choice, don't really need to check that we can get to the choice
		if (!liba_peridot_have())
			return liba_peridot_error(`no {peridot} detected`);
		if (equipped_amount(peridot) == 0)
			return liba_peridot_error(`{peridot} not equipped`);
		if (loc.id == -1)
			return liba_peridot_error(`{loc} is not a valid location`);
		if (!can_adventure(loc))
			return liba_peridot_error(`{loc} not available for adventure`);
		if (liba_peridot_used(loc))
			return liba_peridot_error(`already used at {loc}`);
	}

	int tries = 0,max = 5;
	repeat {
		if (page == blank || tries > 0)
			page = loc.to_url().visit_url(false,true);
		//encountered something unexpected
		if (!liba_inChoice(1557) && !page.liba_peridot_inCombat(monsterPriority)) {
			liba_peridot_print("encountered something unexpected; trying to gracefully handle it");
			run_turn();
			continue;
		}
		//the choice
		if (liba_inChoice(1557)) {
			target = page.liba_peridot_checkChoicePriority(monsterPriority);
			if (target == $monster[none]) {
				string choList = page.liba_peridot_monstersInChoice().liba_peridot_monList();
				//choosing a monster that isn't on the list goes to a bugged adventure that costs a turn to get out of, so this is the safer and more streamlined alternative
				//i.e. would rather lose a charge and keep going than lose a turn for nothing or abort on this
				run_choice(2);
				return liba_peridot_error(`no {monList} found at {loc}; choice adventure was exited and the {peridot} charge has been used; for future reference, monsters that were available: {choList}`);
			}
			page = visit_url(`choice.php?pwd&option=1&whichchoice=1557&bandersnatch={target.id}`,true,true);
		}
		//the combat
		if (page.liba_peridot_inCombat(monsterPriority)) {
			run_combat(macro);
			return true;
		}
	} until (turns_played() > start || ++tries >= max);

	//errors
	if (turns_played() > start)
		return liba_peridot_error(`a turn was used up before even trying to fight one of {monList} at {loc}, so giving up`);
	if (tries >= max)
		return liba_peridot_error(`too many attempts were made trying to fight one of {monList} at {loc}, so giving up`);

	return liba_peridot_error("no idea how this got to the end, but it did");
}
boolean liba_peridot(string player_name_or_id) {
	if (!liba_peridot_have())
		return liba_peridot_error(`no peridot detected`);
	int start = get_property("_perilsForeseen").to_int();
	if (start >= 3)
		return liba_peridot_error("foresee peril has been used max times already");
	cli_execute(`try;throw peridot of peril at {player_name_or_id}`);
	return start != get_property("_perilsForeseen").to_int();
}
boolean liba_peridot(int player_id) {
	return liba_peridot(player_id.to_string());
}
boolean liba_peridot_used(location loc) {
	return create_matcher(`(?<=(^|,)){loc.id}(?=($|,))`,get_property("_perilLocations")).find();
}
boolean[monster] liba_peridot_monstersInChoice(buffer page) {
	boolean[monster] out;
	matcher mat = create_matcher('name="bandersnatch" value="(\\d+)"',page);
	while (mat.find())
		out[mat.group(1).to_monster()] = true;
	return out;
}
boolean[monster] liba_peridot_monstersInChoice(string page) {
	return page.to_buffer().liba_peridot_monstersInChoice();
}
boolean liba_peridot_checkChoice(buffer page,monster mon) {
	return page.contains_text(`name="bandersnatch" value="{mon.id}"`);
}
boolean liba_peridot_checkChoice(string page,monster mon) {
	return page.to_buffer().liba_peridot_checkChoice(mon);
}
monster liba_peridot_checkChoicePriority(buffer page,monster[int] monsterPriority) {
	boolean[monster] available = page.liba_peridot_monstersInChoice();
	foreach i,x in monsterPriority
		if (available[x])
			return x;
	return $monster[none];
}
monster liba_peridot_checkChoicePriority(string page,monster[int] monsterPriority) {
	return page.to_buffer().liba_peridot_checkChoicePriority(monsterPriority);
}
boolean liba_peridot_inCombat(buffer page,monster[int] monsterPriority) {
	if (page.liba_inCombat())
		foreach i,x in monsterPriority
			if (page.liba_inCombat(x))
				return true;
	return false;
}
string liba_peridot_monList(monster[int] monsterPriority) {
	string out;
	foreach i,x in monsterPriority
		out += (out == "" ? "" : ",") + x;
	return out;
}
string liba_peridot_monList(boolean[monster] monstersInChoice) {
	string out;
	foreach x in monstersInChoice
		out += (out == "" ? "" : ",") + `[{x.id}]{x}`;
	return out;
}
boolean liba_peridot_error(string s) {
	print(`liba_peridot error: {s}`,"red");
	return false;
}
void liba_peridot_print(string s) {
	print(`liba_peridot: {s}`);
}

/* overloads */
//monster at location
boolean liba_peridot(monster mon,location loc) {
	return liba_peridot("".to_buffer(),monster[int]{mon},loc,'');
}
boolean liba_peridot(monster mon,location loc,string macro) {
	return liba_peridot("".to_buffer(),monster[int]{mon},loc,macro);
}
boolean liba_peridot(location loc,monster mon) {
	return liba_peridot("".to_buffer(),monster[int]{mon},loc,'');
}
boolean liba_peridot(location loc,monster mon,string macro) {
	return liba_peridot("".to_buffer(),monster[int]{mon},loc,macro);
}
//priority list at location
boolean liba_peridot(monster[int] monsterPriority,location loc) {
	return liba_peridot("".to_buffer(),monsterPriority,loc,'');
}
boolean liba_peridot(monster[int] monsterPriority,location loc,string macro) {
	return liba_peridot("".to_buffer(),monsterPriority,loc,macro);
}
boolean liba_peridot(location loc,monster[int] monsterPriority) {
	return liba_peridot("".to_buffer(),monsterPriority,loc,'');
}
boolean liba_peridot(location loc,monster[int] monsterPriority,string macro) {
	return liba_peridot("".to_buffer(),monsterPriority,loc,macro);
}
//no location; i.e. in the choice already
boolean liba_peridot(monster mon) {
	return liba_peridot("".to_buffer(),monster[int]{mon},my_location(),'');
}
boolean liba_peridot(monster mon,string macro) {
	return liba_peridot("".to_buffer(),monster[int]{mon},my_location(),macro);
}
boolean liba_peridot(monster[int] monsterPriority) {
	return liba_peridot("".to_buffer(),monsterPriority,my_location(),'');
}
boolean liba_peridot(monster[int] monsterPriority,string macro) {
	return liba_peridot("".to_buffer(),monsterPriority,my_location(),macro);
}
//no location with page; i.e. in the choice already
boolean liba_peridot(buffer page,monster mon) {
	return liba_peridot(page,monster[int]{mon},my_location(),'');
}
boolean liba_peridot(buffer page,monster mon,string macro) {
	return liba_peridot(page,monster[int]{mon},my_location(),macro);
}
boolean liba_peridot(buffer page,monster[int] monsterPriority) {
	return liba_peridot(page,monsterPriority,my_location(),'');
}
boolean liba_peridot(buffer page,monster[int] monsterPriority,string macro) {
	return liba_peridot(page,monsterPriority,my_location(),macro);
}
boolean liba_peridot(string page,monster mon) {
	return liba_peridot(page.to_buffer(),monster[int]{mon},my_location(),'');
}
boolean liba_peridot(string page,monster mon,string macro) {
	return liba_peridot(page.to_buffer(),monster[int]{mon},my_location(),macro);
}
boolean liba_peridot(string page,monster[int] monsterPriority) {
	return liba_peridot(page.to_buffer(),monsterPriority,my_location(),'');
}
boolean liba_peridot(string page,monster[int] monsterPriority,string macro) {
	return liba_peridot(page.to_buffer(),monsterPriority,my_location(),macro);
}

