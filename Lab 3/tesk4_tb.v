`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module task4_tb;

reg clk=0;
always #6 clk = !clk;

reg a;
wire p, q;

task4_top task4_inst (
    .clock(clk),
    .a(a),
    .p(p),
    .q(q)
);

initial begin
    $dumpfile("wave.vcd");		// create a VCD waveform dump called "wave.vcd"
    $dumpvars(0, task4_tb);	    // dump variable changes in the testbench and all modules under it

    a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #10 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #3 a = 1;
    #3 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;
    #1 a = 1;
    #1 a = 0;



    $finish();
end

initial begin
    $monitor("t=%-4d: clock = $d, a = %d, p = %d, q = %d" , $time, clk, a, p, q);
end

endmodule