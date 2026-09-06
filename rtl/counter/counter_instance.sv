// 4bit counter by module instantiation

module cnt_unit(clk, reset, en, q, co);
    input clk, reset, en;
    output logic q, co;

    always @ (posedge clk or posedge reset) begin
        if (reset == 1'b1)
            q <= 1'b0;
        
        else if (en == 1'b1)
            q <= ~q;
    end

    assign co = en & q;

endmodule

module counter_cell(clk, reset, q);
    input clk, reset;
    output logic [3:0] q;
    logic [3:0] co;

    cnt_unit cu0(.clk(clk), .reset(reset), .en(1'b1), .q(q[0]), .co(co[0]));
    cnt_unit cu1(.clk(clk), .reset(reset), .en(co[0]), .q(q[1]), .co(co[1]));
    cnt_unit cu2(.clk(clk), .reset(reset), .en(co[1]), .q(q[2]), .co(co[2]));
    cnt_unit cu3(.clk(clk), .reset(reset), .en(co[2]), .q(q[3]), .co(co[3]));

endmodule