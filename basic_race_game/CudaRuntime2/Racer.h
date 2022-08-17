#pragma once
#include <iostream>

class Racer 
{
private:
	friend class Racers;
	int currPos;
	int currSpeed;
	int racerNo;
	
public:

Racer(int x = 0, int y = 0, int z = 0) :currPos(x), currSpeed(y), racerNo(z) {}

};
