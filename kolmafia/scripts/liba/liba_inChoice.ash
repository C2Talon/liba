//liba inChoice

//returns true if currently in the choice number
boolean liba_inChoice(int choice_id) {
	return handling_choice() && last_choice() == choice_id;
}

