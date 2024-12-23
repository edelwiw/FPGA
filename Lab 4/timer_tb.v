`timescale 1ps/1ps

module timer_tb;

reg clk = 0;
always #1 clk = ~clk;

reg data = 0;
reg rst = 0;
reg ask = 0;

wire counting;
wire done;
wire shift_ena;


timer tim(
    .clk(clk),
    .data(data),
    .rst(rst),
    .ask(ask),
    .counting(counting),
    .done(done)
);

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, timer_tb);

    data = 0;
    #1 data = 1;
    #2 data = 1;
    #2 data = 0;
    #2 data = 1;


    #2 data = 0;
    #2 data = 0;
    #2 data = 0;
    #2 data = 0;

    #2400 ask = 1;
    #2 ask = 0;

    #100 $finish();
end

always @(posedge clk) begin
    // $display("t=%-4d: data = %d, counting = %d, done = %d, ask = %d", ($time + 1)/ 2, data, counting, done, ask);
end

endmodule