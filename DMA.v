`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////////
module DMA(

	input clk,
	input reset,
   input [3:0] dreq,
	input cs,
	input hack,

	inout mem_to_mem,	
	inout IO,
	inout [7:0] data,
	inout [3:0] A3_A0,
	inout eop ,
	
	output reg memory,
	output reg hreq,
	output reg [3:0] dack,
	output reg [3:0] A7_A4


	);
/* registers used to output data at inout ports */
reg mem_to_mem_reg;
reg eop_reg;
reg IO_reg;
reg [7:0] data_reg;
reg [3:0] A3_A0_reg;

/* register and paramters  used for finite state machine implementation of the design */ 
reg state;
parameter 	idle=1'b0,
			active=1'b1;
/* register and paramters  used for finite state machine implementation of the memory to memory tranfer */ 
reg mem_to_mem_state;
/* extra parameter 1 for read and 0 for write*/			 
parameter	 read=1'b1,
			 write=1'b0,
			 channel0=0,
			 channel1=1,
			 channel2=2,
			 channel3=3;
			 
/* each channel has current address register to hold address used during DMA transfer*/			 
reg [7:0] current_address [0:3];

/* mem_to_mem_enable give the cpu the ability to disable memory to memory data transfer type*/ 
reg mem_to_mem_enable;			 
/* mode register used to determine the transfer type of each channel is either write or read
 as every bit represents a channel , also 1 for read and 0 for write */ 
reg [3:0] mode;			 
/* mask reg used to disable channels even if devices has requested a DMA transfer*/
reg [3:0] mask;
/* temp register is used at memory to memory transfer data type to exchange data*/
reg [7:0] temp;

			 
always @(posedge clk or posedge reset) begin  
if (reset) begin
/*when reset signal is high we enter Idle state and reseting all registers 
also enabling memory to memory transfer as a default state 
by setting mem_to_mem_enable to high*/
state<=idle;
mem_to_mem_state<=read;
eop_reg<=0;
data_reg<=0;
A3_A0_reg<=0;
mem_to_mem_enable<=1;
mode<=0;
mask<=0;
temp<=0; 

end
	else begin 
			case (state)
/* 						Idle state
DMA enters idle state when no channel are requesting service.
check dreq every cycle to determine if any device requested the DMA service and 
if there's a request a dreq signal is sent to cpu to ask for controling the buses.
at idle state the cpu could programe the DMA by writing data at the internal registers
and this done using cs , IO A3_A0 as input control signals and data bus for data transfer*/

			idle: if(hack) begin 
					state <= active;
				  end			
				  else if (dreq != 0 || mem_to_mem ==1) begin
					hreq <= 1;
				  end
				else begin
/* programming the DMA by the cpu*/							
							case ({cs,IO,A3_A0})
							6'b011000: mem_to_mem_enable <= data[0];
							6'b011011: mode <= data[3:0];
							6'b011111: mask <= data[3:0];
							6'b010000: current_address[channel0] <= data;
							6'b010010: current_address[channel1] <= data;
							6'b010100: current_address[channel2] <= data;
							6'b010110: current_address[channel3] <= data;
							default: state <= idle;
								endcase
					end
/*												ACTIVE state  				
state where transfer of data is done. data could transfer from memory to I/O and vise versa with no 
need to store data at DMA. also data could be transfered from memory location to another one 
by saving the data temperory at temp register inside DMA ,data is transfered by a demand transfer mode that
continue making transfers until a TC or external EOP is encountered or until DREQ goes inactive.*/			
		
		active: begin
								state <= idle; 
								hreq <= 0;
								
/* tranfer data is done by checking if  there's a memory to memory tranfer as highist priority then check  which channel has requested 
the service and for fixed channel priority (high priority for channel0). then output signals required for either read or write mode    */	
						if(mem_to_mem_enable&&mem_to_mem) begin							
							case (mem_to_mem_state)
							
							read: begin
								mem_to_mem_state <= write;
								A3_A0_reg <=  current_address [channel0] [3:0] ;
								A7_A4 <= current_address [channel0] [7:4];
								memory <= read;
								temp <= data;
							end
							write: begin
								mem_to_mem_state <= read;
								A3_A0_reg <=  current_address [channel1] [3:0] ;
								A7_A4 <= current_address [channel1] [7:4];
								memory <= write;
								data_reg <= temp;
								mem_to_mem_reg <= 1'b1;
							end
							endcase
						
						end	
						
							if (dreq[channel0]== 1) begin
									A3_A0_reg <=  current_address [channel0] [3:0] ;
									A7_A4 <= current_address [channel0] [7:4]	;
									if(mode[channel0]==read) begin
										memory <= read;
										IO_reg <= write;
									end
									else begin
										memory <= write;
										IO_reg <= read;
									end
							end
							
							else if (dreq[channel1]== 1) begin
									A3_A0_reg <=  current_address [channel1] [3:0] ;
									A7_A4 <= current_address [channel1] [7:4]	;
									if(mode[channel1]==read) begin
										memory <= read;
										IO_reg <= write;
									end
									else begin
										memory <= write;
										IO_reg <= read;
									end
							end
							
							
							else if (dreq[channel2]== 1) begin
									A3_A0_reg <=  current_address [channel2] [3:0] ;
									A7_A4 <= current_address [channel2] [7:4]	;
									if(mode[channel2]==read) begin
										memory <= read;
										IO_reg <= write;
									end
									else begin
										memory <= write;
										IO_reg <= read;
									end
							end
							
							
							else if (dreq[channel3]== 1) begin
									A3_A0_reg <=  current_address [channel3] [3:0] ;
									A7_A4 <= current_address [channel3] [7:4]	;
									if(mode[channel3]==read) begin
										memory <= read;
										IO_reg <= write;
									end
									else begin
										memory <= write;
										IO_reg <= read;
									end
							end
																													
					
					end
	
	
	endcase 
	end


end
	assign mem_to_mem = mem_to_mem_reg; 		 
	assign data = data_reg;
	assign A3_A0 = A3_A0_reg;
	assign eop = eop_reg; 
	assign IO = IO_reg;


endmodule
