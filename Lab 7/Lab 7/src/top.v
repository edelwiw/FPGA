module top(
    input clk,
    output spi_mosi,
    input spi_miso,
    output spi_clk,
    output reg mosi_ss,
    output reg miso_ss,
    output uart_tx
);

// GLOBAL PARAMETERS 
localparam CLOCK_FREQ = 27_000_000; // main clock frequency is 27Mhz

// clock source 
localparam ms_period = 0.05; // 1ms
localparam MS_TIMER_VALUE = CLOCK_FREQ * ms_period; // the number of clocks needed to time 1ms 
localparam MS_TIMER_LEN = $clog2($rtoi(MS_TIMER_VALUE)); 
reg [MS_TIMER_LEN - 1:0] ms_timer_reg = {MS_TIMER_LEN{1'b0}};

reg [31:0] sin_time = 0;
always @(posedge clk) begin
    if (ms_timer_reg <= MS_TIMER_VALUE) begin 
        ms_timer_reg  <= ms_timer_reg + 1'b1;
    end else begin 
        ms_timer_reg  <= {MS_TIMER_LEN{1'b0}};
        sin_time <= sin_time + 1;
    end
end


reg start_transfer = 1'b0;
// SPI configuration
localparam SPI_CLOCK_FREQ = 10_000; 
localparam CPOL = 0;

// SPI module
reg [7:0] tx_data_reg = 8'hAA;
wire [7:0] rx_data_reg;

wire done; 
spi_master # (
    .SPI_CLOCK_FREQ(SPI_CLOCK_FREQ),
    .MAIN_CLOCK_FREQ(CLOCK_FREQ),
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


// Finite state machine 
localparam IDLE = 0;
localparam WRITING_DAC = 1;
localparam READING_ADC = 2; 
localparam UART_TRANSFER = 3;
localparam DONE = 4;

localparam NUMBER_OF_STATES = 5;
localparam STATE_LEN = $clog2(NUMBER_OF_STATES);

reg [STATE_LEN - 1:0] fsm_state = IDLE;
reg [STATE_LEN - 1:0] fsm_next_state = IDLE;

// next state logic
always @(*) begin
    case(fsm_state)
        IDLE: fsm_next_state = start_transfer ? WRITING_DAC : IDLE;
        WRITING_DAC: fsm_next_state = done ? (~DAC_value_high ? WRITING_DAC : READING_ADC) : WRITING_DAC;
        READING_ADC: fsm_next_state = done ? (~ADC_value_high ? READING_ADC : UART_TRANSFER) : READING_ADC;
        UART_TRANSFER: fsm_next_state = uart_done ? DONE : UART_TRANSFER;
        DONE: fsm_next_state = IDLE; 
    endcase
end

always @(posedge clk) begin
    fsm_state <= fsm_next_state;
end


// start transfer logick
always @(posedge clk) begin
    case(fsm_state)
        IDLE: start_transfer <= (ms_timer_reg == MS_TIMER_VALUE) ? 1'b1 : 1'b0;
        WRITING_DAC: start_transfer <= DAC_value_high ? 1'b0 : 1'b1;
        READING_ADC: start_transfer <= ADC_value_high ? 1'b0 : 1'b1;
        DONE: start_transfer <= 1'b0;
    endcase
end 

// tx reg forming 
always @(posedge clk) begin
    case(fsm_state)
        IDLE: tx_data_reg <= {8{1'b0}};
        WRITING_DAC: tx_data_reg <= DAC_value_high ? DAC_value_reg[8:15] : DAC_value_reg[0:7];
        READING_ADC: tx_data_reg <= {8{1'b0}};
        DONE: tx_data_reg <= {8{1'b0}};
    endcase
end

// high or low byte logic 
always @(posedge clk) begin
    if(fsm_state == WRITING_DAC && done) begin
        DAC_value_high <= ~DAC_value_high;
    end

    if(fsm_state == READING_ADC && done) begin
        ADC_value_high <= ~ADC_value_high;
    end
end

always @(posedge clk) begin
    if(fsm_state == READING_ADC && done) begin
        if(ADC_value_high) 
            ADC_value_reg[8:15] <= rx_data_reg;
        else
            ADC_value_reg[0:7] <= rx_data_reg;
    end
end

// SS logic
always @(posedge clk) begin
    mosi_ss <= fsm_state == READING_ADC ? 1'b0 : 1'b1;
    miso_ss <= fsm_state == WRITING_DAC ? 1'b0 : 1'b1;
end


// DAC waveform generator 
reg [0:15] DAC_value_reg = 16'hABCD; 
reg DAC_value_high = 1'b0; // if we are sending the high byte of the DAC value

// sign + whole number + 15 bits of fraction
// xi = 0.607253
// yi = 0 
reg[16:0] xi = 17'd19898;
reg[16:0] yi = 17'd0; // TODO: maybe 1
reg[16:0] theta = 17'd0;    
wire[16:0] sin_theta;

localparam theta_end = 17'd51445; // TODO 

always @(posedge clk) begin 
    if(ms_timer_reg == MS_TIMER_VALUE) begin 
        if(theta < theta_end) begin 
            theta <= theta + 1;
        end else begin 
            theta <= 0;
        end
    end
end

CORDIC_Top cordic_inst(
    .clk(clk), //input clk
    .rst(1'b0), //input rst
    .x_i(xi), //input [16:0] x_i
    .y_i(yi), //input [16:0] y_i
    .theta_i(theta), //input [16:0] theta_i
    .x_o(), //output [16:0] x_o
    .y_o(sin_theta), //output [16:0] y_o
    .theta_o() //output [16:0] theta_o
);

always @(posedge clk) begin 
    DAC_value_reg <= sin_theta; 
end

// ADС value 
reg [0:15] ADC_value_reg = 16'h0000;
reg ADC_value_high = 1'b0; // if we are reading the high byte of the ADC value



// UART TX module
reg [7:0] uart_buffer;
reg [2:0] uart_byte_num = 0;
always @(posedge clk) begin 
    case(uart_byte_num) 
        3'b000: uart_buffer <= 8'hA9;
        3'b001: uart_buffer <= ADC_value_reg[8:15] & 8'h0F;
        3'b010: uart_buffer <= ADC_value_reg[0:7] & 8'h0F;
        3'b011: uart_buffer <= 8'h91;
    endcase
end

wire uart_busy;
reg uart_done;

uart_tx #(
    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD_RATE(115200)
) uart_tx_inst (
    .clk(clk),
    .uart_tx_en(uart_tx_en),
    .uart_tx_data(uart_buffer),
    .uart_tx_busy(uart_busy),
    .uart_txd(uart_tx)
);

// uart start 
reg uart_tx_en;
always @(posedge clk) begin
    if(fsm_state == UART_TRANSFER && !uart_busy && ~change_byte_uart) begin
        uart_tx_en <= 1'b1;
    end else begin
        uart_tx_en <= 1'b0;
    end
end 

always @(posedge clk) begin 
    if (uart_byte_num == 3) 
        uart_done <= 1;
    else 
        uart_done <= 0;
end

reg prev_uart_busy = 1'b0;
wire change_byte_uart = ~uart_busy && prev_uart_busy;
always @(posedge clk) begin 
    prev_uart_busy <= uart_busy;
end

always @(posedge clk) begin 
    if(uart_byte_num == 3 && change_byte_uart) 
        uart_byte_num <= 0;
    else if(uart_byte_num < 3 && change_byte_uart) 
        uart_byte_num <= uart_byte_num + 1;
end

endmodule