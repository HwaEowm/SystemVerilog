// 4bit full adder

module fulladd(a, b, c_in, q, c_out);
    
    input a, b, c_in;
    output q, c_out;
    
    assign q  = a ^ b ^ c_in;
    assign c_out = (a & b) | (a & c_in) | (b & c_in);
    
endmodule
    
    
// adder_ripple
    
module adder_ripple(a, b, q);
        
        input [3:0] a, b;
        output [3:0] q;
        wire [3:0] co;
        
        // making instances
        // 1'b0 : means binary 1 bit '0'
        fulladd add0 (a[0], b[0], 1'b0, q[0], co[0]);
        fulladd add1 (a[1], b[1], co[0], q[1], co[1]);
        fulladd add2 (a[2], b[2], co[1], q[2], co[2]);
        fulladd add3 (a[3], b[3], co[2], q[3], co[3]);
        
endmodule
