//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2021 12:53:17 PM
// Design Name: 
// Module Name: motor_spin_all
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


module motor_spin_all(
    input switch0,
    input switch1,
    input switch2,
    input switch3,
    output JC3,
    output JC9,
    output JC4,
    output JC10
    );
    
    assign JC3 = switch0;
    assign JC10 = switch1;
    assign JC4 = switch2;
    assign JC9 = switch3;
   
    
    
endmodule
