module top(
    input  clk,
    output data_out,
    output clk_out,
    output latch
);

// spi clock source 
//parameter clk_frequency = 27_000_000; // Crystal oscillator frequency is 27Mhz

parameter spi_timer_val = 54; // The number of times needed to frequency 
reg [19:0] spi_timer; // counter_value
reg spi_clk = 1; // spi clock signal  

parameter second = 27_000_000; // 0.1 second
reg [31:0] second_timer = 0; // 1 second counter
reg sec_clk = 1; // 1 second clock signal
reg [31:0] timer = 0; 

parameter ms_timer_value = 27_000_000 / 1000; 
reg [31:0] ms_timer = 0; 

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
        timer <= timer + 1'b1;
    end

    if(ms_timer <= ms_timer_value) begin 
        ms_timer <= ms_timer + 1;
    end else begin 
        ms_timer = 32'b0;
    end

end


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

reg [0:63] display_buffer = 64'h0102030405060708;
reg [3:0] display_index = 0;

reg [0:15] send_buffer = 0; 
reg start_transfer = 0;
wire busy; 

shifter shifter_instance(
    .clk(spi_clk),
    .data_buffer(send_buffer),
    .start_transfer(start_transfer),
    .data_out(data_out),
    .latch(latch),
    .clk_out(clk_out),
    .busy(busy)
);


always @(posedge clk) begin 
    if(ms_timer == 0) begin 
//        send_buffer <= ((1 << display_index)) | ((~(display_buffer >> ((7 - display_index) * 8))) << 8);
//         send_buffer <= ((~(1 << display_index)) & 8'hFF) | (((display_buffer >> ((7 - display_index) * 8))) << 8);
        send_buffer <=  (((display_buffer >> ((7 - display_index) * 8)) & 8'hff) << 8) | ((~(1 << display_index)) & 8'hFF);
        start_transfer <= 1;
        display_index = (display_index + 1) % 8;
    end else if (busy == 1) begin
        start_transfer <= 0;    
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