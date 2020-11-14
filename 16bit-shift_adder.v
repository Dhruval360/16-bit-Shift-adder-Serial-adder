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

module shift_ff(input wire clk, reset, shift, shift_, prev_dff, d_in, output wire q);
wire t1, t2, d;
  and2 a1(prev_dff, shift, t1);
  and2 a2(d_in, shift_, t2);
  or2 o(t1, t2, d);
  dfr dff(clk, reset, in, q);
endmodule

module shift_register(input wire clk, reset, load, input wire [15:0] in, output wire out);
// This is a module for one shift register, i.e a collection of 16 D-Flip Flops
// Loads data parallely and on each clock cycle shifts the data by one bit
// load is used to identify whether data is being loaded into the register or a shift should occur
wire shift;
wire intermediate[14:0];
  invert n1 (load, shift);
  dfr d1(clk, reset, in[15], intermediate[14]);
  shift_ff d2(clk, reset, shift, load, intermediate[14], in[14], intermediate[13]);
  shift_ff d3(clk, reset, shift, load, intermediate[13], in[13], intermediate[12]);
  shift_ff d4(clk, reset, shift, load, intermediate[12], in[12], intermediate[11]);
  shift_ff d5(clk, reset, shift, load, intermediate[11], in[11], intermediate[10]);
  shift_ff d6(clk, reset, shift, load, intermediate[10], in[10], intermediate[9]);
  shift_ff d7(clk, reset, shift, load, intermediate[9], in[9], intermediate[8]);
  shift_ff d8(clk, reset, shift, load, intermediate[8], in[8], intermediate[7]);
  shift_ff d9(clk, reset, shift, load, intermediate[7], in[7], intermediate[6]);
  shift_ff d10(clk, reset, shift, load, intermediate[6], in[6], intermediate[5]);
  shift_ff d11(clk, reset, shift, load, intermediate[5], in[5], intermediate[4]);
  shift_ff d12(clk, reset, shift, load, intermediate[4], in[4], intermediate[3]);
  shift_ff d13(clk, reset, shift, load, intermediate[3], in[3], intermediate[2]);
  shift_ff d14(clk, reset, shift, load, intermediate[2], in[2], intermediate[1]);
  shift_ff d15(clk, reset, shift, load, intermediate[1], in[1], intermediate[0]);
  shift_ff d16(clk, reset, shift, load, intermediate[0], in[0], out);
endmodule

module shift_resgister_out(input wire clk, reset, in1, output wire [15:0] sum);
// This register is used to store the sum output
// in1 is the input bit received from the sum output of the fulladder
wire intermediate[14:0];  
  dfr d1(clk, reset, in1, intermediate[14]);
  dfr d2(clk, reset, intermediate[14], intermediate[13]);
  dfr d3(clk, reset, intermediate[13], intermediate[12]);
  dfr d4(clk, reset, intermediate[12], intermediate[11]);
  dfr d5(clk, reset, intermediate[11], intermediate[10]);
  dfr d6(clk, reset, intermediate[10], intermediate[9]);
  dfr d7(clk, reset, intermediate[9], intermediate[8]);
  dfr d8(clk, reset, intermediate[8], intermediate[7]);
  dfr d9(clk, reset, intermediate[7], intermediate[6]);
  dfr d10(clk, reset, intermediate[6], intermediate[5]);
  dfr d11(clk, reset, intermediate[5], intermediate[4]);
  dfr d12(clk, reset, intermediate[4], intermediate[3]);
  dfr d13(clk, reset, intermediate[3], intermediate[2]);
  dfr d14(clk, reset, intermediate[2], intermediate[1]);
  dfr d15(clk, reset, intermediate[1], intermediate[0]);
  assign sum = {in1, intermediate[14:0]};
endmodule

module shift_adder (input wire clk, reset, input wire [15:0] a, b, output wire [15:0] op, output wire carry);
  wire t1, t2, fa_out, cin, cout;
  wire load;
  shift_register a0(clk, reset, load, a, t1);
  shift_register b0(clk, reset, load, b, t2);
  dfr carry_hold(clk, reset, cout, cin); // This DFF will hold the carry to be used by the full adder in the next clock cycle
  fulladder fa(t1, t2, cin, fa_out, cout);
  assign carry = cout;
endmodule