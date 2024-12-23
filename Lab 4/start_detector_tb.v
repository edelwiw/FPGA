`timescale 1ps/1ps

module start_detector_tb;

reg clk = 0;
always #1 clk = ~clk;

wire [3:0] q;
wire shift_ena;
reg count_ena = 0;
reg data = 0;
reg rst = 0;

start_detector startd (
    .clk(clk),
    .data(data),
    .rst(rst),
    .start_shifting(shift_ena)
);

// shift_counter counter (
//     .clk(clk),
//     .shift_ena(shift_ena),
//     .count_ena(count_ena),
//     .data(data)
// );



initial begin
    $dumpfile("start_detector_tb.vcd");
    $dumpvars(0, start_detector_tb);

    data = 0;
    rst = 1;

    #1 rst <= 0;
    #2 data <= 1;
    #2 data <= 0;
    #2 data <= 0;
    #2 data <= 1;
    #2 data <= 1;
    #2 data <= 0;
    #2 data <= 1;
    #2 data <= 0;

    #6 rst <= 1;
    #2 rst <= 0;

    #10 $finish();
end

always @(posedge clk) begin
    $display("t=%-4d: shift_ena = %d, data = %d", $time, shift_ena, data);
end

endmodule