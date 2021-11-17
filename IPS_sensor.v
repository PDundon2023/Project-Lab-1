module IPS_sensor(
    input ips_r, ips_L, clk,obs_det,     
    output RMF,RMB,LMF,LMB, LM_pwm,RM_pwm   
    );
    
    reg[22:0] counter_r;
    reg[22:0] counter_L;
    reg[22:0] pulsewidth_r;
    reg[22:0] pulsewidth_L;
    reg RM_pwm_temp;
    reg LM_pwm_temp;
    
    reg [6:0] motor_temp;
    reg RMF_temp, RMB_temp, LMF_temp, LMB_temp;
    reg [6:0] state_temp;
    reg [6:0] obs_state;
    reg state_two;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
always@(posedge clk)
    begin
        if(counter_r == 1666667)
            counter_r <= 0;
        else
            counter_r <= counter_r +1;
        if(counter_r < pulsewidth_r)
            RM_pwm_temp  = 1;
        else
            RM_pwm_temp = 0;  
    end
    
always@(posedge clk)
    begin
        if(counter_L == 1666667)
            counter_L <= 0;
        else
            counter_L <= counter_L +1;
        if(counter_L < pulsewidth_L)
            LM_pwm_temp = 1;
        else
            LM_pwm_temp = 0;  
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 

always@(*)
begin
    if(obs_det == 0)
     begin
        state_temp = 4'd1;
     end
    else 
     begin
        state_temp = state_temp;
     end
     
     
    case(state_temp)
    4'd0: // normal state
        begin
           if(ips_L == 1 && ips_r == 1)
                begin
                    pulsewidth_L = 1333333;
                    pulsewidth_r = 1333333;
                    motor_temp = 4'd0;
                end 
          else if(ips_L == 1)
                begin
                    pulsewidth_L = 1333333;
                    pulsewidth_r = 1333333;
                    motor_temp = 4'd1;
                end
          else if(ips_r == 1)
                begin
                    pulsewidth_L = 1333333;
                    pulsewidth_r = 1333333;
                    motor_temp = 4'd2;
                end
          else
                begin
                    pulsewidth_L = 1333333;
                    pulsewidth_r = 1333333;
                    motor_temp = 4'd0;
                end
        end
        4'd1: // start of obstalce state
         begin
            if(ips_r == 1) // alterante path is detected 
             begin
                state_temp = 4'd2;
             end
            else if(ips_r == 0)
             begin
                pulsewidth_L = 500000;
                pulsewidth_r = 500000;
                motor_temp = 4'd4; // go backwards
             end
         end
        
        4'd2:
         begin
           if(ips_L == 1) // rover is now on the altertante path                                      
             begin
                state_temp = 4'd3;
             end
            else if(ips_L == 0)
             begin
                pulsewidth_L = 500000;
                pulsewidth_r = 500000;
                motor_temp = 4'd2; // turn right while detecting alterante path
             end
         end
        4'd3:
         begin
            if(ips_L == 0)
             begin
                state_temp = 4'd4;
             end
            else if(ips_L == 1)
             begin
                pulsewidth_L = 500000;
                pulsewidth_r = 500000;
                motor_temp = 4'd2; // turn right while detecting alterante path
             end
         end
        4'd4:
         begin
            if(ips_L == 1)
             begin
                state_temp = 4'd0;
             end
            else if(ips_L == 0)
             begin
                pulsewidth_L = 500000;
                pulsewidth_r = 500000;
                motor_temp = 4'd2; // turn right while detecting alterante path
             end
         end
   default:
        begin
            if(ips_L == 1 && ips_r == 1)
                begin
                    pulsewidth_L = 1333333;
                    pulsewidth_r = 1333333;
                    motor_temp = 4'd0;
                end 
          else if(ips_L == 1)
                begin
                    pulsewidth_L = 1333333;
                    pulsewidth_r = 1333333;
                    motor_temp = 4'd1;
                end
          else if(ips_r == 1)
                begin
                    pulsewidth_L = 1333333;
                    pulsewidth_r = 1333333;
                    motor_temp = 4'd2;
                end
          else
                begin
                    pulsewidth_L = 1333333;
                    pulsewidth_r = 1333333;
                    motor_temp = 4'd0;
                end       
        end       
    endcase
    
end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(*)
     begin 
        case(motor_temp)
            4'd0: // forwards
                begin
                    RMF_temp  =  1;
                    RMB_temp  =  0;
                    LMF_temp  =  1;
                    LMB_temp  =  0;
                end
            4'd1: // left turn
                begin
                    RMF_temp  =  1;
                    RMB_temp  =  0;
                    LMF_temp  =  0;
                    LMB_temp  =  1;
                end
           4'd2: // right turn
                begin
                    RMF_temp  =  0;
                    RMB_temp  =  1;
                    LMF_temp  =  1;
                    LMB_temp  =  0;
                end
          4'd3: // Stop
                begin
                    RMF_temp  =  0;
                    RMB_temp  =  0;
                    LMF_temp  =  0;
                    LMB_temp  =  0;
                end
          4'd4: // Backwards
                begin
                    RMF_temp  =  0;
                    RMB_temp  =  1;
                    LMF_temp  =  0;
                    LMB_temp  =  1;
                end
           default: // forwards
                begin
                    RMF_temp  =  1;
                    RMB_temp  =  0;
                    LMF_temp  =  1;
                    LMB_temp  =  0;
                end
        endcase
     end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    
    assign RM_pwm = RM_pwm_temp; //JC2
    assign LM_pwm = LM_pwm_temp; //JC8
    
    assign RMF = RMF_temp;
    assign RMB = RMB_temp;
    assign LMF = LMF_temp;
    assign LMB = LMB_temp;
    
    
endmodule