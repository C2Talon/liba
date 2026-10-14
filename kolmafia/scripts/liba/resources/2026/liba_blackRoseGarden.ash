//liba blackRoseGarden

//do all the things in the black rose garden

import <liba_inChoice.ash>
import <liba_inCombat.ash>

//returns true if black rose garden is in the campground
boolean liba_blackRoseGarden_have();

//does all the things in the garden
//macro is the combat macro you want to use in all combats in the garden
//	omit to use whatever you have set up to handle combats in kolmafia
//fountain_choice is which choice you want to send to the fountain upon encountering it
//	setting it to 0 (zero) will skip the fountain to use later
//	omitting defaults it to -1, which means kolmafia will handle it with however you have it set up
//returns true on success; returns false if it does not finish before max tries is reached
boolean liba_blackRoseGarden(string macro,int fountain_choice);
boolean liba_blackRoseGarden(int fountain_choice,string macro);
boolean liba_blackRoseGarden(string macro);
boolean liba_blackRoseGarden(int fountain_choice);
boolean liba_blackRoseGarden();

//does the fountain and only the fountain
//choice is the choice number you want to send when it's entered
//	omitting defaults it to -1, which means kolmafia will handle it with however you have it set up
//returns true on success
boolean liba_blackRoseGarden_fountain(int choice);
boolean liba_blackRoseGarden_fountain();

/* helper functions */

//enters black rose garden
//returns true if garden entered
boolean _liba_blackRoseGarden_enter();

//restores hp and mp based on kolmafia settings to hopefully not die after multiple combats since normal automated recovery won't fire here
void _liba_blackRoseGarden_restore();

//print
void _liba_blackRoseGarden_print(string s);

//prints message;returns result
boolean _liba_blackRoseGarden_result(string s,boolean result);

/* implementations */

boolean liba_blackRoseGarden_have() {
	return get_campground() contains $item[black garden rose];
}

boolean liba_blackRoseGarden(string macro,int fountain_choice) {
	_liba_blackRoseGarden_restore();
	if (!_liba_blackRoseGarden_enter())
		return _liba_blackRoseGarden_result("could not enter garden",false);
	buffer page;
	int fountain = 1639;
	int fountains,count,skipped;
	int tries = 0,max = 5;
	for (;tries < max;tries++) {
		fountains = skipped = 0;
		foreach i,x in available_choice_extras() {
			if (x.decision == 2)
				continue;
			if (fountain_choice == 0 && x.label.contains_text("blood fountain")) {
				fountains++;
				continue;
			}
			if (skipped > 0 && x.label.starts_with("Fight")) {
				skipped++;
				continue;
			}
			_liba_blackRoseGarden_print(x.label);
			page = run_choice(1,x.extras_joined);
			if (page.contains_text("You're in no shape for this fight right now.")) {
				_liba_blackRoseGarden_print("could not enter fight; will not try to fight again");
				skipped++;
				continue;
			}
			if (liba_inChoice(fountain))
				run_choice(fountain_choice);
			else if (liba_inCombat(page))
				run_combat(macro);
			_liba_blackRoseGarden_restore();
			_liba_blackRoseGarden_enter();
		}
		count = available_choice_extras().count();
		if (count == 1
			|| (fountain_choice == 0 && count == fountains + 1)
			|| skipped > 0)
		{
			string message = "done";
			if (fountains > 0)
				message += "; fountains skipped";
			if (skipped > 0) {
				message += `; couldn't fight {skipped} monsters`;
				if (my_inebriety() > inebriety_limit())
					message += " (overdrunk)";
			}
			return _liba_blackRoseGarden_result(message,true);
		}
	}
	return _liba_blackRoseGarden_result(`unable to finish after {tries} tries; still {count-1} things available`,false);
}
boolean liba_blackRoseGarden(int fountain_choice,string macro) {
	return liba_blackRoseGarden(macro,fountain_choice);
}
boolean liba_blackRoseGarden(string macro) {
	return liba_blackRoseGarden(macro,-1);
}
boolean liba_blackRoseGarden(int fountain_choice) {
	return liba_blackRoseGarden('',fountain_choice);
}
boolean liba_blackRoseGarden() return liba_blackRoseGarden('',-1);

boolean liba_blackRoseGarden_fountain(int choice) {
	if (!_liba_blackRoseGarden_enter())
		return _liba_blackRoseGarden_result("could not enter garden",false);
	int fountain = 1639;
	foreach i,x in available_choice_extras() {
		if (x.decision == 2)
			continue;
		if (!x.label.contains_text("blood fountain"))
			continue;
		_liba_blackRoseGarden_print(x.label);
		run_choice(1,x.extras_joined);
		if (liba_inChoice(fountain))
			run_choice(choice);
		_liba_blackRoseGarden_enter();
	}
	return _liba_blackRoseGarden_result("fountain done",true);
}
boolean liba_blackRoseGarden_fountain() return liba_blackRoseGarden_fountain(-1);

boolean _liba_blackRoseGarden_enter() {
	if (!liba_inChoice(1637)) {
		if (!liba_blackRoseGarden_have())
			return false;
		visit_url("campground.php?action=rosegarden&pwd="+my_hash(),false,true);
	}
	return liba_inChoice(1637);
}

void _liba_blackRoseGarden_restore() {
	restore_hp(0);
	restore_mp(0);
}

void _liba_blackRoseGarden_print(string s) {
	print(`liba_blackRoseGarden: {s}`);
}

boolean _liba_blackRoseGarden_result(string s,boolean result) {
	_liba_blackRoseGarden_print(s);
	return result;
}

