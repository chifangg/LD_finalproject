module Top(
    input clk,
    input rst,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    inout PS2_DATA,   // Keyboard I/O
    inout PS2_CLK,    // Keyboard I/O
    output reg [15:0] led,
    output IN1,
    output IN2,
    output IN3, 
    output IN4,
    output left_pwm,
    output right_pwm,
    input echo,
    output trig,
    output mid_pwm,
    output mid_pwm_2,
    output IN5,
    output IN6,
    output IN7,
    output IN8
    );
    
    reg [6:0] timer;

//      debounce and onepulse
    wire clk_25MHz;
    clock_divider #(.n(2)) clock_25(.clk(clk), .clk_div(clk_25MHz));
    debounce de_1(rst_debounced, rst ,clk);
    onepulse op_0(rst_debounced, clk_25MHz, rst_25M);
    onepulse op_1(rst_debounced, clk, rst_normal);
    
//      FSM
    reg [2:0] state, next_state;
    parameter INIT = 3'b000;
    parameter PLAYER1 = 3'b001;
    parameter PAUSE = 3'b010;
    parameter PLAYER2 = 3'b011;
    parameter GAMEOVER = 3'b100;
    integer flag = 0;
    wire [19:0] distance;
    reg [3:0] P1_score, P2_score;
    reg [1:0] score_flag;

    
    always@(posedge clk, posedge rst_normal) begin
        if(rst_normal) begin
            state <= INIT;
        end
        else begin
            state <= next_state;
        end
    end
    
    always@(*) begin
        case(state)
            INIT: begin
                led[4:0] = 5'b00001;
                if(flag == 1) begin
                    next_state = PLAYER1;
                end
                else begin
                    next_state = state;
                end
            end
            PLAYER1: begin
                led[4:0] = 5'b00010;
                if(timer == 0) begin
                    next_state = PAUSE;
                end
                else begin
                    next_state = state;
                end
            end
            PAUSE: begin
                led[4:0] = 5'b00100;
                if(flag == 1) begin
                    next_state = PLAYER2;
                end
                else begin
                    next_state = state;
                end
            end
            PLAYER2: begin
                led[4:0] = 5'b01000;
                if(timer == 0) begin
                    next_state = GAMEOVER;
                end
                else begin
                    next_state = state;
                end
            end
            GAMEOVER: begin
                led[4:0] = 5'b10000;
                if(timer == 3) begin
                    next_state = INIT;
                end
                else begin
                    next_state = state;
                end
            end
        endcase
    end
    
//     Timer
    reg [31:0] counter;
    always@(posedge clk) begin
        case(state)
            INIT: begin
                counter = 0;
                timer = 30;
            end
            PLAYER1: begin
                counter = counter + 1;
                if(counter == 100000000) begin
                    counter = 0;
                    timer = timer - 1;
                end
            end
            PAUSE: begin
                counter = 0;
                timer = 30;
            end
            PLAYER2: begin
                counter = counter + 1;
                if(counter == 100000000) begin
                    counter = 0;
                    timer = timer - 1;
                end
            end
            GAMEOVER: begin
                counter = counter + 1;
                if(counter == 100000000) begin
                    counter = 0;
                    timer = timer + 1;
                end
            end
        endcase
    end

//      Keyboard
    wire [144:0] key_down;
    wire [8:0] last_change;
    wire been_ready;
    KeyboardDecoder key_de (
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst_normal),
        .clk(clk)
    );
    
    parameter [8:0] KEY_CODES [0:5] = {
        9'b0_0001_1100, // A => 1C
        9'b0_0010_0011, // D => 23
        9'b0_0010_1001, // space => 29
        9'b0_0110_1001, // 1 => 69
        9'b0_0111_1010, // 3 => 7A
        9'b0_0100_1101  // P => 4D
    };
    
    always@(posedge clk) begin
       if(state == INIT || state == PAUSE) begin
           if(been_ready == 1 && key_down[last_change] == 1) begin
               if(last_change == KEY_CODES[5]) begin
                   flag = 1;
               end
           end
       end
       else begin
           flag = 0;
       end
    end

