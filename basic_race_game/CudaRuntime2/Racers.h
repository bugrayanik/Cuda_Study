#pragma once
#include "Racer.h"
#include<vector>
#include<iterator>
#include <iostream>
#include <algorithm>

using namespace std;

class Racers
{
private:
	vector <Racer> Tabela;
	

public:
	Racers() {};

	void add_racer(int currPos, int currSpeed, int racerNo) {
		Racer* new_racer = new Racer(currPos, currSpeed, racerNo);
		Tabela.push_back(*new_racer);
		delete new_racer;
	}

	void display_tabela() const {
		for (auto i : Tabela) {
			cout << "RacerNO:" << i.racerNo << " Speed(m/s):" << i.currSpeed << " Position(meters):" << i.currPos << endl;
		}
	}

	void modify_variable_of(int* newPos, int* newSpeed) {
		for (int i = 0; i < 100;i++) // access by reference to avoid copying
		{
			Tabela[i].currPos = newPos[i];
			Tabela[i].currSpeed = newSpeed[i];
		}
	}


	bool check_winner() {
		vector <int> Winners;
		vector <int> WinnersIndex;
		bool a = false;

		for (int i = 0; i < 100; i++)
		{
			if (Tabela[i].currPos >= 100) {
				a = true;
				Winners.push_back(Tabela[i].currPos);
				WinnersIndex.push_back(i);
			}
		}
		int maxElementIndex = max_element(Winners.begin(), Winners.end()) - Winners.begin();

		cout << "GAME IS FINISHED!" << endl << "WINNER IS " << WinnersIndex[maxElementIndex];
	
		return a;
	}	
};