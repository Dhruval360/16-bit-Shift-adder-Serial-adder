`timescale 1 ns / 100 ps
module tb;
    reg clk, reset, load;
    reg [15:0] a, b, out;

    wire [15:0] op, contents_a, contents_b;
    wire carry;

    shift_adder addr(clk, reset, load, a, b, contents_a, contents_b, op, carry);
    
    initial begin $dumpfile("test.vcd"); $dumpvars(0,tb); end
    initial begin
        reset = 1'b1; 
        load = 1'b0;
        #5
        reset = 1'b0;
        load = 1'b1;
        a = 16'b0101011101001001; // Loading a number into register a
        b = 16'b1000001110101001; // Loading a number into register b
        #5
        load = 1'b0;
        #160 $finish;
    end
    initial clk = 1'b1; always #5 clk =~ clk;
endmodule