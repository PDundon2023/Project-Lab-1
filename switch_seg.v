`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2021 12:41:56 AM
// Design Name: 
// Module Name: switch_seg
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


module switch_seg(
    input switch0,
    input switch1,
    input switch2,
    input switch3,
    output [6:0]seg,
    output [3:0] an
    );
    
    reg [6:0]seg_temp;
    reg an_temp = 4'b1110;
    
    always @(*)
        begin
            if(switch0 == 1)
                seg_temp = 7'b1000000;
                //0
            else if(switch1 == 1)
                seg_temp = 7'b1111001; 
                //1
            else if(switch2 == 1)
                seg_temp = 7'b0100100;
                //2
            else if(switch3 == 1)
                seg_temp = 7'b0110000;
                //3
            else
                seg_temp = 7'b0111111;          
        end
        
   assign seg = seg_temp;
   assign an = an_temp;
       
endmodule
