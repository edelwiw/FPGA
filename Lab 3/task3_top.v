module task3_top (
    input [3:0] a, b, c, d, e,
    output reg [3:0] q
);

always @(*) begin
    case (c)
        4'b00: q = b;
        4'b01: q = e;
        4'b10: q = a;
        4'b11: q = d;
    default: 
        q = 4'b1111;
    endcase
end

    
endmodule