#include <iostream>
using namespace std;

__global__ void Min(int* d_a, int* d_b, int size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
    int t_id = threadIdx.x;
    int b_id = blockIdx.x;

	__shared__ int a[1024];

    if(id < size)
     a[t_id] = d_a[id];    

	__syncthreads();

	for(int s = 512; s>0; s = s/2)
    {
        __syncthreads();
        if(id>=size || id+s>=size)
            continue;
        if(t_id<s)
            {
               if(a[t_id] > a[t_id + s])
                a[t_id]= a[t_id + s];
            }
    }
    __syncthreads();

	 if(t_id==0)
        d_b[b_id] = a[t_id];   
}

__global__ void Max(int* d_a, int* d_b, int size)
{
    int id = blockIdx.x * blockDim.x + threadIdx.x;
	int t_id = threadIdx.x;
    int b_id = blockIdx.x;

	__shared__ int a[1024];

    if(id < size)
     a[t_id] = d_a[id];    

	__syncthreads();

	for(int s = 512; s>0; s = s/2)
    {
        __syncthreads();
        if(id>=size || id+s>=size)
            continue;
        if(t_id<s)
            {
               if(a[t_id] < a[t_id + s])
                a[t_id] = a[t_id + s];
            }
    }
    __syncthreads();

	 if(t_id==0)
        d_b[b_id] = a[t_id];   
}

int main() 
{
    int size;
    cin>>size;
    int h_a[size], h_min, h_max;
    int bytes=size*sizeof(int);
    int length=(int)ceil(1.0*size/1024);
    for(int i=0;i<size;i++)
    {
        h_a[i]=i+1;
    }
    int *d_a, *d_b, *d_min, *d_max;
    cudaMalloc((void**)&d_b, bytes);
    cudaMalloc((void**)&d_a, bytes);
    cudaMalloc((void**)&d_min, sizeof(int));
    cudaMalloc((void**)&d_max, sizeof(int));
    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
    
        Min<<<((int)ceil(1.0*size/1024)), 1024>>>(d_a, d_b, size);
	Min<<<1, 1024>>>(d_b, d_min, length);
	
	Max<<<((int)ceil(1.0*size/1024)), 1024>>>(d_a, d_b, size);
	Max<<<1, 1024>>>(d_b, d_max, length);
	
	cudaMemcpy(&h_min, d_min, sizeof(int), cudaMemcpyDeviceToHost);
	cudaMemcpy(&h_max, d_max, sizeof(int), cudaMemcpyDeviceToHost);

	int min=h_a[0], max=h_a[0];
	for(int i=1;i<size;i++)
	{
	    if(h_a[i]<min)
		min=h_a[i];
	    if(h_a[i]>max)
         	max=h_a[i];
	}

	if(h_min==min && h_max==max)
	cout<<"correct result";
	else
        cout<<"Invalid";
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_max);
	cudaFree(d_min);
}