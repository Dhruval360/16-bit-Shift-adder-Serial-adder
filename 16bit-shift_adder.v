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

module fa (input wire i0, i1, cin, output wire sum, cout); // 1 bit full adder
   wire t0, t1, t2;
   xor3 _i0 (i0, i1, cin, sum);
   and2 _i1 (i0, i1, t0);
   and2 _i2 (i1, cin, t1);
   and2 _i3 (cin, i0, t2);
   or3 _i4 (t0, t1, t2, cout);
endmodule

module shift_dff(input wire clk, reset, shift, shift_, load, prev_dff, d_in, output wire q);
    wire t1, t2, d;
    and2 a1(prev_dff, shift, t1);
    and2 a2(d_in, shift_, t2);
    or2 o(t1, t2, d);
    dfrl dff(clk, reset, load, in, q);
endmodule

module shift_register(input wire clk, reset, load, load0, input wire [15:0] in, output wire out);
// This is a module for one shift register, i.e a collection of 16 D-Flip Flops
// Loads data parallely and on each clock cycle shifts the data by one bit
// load0 is used to identify which register is being written to while inputing the data parallely
	wire shift;
    wire intermediate[14:0];
    invert n1 (load, shift);
    dfrl d1(clk, reset, load0, in[15], intermediate[14]);
    shift_dff d2(clk, reset, shift, load, load0, intermediate[14], in[14], intermediate[13]);
    shift_dff d3(clk, reset, shift, load, load0, intermediate[13], in[13], intermediate[12]);
    shift_dff d4(clk, reset, shift, load, load0, intermediate[12], in[12], intermediate[11]);
    shift_dff d5(clk, reset, shift, load, load0, intermediate[11], in[11], intermediate[10]);
    shift_dff d6(clk, reset, shift, load, load0, intermediate[10], in[10], intermediate[9]);
    shift_dff d7(clk, reset, shift, load, load0, intermediate[9], in[9], intermediate[8]);
    shift_dff d8(clk, reset, shift, load, load0, intermediate[8], in[8], intermediate[7]);
    shift_dff d9(clk, reset, shift, load, load0, intermediate[7], in[7], intermediate[6]);
    shift_dff d10(clk, reset, shift, load, load0, intermediate[6], in[6], intermediate[5]);
    shift_dff d11(clk, reset, shift, load, load0, intermediate[5], in[5], intermediate[4]);
    shift_dff d12(clk, reset, shift, load, load0, intermediate[4], in[4], intermediate[3]);
    shift_dff d13(clk, reset, shift, load, load0, intermediate[3], in[3], intermediate[2]);
    shift_dff d14(clk, reset, shift, load, load0, intermediate[2], in[2], intermediate[1]);
    shift_dff d15(clk, reset, shift, load, load0, intermediate[1], in[1], intermediate[0]);
    shift_dff d16(clk, reset, shift, load, load0, intermediate[0], in[0], out);
endmodule
