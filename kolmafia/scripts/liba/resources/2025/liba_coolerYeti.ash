//liba coolerYeti

import <liba_inChoice.ash>

record liba_coolerYeti_data {
	int cost;
	string thing;
};

//returns whether have cooler yeti or not
boolean liba_coolerYeti_have();

//uses yeti to pick a choice in its choice adventure
//returns true on success
//less esoteric functions follow this one to make things easier to use and remember
boolean liba_coolerYeti(int choice);

//uses yeti to try to double adventures with next drink
boolean liba_coolerYeti_getAdventures() return liba_coolerYeti(2);

//uses yeti to try to get looking cool effect with next drink
boolean liba_coolerYeti_getEffect() return liba_coolerYeti(3);

//uses yeti to try to get ingredients with next drink
boolean liba_coolerYeti_getIngredients() return liba_coolerYeti(4);

//uses yeti to try to get extra stat increase with next drink
boolean liba_coolerYeti_getStat() return liba_coolerYeti(5);

//returns whether yeti's double adventures from booze has been used today or not
boolean liba_coolerYeti_usedAdventures() return get_property("_coolerYetiAdventures").to_boolean();

//returns what cooler yeti's next drink will do; will be empty if yeti can be used
string liba_coolerYeti_mode() return get_property("coolerYetiMode");

/* helper functions */

//does the actual work
//returns true on success
boolean _liba_coolerYeti(int choice);

//returns data applicable to choice
liba_coolerYeti_data liba_coolerYeti_data(int choice);

//tries to enter choice adventure if not already there
//returns true if left in the choice
boolean liba_coolerYeti_enter();

//print message
void liba_coolerYeti_print(string s);

//print message
//returns false
boolean liba_coolerYeti_error(string s);

/* implementations */

boolean liba_coolerYeti_have() {
	return have_familiar($familiar[cooler yeti]);
}

boolean liba_coolerYeti(int choice) {
	familiar fam = my_familiar();
	item equip = equipped_item($slot[familiar]);
	boolean result = _liba_coolerYeti(choice);
	use_familiar(fam);
	equip($slot[familiar],equip);
	return result;
}

boolean _liba_coolerYeti(int choice) {
	familiar yeti = $familiar[cooler yeti];

	if (!liba_coolerYeti_have())
		return liba_coolerYeti_error(`no {yeti} detected`);
	if (liba_coolerYeti_mode() != "")
		return liba_coolerYeti_error(`already set to enhance next drink with "{liba_coolerYeti_mode()}"`);

	liba_coolerYeti_data attempt = liba_coolerYeti_data(choice);

	if (attempt.cost == 0)
		return liba_coolerYeti_error(`{choice} is not a valid choice`);
	if (choice == 2 && liba_coolerYeti_usedAdventures())
		return liba_coolerYeti_error(`{attempt.thing} can only be used once per day`);
	if (yeti.experience < attempt.cost)
		return liba_coolerYeti_error(`{yeti} needs {attempt.cost} experience to get {attempt.thing}`);
	if (!liba_coolerYeti_enter())
		return liba_coolerYeti_error(`could not enter choice adventure for {yeti}`);
	if (!(available_choice_options() contains choice)) {
		run_choice(1);
		return liba_coolerYeti_error(`{attempt.thing} was not an available option; likely need to drink something to clear the previous use; exited the choice adventure`);
	}

	run_choice(choice);
	return true;
}

liba_coolerYeti_data liba_coolerYeti_data(int choice) {
	liba_coolerYeti_data out;
	switch (choice) {
		case 2:
			out = new liba_coolerYeti_data(400,"double adventures");
			break;
		case 3:
			out = new liba_coolerYeti_data(225,`{$effect[looking cool]} effect`);
			break;
		case 4:
			out = new liba_coolerYeti_data(100,"ingredients");
			break;
		case 5:
			out = new liba_coolerYeti_data(25,"stat increase");
			break;
	}
	return out;
}

void liba_coolerYeti_print(string s) {
	print(`liba_coolerYeti: {s}`);
}

boolean liba_coolerYeti_error(string s) {
	print(`liba_coolerYeti error: {s}`);
	return false;
}

boolean liba_coolerYeti_enter() {
	int choiceId = 1560;
	if (liba_inChoice(choiceId))
		return true;
	use_familiar($familiar[cooler yeti]);
	visit_url("main.php?talktoyeti=1",false);
	if (liba_inChoice(choiceId))
		return true;
	return false;
}

