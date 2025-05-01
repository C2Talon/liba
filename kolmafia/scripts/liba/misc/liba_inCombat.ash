//liba inCombat

//reads a page to determine if it is a combat page or not, but not neccessarily the state of the combat
//returns true if the page is a combat page
boolean liba_inCombat(buffer page);
boolean liba_inCombat(string page);

//reads a page to determine if it is a combat page or not, and also if the combat is with the monster, but not neccessarily the state of the combat
//returns true if the page is a combat page with monster
//returns false if either monster or combat page is not found
boolean liba_inCombat(buffer page,monster mon);
boolean liba_inCombat(string page,monster mon);
boolean liba_inCombat(monster mon,buffer page);
boolean liba_inCombat(monster mon,string page);

/* implementations */

boolean liba_inCombat(buffer page) {
	return create_matcher("<!-*\\s*MONSTERID:\\s+\\d+\\s*-*>",page).find();
}
boolean liba_inCombat(string page) {
	return liba_inCombat(page.to_buffer());
}
boolean liba_inCombat(buffer page,monster mon) {
	return create_matcher(`<!-*\\s*MONSTERID:\\s+{mon.id}\\s*-*>`,page).find();
}
boolean liba_inCombat(string page,monster mon) {
	return liba_inCombat(page.to_buffer(),mon);
}
boolean liba_inCombat(monster mon,buffer page) {
	return liba_inCombat(page,mon);
}
boolean liba_inCombat(monster mon,string page) {
	return liba_inCombat(page.to_buffer(),mon);
}

