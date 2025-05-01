//liba leprecondo

//functions to handle leprecondo

import <liba_inChoice.ash>
import <liba_rawUse.ash>

//returns true of have leprecondo
boolean liba_leprecondo_have();

//all of the following arrange leprecondo pieces with different inputs
//returns true if pieces already or in order or if successfully changed
boolean liba_leprecondo(int[int] map); //e.g. {4,1,3,2}
boolean liba_leprecondo(string[int] map); //e.g. {"d","a","c","b"}
boolean liba_leprecondo(int part1,int part2,int part3,int part4);
boolean liba_leprecondo(string name1,string name2,string name3,string name4);

/* helper functions */

//returns number of piece given by name
int liba_leprecondo_nameToInt(string name);

//returns name of piece given by number
string liba_leprecondo_intToName(int number);

//returns a map keyed to pieces discovered (available to use)
boolean[int] liba_leprecondo_discovered();

//for standardizing error messages
//always returns false
boolean liba_leprecondo_error(string s);

//for standarizing success messages
//always returns true
boolean liba_leprecondo_success(string s);

//goes to leprecondo choice adventure if not already there
//returns true if in the choice adventure
boolean liba_leprecondo_visit();


/* implementations */

boolean liba_leprecondo_have() {
	return available_amount($item[leprecondo]) > 0;
}
boolean liba_leprecondo(int[int] map) {
	if (!liba_leprecondo_have())
		return liba_leprecondo_error("Leprecondo not available");
	if (map.count() > 4)
		return liba_leprecondo_error("cannot arrange more than 4 pieces");

	boolean[int] discovered = liba_leprecondo_discovered();
	string currentConfig = get_property("leprecondoInstalled");
	string newConfig,names,sendit;
	int num = -1;

	//validate input
	foreach i,x in map {
		//need to be in range
		if (x > 27 || x < 1)
			return liba_leprecondo_error(`input of {x} is out of range`);
		//needs to be available
		if (!(discovered contains x))
			return liba_leprecondo_error(`do not have piece {x} ({x.liba_leprecondo_intToName()})`);
		//cannot repeat
		foreach j,y in map if (i != j && x == y)
			return liba_leprecondo_error(`inputs {i} and {j} have same value of {x} ({x.liba_leprecondo_intToName()})`);
		//assemble strings used later
		newConfig += (newConfig == "" ? "" : ",") + x;
		names += (names == "" ? "" : ",") + x.liba_leprecondo_intToName();
		sendit += (++num == 0 ? "" : "&") + `r{num}={x}`;
	}
	//don't bother if configs already match
	if (newConfig == currentConfig)
		return liba_leprecondo_success(`config already set to {newConfig} ({names})`);
	//don't want to check this until config matching is checked
	if (get_property("_leprecondoRearrangements") >= 3)
		return liba_leprecondo_error("already reached max rearrangements");

	//get to the leprecondo
	if (!liba_leprecondo_visit())
		return liba_leprecondo_error("using the Leprecondo failed");

	run_choice(1,sendit);

	if (newConfig == get_property("leprecondoInstalled"))
		return liba_leprecondo_success(`config changed to {newConfig} ({names})`);

	return liba_leprecondo_error("failed to arrange Leprecondo");
}
boolean liba_leprecondo(string[int] map) {
	int[int] out;
	foreach i,x in map
		out[i] = x.liba_leprecondo_nameToInt();
	return liba_leprecondo(out);
}
boolean liba_leprecondo(int part1,int part2,int part3,int part4) {
	int[int] out = {part1,part2,part3,part4};
	return liba_leprecondo(out);
}
boolean liba_leprecondo(string name1,string name2,string name3,string name4) {
	int[int] out = {
		name1.liba_leprecondo_nameToInt(),
		name2.liba_leprecondo_nameToInt(),
		name3.liba_leprecondo_nameToInt(),
		name4.liba_leprecondo_nameToInt(),
	};
	return liba_leprecondo(out);
}
int liba_leprecondo_nameToInt(string name) {
	int[string] legend = {
		"buckets of concrete":1,
		"thrift store oil painting":2,
		"boxes of old comic books":3,
		"second-hand hot plate":4,
		"beer cooler":5,
		"free mattress":6,
		"gigantic chess set":7,
		"ultradance karaoke machine":8,
		"cupcake treadmill":9,
		"beer pong table":10,
		"padded weight bench":11,
		"internet-connected laptop":12,
		"sous vide laboratory":13,
		"programmable blender":14,
		"sensory deprivation tank":15,
		"fruit-smashing robot":16,
		"mancave™ sports bar set":17,
		"couch and flatscreen":18,
		"kegerator":19,
		"fine upholstered dining table set":20,
		"whiskeybed":21,
		"high-end home workout system":22,
		"complete classics library":23,
		"ultimate retro game console":24,
		"omnipot":25,
		"fully-stocked wet bar":26,
		"four-poster bed":27,
		//mancave alternate "spellings"
		"mancave&trade; sports bar set":17,
		"mancave sports bar set":17,
	};
	return legend[name.to_lower_case()];
}
string liba_leprecondo_intToName(int number) {
	string[int] legend = {
		1:"buckets of concrete",
		2:"thrift store oil painting",
		3:"boxes of old comic books",
		4:"second-hand hot plate",
		5:"beer cooler",
		6:"free mattress",
		7:"gigantic chess set",
		8:"UltraDance karaoke machine",
		9:"cupcake treadmill",
		10:"beer pong table",
		11:"padded weight bench",
		12:"internet-connected laptop",
		13:"sous vide laboratory",
		14:"programmable blender",
		15:"sensory deprivation tank",
		16:"fruit-smashing robot",
		17:"ManCave™ sports bar set",
		18:"couch and flatscreen",
		19:"kegerator",
		20:"fine upholstered dining table set",
		21:"whiskeybed",
		22:"high-end home workout system",
		23:"complete classics library",
		24:"ultimate retro game console",
		25:"Omnipot",
		26:"fully-stocked wet bar",
		27:"four-poster bed",
	};
	return legend[number];
}
boolean[int] liba_leprecondo_discovered() {
	boolean[int] out;
	foreach i,x in get_property("leprecondoDiscovered").split_string(",")
		out[x.to_int()] = true;
	return out;
}
boolean liba_leprecondo_error(string s) {
	print(`liba_leprecondo error: {s}`,"red");
	return false;
}
boolean liba_leprecondo_success(string s) {
	print(`liba_leprecondo: {s}`);
	return true;
}
boolean liba_leprecondo_visit() {
	if (!liba_inChoice(1556))
		liba_rawUse($item[leprecondo]);
	return liba_inChoice(1556);
}

