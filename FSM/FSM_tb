`timescale 1ns / 1ns

module FSM_tb();
    reg clock_tb;
    reg reset_tb;
    reg w_tb;
    wire z_tb;
    wire stateLED_tb;
    
    initial
    begin: CLOCK_GENERATOR
    clock_tb = 0;
        forever
        begin
            #10 clock_tb = ~clock_tb;
        end
    end
    
    initial
    begin
        reset_tb <= 0; w_tb <= 0;
        #10 reset_tb <= 1; w_tb <= 1;
        #90 w_tb <= 0;
        #40 w_tb <= 1;
        #100 w_tb <= 0;
        #80 w_tb <= 1;
        #100 reset_tb <= 0; w_tb <= 0;
        #80 w_tb <= 1;
    end
    
    FSM1 DUT(clock_tb, reset_tb, w_tb, z_tb, stateLED_tb);
endmodule
