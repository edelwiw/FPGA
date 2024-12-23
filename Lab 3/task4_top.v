module task4_top (
    input clock, a,
    output reg p = 0, q = 0
);

always @(a) begin   
    if(clock) begin 
        p <= a;
    end
end

always @(negedge clock) begin 
    q <= p;
end

    
endmodule