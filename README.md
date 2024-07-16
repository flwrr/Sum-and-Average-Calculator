# Sum and Average Calculator
As an exercise to explore the differences between integer and floating-point arithmetic in assembly, this program calculates the sums and averages of 10 imput integers using the CPU and 10 input floating-point numbers using the [FPU](https://en.wikipedia.org/wiki/Floating-point_unit). For both, the program first converts user input from strings to numbers while validating input, then calculates their sum and average, finally displaying formatted results for 10 input values.



## :large_orange_diamond: Run Example - Integers
This portion of the program is fairly straightforward and is capable of processing the full range of 32-bit signed integers from -2,147,483,648 to 2,147,483,647. The most challenging aspect was parsing + and - signs from input, and the logic of deciding when to and when not to display them to the user (e.g., not -0 nor +0).

![Calc_Integers-crop](https://github.com/user-attachments/assets/0f27d696-5ed5-4d83-8f13-b2df10b30e05)


## :fish: Run Example - Floating Point Numbers
Using the FPU, this portion of the program accepts signed inputs with up to 5 decimal places. A very memorable lesson on floating-point arithmetic and floating-point errors. Working with the FPU and fixing rounding errors without looking much up was a challenging exercise.

![Calc_FloatingPoint](https://github.com/user-attachments/assets/0888abb5-ab1b-4897-adca-8d8afcbe87e8)
