#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <cstdio>
#include <string.h>
#include <stdlib.h>
#include <vector>
#include <iostream>
#include <chrono>
#include <thread>
#include <stdio.h>
#include <curand.h>
#include <curand_kernel.h>
#include <math.h>
#include <assert.h>
#include "Racers.h"
#include "Racer.h"

//note that to get use of atomicAdd function, you need to use compute_20.sm_21 compilation flag

using namespace std;


class Game
{
public:
    int  data_size;   // Set from host
    __host__ Game();
    __host__ ~Game();
    __host__ void setValues(int size);
    __device__ void dosomething(int, int*);
    __host__ int* export_data();
    __host__ void free_data();
    __host__ void prepareDeviceObj();
    __host__ void retrieveDataToHost();
    

private:
    int* data; // device side
    int* h_data; //host side
};

__host__ Game::Game()
{
}

__host__ Game::~Game()
{
}

__host__ void Game::prepareDeviceObj() {
    cudaMemcpy(data, h_data, data_size * sizeof(h_data[0]), cudaMemcpyHostToDevice);
}
__host__ void Game::retrieveDataToHost() {
    cudaMemcpy(h_data, data, data_size * sizeof(h_data[0]), cudaMemcpyDeviceToHost);
    
}

__host__ void Game::setValues( int size)
{
    data_size = size;
    cudaMalloc(&data, data_size * sizeof(data[0]));
    h_data = (int*)malloc(data_size * sizeof(h_data[0]));
    memset(h_data, 0, data_size * sizeof(h_data[0]));
}

__device__ void Game::dosomething(int idx, int* newspeed)

{
    int toAdd = newspeed[idx];
    atomicAdd(&data[idx], toAdd);
    
}

__host__ void Game::free_data() {

    cudaFree(data);
    free(h_data);
}

__host__ int* Game::export_data() {

    return h_data;
}


__global__ void myKernel(Game obj, int* h_result)
{
    const int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < obj.data_size)
    {
        obj.dosomething(idx,h_result);
       
    }
}
__global__ void setup_kernel(curandState* state, unsigned long seed)
{
    int id = threadIdx.x;
    curand_init(seed, id, 0, &state[id]);
}
__global__ void generate(curandState* globalState, int* result, int* max, int* min, int count)
{
    int ind = threadIdx.x;
    curandState localState = globalState[ind];
    float RANDOM = curand_uniform(&localState);
    globalState[ind] = localState;
    if (ind < count)
        result[ind] = truncf(*min + (*max - *min) * RANDOM);
}

Racers Real_Tabela;
Game globalInstance;

int main(int argc, char** argv){

   
    for(int i=1;i<101;i++)
    Real_Tabela.add_racer(0,0,i);
    Real_Tabela.display_tabela();

    int N = 100; // no of random numbers to be generated
    int MIN = 1; // max range of random number
    int MAX = 5; // min range of random number
    dim3 tpb(N, 1, 1);

    
    globalInstance.setValues(100);
    

    for (int i = 1; i < 101; i++ ) {
        
        curandState* devStates;
        cudaMalloc(&devStates, N * sizeof(curandState));
        // setup seeds 
        setup_kernel << < 1, tpb >> > (devStates, time(NULL));
        cudaDeviceSynchronize();
        int* d_result, * h_result;
        cudaMalloc(&d_result, N * sizeof(int));
        h_result = (int*)malloc(N * sizeof(int));
        int* d_max, * h_max, * d_min, * h_min;
        cudaMalloc(&d_max, sizeof(int));
        h_max = (int*)malloc(sizeof(int));
        cudaMalloc(&d_min, sizeof(int));
        h_min = (int*)malloc(sizeof(int));
        *h_max = MAX;
        *h_min = MIN;
        cudaMemcpy(d_max, h_max, sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(d_min, h_min, sizeof(int), cudaMemcpyHostToDevice);
        // generate random numbers
        generate << < 1, tpb >> > (devStates, d_result, d_max, d_min, N);
        cudaDeviceSynchronize();

        cudaMemcpy(h_result, d_result, N * sizeof(float), cudaMemcpyDeviceToHost);
        globalInstance.prepareDeviceObj();
        myKernel <<<1, 100 >>> (globalInstance, d_result);
        cudaDeviceSynchronize();
        globalInstance.retrieveDataToHost();
        
        int* position = globalInstance.export_data();
        Real_Tabela.modify_variable_of(position,h_result);
        Real_Tabela.display_tabela();

        if (Real_Tabela.check_winner() == true)
            break;

        this_thread::sleep_for(chrono::milliseconds(500));
        cudaDeviceReset();
    };
    globalInstance.free_data();

    Real_Tabela.display_winner();

    return 0;
}