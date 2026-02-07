//liba bloodCubicZirconia

//handles blood cubic zirconia (BCZ)
//will automatically equip the BCZ as needed, restoring state of equipment before use before returning
//will return false for everything if player does not have the BCZ

import <liba_equipCast.ash>
import <liba_eternityCodpiece.ash>

//returns true if have the BCZ
boolean liba_bloodCubicZirconia_have();

//returns which item acts as the BCZ; e.g. if eternity codpiece has it, this will return the codpiece
//returns $item[none] if BCZ not found
item liba_bloodCubicZirconia_item();

//get an effect with the BCZ
//duration is how many turns of the effect you want to get with its use
//keepStatAbove will limit the number of casts to keep the stat at or above its value
//returns result of the use_skill() to get effect
boolean liba_bloodCubicZirconia(effect eff);
boolean liba_bloodCubicZirconia(effect eff,int keepStatAbove);
boolean liba_bloodCubicZirconia(int duration,effect eff);
boolean liba_bloodCubicZirconia(int duration,effect eff,int keepStatAbove);

//use skill with BCZ
//casts is how many times you want to cast the skill
//keepStatAbove will limit the number of casts to keep the stat at or above its value
//returns result of use_skill()
boolean liba_bloodCubicZirconia(skill ski);
boolean liba_bloodCubicZirconia(skill ski,int keepStatAbove);
boolean liba_bloodCubicZirconia(int casts,skill ski);
boolean liba_bloodCubicZirconia(int casts,skill ski,int keepStatAbove);

//get items from BCZ
//num is the number of items to get with BCZ
//keepStatAbove will limit the number of casts to keep the stat at or above its value
//returns result of use_skill() to get items
boolean liba_bloodCubicZirconia(item ite);
boolean liba_bloodCubicZirconia(item ite,int keepStatAbove);
boolean liba_bloodCubicZirconia(int num,item ite);
boolean liba_bloodCubicZirconia(int num,item ite,int keepStatAbove);

/* helper functions */

//returns number of times skill has been cast previously
int liba_bloodCubicZirconia_casts(skill ski);
int liba_bloodCubicZirconia_used(skill ski);

//returns substat cost of a skill given previousCasts
int liba_bloodCubicZirconia_cost(int previousCasts);
//returns current substat cost of skill
int liba_bloodCubicZirconia_cost(skill ski);

//returns substat that skill uses to cast
stat liba_bloodCubicZirconia_toStat(skill ski);

//returns the lower of max or casts needed to keep the corresponding stat of skill at or above keepStatAbove
int liba_bloodCubicZirconia_limitToProtectStats(int max,skill ski,int keepStatAbove);

/* implementations */

