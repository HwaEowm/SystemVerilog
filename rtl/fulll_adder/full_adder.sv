// 4bit full adder
module fulladd(a, b, c_in, q, c_out);
    input logic a, b, c_in;
    output logic q, c_out;
    
    assign q  = a ^ b ^ c_in;
    assign c_out = (a & b) | (a & c_in) | (b & c_in);
    
endmodule
    
// RCA(Ripple Carry Adder)
module adder_ripple(a, b, q);
    input logic [3:0] a, b;
    output logic [3:0] q;
    logic [3:0] co;

    // making instances
    // 1'b0 : means binary 1 bit '0'
    fulladd add0 (.a(a[0]), .b(b[0]), .c_in(1'b0),  .q(q[0]), .c_out(co[0]));
    fulladd add1 (.a(a[1]), .b(b[1]), .c_in(co[0]), .q(q[1]), .c_out(co[1]));
    fulladd add2 (.a(a[2]), .b(b[2]), .c_in(co[1]), .q(q[2]), .c_out(co[2]));
    fulladd add3 (.a(a[3]), .b(b[3]), .c_in(co[2]), .q(q[3]), .c_out(co[3])); 
endmodule