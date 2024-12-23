module part_4_top_module (
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);

wire [31:0] res;
wire carry;

part_3_add16 add16_1(.a(a[15:0]), .b(b[15:0]), .cin(1'b0), .sum(res[15:0]), .cout(carry));

wire [31:16] sum_high_0, sum_high_1;
part_3_add16 add16_2(.a(a[31:16]), .b(b[31:16]), .cin(1'b0), .sum(sum_high_0), .cout());
part_3_add16 add16_3(.a(a[31:16]), .b(b[31:16]), .cin(1'b1), .sum(sum_high_1), .cout());

assign res[31:16] = carry ? sum_high_1 : sum_high_0;


assign sum = res;

endmodule