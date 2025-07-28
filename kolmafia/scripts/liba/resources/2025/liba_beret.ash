//liba beret

//handle busking with the prismatic beret either through simulation or player state

import <liba_clamp.ash>

record liba_beret_busk {
	int power;		//total power of gear for busk
	float score;		//total score of effects in busk
	item[slot] gear;	//map of slots of gear used for busk
	int[effect] effects;	//map of effects in busk
};

//record used for input of many functions to simplify a lot of things
record liba_beret_sim {
	float[modifier] modifierWeights;//map of weights of modifiers for busk scoring
	float[effect] effectWeights;	//map of weights of effects for busk scoring
	boolean onlyNewEffects;		//consider only new effects for busk scoring
	int[effect] effects;		//map of duration of effects the player has
	item[int] hats;			//map of power of hats the player has access to
	item[int] shirts;		//map of power of shirts the player has access to
	item[int] pants;		//map of power of pants the player has access to
	boolean tao;			//whether or not the player has the tao skill
	int used;			//number of times beret busking skill has been used previously
};

//returns whether have the beret or not
boolean liba_beret_have();

//returns number of times beret busks have been used
int liba_beret_used();

//returns number of beret busk uses remaining
int liba_beret_left();

//finds and gets optimal beret busks with given weights on modifiers among all available combinations of gear the player currently has
//times: number of busks to do; defaults to 1 if omitted
//modWeights: map of weights you want to give to modifiers in busk effects
//effWeights: map of weights you want to give specific effects in busks
//onlyNewEffects: will only consider new effects; defaults to true if omitted
//returns number of times busk is cast with given parameters
//not for simulating--use bestBusks or allBusks for that
int liba_beret(int times,float[modifier] modifierWeights,float[effect] effectWeights,boolean onlyNewEffects);

//same as above, but uses record for input
//mostly for adding gear for consideration that the player does not currently have, but can reliably get with retrieve_item()
//if any gear is considered for a busk and not able to be retrieved, the function will stop before doing any actual busking
//other player state things in sim will be overridden with current player state to prevent breakage
int liba_beret(int times,liba_beret_sim sim);

/* helper functions */

//used to initialize some default values to be used for input of most things based on the state of the player
liba_beret_sim liba_beret_simInit(float[modifier] modifierWeights,float[effect] effectWeights,boolean onlyNewEffects);
liba_beret_sim liba_beret_simInit() return liba_beret_simInit(float[modifier]{},float[effect]{},true);

//print a message
void liba_beret_print(string s);

//uses beret busking with given gear
//omitting gear just equips the beret if needed and uses the busk skill
//returns true on success
boolean liba_beret_execute(item[slot] gear);
boolean liba_beret_execute();

//returns map of all busks possible based on available gear
//does not count potential effects from previous busks for onlyNewEffects or changes in hammertime status
liba_beret_busk[int,int] liba_beret_allBusks(int times,liba_beret_sim sim);

//returns map of best busks based on weights based on currently available gear
liba_beret_busk[int] liba_beret_bestBusks(int times,liba_beret_sim sim);

//returns map of all available equipment for a particular slot
item[int] liba_beret_allEquipment(slot slo);

//returns the power of the equipped gear in given map based on simulated skills and effects; only counts hat, shirt, pants
int liba_beret_getPower(item[slot] gear,liba_beret_sim sim);

//returns the score of the given effects based on weight and optionally whether you already have the effect or not
float liba_beret_getScore(int[effect] buskEffects,liba_beret_sim sim);

/*===========================
	implementations
  ===========================*/

liba_beret_sim liba_beret_simInit(float[modifier] modifierWeights,float[effect] effectWeights,boolean onlyNewEffects) {
	return new liba_beret_sim(
		modifierWeights,
		effectWeights,
		onlyNewEffects,
		my_effects(),
		liba_beret_allEquipment($slot[hat]),
		liba_beret_allEquipment($slot[shirt]),
		liba_beret_allEquipment($slot[pants]),
		have_skill($skill[tao of the terrapin]),
		liba_beret_used()
	);
}

boolean liba_beret_have() {
	return available_amount($item[prismatic beret]) > 0;
}

int liba_beret_used() {
	return get_property("_beretBuskingUses").to_int();
}

int liba_beret_left() {
	return 5-liba_beret_used();
}

