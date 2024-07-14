# Sum and Average Calculator
This assembly language program calculates sums and averages using both the CPU and FPU for integer and floating-point numbers. It first converts user input from strings to numbers while validating input, then calculates their sum and average, finally displaying formatted results for 10 input values.



## :large_orange_diamond: Run Example - Integers
This portion of the program is fairly straightforward and is capable of processing the full range of 32-bit signed integers from -2,147,483,648 to 2,147,483,647. The most challenging aspect was parsing + and - signs from input, and the logic of deciding when to and when not to display them to the user (e.g., not -0 nor +0).

![Calc_Integers](https://github.com/user-attachments/assets/26ff24a2-c0c0-4376-83e0-af3a01739524)



## :fish: Run Example - Floating Point Numbers
Using the FPU, this portion of the program accepts signed inputs with up to 5 decimal places. A very memorable lesson on floating-point arithmetic and floating-point errors. Working with the FPU and fixing rounding errors without looking much up was a challenging exercise.

![Calc_FloatingPoint](https://github.com/user-attachments/assets/0888abb5-ab1b-4897-adca-8d8afcbe87e8)
