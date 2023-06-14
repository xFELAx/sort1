#include <iostream>
#include <cstdlib>
#include <ctime>
#include <cstring>
#include <algorithm>
#include <vector>
#include <chrono>

#define MAX_VALUE 1000 // maksymalna wartość, jaką może przyjąć element tablicy

// sortowanie przysto-nieparzyste na CUDA
__global__ void odd_even_sort(int *a, int n)
{
    int phase, temp;

    // iteracja po fazach
    for (phase = 0; phase < n; phase++)
    {
        // faza parzysta
        if (phase % 2 == 0)
        {
            // indeks biezacego bloku w watku
            // kazdy watek przetwarza tylko jeden element tablicy
            if (threadIdx.x % 2 == 0 && threadIdx.x < n - 1)
            {
                if (a[threadIdx.x] > a[threadIdx.x + 1])
                {
                    temp = a[threadIdx.x];
                    a[threadIdx.x] = a[threadIdx.x + 1];
                    a[threadIdx.x + 1] = temp;
                }
            }
        }
        // faza nieparzysta
        else
        {
            if (threadIdx.x % 2 != 0 && threadIdx.x < n - 1)
            {
                if (a[threadIdx.x] > a[threadIdx.x + 1])
                {
                    temp = a[threadIdx.x];
                    a[threadIdx.x] = a[threadIdx.x + 1];
                    a[threadIdx.x + 1] = temp;
                }
            }
        }
        __syncthreads();
    }
}

// sprawdzenie, czy tablica została poprawnie posortowana
void self_test(int *initial, int *sorted, int length)
{
    std::vector<int> initial_copy(initial, initial + length);
    std::sort(initial_copy.begin(), initial_copy.end());

    for (int i = 0; i < length; i++)
    {
        if (initial_copy[i] != sorted[i])
        {
            std::cout << "[Error] Array is not sorted" << std::endl;
            return;
        }
    }
    std::cout << "[OK] Array is sorted" << std::endl;
}

// generowanie tablicy losowych liczb
void generate_array(int *a, int size)
{
    std::srand(std::time(nullptr));

    for (int i = 0; i < size; i++)
    {
        a[i] = std::rand() % MAX_VALUE;
    }
}

// wypisanie tablicy
void print_array(int *a, int size)
{
    for (int i = 0; i < size; i++)
    {
        std::cout << a[i] << std::endl;
    }
}

int main(int argc, char **argv)
{
    if (argc != 3)
    {
        std::cout << "Error: Please provide the size of the array to sort and the number of threads to use" << std::endl;
        return -1;
    }
    // konwersja argumentów string na int
    int size = std::atoi(argv[1]);
    int threads = std::atoi(argv[2]);

    // stworzenie dynamicznej tablicy
    int *a = new int[size];
    int *initial = new int[size];

    generate_array(a, size);

    // skopiowanie tablicy 'a' do tablicy 'initial'
    std::memcpy(initial, a, size * sizeof(int));

    //printf("\nUnsorted array:\n");
    //print_array(a, size);

    // Alokacja pamięci na GPU
    int *dev_a;
    cudaMalloc((void **)&dev_a, size * sizeof(int));

    // Kopiowanie danych z CPU do GPU
    cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);

    auto start = std::chrono::high_resolution_clock::now();
    // Uruchamianie sortowania przysto-nieparzystego na GPU
    odd_even_sort<<<1, threads>>>(dev_a, size);

    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> diff = end - start;
    printf("\nTime: %f\n", diff.count());

    // Kopiowanie wyników z GPU do CPU
    cudaMemcpy(a, dev_a, size * sizeof(int), cudaMemcpyDeviceToHost);

    //printf("\nSorted array:\n");
    //print_array(a, size);
    self_test(initial, a, size);

    // Zwolnienie pamięci na GPU
    cudaFree(dev_a);

    // Zwolnienie pamięci na CPU
    delete[] a;
    delete[] initial;

    return 0;
}