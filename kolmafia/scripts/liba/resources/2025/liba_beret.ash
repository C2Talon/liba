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

//returns the power of the equipped gear in given map based on current skills and effects; only counts hat, shirt, pants
int liba_beret_getPower(item[slot] gear);
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

int liba_beret(int times,float[modifier] modWeights,float[effect] effWeights,boolean onlyNewEffects) {
	if (!liba_beret_have()
		|| liba_beret_left() <= 0)
	{
		return 0;
	}
	liba_beret_sim sim = liba_beret_simInit(modWeights,effWeights,onlyNewEffects);
	int limit = liba_clamp(times,1,liba_beret_left());
	int success;
	liba_beret_busk[int] best = liba_beret_bestBusks(limit,sim);
	item[slot] restore;
	boolean[slot] slots = $slots[hat,shirt,pants,familiar];
	familiar fam = my_familiar();

	foreach x in slots
		restore[x] = equipped_item(x);

	foreach cast,busk in best {
		int tries;
		//did not find a best busk for every use, so burn the use to get to the next
		while (cast > liba_beret_used() && ++tries < 5) {
			liba_beret_print(`burning busk {cast+1} since all busk scores for all gear was zero`);
			if (liba_beret_execute())
				success++;
		}
		liba_beret_print(`executing busk {cast+1}; weighted score {busk.score}; gear power {busk.power}`);
		if (liba_beret_execute(busk.gear))
			success++;
	}
	use_familiar(fam);
	foreach i,x in restore
		equip(i,x);

	return success;
}

liba_beret_busk[int] liba_beret_bestBusks(int times,liba_beret_sim sim) {
	liba_beret_busk[int,int] all = liba_beret_allBusks(times,sim);
	liba_beret_busk[int] out;
	float[int] tally;
	int start = sim.used,count;
	effect hammertime = $effect[hammertime];

	int[effect] starting = sim.effects;

	int[effect] exclude;
	if (sim.onlyNewEffects) foreach i,x in sim.effects
		exclude[i] = x;
	sim.effects = exclude;

	foreach cast in all {
		if (start > cast)
			continue;
		start = count = cast;
		break;
	}

	foreach cast,power,busk in all {
		if (start > cast)
			continue;

		//exclude previous busk effects
		if (count < cast) {
			foreach eff in out[count].effects
				exclude[eff] += 10;
			count = cast;
		}

		//get score of this busk
		float score;
		if (count > start) {//potentially recalculate everything if not first busk
			if (!(starting contains hammertime)
				&& exclude contains hammertime)
			{
				busk.power = liba_beret_getPower(busk.gear,sim);
				busk.effects = beret_busking_effects(busk.power,cast);
				busk.score = liba_beret_getScore(busk.effects,sim);
			}
			else if (sim.onlyNewEffects)
				busk.score = liba_beret_getScore(busk.effects,sim);
			score = busk.score;
		}
		else
			score = busk.score;

		//compare and save if bigger
		if (score > tally[cast]) {
			out[cast] = busk;
			busk.score = tally[cast] = score;
		}
	}
	float total;
	foreach i,x in tally
		total += x;
	liba_beret_print(`best busks total score {total}`);

	sim.effects = starting;
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
	int hammer = sim.effects[$effect[hammertime] ] != 0 ? 2 : 0;

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
	power = floor(min(power,1100) + max(0,power-1100)**0.8);
	return power;
}

float liba_beret_getScore(int[effect] buskEffects,liba_beret_sim sim) {
	float score,value;
	foreach eff in buskEffects {
		if (sim.onlyNewEffects && sim.effects[eff] != 0)
			continue;
		if (eff == $effect[none])
			continue;
		buskEffects[eff] = 0;
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

