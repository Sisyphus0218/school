`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

`define ALUop_AND  3'b000
`define ALUop_OR   3'b001
`define ALUop_ADD  3'b010
`define ALUop_SLTU 3'b011
`define ALUop_XOR  3'b100
`define ALUop_NOR  3'b101
`define ALUop_SUB  3'b110
`define ALUop_SLT  3'b111

module alu(
	input  [`DATA_WIDTH - 1:0]  A,
	input  [`DATA_WIDTH - 1:0]  B,
	input  [              2:0]  ALUop,
	output                      Overflow,
	output                      CarryOut,
	output                      Zero,
	output [`DATA_WIDTH - 1:0]  Result
);
	// TODO: Please add your logic design here
	// decoding
	wire op_and  = ALUop == `ALUop_AND;
	wire op_or   = ALUop == `ALUop_OR;
	wire op_add  = ALUop == `ALUop_ADD;
	wire op_sltu = ALUop == `ALUop_SLTU;
	wire op_xor  = ALUop == `ALUop_XOR;
	wire op_nor  = ALUop == `ALUop_NOR;
	wire op_sub  = ALUop == `ALUop_SUB;
	wire op_slt  = ALUop == `ALUop_SLT;

	// and & or & xor & nor
	wire [`DATA_WIDTH - 1:0] and_res, or_res, xor_res, nor_res;

	assign and_res = A & B;
	assign or_res  = A | B;
	assign xor_res = A ^ B;
	assign nor_res = ~(A | B);

	// add & sub
	wire [`DATA_WIDTH - 1:0] add_res;
	wire [`DATA_WIDTH - 1:0] choose_B;
	wire carryin, carryout;

	assign carryin  = ~op_add;      // if add, carryin = 1; else if add or slt or sltu, carryin = 0
	assign choose_B = op_add? B:~B; // if add, choose B; else if add or slt or sltu, choose ~B
	assign {carryout, add_res} = A + choose_B + carryin; // if add, add_res = A + B; otherwise, add_res = A + ~B + 1

	// sltu (compare unsigned int)
	wire sltu_res;

	assign sltu_res = ~carryout; // if A<B, A-B will borrow a bit

	// slt (compare signed int)
	wire slt_res;
	wire slt1,slt2,slt3;

	assign slt1 =  A[`DATA_WIDTH-1] & ~B[`DATA_WIDTH-1];  // if A<0,B>0 slt1=1
	assign slt2 = ~A[`DATA_WIDTH-1] &  B[`DATA_WIDTH-1];  // if A>0,B<0 slt2=1
	assign slt3 = add_res[`DATA_WIDTH-1];                 // if A and B have the same sign, check the sign of the add_res
	assign slt_res = slt1 | (~slt1 & ~slt2 & slt3);     
	
	// overflow (signed int)
	wire overflow_add, overflow_sub;

	assign overflow_add = (A[`DATA_WIDTH-1] ^ ~B[`DATA_WIDTH-1]) & (A[`DATA_WIDTH-1] ^ add_res[`DATA_WIDTH-1]); // pos + pos = neg (0 0 1) or neg + neg = pos (1 1 0)
	assign overflow_sub = (A[`DATA_WIDTH-1] ^  B[`DATA_WIDTH-1]) & (A[`DATA_WIDTH-1] ^ add_res[`DATA_WIDTH-1]); // pos - neg = neg (0 1 1) or neg - pos = pos (1 0 0)
	
	// choose the result
	assign Result   = {32{op_and}} & and_res | {32{op_or}} & or_res | {32{op_add}} & add_res | {32{op_sltu}} & sltu_res | {32{op_xor}} & xor_res | {32{op_nor}} & nor_res | {32{op_sub}} & add_res | {32{op_slt}} & slt_res;
	assign Overflow = op_add & overflow_add | op_sub & overflow_sub;
	assign CarryOut = op_add & carryout | op_sub & ~carryout;
	assign Zero     = ~|Result;
	
endmodule
