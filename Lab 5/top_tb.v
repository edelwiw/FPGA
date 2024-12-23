`timescale 1 ps / 1ps

module top_tb(
    output data_out, 
    output clk_out, 
    output latch
);

reg clk = 0;

always
    #18 clk = !clk; 

initial begin
	$display ("###################################################");
	$display ("Start TestBench");
	clk = 0;
end

initial begin
    $dumpfile ("top.vcd");
    $dumpvars(0, top_tb);
end 

top topi(
    .clk(clk),
    .data_out(data_out),
    .clk_out(clk_out),
    .latch(latch)
);

initial begin 
    #5000000 $finish;
end

endmodule