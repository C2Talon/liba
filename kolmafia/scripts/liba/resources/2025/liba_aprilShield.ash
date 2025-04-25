//liba aprilShield

//handle april shower thoughts shield
//will automatically equip and unequip april shield as appropriate, restoring state of equipment before use before returning
//will return false for everything if player does not have april shield

import <liba_equipCast.ash>

//returns true if have the april shield item
boolean liba_aprilShield_have();

//get an effect with (or without in the case of empathy) april shield
//duration is how many turns of the effect you want to get with its use
//returns result of the use_skill() to get effect
//returns false if the effect is not an effect exclusive to april shield or empathy
boolean liba_aprilShield(effect eff);
boolean liba_aprilShield(int duration,effect eff);

//use skill with april shield
//casts is how many times you want to cast the skill
//returns result of use_skill()
boolean liba_aprilShield(skill ski);
boolean liba_aprilShield(int casts,skill ski);

//buy items from april shield coinmaster with glob of wet paper
//returns result of buy() from coinmaster for the item(s)
boolean liba_aprilShield(item ite);
boolean liba_aprilShield(int num,item ite);

/* implementaitons */

boolean liba_aprilShield_have() {
	return available_amount($item[april shower thoughts shield]) > 0;
}
boolean liba_aprilShield(effect eff) {
	return liba_aprilShield(1,eff);
}
boolean liba_aprilShield(int duration,effect eff) {
	if (!liba_aprilShield_have())
		return false;

	boolean out;
	item aprilShield = $item[april shower thoughts shield];
	skill[effect] legend = {
		$effect[disco over matter]:$skill[disco aerobics],
		$effect[leash of linguini]:$skill[leash of linguini],
		$effect[lubricating sauce]:$skill[sauce contemplation],
		$effect[mariachi moisture]:$skill[moxie of the mariachi],
		$effect[simmering]:$skill[simmer],
		$effect[slippery as a seal]:$skill[seal clubbing frenzy],
		$effect[strength of the tortoise]:$skill[patience of the tortoise],
		$effect[empathy]:$skill[empathy of the newt],
		$effect[thoughtful empathy]:$skill[empathy of the newt],
		$effect[tubes of universal meat]:$skill[manicotti meditation],
	};
	skill ski = legend[eff];
	if (ski == $skill[none])
		return false;
	int turnsPerCast = ski == $skill[leash of linguini] ? 15 : ski.turns_per_cast();
	int casts = duration / turnsPerCast + (duration % turnsPerCast == 0 ? 0 : 1);

	//need to not have april shield equipped to get empathy
	if (eff == $effect[empathy]) {
		boolean restore = false;
		if (have_equipped(aprilShield)) {
			equip($slot[off-hand],$item[none]);
			restore = true;
		}
		out = use_skill(casts,ski);
		if (restore)
			equip($slot[off-hand],aprilShield);
		return out;
	}
	return liba_equipCast(casts,$item[april shower thoughts shield],ski);
}
boolean liba_aprilShield(skill ski) {
	return liba_aprilShield(1,ski);
}
boolean liba_aprilShield(int casts,skill ski) {
	if (!liba_aprilShield_have())
		return false;
	return liba_equipCast(casts,$item[april shower thoughts shield],ski);
}
boolean liba_aprilShield(item ite) {
	return liba_aprilShield(1,ite);
}
boolean liba_aprilShield(int num,item ite) {
	coinmaster master = $coinmaster[using your shower thoughts];
	if (ite.seller != master)
		return false;
	return buy(master,num,ite);
}

