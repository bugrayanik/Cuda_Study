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

		for (int i = 0; i < 100; i++)
		{
			if (Tabela[i].currPos >= 100) 
			{
				cout << "GAME IS OVER!" << endl;
				return 1;
			}
		}
	return 0;
	}

	void display_winner() {


		vector <int> Winners;

		for (int i = 0; i < 100; i++)
		{
			if (Tabela[i].currPos >= 100)
			{
				Winners.push_back(i);
			}
		}

		cout << "Winners List:" << endl;

		for (int i : Winners)
			cout << "RacerNo" << i+1 << "(LastSpeed:" << Tabela[i].currSpeed << ")" << endl;
	}
};