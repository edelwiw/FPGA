`timescale 1ps/1ps

module counter_tb;

reg clk = 0;
always #1 clk = ~clk;

wire [9:0] q;
reg rst = 0;

counter cnt1 (
    .clk(clk),
    .rst(rst),
    .q(q)
);

initial begin
    $dumpfile("counter_tb.vcd");
    $dumpvars(0, counter_tb);

    #25 rst <= 1;
    #2 rst <= 0;

    #10 $finish();
end

always @(posedge clk) begin
    $display("t=%-4d: rst = %d, cnt = %d", $time, rst, q);
end

endmodule