module start_detector(
    input wire clk,
    input wire rst,
    input wire data,
    output reg start_shifting = 0
);

reg [3:0] buffer = 0;

// always @(posedge clk) begin

//     // if(~start_shifting) begin 
//         buffer = {buffer[2:0], data};
//     // end

//     if(rst) begin 
//         start_shifting <= 0;
//     end 

//     if(buffer == 4'b1101) begin 
//         start_shifting = 1;
//     end 
// end

reg [2:0] state = 0;

always @(posedge clk) begin
    if(state == 0) begin
        if(data == 1) begin 
            state <= 1;
        end
    end
    if(state == 1) begin
        if(data == 1) begin 
            state <= 2;
        end else begin 
            state <= 0;
        end
    end
    if(state == 2) begin
        if(data == 0) begin 
            state <= 3;
        end else begin 
            state <= 0;
        end
    end
    if(state == 3) begin
        if(data == 1) begin 
            state <= 0;
            start_shifting = 1;
        end else begin 
            state <= 0;
        end
    end

    if(rst) begin 
        start_shifting <= 0;
        state = 0;
    end 
end

endmodule