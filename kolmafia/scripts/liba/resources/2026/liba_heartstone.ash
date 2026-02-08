//liba heartstone

import <liba_equipCast.ash>
import <liba_eternityCodpiece.ash>

//returns whether have the heartstone or not
boolean liba_heartstone_have();

//returns which item acts as the heartstone; e.g. if eternity codpiece has it, this will return the codpiece
//returns $item[none] if heartstone not found
item liba_heartstone_item();

//use skill with heartstone
//tries to use skill as many times as count
//returns result of the use_skill() for skill
boolean liba_heartstone(skill ski);
boolean liba_heartstone(int count,skill ski);

//get effect with heartstone
//try to get as much of an effect as duration
//returns result of the use_skill() to get effect
boolean liba_heartstone(effect eff);
boolean liba_heartstone(int duration,effect eff);

/*implementations*/

boolean liba_heartstone_have() {
	return liba_eternityCodpiece_availableAmount($item[heartstone]) > 0;
}
item liba_heartstone_item() {
	item out,stone = $item[heartstone];
	if (available_amount(stone) > 0)
		out = stone;
	else if (liba_eternityCodpiece_equippedAmount(stone) > 0)
		out = $item[the eternity codpiece];
	return out;
}
boolean liba_heartstone(int count,skill ski) {
	if (!liba_heartstone_have())
		return false;
	if (!($skills[
		heartstone: %buff,
		heartstone: %luck,
		heartstone: %pals,
		] contains ski))
	{
		return false;
	}
	return liba_equipCast(count,ski,liba_heartstone_item());
}
boolean liba_heartstone(skill ski) {
	return liba_heartstone(1,ski);
}
boolean liba_heartstone(int duration,effect eff) {
	if (!liba_heartstone_have())
		return false;
	skill ski = skill[effect]{
		$effect[best pals]:$skill[heartstone: %pals],
		$effect[ultraheart]:$skill[heartstone: %buff],
		$effect[lucky!]:$skill[heartstone: %luck],
	}[eff];
	if (ski == $skill[none])
		return false;
	int turnsPerCast = eff == $effect[lucky!] ? 2147483647 : ski.turns_per_cast();
	int count = duration / turnsPerCast + (duration % turnsPerCast == 0 ? 0 : 1);
	return liba_equipCast(count,ski,liba_heartstone_item());
}
boolean liba_heartstone(effect eff) {
	return liba_heartstone(1,eff);
}

