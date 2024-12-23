`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module task6_tb;

reg clk=0;
always #1 clk = !clk;

reg a, b;
wire q, state;

task6_top task6_inst (
    .clock(clk),
    .a(a),
    .b(b),
    .q(q),
    .state(state)
);

initial begin
    $dumpfile("wave.vcd");		// create a VCD waveform dump called "wave.vcd"
    $dumpvars(0, task6_tb);	    // dump variable changes in the testbench and all modules under it

    a <= 0;
    b <= 0;
    #3 b <= 1;
    #2 a <= 1; b <= 0;
    #2 b <= 1;
    #2 a <= 0; b <= 0;
    #2 a <= 1; b <= 1;
    #6 b <= 0;
    #2 a <= 0; b <= 1;
    #2 b <= 0;


    #5 $finish();
end

initial begin
    $monitor("t=%-4d: clock = $d, a = %d, b = %d, q = %d, state = %d" , $time, clk, a, b, q, state);
end

endmodule