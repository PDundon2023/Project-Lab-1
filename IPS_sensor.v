`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2021 12:30:08 PM
// Design Name: 
// Module Name: IPS_sensor
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


module IPS_sensor(

    input ips_r, ips_L, clk,obs_det,  
    
    output JC3,JC4,JC9,JC10, pwm1,pwm2
    
    );
    
    reg[22:0] counter_r;
    reg[22:0] counter_L;
    reg[22:0] pulsewidth_r;
    reg[22:0] pulsewdth_L;
    reg curr_pwm_r;
    reg curr_pwm_L;
    
    reg[6:0] motor_temp;
    reg JC3_temp, JC4_temp, JC9_temp, JC10_temp;
    reg[6:0] state_temp;
    
    always@(posedge clk)
    begin
        if(counter_r == 1666667)
            counter_r <= 0;
        else
            counter_r <= counter_r +1;
        if(counter_r < pulsewidth_r)
            curr_pwm_r  = 1;
        else
            curr_pwm_r = 0;  
    end
    
    always@(posedge clk)
    begin
        if(counter_L == 1666667)
            counter_L <= 0;
        else
            counter_L <= counter_L +1;
        if(counter_L < pulsewidth_r)
            curr_pwm_L  = 1;
        else
            curr_pwm_L = 0;  
    end
    
    always@(*)
    begin
       if(ips_L == 1)
        begin
            state_temp = 4'd1;
        end
       else if(ips_r == 1)
        begin
            state_temp = 4'd2;
        end
       else if(ips_r == 1 && ips_L ==1)
        begin
            state_temp = 4'd3;
        end
       else
        begin
            state_temp = 4'd0;
        end
        
       if(obs_det == 0)
        begin
            state_temp = 4'd0;
        end   
    end
    
    always@(*)
        case(state_temp)
            4'd0: // rover continues forwards - neither ips sensor detected anything
                begin
                    pulsewdth_L  = 833334;
                    pulsewidth_r = 833334;
                    motor_temp = 4'd0;
                end
            4'd1: // rover turns left - left ips sensor detected something
                begin
                    pulsewdth_L  = 500000;
                    pulsewidth_r = 833334;
                    motor_temp = 4'd1;      
                end
            4'd2: // rover turns right - right ips sensor detected something
                begin
                    pulsewdth_L  = 833334;
                    pulsewidth_r = 500000;
                    motor_temp = 4'd2;    
                end
           4'd3:
                begin
                    pulsewidth_r = 833334;
                    pulsewdth_L  = 833334;
                    motor_temp = 4'd1;
                end
            default: // rover will continue forward
                begin
                    pulsewdth_L  = 833334;
                    pulsewidth_r = 833334;
                    motor_temp = 4'd0;   
                end
        endcase
     always@(*)
     begin 
        case(motor_temp)
            4'd0: // forwards
                begin
                    JC3_temp  =  0;
                    JC4_temp  =  1;
                    JC9_temp  =  1;
                    JC10_temp =  0;
                end
            4'd1: // left turn
                begin
                    JC3_temp  =  1;
                    JC4_temp  =  0;
                    JC9_temp  =  1;
                    JC10_temp =  0;
                end
           4'd2: // right turn
                begin
                    JC3_temp  =  0;
                    JC4_temp  =  1;
                    JC9_temp  =  0;
                    JC10_temp =  1;
                end
           default: // forwards
                begin
                    JC3_temp  =  0;
                    JC4_temp  =  1;
                    JC9_temp  =  1;
                    JC10_temp =  0; 
                end
        endcase
     end
    
    
    assign pwm1 = curr_pwm_L;
    assign pwm2 = curr_pwm_r;
    
    assign JC3 = JC3_temp;
    assign JC4 = JC4_temp;
    assign JC9 = JC9_temp;
    assign JC10 = JC10_temp;
    
    
endmodule
