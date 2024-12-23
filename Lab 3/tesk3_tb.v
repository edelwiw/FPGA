`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module task3_tb;

reg [3:0] a, b, c, d, e;
wire [3:0] q;

task3_top task3_inst (
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .e(e),
    .q(q)
);



initial begin
    $dumpfile("wave.vcd");		// create a VCD waveform dump called "wave.vcd"
    $dumpvars(0, task3_tb);	    // dump variable changes in the testbench and all modules under it

    a = 0; b = 0; c = 0; d = 0; e = 0;
    #5 a = 10; b = 11; c = 0; d = 13; e = 14;
    #5 c = 4'h1;
    #5 c = 4'h2;
    #5 c = 4'h3;
    #5 c = 4'h4;
    #5 c = 4'h5;
    #5 c = 4'h6;
    #5 c = 4'h7;
    #5 c = 4'h8;
    #5 c = 4'h9;
    #5 c = 4'ha;
    #5 c = 4'hb;
    #5 c = 4'hc;
    #5 c = 4'hd;
    #5 c = 4'he;
    #5 c = 4'hf;
    #5 c = 4'h0;
    #5 c = 4'h1;
    #5 c = 4'h2;
    #5 a = 4'h1; b = 4'h2; c = 0; d = 4'h3; e = 4'h4;
    #5 c = 4'h1;
    #5 c = 4'h2;
    #5 c = 4'h3;
    #5 c = 4'h4;
    #5 c = 4'h5;
    #5 c = 4'h6;
    #5 c = 4'h7;
    #5 c = 4'h8;
    #5 a = 4'h5; b = 4'h6; c = 0; d = 4'h7; e = 4'h8;
    #5 c = 4'h1;
    #5 c = 4'h2;
    #5 c = 4'h3;
    #5 c = 4'h4;
    #5 c = 4'h5;
    #5 c = 4'h6;
    #5 c = 4'h7;
    #5 c = 4'h8;


    $finish();
end

initial begin
    $monitor("t=%-4d: a = %d, b = %d, c = %d, d = %d, e = %d, q = %d" , $time, a, b, c, d, e, q);
end

endmodule