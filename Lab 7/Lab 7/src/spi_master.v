module spi_master(
    input wire clk, 
    input wire [7:0] tx_data_reg, 
    output reg [7:0] rx_data_reg,
    input wire start_transfer,
    output wire spi_mosi, 
    input wire spi_miso,
    output wire spi_clk,
    output wire done
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

assign spi_clk = fsm_state == TRANSFER ? spi_clk_source : CPOL;

// finite state machine 
localparam IDLE = 0;
localparam TRANSFER = 1;
localparam DONE = 2;

localparam NUMBER_OF_STATES = 3;
localparam STATE_LEN = $clog2(NUMBER_OF_STATES);

reg [STATE_LEN - 1:0] fsm_state = IDLE;
reg [STATE_LEN - 1:0] fsm_next_state = IDLE;

always @(*) begin
    case(fsm_state)
        TRANSFER: fsm_next_state = current_bit_index == 8 ? DONE : TRANSFER;
        IDLE: fsm_next_state = start_transfer ? TRANSFER : IDLE;
        // DONE: fsm_next_state = IDLE;
        DONE: fsm_next_state = ~start_transfer ? IDLE : DONE;
        default: fsm_next_state = IDLE;
    endcase
end

always @(posedge clk) begin
   fsm_state <= fsm_next_state;
end

assign spi_mosi = fsm_state == TRANSFER && current_bit_index != 8 ? current_bit_sample : 1'b0;
assign done = fsm_state == DONE;


// SPI MOSI 
reg [3:0] current_bit_index = 0;
reg current_bit_sample = 1'b0; 

always @(*) begin
    if (spi_clock_timer_reg == 0 && fsm_state == TRANSFER)  // set next bit (at falling edge of spi_clk)
        current_bit_sample <= tx_data_reg[current_bit_index];
end 

always @(posedge clk) begin
    if(fsm_state == TRANSFER && spi_clock_timer_reg == SPI_CLOCK_TIMER_VALUE) // increment bit index (at rising edge of spi_clk)
        current_bit_index <= current_bit_index + 1'b1;
    else if (fsm_state == IDLE) 
        current_bit_index <= 4'b0;
end

// SPI MISO 
reg [7:0] input_register;
always @(*) begin
    if(fsm_state == TRANSFER && spi_clock_timer_reg == SPI_CLOCK_TIMER_VALUE) // read bit (at rising edge of spi_clk)
        input_register[current_bit_index] = spi_miso;
end 

always @(posedge clk) begin
    case(fsm_state)
        TRANSFER: rx_data_reg <= 8'h00;
        default: rx_data_reg <= input_register;
    endcase
end


endmodule