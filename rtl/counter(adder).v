// 4bit binary counter by addition operator

module counter(clk, reset, q);
    
    input clk, reset;
    output [3:0] q;
    reg [3:0] q;
    // reg : Type declaration, register type
    
    // posedge : positive edge(rising edge)
    always @(posedge clk or posedge reset) begin
        // Asynchronous input
        if (reset == 1'b1)
            // 4'h0 : 4bit 0x0 = 0000(2)
            q <= 4'h0;
        
        else
            // 4'h1 : 4bit 0x1 = 0001(2)
            q <= q + 4'h1;
    end
    
endmodule