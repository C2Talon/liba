//liba eternityCodpiece

//inserts gems into the eternity codpiece

//returns whether player has eternity codpiece or not
boolean liba_eternityCodpiece_have();

//returns the gems in eternity codpiece as map keyed to slots
item[slot] liba_eternityCodpiece_get();

//smartly insert gems into the eternity codpiece
//returns number of gems in the eternity codpiece that match input after insertion
int liba_eternityCodpiece_set(item gem1,item gem2,item gem3,item gem4,item gem5);
int liba_eternityCodpiece_set(boolean[item] gems);
int liba_eternityCodpiece_set(item[int] gems);

//forces gems into specific slots
//returns number of correct gems in matching slots
int liba_eternityCodpiece_set(item[slot] gems);

//equips single gem to first empty slot or first slot if full, but only if a copy of the gem isn't already in it
//returns 0 if the gem is not equipped, 1 elsewise
int liba_eternityCodpiece_set(item gem);

//inserts given gem into every slot
//returns number of given gem the codpiece has after insertion
int liba_eternityCodpiece_setAll(item gem);

//take gems from codpiece
//returns number of gems taken
int liba_eternityCodpiece_take(item gem);
int liba_eternityCodpiece_take(item[int] gems);
int liba_eternityCodpiece_take(boolean[item] gems);

//remove all gems from codpiece
//returns true if codpiece is empty
boolean liba_eternityCodpiece_takeAll();

//returns number of equipped gem in codpiece
int liba_eternityCodpiece_equippedAmount(item gem);

//returns available_amount() of the gem plus the number of the gem inserted into the codpiece
int liba_eternityCodpiece_availableAmount(item gem);

/* implementations */

boolean liba_eternityCodpiece_have() {
	return $item[the eternity codpiece].available_amount() > 0;
}

item[slot] liba_eternityCodpiece_get() {
	item[slot] out;
	if (!liba_eternityCodpiece_have())
		return out;
	foreach x in $slots[codpiece1,codpiece2,codpiece3,codpiece4,codpiece5]
		out[x] = equipped_item(x);
	return out;
}

int liba_eternityCodpiece_set(item gem1,item gem2,item gem3,item gem4,item gem5) {
	return liba_eternityCodpiece_set(item[int]{gem1,gem2,gem3,gem4,gem5});
}
int liba_eternityCodpiece_set(boolean[item] gems) {
	item[int] out;
	int i = -1;
	foreach x in gems
		out[i++] = x;
	return liba_eternityCodpiece_set(out);
}
int liba_eternityCodpiece_set(item[int] gems) {
	if (!liba_eternityCodpiece_have())
		return 0;
	slot[int] remain = {$slot[codpiece1],$slot[codpiece2],$slot[codpiece3],$slot[codpiece4],$slot[codpiece5]};
	item[slot] out,current = liba_eternityCodpiece_get();
	item[int] want;
	//copy gems to want
	foreach i,x in gems
		want[i] = x;
	//first pass to keep number of gems desired that are already set
	foreach i,gem in want foreach j,sl in remain if (current[sl] == gem) {
		out[sl] = gem;
		remove want[i];
		remove remain[j];
		break;
	}
	//second pass to put each new gem in empty slots
	foreach j,sl in remain if (current[sl] == $item[none]) foreach i,gem in want {
		out[sl] = gem;
		remove want[i];
		remove remain[j];
		break;
	}
	//third pass to put new gems in remaining slots
	foreach j,sl in remain foreach i,gem in want {
		out[sl] = gem;
		remove want[i];
		break;
	}
	return liba_eternityCodpiece_set(out);
}
int liba_eternityCodpiece_set(item[slot] gems) {
	if (!liba_eternityCodpiece_have())
		return 0;
	slot[int] remain = {$slot[codpiece1],$slot[codpiece2],$slot[codpiece3],$slot[codpiece4],$slot[codpiece5]};
	for (int tries = 0;remain.count() > 0 && tries < 5;tries++) foreach i,sl in remain {
		if (gems[sl] == equipped_item(sl)) {
			remove remain[i];
		}
		else if (available_amount(gems[sl]) > 0) {
			equip(sl,gems[sl]);
			remove remain[i];
		}
	}
	int out;
	foreach sl,gem in liba_eternityCodpiece_get() if (gems[sl] == gem)
		out++;
	return out;
}
int liba_eternityCodpiece_set(item gem) {
	return liba_eternityCodpiece_set(item[int]{gem});
}
int liba_eternityCodpiece_setAll(item gem) {
	return liba_eternityCodpiece_set(item[int]{gem,gem,gem,gem,gem});
}

int liba_eternityCodpiece_take(item gem) {
	return liba_eternityCodpiece_take(item[int]{gem});
}
int liba_eternityCodpiece_take(item[int] gems) {
	if (!liba_eternityCodpiece_have())
		return 0;
	slot[int] remain = {$slot[codpiece1],$slot[codpiece2],$slot[codpiece3],$slot[codpiece4],$slot[codpiece5]};
	item[slot] current = liba_eternityCodpiece_get();
	int out;
	foreach i,gem in gems foreach j,sl in remain if (current[sl] == gem && equip(sl,$item[none])) {
		out++;
		remove remain[j];
		break;
	}
	return out;
}
int liba_eternityCodpiece_take(boolean[item] gems) {
	item[int] out;
	int i = -1;
	foreach x in gems
		out[i++] = x;
	return liba_eternityCodpiece_take(out);
}

boolean liba_eternityCodpiece_takeAll() {
	if (!liba_eternityCodpiece_have())
		return false;
	boolean[slot] slots = $slots[codpiece1,codpiece2,codpiece3,codpiece4,codpiece5];
	foreach x in slots
		equip(x,$item[none]);
	foreach x in slots if (equipped_item(x) != $item[none])
		return false;
	return true;
}

int liba_eternityCodpiece_equippedAmount(item gem) {
	boolean[slot] slots = $slots[codpiece1,codpiece2,codpiece3,codpiece4,codpiece5];
	int out;
	foreach x in slots if (equipped_item(x) == gem)
		out++;
	return out;
}
int liba_eternityCodpiece_availableAmount(item gem) {
	return available_amount(gem) + liba_eternityCodpiece_equippedAmount(gem);
}

