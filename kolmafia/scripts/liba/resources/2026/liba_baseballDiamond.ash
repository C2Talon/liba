//liba baseballDiamond

import <liba_eternityCodpiece.ash>

//returns whether have the baseball diamond or not
boolean liba_baseballDiamond_have();

//returns which item acts as the baseball diamond; e.g. if eternity codpiece has it, this will return the codpiece
//returns $item[none] if baseball diamond not found
item liba_baseballDiamond_item();

/*implementations*/

boolean liba_baseballDiamond_have() {
	return liba_eternityCodpiece_availableAmount($item[baseball diamond]) > 0;
}
item liba_baseballDiamond_item() {
	item out,ball = $item[baseball diamond];
	if (available_amount(ball) > 0)
		out = ball;
	else if (liba_eternityCodpiece_equippedAmount(ball) > 0)
		out = $item[the eternity codpiece];
	return out;
}

