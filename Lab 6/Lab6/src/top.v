module top(
    input  clk,
    output data_out,
    output clk_out,
    output latch,
    input uart_rx
);

// spi clock source 
//parameter clk_frequency = 27_000_000; // Crystal oscillator frequency is 27Mhz

parameter spi_timer_val = 54; // The number of times needed to frequency 
reg [19:0] spi_timer; // counter_value
reg spi_clk = 1; // spi clock signal  

parameter second = 27_000_000; // 1 second = 27Mhz
reg [31:0] second_timer = 0; // 1 second counter
reg sec_clk = 1; // 1 second clock signal
reg [31:0] timer = 12345; 


always @(posedge clk) begin
    if (spi_timer <= spi_timer_val) begin 
        spi_timer  <= spi_timer + 1'b1; 
    end
    else begin 
        spi_timer  <= 16'b0; 
        spi_clk <= ~spi_clk; 
    end

    if (second_timer <= second) begin 
        second_timer  <= second_timer + 1'b1; 
    end
    else begin 
        second_timer  <= 32'b0; 
        sec_clk <= ~sec_clk; 
        //timer <= timer + 1'b1;
    end
end


parameter BIT_RATE = 9600;      // Input bit rate of the UART line.
parameter CLK_HZ = 27000000; // Clock frequency in hertz.
parameter PAYLOAD_BITS = 8;  // Number of data bits per UART packet.
parameter STOP_BITS = 1;  // Stop bits per UART packet.


// spi transfer 
parameter DIGIT_N = 8'b00000000;
parameter DIGIT_0 = 8'b00111111;
parameter DIGIT_1 = 8'b00000110;
parameter DIGIT_2 = 8'b01011011;
parameter DIGIT_3 = 8'b01001111;
parameter DIGIT_4 = 8'b01100110;
parameter DIGIT_5 = 8'b01101101;
parameter DIGIT_6 = 8'b01111101;
parameter DIGIT_7 = 8'b00000111;
parameter DIGIT_8 = 8'b01111111;
parameter DIGIT_9 = 8'b01101111;

reg [0:7] digits[9:0];

initial begin
    digits[0] = DIGIT_0;
    digits[1] = DIGIT_1;
    digits[2] = DIGIT_2;
    digits[3] = DIGIT_3;
    digits[4] = DIGIT_4;
    digits[5] = DIGIT_5;
    digits[6] = DIGIT_6;
    digits[7] = DIGIT_7;
    digits[8] = DIGIT_8;
    digits[9] = DIGIT_9;
end



reg [1:0] state = idle;
reg[1:0] next_state = idle;
parameter idle = 0;
parameter sending_first_byte = 1;
parameter sending_second_byte = 2;
parameter sent = 3;

reg [0:63] display_buffer;
reg [3:0] display_index = 0;

reg [0:7] send_buffer = 0; 
reg start_transfer = 0;
wire busy; 
reg drop_latch = 0;

// uart instance

wire uart_data_valid;
wire [7:0] uart_data;

uart #(
    .BAUD_RATE(BIT_RATE),
    .CLK_FREQ  (CLK_HZ)
) uart_instance(
    .clk(clk),
    .nreset(1'b1), // no reset 
    .uart_rx_data(uart_rx),
    .uart_rx_en(1'b1), // enable all time 
    .uart_rx_valid(uart_data_valid),
    .uart_data(uart_data)
);

// spi instances

shifter shifter_instance(
    .clk(spi_clk),
    .data_buffer(send_buffer),
    .start_transfer(start_transfer),
    .data_out(data_out),
    .latch(latch),
    .drop_latch(drop_latch),
    //.drop_latch(1'b1), // drop latch always 1
    .clk_out(clk_out),
    .busy(busy)
);


reg [0:71] uart_char_buffer;
reg [3:0] uart_char_index = 0;
reg time_set_flag = 0;
always @(posedge clk) begin
    if(uart_data_valid) begin
        uart_char_buffer = {uart_char_buffer[7:71], uart_data};
        if (uart_data == 8'h0a || uart_char_index == 8) begin
            if(uart_char_index >= 0) timer = 0;
            if(uart_char_index >= 1) timer = timer + ((uart_char_buffer >> 1 * 8) & 8'hff - 8'h30) * 1; 
            if(uart_char_index >= 2) timer = timer + ((uart_char_buffer >> 2 * 8) & 8'hff - 8'h30) * 10;
            if(uart_char_index >= 3) timer = timer + ((uart_char_buffer >> 3 * 8) & 8'hff - 8'h30) * 100;
            if(uart_char_index >= 4) timer = timer + ((uart_char_buffer >> 4 * 8) & 8'hff - 8'h30) * 1000;
            if(uart_char_index >= 5) timer = timer + ((uart_char_buffer >> 5 * 8) & 8'hff - 8'h30) * 10000;
            if(uart_char_index >= 6) timer = timer + ((uart_char_buffer >> 6 * 8) & 8'hff - 8'h30) * 100000;
            if(uart_char_index >= 7) timer = timer + ((uart_char_buffer >> 7 * 8) & 8'hff - 8'h30) * 1000000;
            if(uart_char_index >= 8) timer = timer + ((uart_char_buffer >> 8 * 8) & 8'hff - 8'h30) * 10000000;
            time_set_flag = 1;
            uart_char_index <= 0;
        end else uart_char_index <= (uart_char_index + 1) % 9;
        if (uart_char_index == 9) begin
            uart_char_index <= 0;
        end
    end 
end



initial begin 
    state = sending_first_byte;
    send_buffer <= ~(1 << display_index);
    display_index <= (display_index + 1) % 8;
    // latch = 0;
    start_transfer <= 1;
    drop_latch = 0;
end


always @(negedge busy) begin // first byte sent callback
    if(state == idle) begin
        state = sending_first_byte;
        send_buffer <= ~(1 << display_index);
        drop_latch = 0;
        // latch = 0;
    end if(state == sending_first_byte) begin
        state = sending_second_byte;
        send_buffer <= ((display_buffer >> ((7 - display_index) * 8)) & 8'hff);
        drop_latch = 0;
        // latch = 0;
        // sent second byte
    end else if(state == sending_second_byte) begin
        display_index <= (display_index + 1) % 8;
        state = sending_first_byte;
        drop_latch = 1;
        // latch = 1;
        send_buffer <= ~(1 << display_index);
    end
end

reg[31:0] temp;

always @(posedge clk) begin

    temp = timer;
    
    display_buffer[56:63] = digits[temp % 10];
    temp = temp / 10;

    display_buffer[48:55] = digits[temp % 10];
    temp = temp / 10;

    display_buffer[40:47] = digits[temp % 10];
    temp = temp / 10;

    display_buffer[32:39] = digits[temp % 10];
    temp = temp / 10;

    display_buffer[24:31] = digits[temp % 10];
    temp = temp / 10;

    display_buffer[16:23] = digits[temp % 10];
    temp = temp / 10;

    display_buffer[8:15] = digits[temp % 10];
    temp = temp / 10;

    display_buffer[0:7] = digits[temp % 10];
end

endmodule