//    motor
    reg [8:0] last_change_space;
    integer space_flag;
    always@(posedge clk) begin
        if(state == PLAYER1 || state == PLAYER2) begin
            if(been_ready == 1 && key_down[last_change] == 1) begin
                if(last_change == KEY_CODES[2]) begin
                    last_change_space = last_change;
                    space_flag = 1;
                end
            end
        end
        else begin
            last_change_space = 0;
            space_flag = 0;
        end
        if(key_down[last_change_space] == 0 && space_flag == 1) begin
            last_change_space = 0;
            space_flag = 0;
        end
    end


    integer first_flag;
    integer third_flag;
    always@(posedge clk) begin
        if(state == PLAYER1 || state == PLAYER2) begin
            if(been_ready == 1 && key_down[last_change] == 1) begin
                if(last_change == KEY_CODES[3]) begin
                    first_flag = 1;
                end
            end
        end
        else begin
            first_flag = 0;
        end
        if(key_down[KEY_CODES[3]] == 0 && first_flag == 1) begin
            first_flag = 0;
        end
    end
    always@(posedge clk) begin
        if(state == PLAYER1 || state == PLAYER2) begin
            if(been_ready == 1 && key_down[last_change] == 1) begin
                if(last_change == KEY_CODES[4]) begin
                    third_flag = 1;
                end
            end
        end
        else begin
            third_flag = 0;
        end
        if(key_down[KEY_CODES[4]] == 0 && third_flag == 1) begin
            third_flag = 0;
        end
    end
    
    reg [2:0] _mode;
    always@(*) begin
        if(state == PLAYER1 || state == PLAYER2) begin
            if(space_flag == 0 && first_flag == 0 && third_flag == 0) begin
                _mode = 0;
            end
            else if(space_flag == 0 && first_flag == 0 && third_flag == 1) begin
                _mode = 1;
            end
            else if(space_flag == 0 && first_flag == 1 && third_flag == 0) begin
                _mode = 2;
            end
            else if(space_flag == 0 && first_flag == 1 && third_flag == 1) begin
                _mode = 3;
            end
            else if(space_flag == 1 && first_flag == 0 && third_flag == 0) begin
                _mode = 4;
            end
            else if(space_flag == 1 && first_flag == 0 && third_flag == 1) begin
                _mode = 5;
            end
            else if(space_flag == 1 && first_flag == 1 && third_flag == 0) begin
                _mode = 6;
            end
            else if(space_flag == 1 && first_flag == 1 && third_flag == 1) begin
                _mode = 7;
            end
        end
        else begin
            _mode = 0;
        end
    end


    // sonic
    reg [31:0] counter2;
    always@(posedge clk) begin
        if(state == INIT || state == PAUSE || state == GAMEOVER) begin
            score_flag = 0;
            counter2 = 0;
        end
        else if(state == PLAYER1 || state == PLAYER2) begin
            score_flag = score_flag;
            if((distance <= 5 || distance >= 25) && score_flag == 0) begin
                score_flag = 3;
            end
            if(score_flag != 0) begin
                counter2 = counter2 + 1;
                if(counter2 == 100000000) begin
                    score_flag = score_flag - 1;
                    counter2 = 0;
                end
            end
            else begin
                counter2 = 0;
            end
        end
    end

    always@(posedge clk) begin
        case(state)
            INIT: begin
                P1_score = 0;
                P2_score = 0;
            end
            PLAYER1: begin
                if(score_flag == 3 && counter2 == 2) begin
                    P1_score = P1_score + 1;
                end
                else begin
                    P1_score = P1_score;
                end
                P2_score = P2_score;
            end
            PAUSE: begin
                P1_score = P1_score;
                P2_score = P2_score;
            end
            PLAYER2: begin
                if(score_flag == 3 && counter2 == 2) begin
                    P2_score = P2_score + 1;
                end
                else begin
                    P2_score = P2_score;
                end
                P1_score = P1_score;
            end
            GAMEOVER: begin
                P1_score = P1_score;
                P2_score = P2_score;
            end
        endcase
    end
    
    integer a_flag;
    integer d_flag;
    always@(posedge clk) begin
        if(state == PLAYER1 || state == PLAYER2) begin
            if(been_ready == 1 && key_down[last_change] == 1) begin
                if(last_change == KEY_CODES[0]) begin
                    a_flag = 1;
                end
            end
        end
        else begin
            a_flag = 0;
        end
        if(key_down[KEY_CODES[0]] == 0 && a_flag == 1) begin
            a_flag = 0;
        end
    end
    always@(posedge clk) begin
        if(state == PLAYER1 || state == PLAYER2) begin
            if(been_ready == 1 && key_down[last_change] == 1) begin
                if(last_change == KEY_CODES[1]) begin
                    d_flag = 1;
                end
            end
        end
        else begin
            d_flag = 0;
        end
        if(key_down[KEY_CODES[1]] == 0 && d_flag == 1) begin
            d_flag = 0;
        end
    end
    
    reg [2:0] _mode2;
    always@(*) begin
        if(state == PLAYER1 || state == PLAYER2) begin
            if(a_flag == 0 && d_flag == 0) begin
                _mode2 = 0;
            end
            else if(a_flag == 0 && d_flag == 1) begin
                _mode2 = 1;
            end
            else if(a_flag == 1 && d_flag == 0) begin
                _mode2 = 2;
            end
            else if(a_flag == 1 && d_flag == 1) begin
                _mode2 = 0;
            end
        end
        else begin
            _mode2 = 0;
        end
    end


    // Debug LED
    always@(posedge clk) begin
        // if((state == PLAYER1 || state == PLAYER2) && space_flag) begin
        //     led[15] = 1;
        // end
        // else begin
        //     led[15] = 0;
        // end
        // if((state == PLAYER1 || state == PLAYER2) && first_flag) begin
        //     led[13] = 1;
        // end
        // else begin
        //     led[13] = 0;
        // end
        // if((state == PLAYER1 || state == PLAYER2) && third_flag) begin
        //     led[12] = 1;
        // end
        // else begin
        //     led[12] = 0;
        // end
        // if((state == PLAYER1 || state == PLAYER2) && first_flag && third_flag) begin
        //     led[10] = 1;
        //     led[12] = 0;
        //     led[13] = 0;
        // end
        // else begin
        //     led[10] = 0;
        // end
        // if(left_pwm > 0) begin
        //     led[15:12] = 4'b1111;
        //     led[11:8] = 0;
        // end
        // else begin
        //     led[15:12] = 0;
        //     led[11:8] = 4'b1111;
        // end
        // if(right_pwm > 0) begin
        //     led[7:5] = 3'b111;
        // end
        // else begin
        //     led[7:5] = 0;
        //     led[6] = 1;
        // end
        
