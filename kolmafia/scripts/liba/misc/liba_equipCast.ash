//liba equipCast

//used to cast things that require a particular item to be equipped
//will automatically equip the item specified if not already equipped, then reequip what was there previously when done
//all functions return the return value of use_skill()
boolean liba_equipCast(skill skil,item equipment);
boolean liba_equipCast(item equipment,skill skil);
boolean liba_equipCast(int times,skill skil,item equipment);
boolean liba_equipCast(int times,item equipment,skill skil);


/* implementations */

boolean liba_equipCast(skill skil,item equipment) {
	return liba_equipCast(1,equipment,skil);
}
boolean liba_equipCast(item equipment,skill skil) {
	return liba_equipCast(1,equipment,skil);
}
boolean liba_equipCast(int times,skill skil,item equipment) {
	return liba_equipCast(times,equipment,skil);
}
boolean liba_equipCast(int times,item equipment,skill skil) {
	item last,main;
	slot slo = equipment.to_slot();
	boolean out;

	if (times < 1)
		return false;
	if (available_amount(equipment) == 0) {
		print(`liba_equipCast: "{equipment}" not found`,"red");
		return false;
	}
	if (slo == $slot[none]) {
		print(`liba_equipCast: "{equipment}" is not something that can be equipped`,"red");
		return false;
	}

	//swap in item
	if (!have_equipped(equipment)) {
		//edge cases with hands
		if ($slots[weapon,off-hand] contains slo) {
			main = equipped_item($slot[weapon]);
			last = equipped_item($slot[off-hand]);
			//unequip mainhand weapon if it blocks equipping offhand
			if (slo == $slot[off-hand]
				&& weapon_hands(main) > 1)
			{
				equip($slot[weapon],$item[none]);
			}
		}
		else
			last = equipped_item(slo);
		equip(slo,equipment);
	}

	//repeatedly cast things that can only be cast one at a time
	if ($items[
		blood cubic zirconia,
		the eternity codpiece,//TODO: if another gem is added the needs to be equipped to use skills outside combat, this might need to change
		] contains equipment)
	{
		int count = 0;
		while (use_skill(1,skil) && ++count < times);
		if (count > 0)
			out = true;
	}
	//cast everything else as normal
	else
		out = use_skill(times,skil);

	//reequip previous item
	if (main != $item[none]) {
		equip($slot[weapon],main);
		equip($slot[off-hand],last);
	}
	else if (last != $item[none])
		equip(slo,last);

	return out;
}

