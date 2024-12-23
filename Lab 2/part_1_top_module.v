module part_1_top_module (
    input clk,
    input d,
    output q
);

wire w1, w2;

part_1_trigger tr1(.clk(clk), .d(d), .q(w1));
part_1_trigger tr2(.clk(clk), .d(w1), .q(w2));
part_1_trigger tr3(.clk(clk), .d(w2), .q(q));

endmodule