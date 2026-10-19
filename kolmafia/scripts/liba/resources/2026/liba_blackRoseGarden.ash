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

//do pre- and post-adventure scripts
//returns true if in garden when done
boolean _liba_blackRoseGarden_preAdv();
boolean _liba_blackRoseGarden_postAdv();

/* implementations */

boolean liba_blackRoseGarden_have() {
	return get_campground() contains $item[black garden rose];
}

boolean liba_blackRoseGarden(string macro,int fountain_choice) {
	if (!_liba_blackRoseGarden_enter())
		return _liba_blackRoseGarden_result("could not enter garden",false);
	buffer page;
	int fountain = 1639;
	item key = $item[black thorn key];
	int fountains,count,monsters,chests;
	int tries = 0,max = 5;
	for (;tries < max;tries++) {
		fountains = monsters = chests = 0;
		foreach i,x in available_choice_extras() {
			if (x.decision == 2)
				continue;
			if (x.label.starts_with("Fight ")) {
				if (monsters > 0) {
					monsters++;
					continue;
				}
				if (!_liba_blackRoseGarden_preAdv())
					return _liba_blackRoseGarden_result("stuck outside garden after pre-adv script",false);
			}
			else if (x.label.starts_with("Drink ")) {
				if (fountain_choice == 0) {
					fountains++;
					continue;
				}
			}
			else if (x.label.starts_with("Open ") && item_amount(key) == 0) {
				chests++;
				continue;
			}
			_liba_blackRoseGarden_print(x.label);
			page = run_choice(1,x.extras_joined);
			if (page.contains_text("You're in no shape for this fight right now.")) {
				_liba_blackRoseGarden_print("could not enter fight; will not try to fight again");
				monsters++;
				continue;
			}
			if (liba_inChoice(fountain))
				run_choice(fountain_choice);
			else if (liba_inCombat(page)) {
				run_combat(macro);
				if (!_liba_blackRoseGarden_postAdv())
					return _liba_blackRoseGarden_result("stuck outside garden after post-adv script",false);
			}
			_liba_blackRoseGarden_enter();
		}
		if (item_amount(key) > 0 && chests > 0)
			continue;
		count = available_choice_extras().count();
		if (count - chests == 1
			|| (fountain_choice == 0 && count - chests == fountains + 1)
			|| monsters > 0)
		{
			string message = "done";
			if (fountains > 0)
				message += "; fountains skipped";
			if (chests > 0)
				message += `; skipped {chests} chests`;
			if (monsters > 0) {
				message += `; couldn't fight {monsters} monsters`;
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

boolean _liba_blackRoseGarden_preAdv() {
	"betweenBattlesScript".get_property().cli_execute();
	_liba_blackRoseGarden_restore();
	return _liba_blackRoseGarden_enter();
}
boolean _liba_blackRoseGarden_postAdv() {
	"afterAdventureScript".get_property().cli_execute();
	return _liba_blackRoseGarden_enter();
}

