module alu (a_in, b_in, s_in, y_out, n_out, z_out, c_out, v_out);
    input logic signed [7:0] a_in, b_in;
    input logic [2:0] s_in; // select signal
    output logic signed [7:0] y_out; // output
    // flags
    output logic c_out, v_out, z_out;
    output logic n_out;

    always_comb begin
        c_out = 1'b0;
        v_out = 1'b0;
        y_out = 8'b0;

        // addition
        if (s_in == 3'b000) begin
            {c_out, y_out} = {1'b0, a_in} + {1'b0, b_in};
            v_out = (a_in[7] ^~ b_in[7]) & (a_in[7] ^ y_out[7]);
        end

        // subtraction
        else if (s_in == 3'b001) begin
            y_out = a_in - b_in;
            v_out = (a_in[7] ^ b_in[7]) & (a_in[7] ^ y_out[7]);
        end

        // AND
        else if (s_in == 3'b010) begin
            y_out = a_in & b_in;
        end

        // OR
        else if (s_in == 3'b011) begin
            y_out = a_in | b_in;
        end

        // SLT
        else if (s_in == 3'b101) begin
            y_out = a_in - b_in;
            v_out = (a_in[7] ^ b_in[7]) & (a_in[7] ^ y_out[7]);
            y_out = {7'b0, y_out[7] ^ v_out};
        end

        else y_out = 8'b0;

        z_out = (y_out == 8'b0);
    end

    assign n_out = y_out[7];

endmodule