module full_add_3b( 
    input [2:0] a, b,
    input cin,
    output [2:0] cout,
    output [2:0] sum );

	// write code here

    full_add add1(
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .cout(cout[0]),
        .sum(sum[0])
    );
    full_add add2(
        .a(a[1]),
        .b(b[1]),
        .cin(cout[0]),
        .cout(cout[1]),
        .sum(sum[1])
    );
    full_add add3(
        .a(a[2]),
        .b(b[2]),
        .cin(cout[1]),
        .cout(cout[2]),
        .sum(sum[2])
    );

    // assign sum = a +b +cin;
    // assign cout[0] = (a[0] & b[0]) | (a[0] & cin) | (b[0] & cin);
    // assign cout[1] = (a[1] & b[1]) | (a[1] & cout[0]) | (b[1] & cout[0]);
    // assign cout[2] = (a[2] & b[2]) | (a[2] & cout[1]) | (b[2] & cout[1]);
    
endmodule