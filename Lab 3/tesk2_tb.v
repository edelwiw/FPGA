`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module task2_tb;

reg a, b, c, d;
reg [3:0] cnt = 0;
wire q;

always #1 cnt = cnt + 1;

task2_top task2_inst (
    .a(cnt[0]),
    .b(cnt[1]),
    .c(cnt[2]),
    .d(cnt[3]),
    .q(q)
);



initial begin
    $dumpfile("wave.vcd");		// create a VCD waveform dump called "wave.vcd"
    $dumpvars(0, task2_tb);	    // dump variable changes in the testbench and all modules under it

    #18 $finish();
end

// initial begin
//     $monitor("t=%-4d: a = %d, b = %d, c = %d, d = %d, q = %d" , $time, a, b, c, d, q);
// end

endmodule