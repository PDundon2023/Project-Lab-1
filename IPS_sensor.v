module IPS_sensor(
    input ips_r, ips_L, ips_a, clk,obs_det,     
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
    reg [6:0] pwm_state;

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
        4'd0: // normal state or green state
         begin
           pwm_state = 4'd0; // sets speed to 100%
           
           if(ips_L == 0 && ips_r == 0)
                begin
                    motor_temp = 4'd0;
                    state_temp = 4'd0;
                end 
          else if(ips_L == 0)
                begin                  
                    motor_temp = 4'd1;
                    state_temp = 4'd0;
                end
          else if(ips_r == 0)
                begin                   
                    motor_temp = 4'd2;
                    state_temp = 4'd0;
                end
          else
                begin
                    motor_temp = 4'd0;
                    state_temp = 4'd0;
                end
        end
        
        4'd1: // start of obstalce state
         begin
            pwm_state = 4'd1; // 50% speeed
                     
            if(ips_a == 0) // alterante path is detected 
             begin           
                state_temp = 4'd2; //chnage into next state
             end
            else 
             begin
                motor_temp = 4'd4; // go backwards
                state_temp = 4'd1;
             end
         end
        
       4'd2: // state once the alternate path is detected to turn right onto the path
        begin
            pwm_state = 4'd2; // 50% speed
            if(ips_r == 0)
             begin
                state_temp = 4'd7; // blue state
             end
            else 
             begin
                motor_temp = 4'd2;
                state_temp = 4'd2;                
             end
        end 
        
        4'd4: // RED STATE
         begin
            motor_temp = 4'd3;
            pwm_state = 4'd6;
            state_temp = 4'd4;
         end
                                   
        4'd7: // state for the alterante path and to get off the alternate path (blue state)
         begin
          pwm_state = 4'd2;
            
          if(ips_a == 0)
                begin
                    state_temp = 4'd2;
                end
            
          else if(ips_L == 0 && ips_r == 0)
                begin
                    motor_temp = 4'd0;
                    state_temp = 4'd7;
                end 
          else if(ips_L == 0)
                begin                  
                    motor_temp = 4'd1;
                    state_temp = 4'd7;
                end
          else if(ips_r == 0)
                begin                   
                    motor_temp = 4'd2;
                    state_temp = 4'd7;
                end
          else
                begin
                    motor_temp = 4'd0;
                    state_temp = 4'd7;
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
           default:
                begin
                    motor_temp = motor_temp;
                end
        endcase
     end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(*)
    begin
        case(pwm_state)
        4'd0: // 100% Duty cycle
         begin
             pulsewidth_L = 1666667;
             pulsewidth_r = 1666667;
         end
        4'd1: // 80% duty cycle
         begin
            pulsewidth_L = 1333333;
            pulsewidth_r = 1333333;
         end
        4'd2: // 50& duty cycle
         begin
            pulsewidth_L = 833334;
            pulsewidth_r = 833334;
         end
        4'd3: // 30% duty cycle
         begin
            pulsewidth_L = 500000;
            pulsewidth_r = 500000;
         end
        4'd4:// 20% duty cycle
         begin
            pulsewidth_L = 333333;
            pulsewidth_r = 333333;            
         end
         4'd5: // 25% speed
          begin 
            pulsewidth_L = 416666;
            pulsewidth_r = 416666;
          end
         4'd6: // stop
          begin
            pulsewidth_L = 0;
            pulsewidth_r = 0;
          end
         4'd7: // 65% speed
          begin
            pulsewidth_L = 1083333;
            pulsewidth_r = 1083333;
          end
               
        endcase
    end

    
    assign RM_pwm = RM_pwm_temp; //JC2
    assign LM_pwm = LM_pwm_temp; //JC8
    
    assign RMF = RMF_temp;
    assign RMB = RMB_temp;
    assign LMF = LMF_temp;
    assign LMB = LMB_temp;
    
    
endmodule