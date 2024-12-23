module timer (
    input clk,
    input data,
    input rst,
    input ask,
    output reg counting = 0,
    output reg done = 0
);


reg[3:0] state = 0;
wire start_shifting;
reg[2:0] bits_read = 0;
wire[3:0] delay;

// 0 - idle 
// 1 - shifting 
// 2 - master_cnt_loop 
// 3 - slave_cnt_loop
// 4 - done

start_detector trigger (
    .clk(clk),
    .rst(rst),
    .data(data),
    .start_shifting(start_shifting)
);


assign shifting = (state == 1);
assign master_cnt = (state == 2);

shift_counter master_cnt (
    .clk(clk),
    .shift_ena(shifting),
    .count_ena(master_cnt),
    .data(data),
    .q(delay)
);

counter slave_cnt (
    .clk(clk),
    .rst(rst),
    .q()
);

always @(posedge clk) begin

    // display state
    $display("t=%-4d: state = %d, bits_read. = %d, delay = %d, slave_delay = %d, ask = %d", ($time + 1) / 2, state, bits_read, delay, slave_cnt.q, ask);

    if(state == 0) begin // if idle 
        if(start_shifting) begin 
            state <= 1;
            bits_read = 0;
            trigger.start_shifting <= 0;
        end
    end

    if(state == 1) begin 
        bits_read <= bits_read + 1;
        if(bits_read == 3) begin
            state <= 3;
            slave_cnt.q <= 0; 
            counting <= 1;
        end
    end

    if(state == 2) begin
        if(delay == 0) begin
            state <= 4;
            counting <= 0;
            done <= 1;
        end
        else begin
            state <= 3;
            slave_cnt.q <= 0; // set start value for slave timer 
        end
    end

    if(state == 3) begin
        if(slave_cnt.q == 999) begin
            state <= 2;
            slave_cnt.q <= 0; // set start value for slave timer 
        end
    end

    if(state == 4) begin
        if(ask == 1) begin
            state <= 0;
            done <= 0;
        end
    end

end

endmodule