////////////////////////////////////////////////////////////////////////////////////////////////////
//
//	File: FunctionUnitAndBus.v
// Top-level file for Function Unit and Bus System (LE C.3)
//
// Created by J.S. Thweatt, 4 November 2019
// Based on BusControl module by Addison Ferrari
//
// The FunctionUnitandBus module should contain both your function unit and your bus control logic.
//
// Modified by: KLC, 14 Jan 2026 - switch mapping
// 
////////////////////////////////////////////////////////////////////////////////////////////////////

// DO NOT MODIFY THE MODULE AND PORT DECLARATIONs OF THIS MODULE!

module FunctionUnitAndBus(MAX10_CLK1_50, KEY, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);
	input  MAX10_CLK1_50;												// System clock
	input  [1:0] KEY;													// DE10 Pushbuttons
	input  [9:0] SW;													// DE10 Switches 
	output [6:0] HEX0;													// DE10 Seven-segment displays
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
// END MODULE AND PORT DECLARATION

// BEGIN WIRE DECLARATION
	
// Buttons is the output of a Finite State Machine.
	output [9:0] LEDR;												// DE10 LEDs

// Each time that one of the DE10 pushbuttons is pressed and released, the corresponding value of BUTTONS goes high for one clock period.
//	This ensures that a single press and release of a pushbutton enables only one register transfer.
// YOU MUST USE THE VALUES FROM BUTTONS INSTEAD OF THE VALUES FROM KEY IN YOUR IMPLEMENTATION.
	
	wire [1:0] buttons;												// DO NOT MODIFY!

// These values represent the register states.
// The synthesis keep directive will allow you to view these wires in simulation.

	wire [7:0] val0 /* synthesis keep */ ;						// DO NOT MODIFY!
	wire [7:0] val1 /* synthesis keep */ ;						// DO NOT MODIFY!
	wire [7:0] val2 /* synthesis keep */ ;						// DO NOT MODIFY!
	wire [7:0] val3 /* synthesis keep */ ;						// DO NOT MODIFY!

// These values represent the inputs of your Function Unit.
// YOU MUST USE THESE NAMES AS THE INPUTS OF YOUR FUNCTION UNIT IN THE INSTANCE YOU PLACE INTO THE TOP-LEVEL MODULE!
// YOU MUST USE THESE NAMES AS THE OUTPUTS OF THE OPERAND BUSES.

	wire [7:0] operandA /* synthesis keep */ ;				// DO NOT MODIFY!
	wire [7:0] operandB /* synthesis keep */ ;				// DO NOT MODIFY!
	
// This value represents the outputs of your Function Unit.
// YOU MUST USE result AS THE RESULT OUTPUT OF YOUR FUNCTION UNIT IN THE INSTANCE YOU PLACE INTO THE TOP-LEVEL MODULE!
// YOU MUST USE V, C, N and Z AS THE STATUS OUTPUTS OF YOUR FUNCTION UNIT IN THE INSTANCE YOU PLACE INTO THE TOP-LEVEL MODULE!
	
	wire [7:0] result /* synthesis keep */ ;					// DO NOT MODIFY!
	wire V, C, N, Z  /* synthesis keep */ ;					// DO NOT MODIFY!

// This value represents the output of the bus that loads the registers.

	wire [7:0] bus, transfer, function_out /* synthesis keep */ ; 						// DO NOT MODIFY!
	
// You MAY alter this wire declarations if you wish, or even delete it entirely.
// What you replace it with will depend on your design.
	
// Add your other wire declarations here

	wire w0_load, w1_load, w2_load, w3_load, w0_transfer, w1_transfer, w2_transfer, w3_transfer, w0, w1, w2, w3;

// Add your other wire declarations here

// END WIRE DECLARATION
	
// BEGIN TOP-LEVEL HARDWARE MODEL //
		
// Review the hardware description for the buttonpress module in buttonpress.v.
// Use BUTTONS as the control signal for your hardware instead of KEY.
//	This ensures that a single press and release of a pushbutton enables only one register transfer.
// DO NOT CHANGE THESE INSTANTIATIONS!

//                System clock   Pushbutton  Enable
	buttonpress b1(MAX10_CLK1_50, KEY[1],     buttons[1]);
	buttonpress b0(MAX10_CLK1_50, KEY[0],     buttons[0]);
	
// Review the hardware description for the register module in register8bit.v
// YOU MAY CHANGE THE LOAD CONTROL as needed by the system you are trying to implement.
// Unlike LE D, you may NOT change the REGISTER INPUTS.
// DO NOT CHANGE THE CLOCK SOURCE, THE REGISTER INPUTS, OR THE REGISTER OUTPUTS!

