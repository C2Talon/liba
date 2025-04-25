//liba photoBooth

//get things from vip photo booth

import <liba_inChoice.ash>

//returns true if current clan has vip photo booth
boolean liba_photoBooth_have();

//returns true if get effect from photo booth
boolean liba_photoBooth(effect eff);
boolean liba_photoBooth(int times,effect eff);

//returns true if get item from photo booth
boolean liba_photoBooth(item ite);

/* implementations */

boolean liba_photoBooth_have() {
	return get_clan_lounge() contains $item[photo booth sized crate];
}
boolean liba_photoBooth(effect eff) {
	return liba_photoBooth(1,eff);
}
boolean liba_photoBooth(int times,effect eff) {
	int advBase = 1533;
	int advEffect = 1534;
	int start = have_effect(eff);
	int limit = 3 - get_property("_photoBoothEffects").to_int();
	int num = times >= limit ? limit : times < 1 ? 1 : times;

	if (limit <= 0)
		return false;
	if (!liba_photoBooth_have())
		return false;
	if (!($effects[wild and westy!,towering muscles,spaced out] contains eff))
		return false;

	for i from 1 to num {
		//don't navigate from start if don't have to
		if (!liba_inChoice(advEffect)) {
			if (!liba_inChoice(advBase)) {
				visit_url("clan_viplounge.php?action=photobooth",false,true);
				if (!liba_inChoice(advBase))
					break;
			}
			if (!(available_choice_options() contains 1))
				break;
			run_choice(1);
		}
		if (!liba_inChoice(advEffect))
			break;

		run_choice(eff.id-$effect[wild and westy!].id+1);
	}

	return have_effect(eff) > start;
}
boolean liba_photoBooth(item ite) {
	int advBase = 1533;
	int advItem = 1535;
	int start = available_amount(ite);

	if (get_property("_photoBoothEquipment").to_int() >= 3)
		return false;
	if (!liba_photoBooth_have())
		return false;

	int[item] list = {
		$item[photo booth supply list]:1,
		$item[fake arrow-through-the-head]:2,
		$item[fake huge beard]:3,
		$item[astronaut helmet]:4,
		$item[cheap plastic pipe]:5,
		$item[oversized monocle on a stick]:6,
		$item[giant bow tie]:7,
		$item[feather boa]:8,
		$item[sheriff badge]:9,
		$item[sheriff pistol]:10,
		$item[sheriff moustache]:11,
	};
	if (list[ite] == 0)
		return false;

	//don't navigate from start if don't have to
	if (!liba_inChoice(advItem)) {
		if (!liba_inChoice(advBase)) {
			visit_url("clan_viplounge.php?action=photobooth",false,true);
			if (!liba_inChoice(advBase))
				return false;
		}
		if (!(available_choice_options() contains 2))
			return false;
		run_choice(2);
	}
	if (!liba_inChoice(advItem))
		return false;
	if (!(available_choice_options() contains list[ite]))
		return false;
	run_choice(list[ite]);

	return available_amount(ite) > start;
}

