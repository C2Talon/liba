//liba containsToken

//returns true if tokenized_string contains token
boolean liba_containsToken(string tokenized_string,string token,string delimiter);

/* implementations */

boolean liba_containsToken(string tokenized_string,string token,string delimiter) {
	return create_matcher(`(?<=(^|{delimiter})){token}(?=($|{delimiter}))`,tokenized_string).find();
}

