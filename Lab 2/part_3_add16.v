module part_3_add16 (
    input [15:0] a,
    input [15:0] b,
    input cin,
    output wire [15:0] sum,
    output cout
);

assign {cout, sum} = a + b + cin;

endmodule