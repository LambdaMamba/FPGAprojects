`timescale 1ns/1ns
	
	module CalcFourBitAdder
		(
		input [1:0] KEY,
		input [3:0] SW,
		output [3:0] LED,
		output cout
		);
		
	
		reg ax;
		reg bx;
		reg ay;
		reg by;
		reg az;
		reg bz;
		reg aw;
		reg bw;
		wire cin;
	
		wire xwire1;
		wire xwire2;
		wire xwire3;
		wire outwirex;
	
		wire ywire1;
		wire ywire2;
		wire ywire3;
		wire outwirey;
	
		wire zwire1;
		wire zwire2;
		wire zwire3;
		wire outwirez; 
		
		wire wwire1;
		wire wwire2;
		wire wwire3; 
		
		assign cin = 0;
		
		//First set of 4 D flip flops
		always @(posedge !KEY[0] or posedge !KEY[1])
		begin
			if(!KEY[1]==1'b1)
			ax <= 1'b0;
			else
			ax <= SW[0];
		end
	
		always @(posedge !KEY[0] or posedge !KEY[1])
		begin
			if(!KEY[1]==1'b1)
			ay <= 1'b0;
			else
			ay <= SW[1];
		end
		
		always @(posedge !KEY[0] or posedge !KEY[1])
		begin
			if(!KEY[1]==1'b1)
			az <= 1'b0;
			else
			az <= SW[2];
		end
		
		always @(posedge !KEY[0] or posedge !KEY[1])
		begin
			if(!KEY[1]==1'b1)
			aw <= 1'b0;
			else
			aw <= SW[3];
		end
		
		//Second set of 4 D flip flops
		always @(posedge !KEY[0] or posedge !KEY[1])
		begin
			if(!KEY[1]==1'b1)
			bx <= 1'b0;
			else
			bx <= ax;
		end
		
		always @(posedge !KEY[0] or posedge !KEY[1])
		begin
			if(!KEY[1]==1'b1)
			by <= 1'b0;
			else
			by <= ay;
		end
		
		always @(posedge !KEY[0] or posedge !KEY[1])
		begin
			if(!KEY[1]==1'b1)
			bz <= 1'b0;
			else
			bz <= az;
		end
		
		always @(posedge !KEY[0] or posedge !KEY[1])
		begin
			if(!KEY[1]==1'b1)
			bw <= 1'b0;
			else
			bw <= aw;
		end
		//4 bit adder made previously
		assign xwire1 = ax^bx;
		assign xwire2 = xwire1&cin;
		assign xwire3 = ax&bx;
		assign LED[0] = xwire1^cin;
		assign outwirex = xwire2|xwire3;
	
		assign ywire1 = ay^by;
		assign ywire2 = ywire1&outwirex;
		assign ywire3 = ay&by;
		assign LED[1] = ywire1^outwirex;
		assign outwirey = ywire2|ywire3;
	
		assign zwire1 = az^bz;
		assign zwire2 = zwire1&outwirey;
		assign zwire3 = az&bz;
		assign LED[2] = zwire1^outwirey;
		assign outwirez = zwire2|zwire3;
		
		assign wwire1 = aw^bw;
		assign wwire2 = wwire1&outwirez;
		assign wwire3 = aw&bw;
		assign LED[3] = wwire1^outwirez;
		assign cout = wwire2|wwire3;
		
	endmodule