#pragma once
#include "Racer.h"
#include<vector>
#include<iterator>

class Racers
{
private:
	std::vector <Racer> Tabela;

public:
	Racers() {};

	void add_racer(int currPos, int currSpeed, int racerNo) {
		Racer* new_racer = new Racer(currPos, currSpeed, racerNo);
		Tabela.push_back(*new_racer);
		delete new_racer;
	}

	void display_tabela() const {
		for (auto i : Tabela) {
			std::cout << "RacerNO:" << i.racerNo << " Speed(m/s):" << i.currSpeed << " Position(meters):" << i.currPos << std::endl;
		}
	}

	void modify_variable_of(int* newPos, int* newSpeed) {
		for (auto& racer : Tabela) // access by reference to avoid copying
		{
			racer.currPos = newPos[i];
			racer.currSpeed = newSpeed[i];
		}
	}
};