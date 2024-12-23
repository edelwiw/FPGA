module chip_7458 ( 
    input p1a, p1b, p1c, p1d, p1e, p1f,
    output p1y,
    input p2a, p2b, p2c, p2d,
    output p2y );

// write code here

assign p1y = (p1a & p1c & p1b) | (p1d & p1e & p1f);
assign p2y = (p2a & p2b) | (p2d & p2c);

endmodule