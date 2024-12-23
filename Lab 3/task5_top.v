module task5_top (
    input clock, a,
    output reg [2:0] q = 4
);


always @(posedge clock) begin
    if (~a) begin
        if(q == 6) begin
            q = 0;
        end else begin
            q = q + 1;
        end
    end
    else begin
        q = 4;
    end
end
    

endmodule

