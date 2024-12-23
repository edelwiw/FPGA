`timescale 1ns/100ps // 1 ns time unit, 100 ps resolution

module task5_tb;

reg clk=0;
always #1 clk = !clk;

reg a;
wire [2:0] q;

task5_top task5_inst (
    .clock(clk),
    .a(a),
    .q(q)
);

initial begin
    $dumpfile("wave.vcd");		// create a VCD waveform dump called "wave.vcd"
    $dumpvars(0, task5_tb);	    // dump variable changes in the testbench and all modules under it

    a <= 1;
    #15 a <= 0;
    #10 a <= 1;
    #5 a <= 0;

    $finish();
end

initial begin
    $monitor("t=%-4d: clock = $d, a = %d, q = %d" , $time, clk, a, q);
end

endmodule


// `timescale 1ns/100ps // 1 ns time unit, 100 ps resolution
// // `include "task_1.v"

// module task5_tb;
	
// 	reg a, clk;

//     wire[2:0] q;


// 	task5_top tsk0
// 	(
// 		.clock(clk),
//         .a(a),
// 		.q(q)
// 	);


// 	event reset;
// 	event reset_done;


// 	initial
// 	begin
// 	$display ("###################################################");
// 	$display ("Start TestBench");
// 	clk = 0;
// 	a = 1;
// 	end

// 	 initial 
// 	begin
// 		$dumpfile ("task5.vcd");
// 		$dumpvars(0, task5_tb);
// 	end

// 	always
// 		#5 clk = !clk;

// 	initial begin
// 		#10
// 		a <= 1;
// 		#15
// 		a <= 0;
// 		#115
// 		a <= 1;
// 		#25
// 		a <= 0;

// 		#40
// 		$display ("###################################################");
// 		$finish();
// 	end

// 	initial begin
// 		$monitor("t=%-4d: clk = %b, a = %b, q = %d", $time, clk, a, q);
// 	end
// endmodule