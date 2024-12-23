`timescale 1 ps / 1ps

module spi_tb(
    output data_out, 
    output clk_out
);

reg clk = 0;

always
    #18 clk = !clk; 

// spi clock source 
parameter spi_timer_val = 27; // The number of times needed to frequency 10kHz 
reg [15:0] spi_timer; // counter_value
reg spi_clk = 1; // spi clock signal  

always @(posedge clk) begin
    if (spi_timer <= spi_timer_val) begin 
        spi_timer  <= spi_timer + 1'b1; 
    end
    else begin 
        spi_timer  <= 16'b0; 
        spi_clk <= ~spi_clk; 
    end
end

reg [0:7] send_buffer = 8'haa; 
reg start_transfer = 1;
wire busy; 

shifter shifter_instance(
    .clk(spi_clk),
    .data_buffer(send_buffer),
    .start_transfer(start_transfer),
    .data_out(data_out),
    .clk_out(clk_out),
    .busy(busy)
);


initial begin
    $display ("###################################################");
    $display ("Start TestBench");
end

initial begin
    $dumpfile ("spi.vcd");
    $dumpvars(0, spi_tb);
end

initial begin 
    #50000000 $finish;
end


endmodule

