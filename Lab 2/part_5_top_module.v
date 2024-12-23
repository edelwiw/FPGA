module part_5_top_module (
    input [31:0] a,
    input [31:0] b,
    input sub,
    output [31:0] sum
);

wire [31:0] xorb;

// assign xorb = sub ? ~b + 1 : b;

assign xorb = b ^ {32{sub}};

part_4_top_module adder0
(
    .a(a),
    .b(xorb),
    .sum(sum)
);

endmodule