int liba_beret(int times,liba_beret_sim sim) {
	if (!liba_beret_have()
		|| liba_beret_left() <= 0)
	{
		return 0;
	}
	int success;
	int limit = liba_clamp(times,1,liba_beret_left());

	//override sim to not break things
	int simUsed = sim.used;
	sim.used = liba_beret_used();
	int[effect] simEffects = sim.effects;
	sim.effects = my_effects();
	boolean simTao = sim.tao;
	sim.tao = have_skill($skill[tao of the terrapin]);

	//find best busks and exit if nothing found
	liba_beret_busk[int] best = liba_beret_bestBusks(limit,sim);
	if (best.count() == 0) {
		liba_beret_print(`no best busks found`);
		return 0;
	}

	//store current equipment and familiar for restoration later
	familiar fam = my_familiar();
	item[slot] restore;
	foreach x in $slots[hat,shirt,pants,familiar]
		restore[x] = equipped_item(x);

	//acquire all gear that were included for consideration for best busks and are now needed
	foreach cast,busk in best foreach i,piece in busk.gear if (available_amount(piece) == 0 && piece != $item[none] && !retrieve_item(piece)) {
		liba_beret_print(`{piece} was included in one of the best busks but could not be acquired, so busking stopped before it started`);
		return 0;
	}

	//do the busks, potentially burning empty ones to get to the next
	foreach cast,busk in best {
		int tries;
		while (cast >= liba_beret_used() && tries++ < 5) {
			if (cast == liba_beret_used())
				liba_beret_print(`executing busk {cast+1}; weighted score {busk.score}; gear power {busk.power}`);
			else
				liba_beret_print(`burning busk {cast+1} since all busk scores for all gear considered was zero or less`);
			if (liba_beret_execute(busk.gear))
				success++;
		}
	}

	//restore equipment and familiar
	use_familiar(fam);
	foreach i,x in restore
		equip(i,x);

	//restore sim in case user wants to use it after
	sim.used = simUsed;
	sim.effects = simEffects;
	sim.tao = simTao;

	return success;
}

liba_beret_busk[int] liba_beret_bestBusks(int times,liba_beret_sim sim) {
	liba_beret_busk[int] out;
	float[int] tally;
	float total;
	int limit = liba_clamp(times,1,5-sim.used);

	if (sim.used >= 5 || sim.used < 0)
		return out;

	//store starting sim values that may change
	int startUsed = sim.used;
	int[effect] startEffects = sim.effects;
	int[effect] simEffects;
	if (sim.onlyNewEffects) foreach i,x in sim.effects
		simEffects[i] = x;
	sim.effects = simEffects;

	repeat {
		float score;
		//add previous best busk effects to sim
		if (sim.used > startUsed) foreach eff in out[sim.used-1].effects
			sim.effects[eff] += 10;

		//find best scoring busk among all busks for current simulated cast
		liba_beret_busk[int,int] all = liba_beret_allBusks(1,sim);
		foreach cast,power,busk in all if (busk.score > score) {
			out[cast] = busk;
			score = tally[cast] = busk.score;
		}
	} until (++sim.used >= startUsed+limit);

	//total
	foreach i,x in tally
		total += x;
	liba_beret_print(`best busks total score {total}`);

	//restore sim and return
	sim.effects = startEffects;
	sim.used = startUsed;
	return out;
}

liba_beret_busk[int,int] liba_beret_allBusks(int times,liba_beret_sim sim) {
	liba_beret_busk[int,int] out;
	if (sim.used >= 5)
		return out;

	int limit = liba_clamp(times,1,5-sim.used);
	float topScore;
	int topPower;
	int start = sim.used;

	foreach i,hat in sim.hats foreach j,shirt in sim.shirts foreach k,pant in sim.pants {
		item[slot] gear = {
			$slot[hat] : hat,
			$slot[shirt] : shirt,
			$slot[pants] : pant,
		};
		int power = liba_beret_getPower(gear,sim);
		for num from start to start+limit-1 {
			int[effect] effs = beret_busking_effects(power,num);
			float score = liba_beret_getScore(effs,sim);
			if (score > 0.01)
				out[num,power] = new liba_beret_busk(power,score,gear,effs);
		}
	}
	return out;
}

item[int] liba_beret_allEquipment(slot slo) {
	item[int] out;
	if (slo == $slot[hat]
		&& !have_familiar($familiar[mad hatrack]))
	{
		return item[int]{10:$item[prismatic beret]};
	}
	out[0] = $item[none];
	if (slo == $slot[shirt] && !have_skill($skill[torso awareness]))//TODO: toros awareness is not the only way to equip shirts
		return out;

	foreach x in $items[] {
		if (available_amount(x) > 0
			&& x.to_slot() == slo
			&& x.can_equip())
		{
			out[x.get_power()] = x;
		}
	}
	return out;
}

