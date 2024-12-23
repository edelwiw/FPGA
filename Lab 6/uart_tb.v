`timescale 1ns/1ns

module uart_tb(
    // output data_out, 
    // output clk_out, 
    // output latch
);


localparam CLK_HZ   = 27_000_000;
localparam CLK_P    = 1_000_000_000 / CLK_HZ;

    
reg resetn;
reg uart_rxd; // UART Recieve pin.

reg uart_rx_en; // Recieve enable
wire uart_rx_valid; // Valid data recieved and available.
wire [7:0] uart_rx_data; // The recieved data.


localparam BIT_RATE = 115200;
localparam BIT_P    = (1_000_000_000 / BIT_RATE);


reg clk = 0;
always begin #(CLK_P / 2) clk = ~clk; end


initial begin
	$display ("###################################################");
	$display ("Start TestBench");
	clk = 0;
end

initial begin
    $dumpfile ("uart.vcd");
    $dumpvars(0, uart_tb);
end 

reg uart_data = 0;
reg uart_rx = 1;

// top topi(
//     .clk(clk),
//     .data_out(data_out),
//     .clk_out(clk_out),
//     .latch(latch),
//     .uart_rx(uart_rx)
// );


uart #(
.BAUD_RATE(BIT_RATE),
.CLK_FREQ  (CLK_HZ)
) i_uart_rx(
.clk          (clk          ), // Top level system clock input.
.nreset       (resetn       ), // Asynchronous active low reset.
.uart_rx_data    (uart_rxd     ), // UART Recieve pin.
.uart_rx_en   (uart_rx_en   ), // Recieve enable
.uart_rx_valid(uart_rx_valid), // Valid data recieved and available.
.uart_data (uart_rx_data )  // The recieved data.
);

task send_byte;
    input [7:0] to_send;
    integer i;
    begin
        $display("Sending byte: %d at time %d", to_send, $time);

        #BIT_P;  uart_rxd = 1'b0;
        for(i=0; i < 8; i = i+1) begin
            #BIT_P;  uart_rxd = to_send[i];

            //$display("    Bit: %d at time %d", i, $time);
        end
        #BIT_P;  uart_rxd = 1'b1;
        #1000;
    end
endtask


integer passes = 0;
integer fails  = 0;
task check_byte;
    input [7:0] expected_value;
    begin
        if(uart_rx_data == expected_value) begin
            passes = passes + 1;
            $display("[PASS] Expected %b and got %b", expected_value, uart_rx_data);
        end else begin
            fails  = fails  + 1;
            $display("[FAIL] Expected %b and got %b", expected_value, uart_rx_data);
        end
    end
endtask


reg [7:0] to_send;
initial begin 
    resetn  = 1'b0;
    clk     = 1'b0;
    uart_rxd = 1'b1;
    #40 resetn = 1'b1;
    
    uart_rx_en = 1'b1;

    #1000;
    repeat(100) begin
        to_send = $random;
        send_byte(to_send);
        check_byte(to_send);
    end

    $display("BIT RATE      : %db/s", BIT_RATE );
    $display("CLK PERIOD    : %dns" , CLK_P    );
    $display("CYCLES/BIT    : %d"   , i_uart_rx.CYCLES_PER_BIT);
    $display("SAMPLE PERIOD : %d", CLK_P *i_uart_rx.CYCLES_PER_BIT);
    $display("BIT PERIOD    : %dns" , BIT_P    );

    $display("Test Results:");
    $display("    PASSES: %d", passes);
    $display("    FAILS : %d", fails);

    $display("Finish simulation at time %d", $time);
    $finish();
end

endmodule