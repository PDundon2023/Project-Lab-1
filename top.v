//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2021 02:05:44 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
 input clk, reset,
 input  switch0, switch1, switch2, switch3, switch4, switch5, switch6, switch7,  
 input comp1, comp2,     
 output a, b, c, d, e, f, g, dp, //the individual LED output for the seven segment along with the digital point
 output [3:0]an,   // the 4 bit enable signal
 output JC3, JC4, JC9, JC10, pwm1, pwm2
 );

//initializing variables, don't really need reset but could still use I guess
//reset would be assigned to a button on the BASYS board

localparam N = 18;
reg [N-1:0]count; //the 18 bit counter which allows us to multiplex at 1000Hz
reg [22:0] counter;
reg [22:0] pulsewidth;
reg curr_pwm;

always @ (posedge clk or posedge reset)
 begin
  if (reset)
   count <= 0;
  else
   count <= count + 1;
 end

reg [6:0]sseg; //the 7 bit register to hold the data to output
reg [3:0]an_temp; //register for which enable pin is active for the seven segment display
reg [6:0]motor_temp;
reg JC3_temp, JC4_temp, JC9_temp, JC10_temp;

initial begin
    curr_pwm = 0;
    counter = 0;
    pulsewidth = 0;
end

always @(posedge clk)
begin 
    if(counter == 1666667)
        counter <= 0;
    else
        counter <= counter +1;
    if(counter < pulsewidth)
        curr_pwm =1;
    else
        curr_pwm =0;        
end

always @ (*)
 begin
  case(count[N-1:N-2]) //using only the 2 MSB's of the counter 
 
   2'b00 :  //When the 2 MSB's are 00 enable the fourth display
    begin
     an_temp = 4'b1110;
	  if(switch0 == 1)
	       begin
	           sseg = 4'd1;
	           motor_temp = 4'd1;
	       end
	  else if(switch1 == 1)
	       begin
	           sseg = 4'd2;
	           motor_temp = 4'd2;
	       end
	  else if(switch2 == 1)
	       begin
	           sseg = 4'd3;
	           motor_temp = 4'd3;
	       end
	  else if(switch3 == 1)
	       begin
	           sseg = 4'd4;
	           motor_temp = 4'd4;
	       end
	  else
	       begin
	           sseg = 4'd0;
	           motor_temp = 4'd0;
	       end
    end
   
   2'b01:  //When the 2 MSB's are 01 enable the third display
    begin
       an_temp = 4'b1101;
        if(switch4 == 1)
	       begin
	           sseg = 4'd5;
	           pulsewidth = 666667;
	       end
	    else if(switch5 == 1)
	       begin
	           sseg = 4'd6;
	           pulsewidth = 916667;
	       end
	    else if(switch6 == 1)
	       begin
	           sseg = 4'd7;
	           pulsewidth = 1166667;
	       end
	    else if(switch7 == 1)
	       begin
	           sseg = 4'd8;
	           pulsewidth = 1416667;
	       end
	    else
	       begin
	           sseg = 4'd0;
	           pulsewidth = 1666667;
	       end   
     
    end
   
   2'b10:  //When the 2 MSB's are 10 enable the second display
    begin
     sseg = 4'd9; 
     an_temp = 4'b1011;
    end
    
   2'b11:  //When the 2 MSB's are 11 enable the first display
    begin
     if(comp1 == 1)
        begin
            sseg = 4'd10;
        end
     else if(comp2 == 1)
        begin 
            sseg = 4'd10;
        end
     else
        begin 
            sseg = 4'd0;
        end        
     an_temp = 4'b0111;
    end
  endcase
  
end

assign an = an_temp;

reg [6:0] sseg_temp; // 7 bit register to hold the binary value of each input given

always @ (*)
 begin
  case(sseg)
   4'd0  : sseg_temp   = 7'b1000000; //to display 0
   4'd1  : sseg_temp   = 7'b0101111; //to display r  
   4'd2  : sseg_temp   = 7'b1000111; //to display L  
   4'd3  : sseg_temp   = 7'b0001110; //to display F  
   4'd4  : sseg_temp   = 7'b0000011; //to display b
   4'd5  : sseg_temp   = 7'b1111001; //to display 1
   4'd6  : sseg_temp   = 7'b0100100; //to display 2
   4'd7  : sseg_temp   = 7'b0110000; //to display 3
   4'd8  : sseg_temp   = 7'b0011001; //to display 4
   4'd9  : sseg_temp   = 7'b0001000; //to display A
   4'd10 : sseg_temp   = 7'b1111001; //to display 1
   default : sseg_temp = 7'b0111111; //to display -
  endcase
 end

always @(*)
begin
    case(motor_temp)
        4'd0:
            begin
                JC3_temp  = 0;
                JC4_temp  = 0;
                JC9_temp  = 0;
                JC10_temp = 0;
            end
        
        4'd1: //turn right
            begin
                JC3_temp = 0;
                JC4_temp = 1;
                JC9_temp = 0;
                JC10_temp = 0;
            end
        4'd2: //turn left
            begin
                JC3_temp = 0;
                JC4_temp = 0;
                JC9_temp = 1;
                JC10_temp = 0;
            end 
        4'd3: //forward
            begin
                JC3_temp = 0;
                JC4_temp = 1;
                JC9_temp = 1;
                JC10_temp = 0;
            end 
        4'd4: //backwards
            begin
                JC3_temp = 1;
                JC4_temp = 0;
                JC9_temp = 0;
                JC10_temp = 1;
            end 
        default: //no moving
            begin
                JC3_temp  = 0;
                JC4_temp  = 0;
                JC9_temp  = 0;
                JC10_temp = 0;
            end
    endcase
end


assign {g, f, e, d, c, b, a} = sseg_temp; //concatenate the outputs to the register, this is just a more neat way of doing this.
// I could have done in the case statement: 4'd0 : {g, f, e, d, c, b, a} = 7'b1000000; 
// its the same thing.. write however you like it

assign dp = 1'b1; //since the decimal point is not needed, all 4 of them are turned off

assign JC3 = JC3_temp;
assign JC4 = JC4_temp;
assign JC9 = JC9_temp;
assign JC10 = JC10_temp;
assign pwm1 = curr_pwm;
assign pwm2 = curr_pwm;

//to display right     -> 7'b0101111 -> r
//to disaply left      -> 7'b1000111 -> L
//to display forward   -> 7'b0001111 -> F
//to display backwards -> 7'b0100001 -> b

//need to use at least 8 switches
//4 switches for speed     -> 1,2,3,4
//4 switches for direction -> r,L,F,b
//need a temp variable for the 1st digit to display 1 Amp -> -A until 1 Amp is detected where it will change to 1A;

//this should just need to be updated to account for PWM and the input for the comparator cicuit input


    
endmodule
