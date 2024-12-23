module task1_top (
    input a, b, c, d,
    output q
);

assign q = (a | b | c | d) & (a | b | c | ~d) & (a | b | ~c | d) & (a | b | ~c | ~d) & (a | ~b | c | d) & (~a | b | c | d) & (~a | ~b | c | d);
    
endmodule