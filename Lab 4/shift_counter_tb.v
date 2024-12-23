`timescale 1ps/1ps

module shift_counter_tb;

reg clk = 0;
always #1 clk = ~clk;

wire [3:0] q;
reg shift_ena = 0;
reg count_ena = 0;
reg data = 0;

shift_counter shiftr (
    .clk(clk),
    .shift_ena(shift_ena),
    .count_ena(count_ena),
    .data(data),
    .q(q)
);

initial begin
    $dumpfile("shift_counter_tb.vcd");
    $dumpvars(0, shift_counter_tb);

    data = 0;
    shift_ena = 0;

    #1 data <= 1; shift_ena <= 1;
    #2 data <= 0;
    #2 data <= 0;
    #2 data <= 1;
    #2shift_ena <= 0;

    #6 count_ena <= 1;
    #10 count_ena <= 0;

    #10 $finish();
end

always @(posedge clk) begin
    $display("t=%-4d: q = %d, cnt_ena = %d, shift_ena = %d, data = %d", $time, q, count_ena, shift_ena, data);
end

endmodule