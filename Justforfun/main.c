#include <stdio.h>
#include <stdlib.h> // For exit()

// This is just made for FUN!

// Function to calculate the factorial of a number
long long int factorial(int n) {
    // Check for negative input
    if (n < 0) {
        printf("Error: Factorial of a negative number cannot be calculated.\\n");
        exit(1); // Exit the program on error
    }
    // Base case
    if (n == 0 || n == 1) {
        return 1;
    }

    long long int result = 1;
    // Iterate from 2 to n to calculate the factorial
    for (int i = 2; i <= n; i++) {
        // Simple overflow check (can be more robust, but good for an example)
        long long int temp = result * i;
        if (temp / i != result) {
            printf("Error: Factorial calculation overflowed for input %d.\\n", n);
            exit(1);
        }
        result = temp;
    }
    return result;
}

// Function to print a separator line for better output formatting
void print_separator() {
    printf("----------------------------------------\\n");
}

int main() {
    int num_inputs;
    printf("Enter the number of factorials you want to calculate: ");
    // Use %d for standard integer input
    if (scanf("%d", &num_inputs) != 1 || num_inputs <= 0) {
        printf("Invalid input. Please enter a positive integer.\\n");
        return 1;
    }

    // Use a dynamically sized array (C99 feature) to store inputs
    int numbers[num_inputs];

    printf("Enter %d non-negative integers (up to ~20 for best results):\\n", num_inputs);
    for (int i = 0; i < num_inputs; i++) {
        printf("Number %d: ", i + 1);
        if (scanf("%d", &numbers[i]) != 1 || numbers[i] < 0) {
            printf("Invalid input. Please enter a non-negative integer.\\n");
            return 1;
        }
    }

    print_separator();
    printf("FACTORIAL RESULTS:\\n");
    print_separator();

    for (int i = 0; i < num_inputs; i++) {
        int current_num = numbers[i];
        long long int fact = factorial(current_num);
        // Use %lld for long long int output
        printf("Factorial of %d is %lld\\n", current_num, fact);
    }

    print_separator();
    printf("Program finished successfully.\\n");

    return 0;
}
