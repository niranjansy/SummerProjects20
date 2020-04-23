#include<iostream>
using namespace std;

__global__ void Add(float *array1, float *array2, float *out,unsigned int *i)
{
	int id = blockIdx.x * blockDim.x + threadIdx.x + *i;
	out[id] = array1[id] + array2[id];
	
}

int main()
{
	unsigned int array_Size, bigBlock = 1024*1024;
		
	cout << "Enter the size of Array: ";
	cin >> array_Size;

	float h_array1[array_Size], h_array2[array_Size], h_out[array_Size];
	
	int array_Bytes = array_Size * sizeof(float);

	for(int i=0;i<array_Size;i++)
		h_array1[i] = i;

	for(int i=1,j=0;j<array_Size;j++){
		h_array2[j] = i;
		
	}

	float *d_array1, *d_array2, *d_out;
	unsigned int *d_i;
	
	cudaMalloc((void**)&d_array1, array_Bytes);
	cudaMalloc((void**)&d_array2,array_Bytes);
	cudaMalloc((void**)&d_out,array_Bytes);
	cudaMalloc((void**)&d_i,sizeof(int));
	
	cudaMemcpy(d_array1, h_array1, array_Bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_array2, h_array2, array_Bytes, cudaMemcpyHostToDevice);
	
	if(array_Size > bigBlock)
	for(unsigned int *i=0;*i>=array_Size + bigBlock;*i+=bigBlock)
	{
		cudaMemcpy(d_i, i, sizeof(int), cudaMemcpyHostToDevice);
		Add<<<1024,1024>>>(d_array1, d_array2, d_out, d_i);
	}
	else
	{
		cudaMemcpy(d_i, 0, sizeof(int), cudaMemcpyHostToDevice);
		Add<<<ceil(1.0*array_Size/1024),1024>>>(d_array1, d_array2, d_out, d_i);
	}
	cudaError e = cudaMemcpy(h_out, d_out, array_Bytes, cudaMemcpyDeviceToHost);
	
	if(e!=cudaSuccess)
        	cout <<"CUDA error copying to Host: " << cudaGetErrorString(e) << endl;
	
	for(int i=0;i<array_Size;i++)
		cout<< i << ". " << h_out[i] << "\n";
	
	cudaFree(d_array1);
	cudaFree(d_array2);
	cudaFree(d_out); 
	cudaFree(d_i);

}