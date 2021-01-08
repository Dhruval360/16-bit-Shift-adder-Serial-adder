# 16-bit Shiftadder(Serial adder)
This is an implementation of a 16 bit serial shift adder using verilog

## Outputs
The following output waveform is obtained when adding the numbers 22345 (0x5749) and 33705 (0x83A9)

<img src="https://github.com/Dhruval360/16-bit-Shift-adder-Serial-adder/blob/main/Images/Output%20waveforms/Hexadecimal%20Representation.png?raw=true">

## Circuit Diagram
<img src="https://github.com/Dhruval360/16-bit-Shift-adder-Serial-adder/blob/main/Images/Circuit_Diagram.png?raw=true">

## Serial Shift Register
<img src="https://github.com/Dhruval360/16-bit-Shift-adder-Serial-adder/blob/main/Images/Shift_register.png?raw=true" width="600">

## Working
A serial shift adder consists of three Shift Registers (two input registers and one output register), a D
flip flop and a Full Adder. The least significant bits of the two input registers are fed to the Full Adder
whose sum output is fed to the most significant bit location of the output shift register. The carry
generated is stored in a D Flip Flop attached to the carry output of the Full Adder. The output of this D
Flip Flop is fed as carry input to the Full Adder. All the registers and the D Flip Flop share the same
clock input and at the positive edge of each clock cycle, all the registers are shifted right by one bit.

The input registers can be loaded parallelly while the output register can only take in serial data. Each
D Flip Flop of the input registers has a corresponding 2:1 multiplexer used to choose between loading
data parallelly to them or shifting right by 1 bit. The output sum register however does not need any of
this and hence, the outputs of each D Flip Flop is directly fed as input to the next one.

Since addition takes place in a serial fashion, this adder takes n-cycles to add two n-bit numbers. In
this implementation, n is 16 and hence this adder takes 16 cycles to compute the sum of two 16 bit
numbers.

## File Structure
* **HelperModules.v** contains helper modules that are used to build the shift adder
* **16bit-ShiftAdder.v** contains the shift adder module
* **TestBench.v** is used to test the shift adder module 

## Running

Clone the repository:

```bash
$ git clone https://github.com/Dhruval360/16-bit-Shift-adder-Serial-adder.git
```

Run the testbench:

```bash
$ iverilog 16bit-ShiftAdder.v HelperModules.v TestBench.v
$ vvp ./a.out
$ gtkwave test.vcd
```