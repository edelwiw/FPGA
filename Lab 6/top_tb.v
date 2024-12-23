`timescale 1ns/1ns

module top_tb(
    output data_out, 
    output clk_out, 
    output latch
);

// clock source 
localparam CLK_FREQ   = 27_000_000;
localparam CLK_DELAY    = 1_000_000_000 / CLK_FREQ;

reg clk = 0;
always begin #(CLK_DELAY / 2) clk = ~clk; end

initial begin
	$display ("###################################################");
	$display ("Start TestBench");
	clk = 0;
end

initial begin
    $dumpfile ("top.vcd");
    $dumpvars(0, top_tb);
end


// testbench code here

top top_instance(
    .clk(clk),
    .uart_rx(uart_rx_data),
    .data_out(data_out),
    .clk_out(clk_out),
    .latch(latch)
);

localparam BAUD_RATE = 9600;
localparam BIT_DELAY = (1_000_000_000 / BAUD_RATE);

reg uart_rx_data = 1'b1;
task send_byte;
    input [7:0] to_send;
    integer i;
    begin
        $display("Sending byte: %d at time %d", to_send, $time);    
        // start bit
        #BIT_DELAY; 
        uart_rx_data = 1'b0;
        for(i = 0; i < 8; i = i + 1) begin
            #BIT_DELAY; // wait for next bit
            uart_rx_data = to_send[i];
        end
        #BIT_DELAY;  uart_rx_data = 1'b1;
        #1000;
    end
endtask

initial begin
    #1000;
    send_byte(8'h31);
    send_byte(8'h32);
    send_byte(8'h33);
    send_byte(8'h0a);
    #1000;


    #10000000 $finish;
end



endmodule