//liba umbrella

//wrapper for the CLI `umbrella` command to chamge the modes of the umbreakable umbrella

//returns true if have the umbrella
boolean liba_umbrella_have() {
	return available_amount($item[unbreakable umbrella]) > 0;
}

//changes umbrella mode based on given modifier
//returns true if umbrella changed to correct mode
boolean liba_umbrella(modifier mod) {
	if (!liba_umbrella_have())
		return false;
	string[modifier] legend = {
		$modifier[monster level]:		"broken",
		$modifier[monster level percent]:	"broken",
		$modifier[item drop]:			"bucket",
		$modifier[damage reduction]:		"forward",
		$modifier[weapon damage]:		"pitchfork",
		$modifier[spell damage]:		"twirling",
		$modifier[combat rate]:			"cocoon",
	};
	string mode = legend[mod];
	if (mode == "")
		return false;
	if (!get_property("umbrellaState").contains_text(mode))
		cli_execute(`try;umbrella {mode}`);
	return get_property("umbrellaState").contains_text(mode);
}

