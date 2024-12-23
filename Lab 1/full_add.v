module full_add ( 
    input a, b, cin,
    output sum, cout );

// write code here

wire a_and_b, a_xor_b, a_xor_b_and_cin;
assign a_and_b = a & b;
assign a_xor_b = a ^ b;
assign a_xor_b_and_cin = a_xor_b & cin;

assign cout = a_and_b ^ a_xor_b_and_cin;
assign sum = a_xor_b ^ cin;

endmodule