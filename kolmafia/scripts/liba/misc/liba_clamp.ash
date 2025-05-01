//liba clamp

//returns a value to the closest range boundary if outside the range
int liba_clamp(int value,int min,int max);
float liba_clamp(float value,float min,float max);

/* implementations */

int liba_clamp(int value,int min,int max) {
	return value.min(min).max(max);
}
float liba_clamp(float value,float min,float max) {
	return value.min(max).max(min);
}