//                 System clock   Load control  Register inputs  Register outputs      
//                 DO NOT CHANGE  CHANGE        DO NOT CHANGE    DO NOT CHANGE
	register8bit r0(MAX10_CLK1_50, w0,         bus,             val0);
	register8bit r1(MAX10_CLK1_50, w1,         bus,             val1);
	register8bit r2(MAX10_CLK1_50, w2,         bus,             val2);
	register8bit r3(MAX10_CLK1_50, w3,         bus,             val3);

// Instantiate your bus hardware here. You may also use continuous assignments as needed.
// - The inputs of your operand buses are the register outputs (val#)
// - The outputs of your operand buses MUST BE wires called operandA and operandB.
// - The bus for operandA is controlled by SW[3:2]: 00 - r0; 01 - r1; 10 - r2; 11 - r3.
// - The bus for operandB is controlled by SW[1:0]: 00 - r0; 01 - r1; 10 - r2; 11 - r3.
// - The destination is controlled by SW[9:8]: 00 - r0; 01 - r1; 10 - r2; 11 - r3.

	load_function key0(w0_load, w1_load, w2_load, w3_load, SW[9:8], buttons);	
	transfer_function key1(w0_transfer, w1_transfer, w2_transfer, w3_transfer, SW[9:8], buttons);
	operand_select operandSelect(operandA, operandB, val0, val1, val2, val3, SW[3:2], SW[1:0]);
	
	assign w0 = w0_load | w0_transfer;
	assign w1 = w1_load | w1_transfer;
	assign w2 = w2_load | w2_transfer;
	assign w3 = w3_load | w3_transfer;

// Instantiate your FUNCTION UNIT here.
// - The inputs of the instance MUST BE wires called operandA and operandB.
// - The result output of the instance MUST BE a wire called result.
// - The status outputs of the instance MUST be wires called V, C, N, Z.
// - The operation performed by the Function unit is controlled by SW[7:4].

	function_unit functionUnit(result, V, C, N, Z, operandA, operandB, SW[7:4]);

// This instance of the 8-bit 2-to-1 multiplexer buses the switches and the Function Unit result to the registers.
// - The destination register should receive the result from the Function Unit when KEY1 is pressed.
// - The destination register should receive the value from SW[7:0] when KEY0 is pressed.
// DO NOT CHANGE THIS INSTANTIATION!

   mux2to1_8bit m1(buttons[0], result, SW[7:0], bus);		

// Review the hardware description for the hexDecoder_7seg module in hexDecoder_7seg.v.
// HEX5/HEX4 must display the value of OperandA, which also comes from your operand bus.
// HEX3/HEX2 must display the value of OperandB, which also comes from your operand bus.
// HEX1/HEX0 must display the result output of the function unit.
// DO NOT CHANGE THESE INSTANTIATIONS!

//                    Upper Hex Display  Lower Hex Display  Register Value
	hexDecoder_7seg h1(HEX5,              HEX4,              operandA);
	hexDecoder_7seg h2(HEX3,              HEX2,              operandB);
	hexDecoder_7seg h3(HEX1,              HEX0,              result);

	
