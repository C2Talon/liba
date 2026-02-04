//liba heartstone

import <liba_eternityCodpiece.ash>

//returns whether have the heartstone or not
boolean liba_heartstone_have();

//returns which item acts as the heartstone; e.g. if eternity codpiece has it, this will return the codpiece
item liba_heartstone_item();

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