boolean liba_bloodCubicZirconia_have() {
	return available_amount($item[blood cubic zirconia]) > 0
		|| liba_eternityCodpiece_equippedAmount($item[blood cubic zirconia]) > 0;
}
boolean liba_bloodCubicZirconia(int duration,effect eff,int keepStatAbove) {
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
	int limit = liba_bloodCubicZirconia_limitToProtectStats(casts,ski,keepStatAbove);
	return liba_equipCast(limit,ski,liba_bloodCubicZirconia_item());
}
boolean liba_bloodCubicZirconia(int casts,skill ski,int keepStatAbove) {
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
	int limit = liba_bloodCubicZirconia_limitToProtectStats(casts,ski,keepStatAbove);
	return liba_equipCast(limit,ski,liba_bloodCubicZirconia_item());
}
boolean liba_bloodCubicZirconia(int num,item ite,int keepStatAbove) {
	if (!liba_bloodCubicZirconia_have())
		return false;
	skill ski = skill[item]{
		$item[spinal tapas]:$skill[bcz: prepare spinal tapas],
		$item[pheromone cocktail]:$skill[bcz: craft a pheromone cocktail],
		$item[blood thinner]:$skill[bcz: create blood thinner],
	}[ite];
	if (ski == $skill[none])
		return false;
	int limit = liba_bloodCubicZirconia_limitToProtectStats(num,ski,keepStatAbove);
	return liba_equipCast(limit,ski,$item[blood cubic zirconia]);
}
int liba_bloodCubicZirconia_casts(skill ski) {
	string pref = string[skill]{
		$skill[bcz: blood bath]:"_bczBloodBathCasts",
		$skill[bcz: dial it up to 11]:"_bczDialitupCasts",
		$skill[bcz: sweat equity]:"_bczSweatEquityCasts",
		$skill[bcz: create blood thinner]:"_bczBloodThinnerCasts",
		$skill[bcz: prepare spinal tapas]:"_bczSpinalTapasCasts",
		$skill[bcz: craft a pheromone cocktail]:"_bczPheromoneCocktailCasts",
		$skill[bcz: blood geyser]:"_bczBloodGeyserCasts",
		$skill[bcz: sweat bullets]:"_bczSweatBulletsCasts",
		$skill[bcz: refracted gaze]:"_bczRefractedGazeCasts",
	}[ski];
	return get_property(pref).to_int();
}
int liba_bloodCubicZirconia_used(skill ski) {
	return liba_bloodCubicZirconia_casts(ski);
}
int liba_bloodCubicZirconia_cost(int previousCasts) {
	int[int] map = {
		0:11,
		1:23,
		2:37,
	};
	if (previousCasts < 12)
		return map[previousCasts % 3] * 10 ** (previousCasts / 3);
	if (previousCasts == 12)
		return 420000;
	return map[(previousCasts - 1) % 3] * 10 ** ((previousCasts - 1) / 3 + 1);
}
int liba_bloodCubicZirconia_cost(skill ski) {
	return ski.liba_bloodCubicZirconia_casts().liba_bloodCubicZirconia_cost();
}
stat liba_bloodCubicZirconia_toStat(skill ski) {
	return stat[skill]{
		$skill[bcz: blood bath]:$stat[submuscle],
		$skill[bcz: dial it up to 11]:$stat[submysticality],
		$skill[bcz: sweat equity]:$stat[submoxie],
		$skill[bcz: create blood thinner]:$stat[submuscle],
		$skill[bcz: prepare spinal tapas]:$stat[submysticality],
		$skill[bcz: craft a pheromone cocktail]:$stat[submoxie],
		$skill[bcz: blood geyser]:$stat[submuscle],
		$skill[bcz: sweat bullets]:$stat[submoxie],
		$skill[bcz: refracted gaze]:$stat[submysticality],
	}[ski];
}
int liba_bloodCubicZirconia_limitToProtectStats(int max,skill ski,int keepStatAbove) {
	int out;
	stat sub = ski.liba_BloodCubicZirconia_toStat();
	int startSub = sub.my_basestat();
	int startCasts = ski.liba_bloodCubicZirconia_casts();
	int threshold = keepStatAbove ** 2;
	for (int cost = out = 0;out < max;out++) {
		cost += liba_bloodCubicZirconia_cost(startCasts + out);
		if (startSub - cost < threshold)
			break;
	}
	return out;
}

item liba_bloodCubicZirconia_item() {
	item out;
	if (available_amount($item[blood cubic zirconia]) > 0)
		out = $item[blood cubic zirconia];
	else if (liba_eternityCodpiece_equippedAmount($item[blood cubic zirconia]) > 0)
		out = $item[the eternity codpiece];
	return out;
}

/* overloads */

//effect
boolean liba_bloodCubicZirconia(effect eff) {
	return liba_bloodCubicZirconia(1,eff,0);
}
boolean liba_bloodCubicZirconia(effect eff,int keepStatAbove) {
	return liba_bloodCubicZirconia(1,eff,keepStatAbove);
}
boolean liba_bloodCubicZirconia(int duration,effect eff) {
	return liba_bloodCubicZirconia(duration,eff,0);
}
//skill
boolean liba_bloodCubicZirconia(skill ski) {
	return liba_bloodCubicZirconia(1,ski,0);
}
boolean liba_bloodCubicZirconia(skill ski,int keepStatAbove) {
	return liba_bloodCubicZirconia(1,ski,keepStatAbove);
}
boolean liba_bloodCubicZirconia(int casts,skill ski) {
	return liba_bloodCubicZirconia(casts,ski,0);
}
//item
boolean liba_bloodCubicZirconia(item ite) {
	return liba_bloodCubicZirconia(1,ite,0);
}
boolean liba_bloodCubicZirconia(item ite,int keepStatAbove) {
	return liba_bloodCubicZirconia(1,ite,keepStatAbove);
}
boolean liba_bloodCubicZirconia(int num,item ite) {
	return liba_bloodCubicZirconia(num,ite,0);
}