// The LEDs must display the status output of the Function Unit
// DO NOT CHANGE THIS CONTINUOUS ASSIGNMENT! 

	assign LEDR = {6'b000000, V, C, N, Z};
	
// END TOP-LEVEL HARDWARE MODEL //

endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//	Module: mux2to1_8bit
// 8-bit 2-to-1 multiplexer for use in the top-level module
//
//	Created by Jason Thweatt, 04 November 2019
//
// **************************
// DO NOT MODIFY THIS MODULE!
// **************************
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module mux2to1_8bit(select, in0, in1, out);
   input        select;
   input  [7:0] in0;
   input  [7:0] in1;
   output [7:0] out;
	
	assign out = (select == 1'b0) ? in0 :
	             (select == 1'b1) ? in1 : 8'bxxxxxxxx;

endmodule

// Write the remaining hardware models that you instantiate into the top-level module starting here.

module tsg_8bit(in, en, out);
   input  [7:0] in;		// 8-bit input
   input        en;		// Enable bit
   output [7:0] out;		// 8-bit output

	bufif1 BUF0(out[0], in[0], en);
	bufif1 BUF1(out[1], in[1], en);
	bufif1 BUF2(out[2], in[2], en);
	bufif1 BUF3(out[3], in[3], en);
	bufif1 BUF4(out[4], in[4], en);
	bufif1 BUF5(out[5], in[5], en);
	bufif1 BUF6(out[6], in[6], en); 
	bufif1 BUF7(out[7], in[7], en);

endmodule 

module decoder(A, B, C, D, S);
	input [1:0] S;
	output A, B, C, D;
	
	wire en;
	assign en = 1'b1;
	
	assign A = (en & (~S[1] & ~S[0]));
	assign B = (en & (~S[1] & S[0]));
	assign C = (en & (S[1] & ~S[0]));
	assign D = (en & (S[1] & S[0]));
	
endmodule

module load_function(r0, r1, r2, rL, S, button);
	input [1:0] S, button;
	output r0, r1, r2, rL;
	
	wire w0, w1, w2, wL;
	
	decoder de1(w0, w1, w2, wL, S);
	
	assign r0 = w0 & button[0];
	assign r1 = w1 & button[0];
	assign r2 = w2 & button[0];
	assign rL = wL & button[0];
	
endmodule

module operand_select(OpA, OpB, r0, r1, r2, r3, a_sel, b_sel);
	input [7:0] r0, r1, r2, r3;
	input [1:0] a_sel, b_sel;
	output [7:0] OpA, OpB;
	
	wire w0, w1, w2, w3, w4, w5, w6, w7, en0, en1, en2, en3, en4, en5, en6, en7;
	
	decoder ASELECT(w0, w1, w2, w3, a_sel);
	decoder BSELECT(w4, w5, w6, w7, b_sel);
	
	tsg_8bit(r0, w0, OpA);
	tsg_8bit(r1, w1, OpA);
	tsg_8bit(r2, w2, OpA);
	tsg_8bit(r3, w3, OpA);
	tsg_8bit(r0, w4, OpB);
	tsg_8bit(r1, w5, OpB);
	tsg_8bit(r2, w6, OpB);
	tsg_8bit(r3, w7, OpB);
	
endmodule

module transfer_function(rA, rB, rC, rL, destination, button);
	input [1:0] destination, button;
	output rA, rB, rC, rL;
	
	wire dA, dB, dC, dL;
	
	decoder de3(dA, dB, dC, dL, destination);

	assign rA = dA & button[1];
	assign rB = dB & button[1];
	assign rC = dC & button[1];
	assign rL = dL & button[1];
	
endmodule

module function_unit (result, V, C, N, Z, OpA, OpB, FS);
  input [3:0] FS;
  input [7:0] OpA, OpB;
  output [7:0] result;
  output V, C, N, Z;

    // Replace these assign statements with your Verilog code.
    // The operation of the arithmetic circuit is defined in the  specification.
	wire carry, cout;
	wire w0, w1, w2;
	wire [7:0] sel0, sel1, sel2;
	
	
	// 0100 movA, 0011 add, 0010 subAB, 0001 incA, 0101 negB, 0110 dec3B
	assign w2 = (~FS[3] & ~FS[1]) | (~FS[3] & ~FS[2]) | (FS[2] & FS[1] & ~FS[0]);
	// 1010 shift, 1011 div4, 1100 mult16
	assign w1 = (FS[3] & ~FS[2] & FS[1]) | (FS[3] & FS[2] & ~FS[1] & ~FS[0]);
	// 0111 AND, 1000 OR, 1001 XOR, 1101 XNOR
	assign w0 = (FS[3] & ~FS[2] & ~FS[1]) | (FS[3] & ~FS[1] & FS[0]) | (~FS[3] & FS[2] & FS[1] & FS[0]);

	block2 arith(sel2, carry, cout, FS, OpA, OpB);
	block1 misc(sel1, OpA, OpB, FS);
	block0 logic(sel0, OpA, OpB, FS);

	assign result = (w2 == 1'b1) ? sel2 :
					(w1 == 1'b1) ? sel1 :
					(w0 == 1'b1) ? sel0 : 8'bx;
  
	assign V = carry ^ cout;
	assign C = ~(carry ^ cout);
	assign N = result[7];
	assign Z = ~result[7] & ~result[6] & ~result[5] & ~result[4] & ~result[3] & ~result[2] & ~result[1] & ~result[0];
endmodule

module block2(result, carry, cout, sel, A, B);
	input [7:0] A, B;
	input [3:0] sel;
	output [7:0] result;
	output carry, cout;

	wire [7:0] w1, w2;
	wire [1:0] sA, sB;
	wire cin;
	wire [7:0] eight_one, eight_zero, neg3;

	// Constants
	assign eight_one = 8'b11111111;
	assign eight_zero = 8'b00000000;
	assign neg3 = 8'b11111101;

	assign sA[1] = ~sel[3] & sel[2] & sel[1] & ~sel[0];
	assign sA[0] = ~sel[3] & sel[2] & ~sel[1] & sel[0];
	assign sB[1] = (~sel[3] & sel[2] & ~sel[1] & ~sel[0]) | (~sel[3] & ~sel[2] & ~sel[1] & sel[0]);
	assign sB[0] = (~sel[3] & ~sel[2] & sel[1] & ~sel[0]) | (~sel[3] & sel[2] & ~sel[1] & sel[0]);
	assign cin = (~sel[3] & ~sel[2] & sel[1] & ~sel[0]) | (~sel[3] & ~sel[2] & ~sel[1] & sel[0]) | (~sel[3] & sel[2] & ~sel[1] & sel[0]);
		
	mux4x1 MUXA(w1, sA, A, eight_zero, neg3,  eight_one);
	mux4x1 MUXB(w2, sB, B, ~B, eight_zero, eight_one);   

	eightbitadder main(result, w1, w2, carry, cout, cin);
endmodule

module full_adder(s, c, a, b, cin);
	input a, b, cin;
	output s, c;

	assign s = a ^ b ^ cin;
	assign c = a & b | (cin & (a ^ b)); 
endmodule
 
module eightbitadder(S, A, B, C7, C8, C0);
	input [7:0] A, B;
	input C0;
	output [7:0] S;
	output C7, C8;
	wire c1, c2, c3, c4, c5, c6, c7;

	full_adder fA0(S[0], c1, A[0], B[0], C0);
	full_adder fA1(S[1], c2, A[1], B[1], c1);
	full_adder fA2(S[2], c3, A[2], B[2], c2);
	full_adder fA3(S[3], c4, A[3], B[3], c3);
	full_adder fA4(S[4], c5, A[4], B[4], c4);
	full_adder fA5(S[5], c6, A[5], B[5], c5);
	full_adder fA6(S[6], c7, A[6], B[6], c6);
	full_adder fA7(S[7], C8, A[7], B[7], c7);
	
	assign C7 = c7;
endmodule 

module mux4x1(F, S, X1, X2, X3, X4);
	input [1:0] S;
	input [7:0] X1, X2, X3, X4;
	output [7:0] F;
	
	assign F = (S == 2'b00) ? X1 :
				  (S == 2'b01) ? X2 :
				  (S == 2'b10) ? X3 :
				  (S == 2'b11) ? X4 : 8'bx;
endmodule

// Block 0 C1b - NEEDS TO BE MODIFIED
module block0 (result, OpA, OpB, sel);
	input [3:0] sel;
	input [7:0] OpA, OpB;
	output [7:0] result;

	// 0111 AND, 1000 OR, 1001 XOR, 1101 XNOR
	assign result = (sel == 4'b0111) ? (OpA & OpB) :
					(sel == 4'b1000) ? (OpA | OpB) :
					(sel == 4'b1001) ? (OpA ^ OpB) :
					(sel == 4'b1101) ? ~(OpA ^ OpB) : 8'bx;
endmodule

// Block 1 C1b - NEEDS TO BE MODIFIED
module block1 (result, OpA, OpB, sel);
	input [3:0] sel;
	input [7:0] OpB;
	output [7:0] result;
	wire [7:0] div, mult, shift, notA;
	// Replace this assign statement with your Verilog code.
	// The operation of the arithmetic circuit is defined in the  specification.

	// Implements lslb
	assign shift[0] = 1'b0;
	assign shift[1] = OpB[0];
	assign shift[2] = OpB[1];
	assign shift[3] = OpB[2];
	assign shift[4] = OpB[3];
	assign shift[5] = OpB[4];
	assign shift[6] = OpB[5];
	assign shift[7] = OpB[6];
	
	// Implements div4
	assign div[0] = OpB[2];
	assign div[1] = OpB[3];
	assign div[2] = OpB[4];
	assign div[3] = OpB[5];
	assign div[4] = OpB[6];
	assign div[5] = OpB[7];
	assign div[6] = 1'b0;
	assign div[7] = 1'b0;
	
	// Implements mult16
	assign mult[0] = 1'b0;
	assign mult[1] = 1'b0;
	assign mult[2] = 1'b0;
	assign mult[3] = 1'b0;
	assign mult[4] = OpB[0];
	assign mult[5] = OpB[1];
	assign mult[6] = OpB[2];
	assign mult[7] = OpB[3];
	
	assign notA[0] = ~OpA[0];
	assign notA[1] = ~OpA[1];
	assign notA[2] = ~OpA[2];
	assign notA[3] = ~OpA[3];
	assign notA[4] = ~OpA[4];
	assign notA[5] = ~OpA[5];
	assign notA[6] = ~OpA[6];
	assign notA[7] = ~OpA[7];
	// Selects the output

	// 1010 shift, 1011 div4, 1100 mult16
	assign result = (sel == 4'b1010) ? shift :
					(sel == 4'b1011) ? div :
					(sel == 4'b1111) ? notA :
					(sel == 4'b1100) ? mult : 8'bx;
						
endmodule