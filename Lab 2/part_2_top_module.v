module part_2_top_module (
    input clk,
    input [7:0] d,
    input [1:0] sel,
    output reg [7:0] q
);

wire [7:0] w1, w2, out;

part_2_trigger tr1(.clk(clk), .d(d), .q(w1));
part_2_trigger tr2(.clk(clk), .d(w1), .q(w2));
part_2_trigger tr3(.clk(clk), .d(w2), .q(out));

// mux 
always @(negedge clk) begin
    case(sel)
        2'b00: q = d;
        2'b01: q = w1;
        2'b10: q = w2;
        2'b11: q = out;
    endcase
end


endmodule