module part_1_trigger (
    input clk,
    input d,
    output reg q
);

// reg q_reg;

always @(negedge clk) begin
    q <= d;
end

// assign q = q_reg;

endmodule