module FSM4(in, clock50, reset, dash, dot, dotdash, seg7, stateLED);
    input in;
    input clock50;
    input reset;

    output dash;
    output dot;
    output [1:0] dotdash;
    output reg[7:0] seg7 = 8'b00000000;
    output [4:0] stateLED; //this shows the statecode on LED

    reg[7:0] present = s0;
    reg[7:0] next;
    
    reg dash = 0;
    reg dot = 0;
    reg clockout;
    reg [9:0] count = 10'b0;
    reg [22:0] c=23'd0;
    parameter divide = 23'b10111110101111000010000;
    reg[1:0] dotdash =2'b00;
    

    
    //statecodes
    parameter A = 5'b00001;
    parameter B = 5'b00010;
    parameter C = 5'b00011;
    parameter D = 5'b00100;
    parameter E = 5'b00101;
    parameter F = 5'b00110;
    parameter G = 5'b00111;
    parameter H = 5'b01000;
    parameter s0= 5'b01001;
    parameter s1= 5'b01010;
    parameter s2= 5'b01011;
    parameter s3= 5'b01100;
    parameter s4= 5'b01101;
    parameter s5= 5'b01110;
    parameter s6= 5'b01111;
    parameter s7= 5'b10000;
    parameter x = 5'b10001;
    

    assign stateLED = present;
    
    

    //clock dividor, clockout period will be around 0.1 s
    always @(posedge clock50) begin
            if(c==divide)
                c<=23'b0;
            else
                c <= c + 1;
            clockout <= (c==23'b0); //if c is 23'b0, clouckout is 1, otherwise 0.
    end
    
    
    
    //count is used to distinguish dash from dot depending on how long you hold the button
    
    always @(posedge clockout)
    begin
        if(in==0)
        begin
            count <= count+1;
            //long press in will be dash
            if(count>=10'bb0000000101)
            begin
                dash = 1;
                dot = 0;
                //dotdash will be used for state transition
                
            end
            //short press in will be dot
            else if((10'b1 <=count)&&(count< 10'b0000000101))
            begin
                dot = 1;
            end
        end
        
        else
        begin
        count <= 10'b0;
        dash = 0;
        dot = 0;
        end
        
    end
    
    
    
    
    
    //dotdash is assigned value as soon as you let go "in" button, so that
    //program knows to distinguish dot from dash (since dash is same input as dot,
    //except longer)
    always@(posedge in or negedge reset)
    begin
            if (reset==1'b0) begin//active low asynchronous reset
                present = s0; //if resetted, go to state s0
                dotdash = 2'b00;
            end
            
        else
        begin
            //dotdash is used for state transition
            if ((dot==1)&&(dash==0)) dotdash = 2'b10;
            else if((dot==0)&&(dash==1)) dotdash = 2'b01;
            present = next; //state transitions as soon as you let go "in"
        end
    end
    
    
    
    //finite states
    always @(dotdash)
    begin
        case(present)
        
        s0:
        begin
            case(dotdash)
            2'b10: next = E;
            2'b01: next = s1;
            2'b00: next = s0;
            endcase
        end
        
        
        s1:
        begin
            case(dotdash)
            2'b10: next = s3;
            2'b01: next = s2;
            endcase
        end
        
        s2:
        begin
            case(dotdash)
            2'b10: next = G;
            2'b01: next = x;
            endcase
        end
        
        s3:
        begin
            case(dotdash)
            2'b10: next = D;
            2'b01: next = s4;
            endcase
        end
        
        s4:
        begin
            case(dotdash)
            2'b10: next = C;
            2'b01: next = x;
            endcase
        end
        
        D:
        begin
            case(dotdash)
            2'b10: next = B;
            2'b01: next = x;
            endcase
        end
        
        
        E:
        begin
            case(dotdash)
            2'b10: next = s5;
            2'b01: next = A;
            endcase
        end
        
        s5:
        begin
            case(dotdash)
            2'b10: next = s7;
            2'b01: next = s6;
            endcase
        end
        
        s6:
        begin
            case(dotdash)
            2'b10: next = F;
            2'b01: next = x;
            endcase
        end
        
        s7:
        begin
            case(dotdash)
            2'b10: next = H;
            2'b01: next = x;
            endcase
        end
        
        default: next = x;
        
        endcase
    end
    
    

    
    //signals for the 7 segment display
    always @(present)
    begin
        case(present)
        A: seg7 = 8'b11101110;
        B: seg7 = 8'b00101111;
        C: seg7 = 8'b10000111;
        D: seg7 = 8'b01101011;
        E: seg7 = 8'b10001111;
        F: seg7 = 8'b10001110;
        G: seg7 = 8'b10101111;
        H: seg7 = 8'b01101110;
        s0:seg7 = 8'b11100111;
        s1:seg7 = 8'b01100000;
        s2:seg7 = 8'b11001011;
        s3:seg7 = 8'b11101001;
        s4:seg7 = 8'b01101100;
        s5:seg7 = 8'b10101101;
        s6:seg7 = 8'b00101111;
        s7:seg7 = 8'b11100000;
        x: seg7 = 8'b10001001;
        
        default: seg7 = 8'b10001001;
        endcase
    end
    
            
    
endmodule
