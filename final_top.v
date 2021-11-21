
module final_top(
    input freqIn,
    input clk,
    input ips_r, ips_L, ips_a,
    input obs_det,
    output RMF,RMB,LMF,LMB, LM_pwm,RM_pwm,  
    output select0,
    output select1,
    output reg select2,
    output reg select3,
    output EO,
    output [3:0]an, 
    output a, b, c, d, e, f, g 
    );
    
    reg [24:0] red;
    reg [24:0] green;
    reg [24:0] blue;
    reg [24:0] clear;
    reg prevFreq;
    reg [26:0] counter;
    reg [26:0] clkCount;
    reg [24:0] freqCount;
    reg [24:0] freq;
    reg JC3_temp, JC4_temp, JC9_temp, JC10_temp, curr_pwm_r, curr_pwm_L;
    reg [3:0]sseg;
    reg [6:0]sseg_temp;
    reg [3:0] colState;
    
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
  
    reg green_state;
    reg red_state;
    reg blue_state;
      
    initial begin
    red = 0;
    green = 0;
    blue = 0;
    clear = 0;
    counter = 0;
    freqCount = 0;
    clkCount = 0;
    freq = 0;
    colState = 0;
    select2 = 0;
    select3 = 0;
    //prevFreq = 0;
    end
       
    assign EO = 0;
    assign select0 = 1;
    assign select1 = 0;
    //assign select2 = 0;
    //assign select3 = 1;
    assign an = 4'b0111;
    
    initial begin
    
        state_temp = 4'd0;
        
    end
    
    always@ (posedge clk)
    begin
        counter <= counter + 1;    
        prevFreq <= freqIn;
    
        if(freqIn == 1 && prevFreq == 0)
        begin
            freqCount <= freqCount + 1;
        end    
        else if(counter == 3_125_000)
        begin
            freq <= freqCount << 5;
            freqCount <= 0;
            counter <= 0;
        end
    end
    
    always@(negedge clk)
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
    
    always@(negedge clk)
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

    always@ (posedge clk)
    begin
    case(colState)
    0 : begin // red filter select
            clkCount <= clkCount + 1;
            if(clkCount == 3_125_000)
            begin 
                red <= freq;
                //red = red - 10000;
                clkCount <= 0;
                colState <= 1;
                select2 <= 0;
                select3 <= 1;
            end
        end
        
    1 : begin // blue filter select
            clkCount <= clkCount + 1;
            if(clkCount == 3_125_000)
            begin
                blue <= freq;
                clkCount <= 0;
                colState <= 2;
                select2 <= 1;
                select3 <= 1;
            end
        end
    2 : begin
            clkCount <= clkCount + 1;
            if(clkCount == 3_125_000)
            begin
                green <= freq;
                clkCount <= 0;
                colState <= 3;
                select2 <= 0;
                select3 <= 0;
            end
        end
    3: begin
         if(blue < green && red > blue && blue > 1000) // green state
            begin
                sseg_temp   = 7'b0000010;
                blue_state  = 0;
                green_state = 1;
                red_state   = 0;
            end
         else if(red < green && red < blue && red > 700) // red state 
            begin   
                sseg_temp   = 7'b0101111;
                blue_state  = 0;
                green_state = 0;
                red_state   = 1;
            end
         else if(green > blue && red > blue && green > 1700) // blue state
            begin
                sseg_temp   = 7'b0000011;
                blue_state  = 1;
                green_state = 0;
                red_state   = 0;
            end
         else
            begin
                sseg_temp = 7'b0111111;
                blue_state = blue_state;
                red_state = red_state;
                green_state = green_state;
            end
            colState <= 0;
            select2 <= 0;
            select3 <= 0;
        end
    endcase
    end

always@(*)
begin
    if(obs_det == 0)
     begin
          state_temp = 4'd1;
     end
    else if(red_state == 1)
     begin
          pwm_state = 4'd6;
     //   state_temp = 4'd9;
     end
    else if(blue_state == 1)
     begin
          pwm_state = 4'd2;
     //   state_temp = 4'd7;
     end
    else if(green_state == 1)
     begin
          pwm_state = 4'd0;
     //   state_temp = 4'd0;
     end
    else 
     begin
        state_temp = state_temp;
     end
     
     
    case(state_temp)
        4'd0: // normal state or green state
         begin
          // pwm_state = 4'd1; // sets speed to 100%
           
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

            if(ips_r == 1)
             begin
                motor_temp = 4'd2;
                state_temp = 4'd2; 
             end
            else 
             begin
              //  motor_temp = 4'd2;
                state_temp = 4'd6;                
             end
        end 
        
        4'd9: // RED STATE
         begin
            motor_temp = 4'd3;
        //    pwm_state = 4'd6;
            state_temp = 4'd4;
         end
                                   
        4'd6: // state for the alterante path and to get off the alternate path (blue state)
         begin

            
         if(ips_L == 0 && ips_r == 0)
                begin
                    motor_temp = 4'd0;
                    state_temp = 4'd6;
                end 
          else if(ips_L == 0)
                begin                  
                    motor_temp = 4'd1;
                    state_temp = 4'd6;
                end
          else if(ips_r == 0)
                begin                   
                    motor_temp = 4'd2;
                    state_temp = 4'd6;
                end
          else if(ips_a == 0)
           begin
                   state_temp = 4'd2;
           end
          else
                begin
                    motor_temp = 4'd0;
                    state_temp = 4'd6;
                end
            
         end
        
    endcase
    
end



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


  
    assign {g, f, e, d, c, b, a} = sseg_temp;
    
    assign RM_pwm = RM_pwm_temp; //JC2
    assign LM_pwm = LM_pwm_temp; //JC8
    
    assign RMF = RMF_temp;
    assign RMB = RMB_temp;
    assign LMF = LMF_temp;
    assign LMB = LMB_temp;
       
endmodule