//        led[15:14] = score_flag;
//        led[13:10] = P1_score;
//        led[8:5] = P2_score;

//        if(a_flag) begin
//            led[9] = 1; 
//        end
//        else begin
//            led[9] = 0;
//        end
        led[15] = IN5;
        led[14] = IN6;
        led[13] = IN7;
        led[12] = IN8;
        led[11:10] = _mode2;
        led[9] = mid_pwm;
        led[8] = mid_pwm_2; 
    end

    motor A(
        .clk(clk),
        .rst(rst_normal),
        // .space_mode(space_flag),
        // .keeper_left_mode(first_flag),
        // .keeper_right_mode(third_flag),
        ._mode(_mode),
        .pwm({left_pwm, right_pwm}),
        .l_IN({IN1, IN2}),
        .r_IN({IN3, IN4})
    );
    
    motor_2 A2(
        .clk(clk),
        .rst(rst_normal),
        ._mode2(_mode2),
        .pwm({mid_pwm, min_pwm_2}),
        .m_IN({IN5, IN6}),
        .m_IN_2({IN7, IN8})
    );

    
//    VGA_template
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480


    pixel_gen pixel_gen_inst(
        .h_cnt(h_cnt),
        .valid(valid),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue)
    );

    vga_controller   vga_inst(
        .pclk(clk_25MHz),
        .reset(rst_25M),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );

    sonic_top B(
        .clk(clk), 
        .rst(rst_normal), 
        .Echo(echo), 
        .Trig(trig),
        .distance(distance)
    );
      
endmodule

module sonic_top(clk, rst, Echo, Trig, distance);
    input clk, rst, Echo;
    output Trig;
    output [19:0] distance;

    wire[19:0] dis;
    wire clk1M;
    wire clk_2_17;

    assign distance = dis;

    div clk1(clk ,clk1M);
    TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
    PosCounter u2(.clk(clk1M), .rst(rst), .echo(Echo), .distance_count(dis));
endmodule

