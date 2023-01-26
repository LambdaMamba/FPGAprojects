

module top(input  logic        clk, reset, 
           output logic [31:0] writedataM, aluoutM, 
           output logic        memwriteM);

  logic [31:0] pc, instr, readdata;
  logic [2:0] alucontrol;
  logic [5:0] op, funct;
   
  logic [1:0] aluop;
  logic       branch;
  
  logic [4:0]  writereg, writeregE;
  logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  logic [31:0] signimmD, signimmsh;
  logic [31:0] srca, srcb;
  logic [31:0] result;
  logic [31:0] instrD, instrE, instrM, instrW, pcplus4D;
  logic       memtoreg, alusrc, regdst, 
              regwrite, jump, zero;

	logic regwriteE, memtoregE, memwriteE, branchE; 
	logic [2:0] alucontrolE;
	logic alusrcE, regdstE;
	logic [31:0] srcaE, writedataE, srcbE;
	logic [31:0] srcaMUX, writedataMUX;
	logic [4:0] rtE, rdE, rsE;
	logic [31:0] signimmE, pcplus4E;
	
	logic regwriteM, memtoregM, memwrite, branchM;
	logic zeroM;
	logic [31:0] aluout, writedata;
	logic [4:0] writeregM;
	logic [31:0] pcbranchM;
	
	logic regwriteW;
	logic memtoregW;
	logic [31:0] aluoutW, readdataW;
	logic [4:0] writeregW;
	
	logic [1:0] forwardAE, forwardBE;
	

	
  
  // instantiate processor and memories
  
  imem imem(pc[7:2], instr);
  dmem dmem(clk, memwriteM, aluoutM, writedataM, readdata);
  
