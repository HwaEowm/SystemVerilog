`timescale 1ns/1ps

module tb_alu;
    logic signed [7:0] tb_a_in, tb_b_in;
    logic [2:0] tb_s_in;

    logic signed [7:0] tb_y_out;
    logic tb_c_out, tb_v_out, tb_z_out, tb_n_out;

    // DUT(Device Under Test)
    // port mapping
    alu dut(
        .a_in(tb_a_in),
        .b_in(tb_b_in),
        .s_in(tb_s_in),
        .y_out(tb_y_out),
        .c_out(tb_c_out),
        .v_out(tb_v_out),
        .z_out(tb_z_out),
        .n_out(tb_n_out)
    );
    
    logic signed [7:0] expected_y;
    logic expected_c, expected_v, expected_z, expected_n;

    // array of vaild ALU opcodes
    logic [2:0] opcodes [5] = '{3'b000, 3'b001, 3'b010, 3'b011, 3'b101};

    // execute the statement once when the simulation starts
    initial begin
        $display("start test"); // $display is the same as printf in C language

        // for-each loop, don't need to declare the index 'k'
        foreach (opcodes[k]) begin
            tb_s_in = opcodes[k];

            // iterate through all possible 
            for (int i = -128; i <= 127; i++) begin
                for (int j = -128; j <= 127; j++) begin
                    tb_a_in = i;
                    tb_b_in = j;

                    // initialize
                    expected_c = 1'b0;
                    expected_v = 1'b0;

                    case (tb_s_in)
                        3'b000: begin
                            {expected_c, expected_y} = {1'b0, tb_a_in} + {1'b0, tb_b_in};
                            expected_v = (tb_a_in[7] ^~ tb_b_in[7]) & (tb_a_in[7] ^ expected_y[7]);
                        end

                        3'b001: begin
                            expected_y = tb_a_in - tb_b_in;
                            expected_v = (tb_a_in[7] ^ tb_b_in[7]) & (tb_a_in[7] ^ expected_y[7]);
                        end

                        3'b010: expected_y = tb_a_in & tb_b_in;
                        3'b011: expected_y = tb_a_in | tb_b_in;

                        3'b101: begin
                            expected_y = tb_a_in - tb_b_in;
                            expected_v = (tb_a_in[7] ^ tb_b_in[7]) & (tb_a_in[7] ^ expected_y[7]);
                            expected_y = {7'b0, expected_y[7] ^ expected_v};
                        end

                        default: expected_y = 8'b0;
                    endcase

                    expected_n = expected_y[7];
                    expected_z = (expected_y == 8'b0);

                    #10; // delta time

                    assert (tb_y_out === expected_y)
                    // $fatal : force stop the simulation
                    else $fatal(1, "[error] Output y mismatch! - opcode : %b | input : %d, %d | expected : %d | result : %d",
                                tb_s_in, tb_a_in, tb_b_in, expected_y, tb_y_out);
                    
                    assert (tb_c_out === expected_c)
                    else $fatal(1, "[error] Flag C mismatch! - opcode : %b | input : %d, %d | expected : %d | result : %d",
                                tb_s_in, tb_a_in, tb_b_in, expected_c, tb_c_out);

                    assert (tb_v_out === expected_v)
                    else $fatal(1, "[error] Flag V mismatch! - opcode : %b | input : %d, %d | expected : %d | result : %d",
                                tb_s_in, tb_a_in, tb_b_in, expected_v, tb_v_out);

                    assert (tb_z_out === expected_z)
                    else $fatal(1, "[error] Flag Z mismatch! - opcode : %b | input : %d, %d | expected : %d | result : %d",
                                tb_s_in, tb_a_in, tb_b_in, expected_z, tb_z_out);

                    assert (tb_n_out === expected_n)
                    else $fatal(1, "[error] Flag N mismatch! - opcode : %b | input : %d, %d | expected : %d | result : %d",
                                tb_s_in, tb_a_in, tb_b_in, expected_n, tb_n_out);
                
                end
            end
        end

        $display("No logical bugs were found.");
        $finish; // end the simulation
    end
endmodule