module PosCounter(clk, rst, echo, distance_count); 
    input clk, rst, echo;
    output[19:0] distance_count;

    parameter S0 = 2'b00;
    parameter S1 = 2'b01; 
    parameter S2 = 2'b10;
    
    wire start, finish;
    reg[1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg[19:0] count, distance_register;
    wire[19:0] distance_count; 

    always@(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 0;
            echo_reg2 <= 0;
            count <= 0;
            distance_register  <= 0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;   
            echo_reg2 <= echo_reg1; 
            case(curr_state)
                S0:begin
                    if (start) curr_state <= next_state; //S1
                    else count <= 0;
                end
                S1:begin
                    if (finish) curr_state <= next_state; //S2
                    else count <= count + 1;
                end
                S2:begin
                    distance_register <= count;
                    count <= 0;
                    curr_state <= next_state; //S0
                end
            endcase
        end
    end

    always @(*) begin
        case(curr_state)
            S0:next_state = S1;
            S1:next_state = S2;
            S2:next_state = S0;
            default:next_state = S0;
        endcase
    end

    assign start = echo_reg1 & ~echo_reg2;  
    assign finish = ~echo_reg1 & echo_reg2;

    // TODO: trace the code and calculate the distance, output it to <distance_count>
    // assign distance_count = (distance_register * 340 * 100 / 2 / 1000000);
    assign distance_count = (distance_register * 17 / 1000);
    
endmodule

// send trigger signal to sensor
module TrigSignal(clk, rst, trig);
    input clk, rst;
    output trig;

    reg trig, next_trig;
    reg[23:0] count, next_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            trig <= 0;
        end
        else begin
            count <= next_count;
            trig <= next_trig;
        end
    end
    // 10^3 clk    10^7 clk
    // count 10us to set <trig> high and wait for 100ms, then set <trig> back to low
    always @(*) begin
        next_trig = trig;
        next_count = count + 1;
        // TODO: set <next_trig> and <next_count> to let the sensor work properly
        if(count < 1000) begin
            next_trig = 1;
        end
        else begin
            next_trig = 0;
        end
        if(count == 9999999) begin
            next_count = 0;
        end
    end
endmodule

// clock divider for T = 1us clock
module div(clk ,out_clk);
    input clk;
    output out_clk;
    reg out_clk;
    reg [6:0]cnt;
    
    always @(posedge clk) begin   
        if(cnt < 7'd50) begin
            cnt <= cnt + 1'b1;
            out_clk <= 1'b1;
        end 
        else if(cnt < 7'd100) begin
            cnt <= cnt + 1'b1;
            out_clk <= 1'b0;
        end
        else if(cnt == 7'd100) begin
            cnt <= 0;
            out_clk <= 1'b1;
        end
    end
endmodule


module motor(
    input clk,
    input rst,
    // input space_mode,
    // input keeper_left_mode,
    // input keeper_right_mode,
    input [2:0] _mode,
    output [1:0]pwm,
    output reg [1:0]r_IN,
    output reg [1:0]l_IN
);

    reg [9:0]next_left_motor, next_right_motor;
    reg [9:0]left_motor, right_motor;
    wire left_pwm, right_pwm;

    motor_pwm m0(clk, rst, left_motor, left_pwm);
    motor_pwm m1(clk, rst, right_motor, right_pwm);

    assign pwm = {left_pwm,right_pwm};

    // TODO: trace the rest of motor.v and control the speed and direction of the two motors
    always @(posedge clk) begin
        if(rst) begin
            left_motor = 0;
            right_motor = 0;
        end
        else begin
            left_motor = next_left_motor;
            right_motor = next_right_motor;
        end
    end

    // always @(*) begin
    //     if(space_mode == 1) begin
    //         next_right_motor = 550;
    //         r_IN = 2'b01;
    //     end
    //     else if(space_mode == 0) begin
    //         next_right_motor = 0;
    //         r_IN = 2'b00;
    //     end
    //     if(keeper_left_mode == 1 && keeper_right_mode == 1) begin
    //         next_left_motor = 0;
    //         l_IN = 2'b00;
    //     end
    //     else if(keeper_left_mode == 1) begin
    //         next_left_motor = 550;
    //         l_IN = 2'b10;
    //     end
    //     else if(keeper_right_mode == 1) begin
    //         next_left_motor = 550;
    //         l_IN = 2'b01;
    //     end
    //     else begin
    //         next_left_motor = 0;
    //         l_IN = 2'b00;
    //     end
    // end
    
    always@(*) begin
        case(_mode)
            3'd0: begin
                next_left_motor = 0;
                next_right_motor = 0;
                l_IN = 2'b00;
                r_IN = 2'b00;
            end
            3'd1: begin
                next_left_motor = 550;
                next_right_motor = 550;
                l_IN = 2'b00;
                r_IN = 2'b10;
            end
            3'd2: begin
                next_left_motor = 550;
                next_right_motor = 550;
                l_IN = 2'b00;
                r_IN = 2'b01;
            end
            3'd3: begin
                next_left_motor = 0;
                next_right_motor = 0;
                l_IN = 2'b00;
                r_IN = 2'b00;
            end
            3'd4: begin
                next_left_motor = 550;
                next_right_motor = 550;
                l_IN = 2'b10;
                r_IN = 2'b00;
            end
            3'd5: begin
                next_left_motor = 550;
                next_right_motor = 550;
                l_IN = 2'b10;
                r_IN = 2'b10;
            end
            3'd6: begin
                next_left_motor = 550;
                next_right_motor = 550;
                l_IN = 2'b10;
                r_IN = 2'b01;
            end
            3'd7: begin
                next_left_motor = 550;
                next_right_motor = 550;
                l_IN = 2'b10;
                r_IN = 2'b00;
            end
        endcase
    end
    
endmodule


module motor_2(
    input clk,
    input rst,
    input [2:0] _mode2,
    output pwm,
    output reg [1:0]m_IN,
    output reg [1:0]m_IN_2
);

    reg [9:0]next_mid_motor, next_mid_motor_2;
    reg [9:0]mid_motor, mid_motor_2;
    wire mid_pwm, mid_pwm_2;

    motor_pwm m2(clk, rst, mid_motor, mid_pwm);
    motor_pwm m3(clk, rst, mid_motor_2, mid_pwm_2);
    
    assign pwm = {mid_pwm, mid_pwm_2};

    always @(posedge clk) begin
        if(rst) begin
            mid_motor = 0;
            mid_motor_2 = 0;
        end
        else begin
            mid_motor = next_mid_motor;
            mid_motor_2 = next_mid_motor_2;
        end
    end
    
    always@(*) begin
        case(_mode2)
            2'd0: begin
                next_mid_motor = 0;
                next_mid_motor_2 = 0;
                m_IN = 2'b00;
                m_IN_2 = 2'b00;
            end
            2'd1: begin
                next_mid_motor = 500;
                next_mid_motor_2 = 500;
                m_IN = 2'b10;
                m_IN_2 = 2'b10;
            end
            2'd2: begin
                next_mid_motor = 500;
                next_mid_motor_2 = 500;
                m_IN = 2'b01;
                m_IN_2 = 2'b01;
            end
            default: begin
                next_mid_motor = 0;
                next_mid_motor_2 = 0;
                m_IN = 2'b00;
                m_IN_2 = 2'b00;
            end
        endcase
    end
    

endmodule


module motor_pwm (
    input clk,
    input reset,
    input [9:0]duty,
    output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1)
    );

endmodule

//generte PWM by input frequency & duty cycle
module PWM_gen (
    input wire clk,
    input wire reset,
    input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);
    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            // TODO: set <PWM> accordingly
            if(count < count_duty) begin
                PWM <= 1;
            end
            else begin
                PWM <= 0;
            end
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule


// pixel_gen
module pixel_gen(
    input [9:0] h_cnt,
    input valid,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue
    );
   
        always @(*) begin
        if(!valid)
            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
        else if(h_cnt < 128)
            {vgaRed, vgaGreen, vgaBlue} = 12'h000;
        else if(h_cnt < 256)
            {vgaRed, vgaGreen, vgaBlue} = 12'h00f;
        else if(h_cnt < 384)
            {vgaRed, vgaGreen, vgaBlue} = 12'hf00;
        else if(h_cnt < 512)
            {vgaRed, vgaGreen, vgaBlue} = 12'h0f0;
        else if(h_cnt < 640)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else
            {vgaRed, vgaGreen, vgaBlue} = 12'h0;
    end
endmodule


`timescale 1ns/1ps
module vga_controller (
    input wire pclk, reset,
    output wire hsync, vsync, valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );

    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;

    parameter HD = 640;
    parameter HF = 16;
    parameter HS = 96;
    parameter HB = 48;
    parameter HT = 800; 
    parameter VD = 480;
    parameter VF = 10;
    parameter VS = 2;
    parameter VB = 33;
    parameter VT = 525;
    parameter hsync_default = 1'b1;
    parameter vsync_default = 1'b1;

    always @(posedge pclk)
        if (reset)
            pixel_cnt <= 0;
        else
            if (pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
            else
                pixel_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            hsync_i <= hsync_default;
        else
            if ((pixel_cnt >= (HD + HF - 1)) && (pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 

    always @(posedge pclk)
        if (reset)
            line_cnt <= 0;
        else
            if (pixel_cnt == (HT -1))
                if (line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            vsync_i <= vsync_default; 
        else if ((line_cnt >= (VD + VF - 1)) && (line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;

endmodule

module debounce(pb_debounced, pb ,clk);
    output pb_debounced;
    input pb;
    input clk;
    
    reg [6:0] shift_reg;
    always @(posedge clk) begin
        shift_reg[6:1] <= shift_reg[5:0];
        shift_reg[0] <= pb;
    end
    
    assign pb_debounced = shift_reg == 7'b111_1111 ? 1'b1 : 1'b0;
endmodule

module onepulse(signal, clk, op);
    input signal, clk;
    output reg op;
    
    reg delay;
    
    always @(posedge clk) begin
        if((signal == 1) & (delay == 0)) op <= 1;
        else op <= 0; 
        delay <= signal;
    end
endmodule

module clock_divider(clk, clk_div);   
    parameter n = 26;     
    input clk;   
    output clk_div;   
    
    reg [n-1:0] num;
    wire [n-1:0] next_num;
    
    always@(posedge clk)begin
        num<=next_num;
    end
    
    assign next_num = num +1;
    assign clk_div = num[n-1];
    
endmodule

module KeyboardDecoder(
    input wire rst,
    input wire clk,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    output reg [128:0] key_down,
    output wire [8:0] last_change,
    output reg key_valid
    );
    
    parameter [1:0] INIT            = 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
    parameter [7:0] IS_INIT         = 8'hAA;
    parameter [7:0] IS_EXTEND       = 8'hE0;
    parameter [7:0] IS_BREAK        = 8'hF0;
    
    reg [9:0] key;      // key = {been_extend, been_break, key_in}
    reg [1:0] state;
    reg been_ready, been_extend, been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [128:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
        .key_in(key_in),
        .is_extend(is_extend),
        .is_break(is_break),
        .valid(valid),
        .err(err),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );
    
    onepulse op (
        .signal(been_ready),
        .clk(clk),
        .op(pulse_been_ready)
    );
    
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            state <= INIT;
            been_ready  <= 1'b0;
            been_extend <= 1'b0;
            been_break  <= 1'b0;
            key <= 10'b0_0_0000_0000;
        end else begin
            state <= state;
            been_ready  <= been_ready;
            been_extend <= (is_extend) ? 1'b1 : been_extend;
            been_break  <= (is_break ) ? 1'b1 : been_break;
            key <= key;
            case (state)
                INIT : begin
                        if (key_in == IS_INIT) begin
                            state <= WAIT_FOR_SIGNAL;
                            been_ready  <= 1'b0;
                            been_extend <= 1'b0;
                            been_break  <= 1'b0;
                            key <= 10'b0_0_0000_0000;
                        end else begin
                            state <= INIT;
                        end
                    end
                WAIT_FOR_SIGNAL : begin
                        if (valid == 0) begin
                            state <= WAIT_FOR_SIGNAL;
                            been_ready <= 1'b0;
                        end else begin
                            state <= GET_SIGNAL_DOWN;
                        end
                    end
                GET_SIGNAL_DOWN : begin
                        state <= WAIT_RELEASE;
                        key <= {been_extend, been_break, key_in};
                        been_ready  <= 1'b1;
                    end
                WAIT_RELEASE : begin
                        if (valid == 1) begin
                            state <= WAIT_RELEASE;
                        end else begin
                            state <= WAIT_FOR_SIGNAL;
                            been_extend <= 1'b0;
                            been_break  <= 1'b0;
                        end
                    end
                default : begin
                        state <= INIT;
                        been_ready  <= 1'b0;
                        been_extend <= 1'b0;
                        been_break  <= 1'b0;
                        key <= 10'b0_0_0000_0000;
                    end
            endcase
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            key_valid <= 1'b0;
            key_down <= 128'b0;
        end else if (key_decode[last_change] && pulse_been_ready) begin
            key_valid <= 1'b1;
            if (key[8] == 0) begin
                key_down <= key_down | key_decode;
            end else begin
                key_down <= key_down & (~key_decode);
            end
        end else begin
            key_valid <= 1'b0;
            key_down <= key_down;
        end
    end

endmodule

