#include <iostream>
#include <cstdlib>
#include <ctime>
#include <cstring>
#include <algorithm>
#include <vector>
#include <chrono>

#define MAX_VALUE 1000 // maksymalna wartosc jaka moze przyjac element tablicy

// sortowanie przysto-nieparzyste
void odd_even_sort(int *a, int n)
{
    int phase, i, temp;

    {
        // iteracja po fazach
        for (phase = 0; phase < n; phase++)
        {
            // faza parzysta
            if (phase % 2 == 0)
            {

                for (i = 1; i < n; i += 2)
                {
                    if (a[i - 1] > a[i])
                    {
                        temp = a[i];
                        a[i] = a[i - 1];
                        a[i - 1] = temp;
                    }
                }
            }
            // faza nieparzysta
            else
            {
                for (i = 1; i < n - 1; i += 2)
                {
                    if (a[i] > a[i + 1])
                    {
                        temp = a[i];
                        a[i] = a[i + 1];
                        a[i + 1] = temp;
                    }
                }
            }
        }
    }
}

// sprawdzenie czy tablica zostala poprawnie posortowana
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
    if (argc != 2)
    {
        std::cout << "Error: Please provide the size of the array to sort." << std::endl;
        return -1;
    }
    // konwersja argumentow string na int
    int size = std::atoi(argv[1]);
    // stworzenie dynamicznych tablic
    int *a = new int[size];
    int *initial = new int[size];

    generate_array(a, size);
    // skopiowanie tablicy a do tablicy initial
    std::memcpy(initial, a, size * sizeof(int));
    //printf("\nUnsorted array:\n");
    //print_array(a, size);

    auto start = std::chrono::high_resolution_clock::now();
    odd_even_sort(a, size);
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> diff = end - start;
    printf("\nTime: %f\n", diff.count());

    //printf("\nSorted array:\n");
    //print_array(a, size);
    self_test(initial, a, size);

    delete[] a;
    delete[] initial;

    return 0;
}