`timescale 1ns/1ns

module top_tb(
);

// clock source 
localparam CLK_FREQ = 27_000_000;
localparam CLK_DELAY = 1_000_000_000 / CLK_FREQ;
localparam ms = 1_000_000;

reg clk = 0;
always begin #(CLK_DELAY / 2) clk = ~clk; end



initial begin
	$display ("###################################################");
	$display ("Start TestBench");
end

initial begin
    $dumpfile ("top_tb.vcd");
    $dumpvars(0, top_tb);
end


// testbench code here
reg mosi = 0;
always @(posedge clk) begin
    mosi <= ~mosi;
end

top top_inst (
    .clk(clk),
    .spi_mosi(),
    .spi_miso(mosi),
    .spi_mosi(),
    .spi_clk()
);

initial begin
    #(ms * 10); $finish;
end



endmodule