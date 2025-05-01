//liba lprom

//handle things with the wearbear lp-rom burner
//will use mafia settings to restore MP if the player runs out prematurely

import <liba_clamp.ash>
import <liba_inChoice.ash>

//returns true if have lprom and it is installed in the workshed
boolean liba_lprom_have();

//commits a song to the record item of the corresponding skill
//returns true if gotten at least one item from the lprom
//returns false with message on any error
boolean liba_lprom(skill ski);
boolean liba_lprom(int qty,skill ski);
boolean liba_lprom(skill ski,int qty);

//gets the song record item from its corresponding skill
//returns true of gotten at least one item from the lprom
boolean liba_lprom(item ite);
boolean liba_lprom(int qty,item ite);
boolean liba_lprom(item ite,int qty);

//helper functions
item liba_lprom_skillToItem(skill ski);
skill liba_lprom_itemToSkill(item ite);
boolean liba_lprom_error(string s);
boolean liba_lprom_enter();


/* implementations */

boolean liba_lprom_have() {
	return get_workshed() == $item[warbear lp-rom burner];
}
boolean liba_lprom(int qty,skill ski) {
	item lprom = $item[warbear lp-rom burner];
	item disc = ski.liba_lprom_skillToItem();
	int option = ski.to_effect().id;
	int start = item_amount(disc);
	int cost = mp_cost(ski);
	int casts,count,top,left;
	int max = qty == -1 ? ski.dailylimit : liba_clamp(qty,1,ski.dailylimit);

	//errors
	if (!liba_lprom_have())
		return liba_lprom_error(`do not have the {lprom} installed`);
	if (!have_skill(ski))
		return liba_lprom_error(`do not have the {ski} skill`);
	if (disc == $item[none])
		return liba_lprom_error(`{ski} is not a valid skill for your class`);
	if (ski.dailylimit == 0)
		return liba_lprom_error(`out of uses of the {ski} skill`);
	if (mp_cost(ski) > my_maxmp())
		return liba_lprom_error(`not enough MP to cast the {ski} skill`);

	//do the thing
	repeat {
		top = item_amount(disc);
		left = max - count;

		//casts and mp juggling
		casts = min(left,ski.dailylimit);
		if (casts > 0)
			restore_mp(cost * casts);
		casts = min(casts,my_mp()/cost);
		if (casts <= 0)
			break;

		//get there
		if (!liba_lprom_enter())
			return liba_lprom_error(`could not visit the {lprom} in the workshed`);

		run_choice(1,`whicheffect={option}&times={casts}`);

		count += item_amount(disc) - top;
	} until (ski.dailylimit == 0
		|| count >= max
		|| top == item_amount(disc));

	//failed-to-create errors
	if (start == item_amount(disc)) {
		if (my_mp() < cost)
			return liba_lprom_error("did not have enough MP to create anything");
		else
			return liba_lprom_error("failed to create anything");
	}

	return true;
}
boolean liba_lprom(skill ski) {
	return liba_lprom(1,ski);
}
boolean liba_lprom(skill ski,int qty) {
	return liba_lprom(qty,ski);
}
boolean liba_lprom(item ite) {
	return liba_lprom(1,ite);
}
boolean liba_lprom(item ite,int qty) {
	return liba_lprom(qty,ite);
}
boolean liba_lprom(int qty,item ite) {
	skill ski = ite.liba_lprom_itemToSkill();
	if (ski == $skill[none])
		return liba_lprom_error(`cannot make "{ite}" as {my_class()}`);
	return liba_lprom(qty,ski);
}
item liba_lprom_skillToItem(skill ski) {
	item[skill] legend;
	if (my_class() == $class[accordion thief]) {
		legend = {
			$skill[chorale of companionship]:$item[recording of chorale of companionship],
			$skill[benetton's medley of diversity]:$item[recording of benetton's medley of diversity],
			$skill[donho's bubbly ballad]:$item[recording of donho's bubbly ballad],
			$skill[elron's explosive etude]:$item[recording of elron's explosive etude],
			$skill[inigo's incantation of inspiration]:$item[recording of inigo's incantation of inspiration],
			$skill[prelude of precision]:$item[recording of prelude of precision],
			$skill[the ballad of richie thingfinder]:$item[recording of the ballad of richie thingfinder],
		};
	}
	else {
		legend = {
			$skill[donho's bubbly ballad]:$item[single of donho's bubbly ballad],
			$skill[inigo's incantation of inspiration]:$item[single of inigo's incantation of inspiration],
		};
	}
	return legend[ski];
}
skill liba_lprom_itemToSkill(item ite) {
	skill[item] legend;
	if (my_class() == $class[accordion thief]) {
		legend = {
			$item[recording of benetton's medley of diversity]:$skill[benetton's medley of diversity],
			$item[recording of chorale of companionship]:$skill[chorale of companionship],
			$item[recording of donho's bubbly ballad]:$skill[donho's bubbly ballad],
			$item[recording of elron's explosive etude]:$skill[elron's explosive etude],
			$item[recording of inigo's incantation of inspiration]:$skill[inigo's incantation of inspiration],
			$item[recording of prelude of precision]:$skill[prelude of precision],
			$item[recording of the ballad of richie thingfinder]:$skill[the ballad of richie thingfinder],
		};
	}
	else {
		legend = {
			$item[single of donho's bubbly ballad]:$skill[donho's bubbly ballad],
			$item[single of inigo's incantation of inspiration]:$skill[inigo's incantation of inspiration],
		};
	}
	return legend[ite];
}
boolean liba_lprom_error(string s) {
	print(`liba_lprom error: {s}`,"red");
	return false;
}
boolean liba_lprom_enter() {
	if (!liba_inChoice(821))
		visit_url('campground.php?action=lprom',true,true);
	return liba_inChoice(821);
}

