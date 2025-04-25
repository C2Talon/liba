//liba lprom

//handle things with the wearbear lp-rom burner
//will use mafia settings to restore MP if the player runs out prematurely

import <c2t_lib.ash>

//returns true if have lprom and it is installed in the workshed
boolean liba_haveLprom();

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
item liba_lpromSkillToItem(skill ski);
skill liba_lpromItemToSkill(item ite);
boolean liba_lpromError(string s);
buffer liba_lpromEnter();


/* implementations */

boolean liba_haveLprom() {
	return get_workshed() == $item[warbear lp-rom burner];
}
boolean liba_lprom(int qty,skill ski) {
	item lprom = $item[warbear lp-rom burner];
	item disc = ski.liba_lpromSkillToItem();
	int option = ski.to_effect().id;
	int start = item_amount(disc);
	int cost = mp_cost(ski);
	int casts,count,top,left;
	int max = qty == -1 ? ski.dailylimit : qty < 1 ? 1 : qty;

	//errors
	if (!liba_haveLprom())
		return liba_lpromError(`do not have the {lprom} installed`);
	if (!have_skill(ski))
		return liba_lpromError(`do not have the {ski} skill`);
	if (disc == $item[none])
		return liba_lpromError(`{ski} is not a valid skill for your class`);
	if (ski.dailylimit == 0)
		return liba_lpromError(`out of uses of the {ski} skill`);
	if (mp_cost(ski) > my_maxmp())
		return liba_lpromError(`not enough MP to cast the {ski} skill`);

	//do the thing
	repeat {
		top = item_amount(disc);
		left = max - count;

		//casts and mp juggling
		casts = left > ski.dailylimit ? ski.dailylimit : left;
		restore_mp(cost * casts);
		casts = my_mp()/cost > casts ? casts : my_mp()/cost;
		if (casts == 0)
			break;

		//get there
		if (!c2t_inChoice(821))
			liba_lpromEnter();
		if (!c2t_inChoice(821))
			return liba_lpromError(`could not visit the {lprom} in the workshed`);

		run_choice(1,`whicheffect={option}&times={casts}`);

		count += item_amount(disc) - top;
	} until (ski.dailylimit == 0
		|| count >= max
		|| top == item_amount(disc));

	//failed-to-create errors
	if (start == item_amount(disc)) {
		if (my_mp() < cost)
			return liba_lpromError("did not have enough MP to create anything");
		else
			return liba_lpromError("failed to create anything");
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
	skill ski = ite.liba_lpromItemToSkill();
	if (ski == $skill[none])
		return liba_lpromError(`cannot make "{ite}" as {my_class()}`);
	return liba_lprom(qty,ski);
}
item liba_lpromSkillToItem(skill ski) {
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
skill liba_lpromItemToSkill(item ite) {
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
boolean liba_lpromError(string s) {
	print(`liba_lprom error: {s}`,"red");
	return false;
}

