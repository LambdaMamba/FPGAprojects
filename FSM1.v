	module FSM1(clock, reset, w, z, stateLED);
		input clock;
		input reset;
		input w;
		output reg z;
		output[8:0] stateLED;
		
		//the following state registers are the circles on state diagram
		reg [8:0] present;
		reg [8:0] next;
		
		//One hot code encoded
		parameter A = 9'b000000001;
		parameter B = 9'b000000010;
		parameter C = 9'b000000100;
		parameter D = 9'b000001000;
		parameter E = 9'b000010000;
		parameter F = 9'b000100000;
		parameter G = 9'b001000000;
		parameter H = 9'b010000000;
		parameter I = 9'b100000000;
		
		parameter w0 = 1'b0;
		parameter w1 = 1'b1;
		
		
	
		assign stateLED = present;
		
		always @(present, w)
		begin
		
			case(present) 
			
			A: 
			begin
				case(w)
				w0: next = B;
				w1: next = F;
				endcase
			end
			
			B:
			begin 
				case(w)
				w0: next = C;
				w1: next = F;
				endcase
			end
			
			C:
			begin
				case(w)
				w0: next = D;
				w1: next = F;
				endcase
			end
			
			D:
			begin
				case(w)
				w0: next = E;
				w1: next = F;
				endcase
			end
			
			E:
			begin
				case(w)
				w0: next = E;
				w1: next = F;
				endcase
			end
			
			F:
			begin
				case(w)
				w0: next = B;
				w1: next = G;
				endcase
			end
			
			G:
			begin
				case(w)
				w0: next = B;
				w1: next = H;
				endcase
			end
			
			H:
			begin
				case(w)
				w0: next = B;
				w1: next = I;
				endcase
			end
			
			I:
			begin
				case(w)
				w0: next = B;
				w1: next = I;
				endcase
			end
			
			endcase
		end
		
		
		//output signal depending on state
		//signals in states E and I will be 1, otherwise 0
		
		always @(posedge clock)
		begin
			if(present==E || present==I)
				z = 1'b1;
			else
				z = 1'b0;
		end
		
		//moves next to present on posedge clock,this is transition in state diagram
		always @(posedge clock)
		begin
			if (reset==1'b0) //active low synchronous reset
				present = A; //if resetted, go to state A
			else 
				present = next;
		end
		
		
	endmodule
