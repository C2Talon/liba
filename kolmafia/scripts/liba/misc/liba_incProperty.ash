//liba incProperty

//increment property
//adds `n` to, and stores new value to, the value contained in property `prop`
//omitting `n` increments the property by 1
//returns int of property after incrementing it
int liba_incProperty(string prop);
int liba_incProperty(string prop,int n);
int liba_incProperty(int n,string prop);

/* implementations */

int liba_incProperty(string prop) {
	return liba_incProperty(prop,1);
}
int liba_incProperty(int n,string prop) {
	return liba_incProperty(prop,n);
}
int liba_incProperty(string prop,int n) {
	set_property(prop,get_property(prop).to_int()+n);
	return get_property(prop).to_int();
}

