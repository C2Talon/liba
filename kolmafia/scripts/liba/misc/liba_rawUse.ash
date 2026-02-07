//liba rawUse

//use an item via inv_use.php
//items that have their own unique use link will probably not work with this
//returns the resultant page
buffer liba_rawUse(item ite);

//use a skill via runskillz.php
//this is exclusively for using skills outside of combat
//count is number of times to use skill, omitting defaults it to 1
//ski is the skill to use
//target is the player ID of the target of the skill, omitting defaults to self
//returns the resultant page
buffer liba_rawUse(skill ski);
buffer liba_rawUse(int count,skill ski);
buffer liba_rawUse(skill ski,string target);
buffer liba_rawUse(int count,skill ski,string target);

/*implementations*/

buffer liba_rawUse(item ite) {
	buffer out;
	if (available_amount(ite) > 0)
		out = visit_url(`inv_use.php?pwd={my_hash()}&which=3&whichitem={ite.id}`,false,true);
	return out;
}
buffer liba_rawUse(int count,skill ski,string target) {
	return visit_url(`runskillz.php?pwd={my_hash()}&action=Skillz&whichskill={ski.id}&targetplayer={target}&quantity={count}`,false,true);
}
buffer liba_rawUse(skill ski) {
	return liba_rawUse(1,ski,my_id());
}
buffer liba_rawUse(int count,skill ski) {
	return liba_rawUse(count,ski,my_id());
}
buffer liba_rawUse(skill ski,string target) {
	return liba_rawUse(1,ski,target);
}

