//liba bloodCubicZirconia

//handles blood cubic zirconia (BCZ)
//will automatically equip the BCZ as needed, restoring state of equipment before use before returning
//will return false for everything if player does not have the BCZ

import <liba_equipCast.ash>

//returns true if have the BCZ
boolean liba_bloodCubicZirconia_have();

//get an effect with the BCZ
//duration is how many turns of the effect you want to get with its use
//returns result of the use_skill() to get effect
boolean liba_bloodCubicZirconia(effect eff);
boolean liba_bloodCubicZirconia(int duration,effect eff);

//use skill with BCZ
//casts is how many times you want to cast the skill
//returns result of use_skill()
boolean liba_bloodCubicZirconia(skill ski);
boolean liba_bloodCubicZirconia(int casts,skill ski);

//get items from BCZ
//num is the number of items to get with BCZ
//returns result of use_skill() to get items
boolean liba_bloodCubicZirconia(item ite);
boolean liba_bloodCubicZirconia(int num,item ite);

/* implementaitons */

boolean liba_bloodCubicZirconia_have() {
	return available_amount($item[blood cubic zirconia]) > 0;
}
boolean liba_bloodCubicZirconia(effect eff) {
	return liba_bloodCubicZirconia(1,eff);
}
boolean liba_bloodCubicZirconia(int duration,effect eff) {
	if (!liba_bloodCubicZirconia_have())
		return false;
	skill ski = skill[effect]{
		$effect[bloodbathed]:$skill[bcz: blood bath],
		$effect[up to 11]:$skill[bcz: dial it up to 11],
		$effect[sweat equity]:$skill[bcz: sweat equity],
	}[eff];
	if (ski == $skill[none])
		return false;
	int turnsPerCast = ski.turns_per_cast();
	int casts = duration / turnsPerCast + (duration % turnsPerCast == 0 ? 0 : 1);
	return liba_equipCast(casts,ski,$item[blood cubic zirconia]);
}
boolean liba_bloodCubicZirconia(skill ski) {
	return liba_bloodCubicZirconia(1,ski);
}
boolean liba_bloodCubicZirconia(int casts,skill ski) {
	if (!liba_bloodCubicZirconia_have())
		return false;
	if (!($skills[
		bcz: blood bath,
		bcz: dial it up to 11,
		bcz: sweat equity,
		bcz: create blood thinner,
		bcz: prepare spinal tapas,
		bcz: craft a pheromone cocktail,
		] contains ski))
	{
		return false;
	}
	return liba_equipCast(casts,ski,$item[blood cubic zirconia]);
}
boolean liba_bloodCubicZirconia(item ite) {
	return liba_bloodCubicZirconia(1,ite);
}
boolean liba_bloodCubicZirconia(int num,item ite) {
	if (!liba_bloodCubicZirconia_have())
		return false;
	skill ski = skill[item]{
		$item[spinal tapas]:$skill[bcz: prepare spinal tapas],
		$item[pheromone cocktail]:$skill[bcz: craft a pheromone cocktail],
		$item[blood thinner]:$skill[bcz: create blood thinner],
	}[ite];
	if (ski == $skill[none])
		return false;
	return liba_equipCast(num,ski,$item[blood cubic zirconia]);
}