int liba_beret_getPower(item[slot] gear,liba_beret_sim sim) {
	int power;
	int tao = sim.tao ? 1 : 0;
	int hammer = (sim.effects contains $effect[hammertime]) ? 3 : 0;

	foreach slo,ite in gear {
		int multi = 1;
		if (slo == $slot[pants])
			multi += tao + hammer;
		else if (slo == $slot[hat])
			multi += tao;
		else if (slo != $slot[shirt])
			continue;
		power += ite.get_power() * multi;
	}
	return power;
}

float liba_beret_getScore(int[effect] buskEffects,liba_beret_sim sim) {
	float score,value;
	foreach eff in buskEffects {
		if (eff == $effect[none])
			continue;
		buskEffects[eff] = 0;
		if (sim.onlyNewEffects && sim.effects contains eff)
			continue;
		foreach mod,weight in sim.modifierWeights {
			value = numeric_modifier(eff,mod);
			if (value > 0.01 || value < 0.01) {
				score += weight * value;
				buskEffects[eff] += weight * value;
			}
		}
		if (sim.effectWeights contains eff) {
			score += sim.effectWeights[eff];
			buskEffects[eff] += sim.effectWeights[eff];
		}
	}
	return score;
}

void liba_beret_print(string s) {
	print(`liba_beret: {s}`);
}

boolean liba_beret_execute(item[slot] gear) {
	int start = liba_beret_used();

	foreach x in $slots[hat,shirt,pants] {
		if (x == $slot[hat] && gear[x] != $item[prismatic beret]) {
			if (!have_familiar($familiar[mad hatrack]))
				return false;
			use_familiar($familiar[mad hatrack]);
			equip($slot[familiar],$item[prismatic beret]);
		}
		equip(x,gear[x]);
	}
	use_skill($skill[beret busking]);
	if (start != liba_beret_used())
		return true;
	return false;
}
boolean liba_beret_execute() {
	item beret = $item[prismatic beret];
	return liba_beret_execute(item[slot]{
		$slot[hat] : (equipped_amount(beret) == 0 ? beret : equipped_item($slot[hat])),
		$slot[shirt] : equipped_item($slot[shirt]),
		$slot[pants] : equipped_item($slot[pants])
	});
}


//liba_beret() overloads
int liba_beret(int times,float[modifier] modWeights,float[effect] effWeights,boolean onlyNewEffects) {
	return liba_beret(times,liba_beret_simInit(modWeights,effWeights,onlyNewEffects));
}
int liba_beret(int times,float[effect] effWeights,float[modifier] modWeights,boolean onlyNewEffects) {
	return liba_beret(times,modWeights,effWeights,onlyNewEffects);
}
int liba_beret(int times,float[modifier] modWeights,float[effect] effWeights) {
	return liba_beret(times,modWeights,effWeights,true);
}
int liba_beret(int times,float[effect] effWeights,float[modifier] modWeights) {
	return liba_beret(times,modWeights,effWeights,true);
}
int liba_beret(int times,float[modifier] modWeights,boolean onlyNewEffects) {
	return liba_beret(times,modWeights,float[effect]{},onlyNewEffects);
}
int liba_beret(int times,float[effect] effWeights,boolean onlyNewEffects) {
	return liba_beret(times,float[modifier]{},effWeights,onlyNewEffects);
}
int liba_beret(int times,float[modifier] modWeights) {
	return liba_beret(times,modWeights,float[effect]{},true);
}
int liba_beret(int times,float[effect] effWeights) {
	return liba_beret(times,float[modifier]{},effWeights,true);
}
int liba_beret(float[modifier] modWeights,float[effect] effWeights,boolean onlyNewEffects) {
	return liba_beret(1,modWeights,effWeights,onlyNewEffects);
}
int liba_beret(float[effect] effWeights,float[modifier] modWeights,boolean onlyNewEffects) {
	return liba_beret(1,modWeights,effWeights,onlyNewEffects);
}
int liba_beret(float[modifier] modWeights,float[effect] effWeights) {
	return liba_beret(1,modWeights,effWeights,true);
}
int liba_beret(float[effect] effWeights,float[modifier] modWeights) {
	return liba_beret(1,modWeights,effWeights,true);
}
int liba_beret(float[modifier] modWeights,boolean onlyNewEffects) {
	return liba_beret(1,modWeights,float[effect]{},onlyNewEffects);
}
int liba_beret(float[effect] effWeights,boolean onlyNewEffects) {
	return liba_beret(1,float[modifier]{},effWeights,onlyNewEffects);
}
int liba_beret(float[modifier] modWeights) {
	return liba_beret(1,modWeights,float[effect]{},true);
}
int liba_beret(float[effect] effWeights) {
	return liba_beret(1,float[modifier]{},effWeights,true);
}

