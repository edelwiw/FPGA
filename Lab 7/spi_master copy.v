module spi_master(
    input clk, 
    input [7:0] tx_data_reg, 
    input start_transfer,
    output spi_mosi, 
    output spi_clk,
    output done
);

parameter CPOL = 0; // clock polarity 

// clock configuration 
parameter SPI_CLOCK_FREQ = 10_000; // 10Khz (default)
parameter MAIN_CLOCK_FREQ = 27_000_000; // main clock frequency is 27Mhz (default)

localparam SPI_CLOCK_TIMER_VALUE = MAIN_CLOCK_FREQ / SPI_CLOCK_FREQ; 
localparam SPI_CLOCK_TIMER_LEN = $clog2((SPI_CLOCK_TIMER_VALUE));

reg [SPI_CLOCK_TIMER_LEN - 1:0] spi_clock_timer_reg = {SPI_CLOCK_TIMER_LEN{1'b0}};

always @(posedge clk) begin
    if(fsm_state == IDLE) 
        spi_clock_timer_reg <= {SPI_CLOCK_TIMER_LEN{1'b0}};
    else if (spi_clock_timer_reg == SPI_CLOCK_TIMER_VALUE) 
        spi_clock_timer_reg <= {SPI_CLOCK_TIMER_LEN{1'b0}};
    else 
        spi_clock_timer_reg <= spi_clock_timer_reg + 1'b1;
end

reg spi_clk_source = 1'b0;
always @(posedge clk) begin
    if(fsm_state == IDLE) 
        spi_clk_source <= 1'b0;
    else if(spi_clock_timer_reg == SPI_CLOCK_TIMER_VALUE || spi_clock_timer_reg == SPI_CLOCK_TIMER_VALUE / 2) 
        spi_clk_source <= ~spi_clk_source;
    else
        spi_clk_source <= spi_clk_source;
end

assign spi_clk = fsm_next_state == TRANSFER ? spi_clk_source : CPOL;

// finite state machine 
localparam IDLE = 0;
localparam TRANSFER = 1;

localparam NUMBER_OF_STATES = 2;
localparam STATE_LEN = $clog2(NUMBER_OF_STATES);

reg [STATE_LEN - 1:0] fsm_state = IDLE;
reg [STATE_LEN - 1:0] fsm_next_state = IDLE;

always @(*) begin
    case(fsm_state)
        TRANSFER: fsm_next_state = current_bit_index == 8 ? IDLE : TRANSFER;
        IDLE: fsm_next_state = start_transfer ? TRANSFER : IDLE;
        default: fsm_next_state = IDLE;
    endcase
end

always @(posedge clk) begin
    fsm_state <= fsm_next_state;
end


// SPI configuration
reg [3:0] current_bit_index = 0;
reg current_bit_sample = 1'b0; 

wire next_bit = spi_clock_timer_reg == 0 && fsm_state == TRANSFER;

always @(*) begin
    if (next_bit) 
        current_bit_sample <= tx_data_reg[current_bit_index];
end 

always @(posedge clk) begin
    if(fsm_state == TRANSFER && spi_clock_timer_reg == SPI_CLOCK_TIMER_VALUE) 
        current_bit_index <= current_bit_index + 1'b1;
    else if (fsm_state == IDLE) 
        current_bit_index <= 4'b0;
end

assign spi_mosi = fsm_state == TRANSFER && fsm_next_state == TRANSFER ? current_bit_sample : 1'b0;

assign done = fsm_state == TRANSFER && fsm_next_state == IDLE;



endmodule