//  always_ff @(instr)
//	$display("pcsrc=%h", pcsrc);
  
  IF_ID IF_ID(clk, instr, pcplus4, instrD, pcplus4D);
  
  ID_EX ID_EX(clk, instrD[25:21], instrD, regwrite, memtoreg, memwrite, branch, alucontrol, alusrc, 
				  regdst, srca, writedata, instrD[20:16], instrD[15:11], signimmD, pcplus4D, 
				  regwriteE, memtoregE, memwriteE, branchE, alucontrolE,alusrcE, 
				  regdstE, srcaMUX, writedataMUX, rtE, rdE, signimmE, pcplus4E, instrE, rsE);
	

  EX_MEM EX_MEM(clk, instrE, regwriteE, memtoregE, memwriteE, branchE, 
					 zero, aluout, writedataE, writeregE, pcbranch,
					 regwriteM, memtoregM, memwriteM, branchM,
					 zeroM, aluoutM, writedataM, writeregM, pcbranchM, instrM);
					 
  MEM_WB MEM_WB(clk, instrM, regwriteM, memtoregM, aluoutM, readdata, writeregM,
					 regwriteW, memtoregW, aluoutW, readdataW,writeregW, instrW);
					 
  
  
  //controller
  
  
  
  assign op = instrD[31:26];
  assign funct = instrD[5:0];
 

  maindec md(op, memtoreg, memwrite, branch,
             alusrc, regdst, regwrite, jump, aluop);
  aludec  ad(funct, aluop, alucontrol);

  assign pcsrc = branchM & zeroM;
  //controller


  //datapath
			


  // next PC logic
  //always_ff @(pcnext) $display("pcnext: %h", pcnext);
  //flopr #(32) pcreg(clk, reset, pcnext, pc);
  //assume that there is no branch in this testso delete the pcsrc mux
  //directly feed pcplus4 into the pcreg
  
  flopr #(32) pcreg(clk, reset, pcnext, pc);
  adder       pcadd1(pc, 32'b100, pcplus4);
  always_ff @(pc) $display("current pc: %h", pc);
  sl2         immsh(signimmE, signimmsh);
  adder       pcadd2(pcplus4E, signimmsh, pcbranch);
  
  //this pcbrmux will not be use for now
  mux_dontcare pcbrmux(pcplus4, pcbranchM, pcsrc, pcnextbr);
  mux_dontcare pcmux(pcnextbr, {pcplus4[31:28], 
                    instrD[25:0], 2'b00}, jump, pcnext);

  // register file logic
  regfile     rf(clk, regwriteW, instrD[25:21], instrD[20:16], 
                 writeregW, result, srca, writedata);
  mux2 #(5)   wrmux(rtE, rdE, regdstE, writeregE);
  mux2 #(32)  resmux(aluoutW, readdataW, memtoregW, result);
  signext     se(instrD[15:0], signimmD);

  // ALU logic
  mux_dontcare3 muxsrca(srcaMUX, result, aluoutM, forwardAE, srcaE);
  mux_dontcare3 muxwritedata(writedataMUX, result, aluoutM, forwardBE, writedataE);
  
 
  mux2 #(32)  srcbmux(writedataE, signimmE, alusrcE, srcbE);
  alu         alu(srcaE, srcbE, alucontrolE, aluout, zero);
				  
  //datapath		  
				  
  hazardunit hazardunit(regwriteM, regwriteW, rsE, rtE, writeregM, writeregW,
						      forwardAE, forwardBE);
	
	
	
	
	always_ff @(forwardAE)
	begin
		case(forwardAE)
			2'b01: $display("Forwarded %h to srcaE from MEM/WB stage", result);
			2'b10: $display("Forwarded %h to srcaE from EX/MEM stage", aluoutM);
		endcase
	end
	
	
	always_ff @(forwardBE)
	begin
		case(forwardBE)
			2'b01: $display("Forwarded %h to writedataE from MEM/WB stage", result);
			2'b10: $display("Forwarded %h to writedataE from EX/MEM stage", aluoutM);
		endcase
	end
 
 
 
//	always_ff @(aluoutM)
//		$display("aluoutM = %h", aluoutM);
//		
//		
//	always_ff @(srcaE)
//		$display("srcaE = %h", srcaE);
//		
//	always_ff @(srcbE)
//		$display("srcbE = %h", srcbE);
				
endmodule

module dmem(input  logic        clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always_ff @(posedge clk) begin
		 if (we) begin
			RAM[a[31:2]] <= wd;
			$display("address %h now has data %h", a[31:0], wd);
		end
	end
endmodule



module imem(input  logic [5:0] a,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];
  
  //always_ff @(a) $display("pc: %h", a);

  initial
      $readmemh("/home/ln2/Desktop/IoT/MIPSproject/Pipeline/forwardtest.dat",RAM);

  assign rd = RAM[a]; // word aligned
  always_ff @(rd) 
  begin
  if(rd!=8'hx)
  $display("Fetched instruction %h", rd);
  end
endmodule


module maindec(input  logic [5:0] op,
               output logic       memtoreg, memwrite,
               output logic       branch, alusrc,
               output logic       regdst, regwrite,
               output logic       jump,
               output logic [1:0] aluop);

  logic [8:0] controls;

  assign {regwrite, regdst, alusrc, branch, memwrite,
          memtoreg, jump, aluop} = controls;

  always_comb
    case(op)
      6'b000000: controls <= 9'b110000010; // RTYPE
      6'b100011: controls <= 9'b101001000; // LW
      6'b101011: controls <= 9'b001010000; // SW
      6'b000100: controls <= 9'b000100001; // BEQ
      6'b001000: controls <= 9'b101000000; // ADDI
      6'b000010: controls <= 9'b000000100; // J
      default:   controls <= 9'bxxxxxxxxx; // illegal op
    endcase
endmodule

module aludec(input  logic [5:0] funct,
              input  logic [1:0] aluop,
              output logic [2:0] alucontrol);

  always_comb
    case(aluop)
      2'b00: alucontrol <= 3'b010;  // add (for lw/sw/addi)
      2'b01: alucontrol <= 3'b110;  // sub (for beq)
      default: case(funct)          // R-type instructions
          6'b100000: alucontrol <= 3'b010; // add
          6'b100010: alucontrol <= 3'b110; // sub
          6'b100100: alucontrol <= 3'b000; // and
          6'b100101: alucontrol <= 3'b001; // or
          6'b101010: alucontrol <= 3'b111; // slt
          default:   alucontrol <= 3'bxxx; // ???
        endcase
    endcase
endmodule



module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [4:0]  ra1, ra2, wa3, 
               input  logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[31:0];
  
  logic [4:0] regname;

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clk
  // register 0 hardwired to 0
  // note: for pipelined processor, write third port
  // on falling edge of clk

	
  always_ff @(negedge clk)
  begin
    if (we3) 
	 begin 
		rf[wa3] <= wd3;
		case(wa3)
			5'b10000: $display("content of $s0 = %h", wd3);
			5'b10001: $display("content of $s1 = %h", wd3);
			5'b10010: $display("content of $s2 = %h", wd3);
			5'b10011: $display("content of $s3 = %h", wd3);
			5'b10100: $display("content of $s4 = %h", wd3);
			5'b01000: $display("content of $t0 = %h", wd3);
			5'b01001: $display("content of $t1 = %h", wd3);
			default: $display("no");
		endcase
	 end
  end

	

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

module adder(input  logic [31:0] a, b,
             output logic [31:0] y);

  assign y = a + b;
endmodule

module sl2(input  logic [31:0] a,
           output logic [31:0] y);

  // shift left by 2
  assign y = {a[29:0], 2'b00};
endmodule

module signext(input  logic [15:0] a,
               output logic [31:0] y);
              
  assign y = {{16{a[15]}}, a};
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule


module mux_dontcare(input  logic [31:0] d0, d1, 
						input  logic             s, 
						output logic [31:0] y);

  always_ff @(*)
  begin
	case(s)
		1'b0 : y<=d0;
		1'bx : y<=d0;
		1'b1 : y<=d1;
	endcase
	end

endmodule




module mux_dontcare3(input  logic [31:0] d0, d1, d2,
						input  logic [1:0]           s, 
						output logic [31:0] y);

  always_ff @(*)
  begin
	case(s)
		2'bxx : y<=d0;
		2'b00 : y<=d0;
		2'b01 : y<=d1;
		2'b10 : y<=d2; 
	endcase
	end

endmodule




module alu(input  logic [31:0] a, b,
           input  logic [2:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);

  logic [31:0] condinvb, sum;

  assign condinvb = alucontrol[2] ? ~b : b;
  assign sum = a + condinvb + alucontrol[2];

  always_comb
    case (alucontrol[1:0])
      2'b00: result = a & b;
      2'b01: result = a | b;
      2'b10: result = sum;
      2'b11: result = sum[31];
    endcase

  assign zero = (result == 32'b0);
endmodule





module hazardunit(input logic regwriteM, regwriteW,
						input logic [4:0] rsE, rtE, 
						input logic [4:0] writeregM, writeregW,
						output logic [1:0] forwardAE, forwardBE);
						
		always_comb
		begin
			//$display("rsE=%h, rtE=%h, writeregM=%h, regwriteM=%h, writeregW=%h, regwriteW=%h", rsE, rtE, writeregM, regwriteM, writeregW, regwriteW);
			

			if((rsE!=5'b00000)&&(rsE==writeregM)&&regwriteM) forwardAE = 2'b10;
			else if ((rsE!=5'b00000)&&(rsE==writeregW)&&regwriteW) forwardAE = 2'b01;
			else forwardAE = 2'b00;
			
			if((rtE!=5'b00000)&&(rtE==writeregM)&&regwriteM) forwardBE = 2'b10;
			else if ((rtE!=5'b00000)&&(rtE==writeregW)&&regwriteW) forwardBE = 2'b01;
			else forwardBE = 2'b00;
		end
		
//		always_ff @(forwardAE)
//			$display("forwardAE=%b", forwardAE);
//			
//		always_ff @(forwardBE)
//			$display("forwardBE=%b", forwardBE);
//			
		
		//always_ff @(forwardAE) $display("forwardAE=%b", forwardAE);
						
endmodule
						




module IF_ID(input logic clk,
				 input logic [31:0] instr, pcplus4,
				 output logic [31:0] instrD, pcplus4D);
		always_ff @(posedge clk)
		begin
			//$display("IF to ID");
			instrD <= instr;
			pcplus4D <= pcplus4;
			if(instrD!=8'hx)
			$display("Instruction %h is in ID stage", instrD);
			//$display("pcplus4D: %h", pcplus4D);
		end
endmodule
			
			
			
			
module ID_EX(input logic clk,
				 input logic [4:0] rsD,
				 input logic [31:0] instrD,
				 input logic regwrite, memtoreg, memwrite, branch, 
				 input logic [2:0] alucontrol,
				 input logic alusrc, regdst,
				 input logic [31:0] srca, writedata,
				 input logic [4:0] rtD, rdD,
				 input logic [31:0] signimmD, pcplus4D,
				 output logic regwriteE, memtoregE, memwriteE, branchE, 
				 output logic [2:0] alucontrolE,
				 output logic alusrcE, regdstE,
				 output logic [31:0] srcaMUX, writedataMUX,
				 output logic [4:0] rtE, rdE,
				 output logic [31:0] signimmE, pcplus4E,
				 output logic [31:0] instrE,
				 output logic [4:0] rsE);
		always_ff @(posedge clk)
		begin
			//$display("ID to EX");
			regwriteE <= regwrite;
			memtoregE <= memtoreg;
			memwriteE <= memwrite;
			branchE <= branch;
			alucontrolE <= alucontrol;
			alusrcE <= alusrc;
			regdstE <= regdst;
			srcaMUX <= srca;
			writedataMUX <= writedata;
			rtE <= rtD;
			rdE <= rdD;
			signimmE <= signimmD;
			pcplus4E <= pcplus4D;
			instrE <= instrD;
			rsE <= rsD;
			if(instrE!=8'hx)
			$display("Instruction %h is in EX stage", instrE);
		end
endmodule


					 


module EX_MEM(input logic clk, 
				  input logic [31:0] instrE,
				  input logic regwriteE, memtoregE, memwriteE, branchE,
				  input logic zero, 
				  input logic [31:0] aluout, writedataE, 
				  input logic [4:0] writeregE, 
				  input logic [31:0] pcbranch,
				  output logic regwriteM, memtoregM, memwriteM, branchM,
				  output logic zeroM, 
				  output logic [31:0] aluoutM, writedataM,
				  output logic [4:0] writeregM, 
				  output logic [31:0] pcbranchM,
				  output logic [31:0] instrM);
	always_ff @(posedge clk)
	begin
		//$display("EX to MEM");
		regwriteM<=regwriteE;
		memtoregM<=memtoregE;
		memwriteM<=memwriteE;
		branchM<=branchE;
		zeroM<=zero;
		aluoutM<=aluout;
		writedataM<=writedataE;
		writeregM<=writeregE;
		pcbranchM<=pcbranch;
		instrM<=instrE;
		if(instrM!=8'hx)
		$display("Instruction %h is in MEM stage", instrM);
	end
endmodule

//ICCD

module MEM_WB(input logic clk,
				  input logic [31:0] instrM,
				  input logic regwriteM,
				  input logic memtoregM,
				  input logic [31:0] aluoutM, readdata,
				  input logic [4:0] writeregM,
				  output logic regwriteW,
				  output logic memtoregW,
				  output logic [31:0] aluoutW, readdataW,
				  output logic [4:0] writeregW,
				  output logic [31:0] instrW);
	always_ff @(posedge clk)
	begin
		//$display("MEM to WB");
		regwriteW<=regwriteM;
		memtoregW<=memtoregM;
		aluoutW<=aluoutM;
		readdataW<=readdata;
		writeregW<=writeregM;
		instrW<=instrM;
		if(instrW!=8'hx)
		$display("Instruction %h is in WB stage", instrW);
	end
endmodule




		
