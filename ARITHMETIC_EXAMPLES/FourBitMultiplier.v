	`timescale 1ns/1ns
			
			module FourBitMultiplier 
				(
				input [1:0] KEY,
				input [3:0] SW,
				output [7:0] LED
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
				
				wire bxax, bxay, bxaz, bxaw;
				wire byax, byay, byaz, byaw;
				wire bzax, bzay, bzaz, bzaw;
				wire bwax, bway, bwaz, bwaw;
				
				wire si1, si2, si3, si4;
				wire ci1, ci2, ci3, ci4;
				
				wire sj1, sj2, sj3, sj4;
				wire cj1, cj2, cj3, cj4;
				
				wire sk1, sk2, sk3, sk4;
				wire ck1, ck2, ck3, ck4;
				
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
				
				assign bxax = bx&ax;
				assign bxay = bx&ay;
				assign bxaz = bx&az;
				assign bxaw = bx&aw;
				
				assign byax = by&ax;
				assign byay = by&ay;
				assign byaz = by&az;
				assign byaw = by&aw;
				
				//first row of 4 bit adders
				
				assign si1 = (bxay^byax)^cin;
				assign ci1 = ((bxay^byax)&cin)|(bxay&byax);
			
				assign si2 = (bxaz^byay)^ci1;
				assign ci2 = ((bxaz^byay)&ci1)|(bxaz&byay);
			
				assign si3 = (bxaw^byaz)^ci2;
				assign ci3 = ((bxaw^byaz)&ci2)|(bxaw&byaz);
				
				assign si4 = (0^byaw)^ci3;
				assign ci4 = ((0^byaw)&ci3)|(0&byaw);
				
				assign bzax = bz&ax;
				assign bzay = bz&ay;
				assign bzaz = bz&az;
				assign bzaw = bz&aw;
				
				//second row of 4 bit adders
				assign sj1 = (bzax^si2)^cin;
				assign cj1 = ((bzax^si2)&cin)|(bzax&si2);
				
				assign sj2 = (bzay^si3)^cj1;
				assign cj2 = ((bzay^si3)&cj1)|(bzay&si3);
				
				assign sj3 = (bzaz^si4)^cj2;
				assign cj3 = ((bzaz^si4)&cj2)|(bzaz&si4);
				
				assign sj4 = (bzaw^ci4)^cj3;
				assign cj4 = ((bzaw^ci4)&cj3)|(bzaw&ci4);
				
				assign bwax = bw&ax;
				assign bway = bw&ay;
				assign bwaz = bw&az;
				assign bwaw = bw&aw;
				
				//third row of 4 bit adders
				assign sk1 = (bwax^sj2)^cin;
				assign ck1 = ((bwax^sj2)&cin)|(bwax&sj2);
				
				assign sk2 = (bway^sj3)^ck1;
				assign ck2 = ((bway^sj3)&ck1)|(bway&sj3);
				
				assign sk3 = (bwaz^sj4)^ck2;
				assign ck3 = ((bwaz^sj4)&ck2)|(bwaz&sj4);
				
				assign sk4 = (bwaw^cj4)^ck3;
				assign ck4 = ((bwaw^cj4)&ck3)|(bwaw&cj4);
				
				
				assign LED[0] = bxax;
				assign LED[1] = si1;
				assign LED[2] = sj1;
				assign LED[3] = sk1;
				assign LED[4] = sk2;
				assign LED[5] = sk3;
				assign LED[6] = sk4;
				assign LED[7] = ck4;
	endmodule