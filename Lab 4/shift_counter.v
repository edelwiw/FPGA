module shift_counter (
    input clk,
    input shift_ena,
    input count_ena,
    input data,
    output reg [3:0] q = 0
);

always @(posedge clk) begin
    if(shift_ena) begin 
        q = {q[2:0], data};
    end

    if(count_ena) begin
        q <= q - 1;
    end
end


endmodule