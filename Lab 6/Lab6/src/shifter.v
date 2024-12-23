module shifter (
    input clk, 
    input [0:7] data_buffer, 
    output reg data_out = level_on_idle, 
    output clk_out,
    output reg latch = 1,
    input drop_latch,
    input start_transfer, 
    output reg busy = 0
);

parameter level_on_idle = 0; // data_buffer level on idle 

reg [4:0] bits_sent = 0;

assign clk_out = (bits_sent != 0 && busy == 1) ? clk : 0; 

// State machine 
always @(negedge clk) begin
    case(busy)
        0: begin
            if(start_transfer) begin
                bits_sent = 0;
                busy = 1;
                data_out <= data_buffer[bits_sent];
                bits_sent = bits_sent + 1;
                latch = 0;
            end
        end

        1: begin
            if(bits_sent == 8) begin
                data_out <= level_on_idle;
                busy = 0;
                if(drop_latch) begin 
                    latch = 1;
                end
            end
            else begin
                data_out <= data_buffer[bits_sent];
                bits_sent = bits_sent + 1;
            end
        end
    endcase
end



endmodule