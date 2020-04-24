#include<iostream>
#include<math.h>
using namespace std;

//Global variable 
unsigned long long int size;

//Function: CPU
void cpu_add(float* h_a, float* h_b, float* h_d){
    for (int i = 0; i < size; i++)
    {
        h_d[i] = h_a[i] + h_b[i];
    }
}

//Kernel: GPU
__global__ void Add(float* d_a, float* d_b, float* d_c){
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    d_c[id] = d_a[id] + d_b[id];
}


int main(){
    //Init GPU pointers
    float *d_a = NULL;
    float *d_b = NULL;
    float *d_c = NULL;

    cout << "Enter number of elements: "; cin >> size;
    //Init input arrays
    float h_a[size], h_b[size], h_c[size], h_d[size];
    
    //Log arrays
    cout << "\nEnter " << size << " numbers for array A " << endl;
    for(int i = 0; i < size; i++){
        cin >> h_a[i];
    }
    cout << "\nEnter " << size << " numbers for array B " << endl;
    for(int i = 0; i < size; i++){
        cin >> h_b[i];
    }

    //Display arrays
    cout << "\nArray A logged: " << endl;
    for(int i = 0; i < size; i++){
        cout << h_a[i] << "  ";
    }
    cout << "\n\nArray B logged: " << endl;
    for(int i = 0; i < size; i++){
        cout << h_b[i] << "  ";
    }

    // Computing using CPU
    cpu_add(h_a, h_b, h_d);

    //CPU result
    cout << "\n\nCPU Result" << endl;
    for (int i = 0; i < size; i++)
    {
        cout << h_d[i] << "  ";
    }

    //Computing using GPU    
    //Allocating memory in GPU pointed by d_x (x=a,b,c)
    int arr_bytes = size * sizeof(float);
    cudaMalloc((void**)&d_a, arr_bytes);
    cudaMalloc((void**)&d_b, arr_bytes);
    cudaMalloc((void**)&d_c, arr_bytes);

    // Copying CPU -->  GPU memory
    cudaMemcpy(d_a, h_a, arr_bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, arr_bytes, cudaMemcpyHostToDevice);

    //Kernel call; Block: b, Threads: 1024 (max possible)
    //b = upper_ceil(1.0*size/1024)
    
    Add<<< ceil(1.0*size/1024), 1024 >>>(d_a, d_b, d_c);

    //Copying GPU --> CPU memory
    cudaMemcpy(h_c, d_c, arr_bytes, cudaMemcpyDeviceToHost);

    //GPU Result 
    cout << "\n\nGPU Result" << endl;
    for(int i = 0;i < size; i++){
        cout << h_c[i] << " ";
    }

    //De-allocating memory
    cudaFree(d_a); cudaFree(d_b); cudaFree(d_c); 
}