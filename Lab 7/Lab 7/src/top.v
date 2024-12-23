module top(
    input clk,
    output spi_mosi,
    input spi_miso,
    output spi_clk
);

// clock source 
localparam period = 0.001; // 0.5S
localparam clock_frequency = 27_000_000; // main clock frequency is 27Mhz
localparam TIMER_VALUE = clock_frequency * period; // the number of times needed to time 0.5S
localparam TIMER_LEN = $clog2($rtoi(TIMER_VALUE)); 
reg [TIMER_LEN - 1:0] timer_reg = {TIMER_LEN{1'b0}};



always @(posedge clk) begin
    if (timer_reg <= TIMER_VALUE) begin 
        timer_reg  <= timer_reg + 1'b1;
    end
    else begin 
        timer_reg  <= {TIMER_LEN{1'b0}};
    end
end


reg start_transfer = 1'b1;

// SPI configuration
localparam SPI_CLOCK_FREQ = 100_000; 
localparam CPOL = 0;

// SPI module
reg [7:0] tx_data_reg = 8'hAA;
wire [7:0] rx_data_reg = 8'h00;

wire done; 
spi_master # (
    .SPI_CLOCK_FREQ(SPI_CLOCK_FREQ),
    .MAIN_CLOCK_FREQ(clock_frequency),
    .CPOL(CPOL)
    ) spi_master_inst (
    .clk(clk),
    .tx_data_reg(tx_data_reg),
    .rx_data_reg(rx_data_reg),
    .start_transfer(start_transfer),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .spi_clk(spi_clk),
    .done(done)
);


always @(posedge done) begin
    start_transfer <= ~start_transfer;
end



endmodule