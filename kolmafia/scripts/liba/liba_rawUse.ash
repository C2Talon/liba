//liba rawUse

//using visit_url() to use an item
//items that have their own unique use link will probably not work with this
//returns the resultant page
buffer liba_rawUse(item ite) {
	buffer out;
	if (available_amount(ite) > 0)
		out = visit_url(`inv_use.php?pwd={my_hash()}&which=3&whichitem={ite.id}`,false,true);
	return out;
}

