module uart(
    input wire clk, // Top level system clock input
    input wire nreset, // Asynchronous active low reset
    input wire uart_rx_data, // UART rx pin  
    input wire uart_rx_en, // rx enable
    output wire uart_rx_valid, // Valid data received 
    output reg [DATA_BITS - 1:0] uart_data   // Received data buffer 
);

// default parameters 
parameter BAUD_RATE = 9600; // bits / sec 
parameter CLK_FREQ = 27_000_000; // hz 
parameter DATA_BITS = 8; 
parameter STOP_BITS = 1; 
// ---------------------------------------------------------------------------

// clock prescaler parameters 
localparam CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE; 
localparam COUNT_REG_LEN = 1 + $clog2(CYCLES_PER_BIT); 
reg [COUNT_REG_LEN-1:0] cycle_counter;
// ---------------------------------------------------------------------------

// finite state machine states 
reg [2:0] fsm_state;
reg [2:0] next_fsm_state;

localparam FSM_IDLE = 2'b00;
localparam FSM_START= 2'b01;
localparam FSM_RECV = 2'b10;
localparam FSM_STOP = 2'b11;
// --------------------------------------------------------------------------- 

// Internally latched value of the uart_rx_data line. Helps break long timing
// paths from input pins into the logic.
reg rxd_reg;
reg rxd_reg_0;

// Storage for the received serial data.
reg [DATA_BITS-1:0] received_data;

reg [3:0] bit_counter;


// Sample of the UART input line whenever we are in the middle of a bit frame.
reg bit_sample;

assign uart_rx_valid = fsm_state == FSM_STOP && next_fsm_state == FSM_IDLE; // raise valid flag when we have a full packet 

wire next_bit = cycle_counter == CYCLES_PER_BIT || fsm_state == FSM_STOP && cycle_counter == CYCLES_PER_BIT / 2; // time to sample the next bit
wire payload_done = bit_counter == DATA_BITS; // all data bits received
//
// Handle picking the next state.
always @(*) begin
    case(fsm_state)
        // FSM_IDLE: next_fsm_state = uart_rx_data ? FSM_IDLE : FSM_START; // start bit detected: IDLE -> START
        FSM_IDLE: next_fsm_state = rxd_reg ? FSM_IDLE : FSM_START; // start bit detected: IDLE -> START
        FSM_START: next_fsm_state = next_bit ? FSM_RECV : FSM_START; // time to read the first bit: START -> RECV 
        FSM_RECV: next_fsm_state = payload_done ? FSM_STOP : FSM_RECV; // all data bits received: RECV -> STOP
        FSM_STOP: next_fsm_state = next_bit ? FSM_IDLE : FSM_STOP; // stop bit detected: STOP -> IDLE
        default: next_fsm_state = FSM_IDLE;
    endcase
end


// handle updates to the received data register
integer i = 0;
always @(posedge clk) begin
    if(!nreset) begin
        // reset the received data buffer
        received_data <= {DATA_BITS{1'b0}};
    end else if(fsm_state == FSM_IDLE) begin
        // reset the received data buffer when not receiving 
        received_data <= {DATA_BITS{1'b0}};
    end else if(fsm_state == FSM_RECV && next_bit) begin
        // time to sample the next bit 
        received_data <= {bit_sample, received_data[DATA_BITS - 1:1]}; // shift the buffer 
        // received_data <= {uart_rx_data, received_data[DATA_BITS - 1:1]}; // shift the buffer  // TODO check 
    end
end

// increments the bit counter when receiving 
always @(posedge clk) begin
    if(!nreset) begin 
        // reset the bit counter
        bit_counter <= 4'b0;
    end else if(fsm_state != FSM_RECV) begin
        // reset the bit counter when not receiving
        bit_counter <= 4'b0;
    end else if(fsm_state == FSM_RECV && next_bit) begin
        // next bit received, increment the counter
        bit_counter <= bit_counter + 1'b1;
    end
end

// Sample the received bit when in the middle of a bit frame.
always @(posedge clk) begin
    if(!nreset) begin
        bit_sample <= 1'b0;
    end else if (cycle_counter == CYCLES_PER_BIT/2) begin
        bit_sample <= rxd_reg;
    end
end

// uart frequency module (cycle counter)
always @(posedge clk) begin 
    if(!nreset) begin
        // reset the cycle counter
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if(next_bit) begin
        // cycle done, reset the counter
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end else if (fsm_state == FSM_IDLE) begin
        // reset the cycle counter when uart is idle
        cycle_counter <= {COUNT_REG_LEN{1'b0}};
    end
    else if(fsm_state == FSM_START || fsm_state == FSM_RECV || fsm_state == FSM_STOP) begin
        // increment the cycle counter when uart is active
        cycle_counter <= cycle_counter + 1'b1;
    end
end


// progresses the next FSM state
always @(posedge clk) begin 
    if(!nreset) begin // reset state
        // set initial state to idle
        fsm_state <= FSM_IDLE;
    end else begin
        // set the next state
        fsm_state <= next_fsm_state; 
    end
end

// output buffer updating 
always @(posedge clk) begin
    if(!nreset) begin // reset state
        // reset the received data buffer
        uart_data  <= {DATA_BITS{1'b0}}; 
    end else if (fsm_state == FSM_STOP) begin 
        // store the received data in the buffer at the end of the transmissions
        uart_data  <= received_data; 
    end
end

// Responsible for updating the internal value of the rxd_reg
always @(posedge clk) begin 
    if(!nreset) begin // reset state 
        rxd_reg     <= 1'b1;
        rxd_reg_0   <= 1'b1;
    end else if(uart_rx_en) begin
        rxd_reg     <= rxd_reg_0;
        rxd_reg_0   <= uart_rx_data;
    end
end


endmodule