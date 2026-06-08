//liba priority

//returns first item in map that is available via available_amount(); returns $item[none] if none found
item liba_priority(boolean[item] items);
item liba_priority(item[int] items);

//returns first familiar in map that the player owns via have_familiar(); returns $familiar[none] if none found
familiar liba_priority(boolean[familiar] familiars);
familiar liba_priority(familiar[int] familiars);

//returns first location in map that player can adventure via can_adventure(); returns $location[none] if none found
location liba_priority(boolean[location] locations);
location liba_priority(location[int] locations);

/* implementations */

item liba_priority(boolean[item] items) {
	foreach x in items
		if (available_amount(x) > 0)
			return x;
	return $item[none];
}
item liba_priority(item[int] items) {
	foreach i,x in items
		if (available_amount(x) > 0)
			return x;
	return $item[none];
}
familiar liba_priority(boolean[familiar] familiars) {
	foreach x in familiars
		if (have_familiar(x))
			return x;
	return $familiar[none];
}
familiar liba_priority(familiar[int] familiars) {
	foreach i,x in familiars
		if (have_familiar(x))
			return x;
	return $familiar[none];
}
location liba_priority(boolean[location] locations) {
	foreach x in locations
		if (can_adventure(x))
			return x;
	return $location[none];
}
location liba_priority(location[int] locations) {
	foreach i,x in locations
		if (can_adventure(x))
			return x;
	return $location[none];
}

