module invert (input wire i, output wire o);
  assign o = !i;
endmodule

module and2 (input wire i0, i1, output wire o);
  assign o = i0 & i1;
endmodule

module or2 (input wire i0, i1, output wire o);
  assign o = i0 | i1;
endmodule

module or3 (input wire i0, i1, i2, output wire o);
  wire t;
  or2 or2_0 (i0, i1, t);
  or2 or2_1 (i2, t, o);
endmodule

module xor2 (input wire i0, i1, output wire o);
  assign o = i0 ^ i1;
endmodule

module xor3 (input wire i0, i1, i2, output wire o);
  wire t;
  xor2 xor2_0 (i0, i1, t);
  xor2 xor2_1 (i2, t, o);
endmodule

module mux2 (input wire i0, i1, j, output wire o);
  assign o = (j==0)?i0:i1;
endmodule

module df (input wire clk, in, output wire out);
  reg df_out;
  always@(posedge clk) df_out <= in;
  assign out = df_out;
endmodule

module dfr (input wire clk, reset, in, output wire out);
  wire reset_, df_in;
  invert invert_0 (reset, reset_);
  and2 and2_0 (in, reset_, df_in);
  df df_0 (clk, df_in, out);
endmodule

module dfrl (input wire clk, reset, load, in, output wire out);
wire _in;
  mux2 mux2_0(out, in, load, _in);
  dfr dfr_1(clk, reset, _in, out);
endmodule

module fulladder (input wire i0, i1, cin, output wire sum, cout); // 1 bit full adder
wire t0, t1, t2;
  xor3 _i0 (i0, i1, cin, sum);
  and2 _i1 (i0, i1, t0);
  and2 _i2 (i1, cin, t1);
  and2 _i3 (cin, i0, t2);
  or3 _i4 (t0, t1, t2, cout);
endmodule

module shift_ff(input wire clk, reset, shift, prev_dff, d_in, output wire q);
  mux2 m(d_in, prev_dff, shift, in); // To select between shift and load operations
  dfrl ff(clk, reset, 1'b1, in, q);
endmodule

module shift_register(input wire clk, reset, load, input wire [15:0] in, 
                      output wire out_bit, output wire [15:0] contents);
// This is a module for one shift register, i.e a collection of 16 D-Flip Flops
// Loads data parallely and on each clock cycle shifts the data by one bit
// load is used to identify whether data is being loaded into the register or a shift should occur
// out_bit is the least significant bit of the the register that is used by the full adder to perform addition
wire shift; // This will be the inverse of the load input
wire intermediate[14:0]; 
  invert n1 (load, shift);
  shift_ff d1(clk, reset, shift, 1'b0, in[15], intermediate[14]);
  shift_ff d2(clk, reset, shift, intermediate[14], in[14], intermediate[13]);
  shift_ff d3(clk, reset, shift, intermediate[13], in[13], intermediate[12]);
  shift_ff d4(clk, reset, shift, intermediate[12], in[12], intermediate[11]);
  shift_ff d5(clk, reset, shift, intermediate[11], in[11], intermediate[10]);
  shift_ff d6(clk, reset, shift, intermediate[10], in[10], intermediate[9]);
  shift_ff d7(clk, reset, shift, intermediate[9], in[9], intermediate[8]);
  shift_ff d8(clk, reset, shift, intermediate[8], in[8], intermediate[7]);
  shift_ff d9(clk, reset, shift, intermediate[7], in[7], intermediate[6]);
  shift_ff d10(clk, reset, shift, intermediate[6], in[6], intermediate[5]);
  shift_ff d11(clk, reset, shift, intermediate[5], in[5], intermediate[4]);
  shift_ff d12(clk, reset, shift, intermediate[4], in[4], intermediate[3]);
  shift_ff d13(clk, reset, shift, intermediate[3], in[3], intermediate[2]);
  shift_ff d14(clk, reset, shift, intermediate[2], in[2], intermediate[1]);
  shift_ff d15(clk, reset, shift, intermediate[1], in[1], intermediate[0]);
  shift_ff d16(clk, reset, shift, intermediate[0], in[0], out_bit);
  assign contents = {intermediate[14], intermediate[13], intermediate[12], intermediate[11], intermediate[10], intermediate[9], 
                     intermediate[8], intermediate[7], intermediate[6], intermediate[5], intermediate[4], intermediate[3], 
                     intermediate[2], intermediate[1], intermediate[0], out_bit};
endmodule

module shift_resgister_out(input wire clk, reset, in1, output wire [15:0] sum);
// This register is used to store the sum output
// in1 is the input bit received from the sum output of the fulladder
wire intermediate[14:0];  
  dfrl d1(clk, reset, 1'b1, in1, intermediate[14]);
  dfrl d2(clk, reset, 1'b1, intermediate[14], intermediate[13]);
  dfrl d3(clk, reset, 1'b1, intermediate[13], intermediate[12]);
  dfrl d4(clk, reset, 1'b1, intermediate[12], intermediate[11]);
  dfrl d5(clk, reset, 1'b1, intermediate[11], intermediate[10]);
  dfrl d6(clk, reset, 1'b1, intermediate[10], intermediate[9]);
  dfrl d7(clk, reset, 1'b1, intermediate[9], intermediate[8]);
  dfrl d8(clk, reset, 1'b1, intermediate[8], intermediate[7]);
  dfrl d9(clk, reset, 1'b1, intermediate[7], intermediate[6]);
  dfrl d10(clk, reset, 1'b1, intermediate[6], intermediate[5]);
  dfrl d11(clk, reset, 1'b1, intermediate[5], intermediate[4]);
  dfrl d12(clk, reset, 1'b1, intermediate[4], intermediate[3]);
  dfrl d13(clk, reset, 1'b1, intermediate[3], intermediate[2]);
  dfrl d14(clk, reset, 1'b1, intermediate[2], intermediate[1]);
  dfrl d15(clk, reset, 1'b1, intermediate[1], intermediate[0]);
  assign sum = {in1, intermediate[14], intermediate[13], intermediate[12], intermediate[11], intermediate[10],
                intermediate[9], intermediate[8], intermediate[7], intermediate[6], intermediate[5], 
                intermediate[4], intermediate[3], intermediate[2], intermediate[1], intermediate[0]};
endmodule

module shift_adder (input wire clk, reset, load, input wire [15:0] a, b, 
                    output wire [15:0] contents_a, contents_b, op, output wire carry);
// This is the serial shift adder module
// It takes two 16 bit numbers a and b as input and loads them to the shift registers a and b  
// Their content is monitored using the output wires contents_a and contents_b respectively
// op is the output shift register where the output gets stored
// The full adder adds the LSBs of a and b at every clock cycle and pushes it onto the output shift register
// A DFF is used to hold the carry generated by the fulladder and this is fed back to the fulladder in the next clock cycle
  wire t1, t2, fa_out, cin, cout;
  shift_register a0(clk, reset, load, a, t1, contents_a);
  shift_register b0(clk, reset, load, b, t2, contents_b);
  fulladder fa(t1, t2, cin, fa_out, cout);
  dfrl carry_hold(clk, reset, 1'b1, cout, cin); // This DFF will hold the carry to be used by the full adder in the next clock cycle
  shift_resgister_out ans(clk, reset, fa_out, op);
  assign carry = cout;
endmodule
