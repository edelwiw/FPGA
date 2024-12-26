module uart_tx(
    input wire clk, 
    output wire uart_txd, 
    output wire uart_tx_busy, 
    input wire uart_tx_en, 
    input wire [PAYLOAD_BITS-1:0] uart_tx_data
);


parameter BAUD_RATE = 115200; 

parameter CLOCK_FREQ = 27_000_000;
parameter PAYLOAD_BITS = 8;
parameter STOP_BITS = 1;

localparam CYCLES_PER_BIT = CLOCK_FREQ / BAUD_RATE; 
localparam COUNT_REG_LEN = $clog2(CYCLES_PER_BIT);
reg [COUNT_REG_LEN-1:0] cycle_counter = 0;


reg [PAYLOAD_BITS-1:0] data_to_send;
reg [3:0] bit_counter;

// Finite state machine 
localparam IDLE = 0;
localparam START = 1;
localparam SEND = 2;
localparam STOP = 3;

reg [2:0] fsm_state = IDLE;
reg [2:0] next_fsm_state = IDLE;


assign uart_tx_busy = fsm_state != IDLE;
assign uart_txd = current_bit;

wire next_bit = cycle_counter == CYCLES_PER_BIT;
wire payload_done = bit_counter == PAYLOAD_BITS;
wire stop_done = bit_counter == STOP_BITS && fsm_state == STOP;

always @(*) begin 
    case(fsm_state)
        IDLE: next_fsm_state <= uart_tx_en ? START : IDLE;
        START: next_fsm_state <= next_bit ? SEND : START;
        SEND: next_fsm_state <= payload_done ? STOP : SEND;
        STOP: next_fsm_state <= stop_done ? IDLE : STOP;
        default: next_fsm_state <= IDLE;
    endcase
end

always @(posedge clk) begin 
    fsm_state <= next_fsm_state;
end


integer i = 0;
always @(posedge clk) begin 
    if(fsm_state == IDLE && uart_tx_en) begin
        data_to_send <= uart_tx_data;
    end else if(fsm_state       == SEND       && next_bit ) begin
        for (i = PAYLOAD_BITS-2; i >= 0; i = i - 1) begin
            data_to_send[i] <= data_to_send[i+1];
        end
    end
end

always @(posedge clk) begin 
    if(fsm_state != SEND && fsm_state != STOP) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == SEND && next_fsm_state == STOP) begin
        bit_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == STOP&& next_bit) begin
        bit_counter <= bit_counter + 1'b1;
    end else if(fsm_state == SEND && next_bit) begin
        bit_counter <= bit_counter + 1'b1;
    end
end


always @(posedge clk) begin 
    if(next_bit) begin
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(fsm_state == START || fsm_state == SEND  || fsm_state == STOP   ) begin
        cycle_counter <= cycle_counter + 1'b1;
    end
end

// USART data output logic 
reg current_bit;
always @(posedge clk) begin
    if(fsm_state == IDLE) begin
        current_bit <= 1'b1;
    end else if(fsm_state == START) begin
        current_bit <= 1'b0;
    end else if(fsm_state == SEND) begin
        current_bit <= data_to_send[0];
    end else if(fsm_state == STOP) begin
        current_bit <= 1'b1;
    end
end

endmodule