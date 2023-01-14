module demo_1(
   input clk,
   input rst,
   output [3:0] vgaRed,
   output [3:0] vgaGreen,
   output [3:0] vgaBlue,
   output hsync,
   output vsync
    );


    wire clk_25MHz;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480


     clock_divider clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz)
    );

   pixel_gen pixel_gen_inst(
       .h_cnt(h_cnt),
       .v_cnt(v_cnt),
       .valid(valid),
       .vgaRed(vgaRed),
       .vgaGreen(vgaGreen),
       .vgaBlue(vgaBlue)
    );

    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt(h_cnt),
      .v_cnt(v_cnt)
    );
     
endmodule

`timescale 1ns/1ps
/////////////////////////////////////////////////////////////////
// Module Name: vga
/////////////////////////////////////////////////////////////////

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

module clock_divider(clk1, clk);
input clk;
output clk1;

reg [1:0] num;
wire [1:0] next_num;

always @(posedge clk) begin
  num <= next_num;
end

assign next_num = num + 1'b1;
assign clk1 = num[1];

endmodule


module pixel_gen(
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   input valid,
   output reg [3:0] vgaRed,
   output reg [3:0] vgaGreen,
   output reg [3:0] vgaBlue
   );
   
       always @(*) begin
       if(!valid)//640*480
             {vgaRed, vgaGreen, vgaBlue} = 12'h0;
             ///t
        else if(h_cnt >= 215 && h_cnt <= 245 && v_cnt >= 20 && v_cnt <= 25)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 227 && h_cnt <= 233 && v_cnt >= 28 && v_cnt <= 50)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
             
             ///i
        else if(h_cnt >= 275 && h_cnt <= 305 && v_cnt >= 20 && v_cnt <= 25)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 275 && h_cnt <= 305 && v_cnt >= 45 && v_cnt <= 50)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 287 && h_cnt <= 293 && v_cnt >= 28 && v_cnt <= 42)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
             
             
             ///m
        else if(h_cnt >= 330 && h_cnt <= 335 && v_cnt >= 20 && v_cnt <= 50)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 338 && h_cnt <= 345 && v_cnt >= 20 && v_cnt <= 30)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
         else if(h_cnt >= 348 && h_cnt <= 352 && v_cnt >= 20 && v_cnt <= 40)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 355 && h_cnt <= 362 && v_cnt >= 20 && v_cnt <= 30)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
         else if(h_cnt >= 365 && h_cnt <= 370 && v_cnt >= 20 && v_cnt <= 50)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|  
             
         ///e
        else if(h_cnt >= 390 && h_cnt <= 395 && v_cnt >= 20 && v_cnt <= 50)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 405 && h_cnt <= 430 && v_cnt >= 20 && v_cnt <= 26)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 405 && h_cnt <= 418 && v_cnt >= 32 && v_cnt <= 38)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;            
        else if(h_cnt >= 405 && h_cnt <= 430 && v_cnt >= 44 && v_cnt <= 50)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
 
        //block
        else if(h_cnt >= 230 && h_cnt <= 410 && v_cnt >= 70 && v_cnt <= 80)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 230 && h_cnt <= 410 && v_cnt >= 190 && v_cnt <= 200)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 230 && h_cnt <= 240 && v_cnt >= 70 && v_cnt <= 200)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;            
        else if(h_cnt >= 400 && h_cnt <= 410 && v_cnt >= 70 && v_cnt <= 200)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 240 && h_cnt <= 245 && v_cnt >= 80 && v_cnt <= 190)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hcd0;
        else if(h_cnt >= 230 && h_cnt <= 410 && v_cnt >= 200 && v_cnt <= 205)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hcd0;
        else if(h_cnt >= 410 && h_cnt <= 415 && v_cnt >= 70 && v_cnt <= 205)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hcd0;
             
        //block_blue
        else if(h_cnt >= 110 && h_cnt <= 290 && v_cnt >= 290 && v_cnt <= 300)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 110 && h_cnt <= 290 && v_cnt >= 450 && v_cnt <= 460)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 110 && h_cnt <= 120 && v_cnt >= 290 && v_cnt <= 460)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;            
        else if(h_cnt >= 280 && h_cnt <= 290 && v_cnt >= 290 && v_cnt <= 460)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 120 && h_cnt <= 125 && v_cnt >= 300 && v_cnt <= 450)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'h0dd;
        else if(h_cnt >= 110 && h_cnt <= 290 && v_cnt >= 460 && v_cnt <= 465)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'h0dd;
        else if(h_cnt >= 290 && h_cnt <= 295 && v_cnt >= 290 && v_cnt <= 465)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'h0dd;
//        else if(h_cnt >= 90 && h_cnt <= 95 && v_cnt >= 280 && v_cnt <= 325)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'h0bd;
//        else if(h_cnt >= 95 && h_cnt <= 130 && v_cnt >= 280 && v_cnt <= 300)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'h0bd;
//        else if(h_cnt >= 85 && h_cnt <= 95 && v_cnt >= 280 && v_cnt <= 325)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'h0bd;
//             else if(h_cnt >= 95 && h_cnt <= 100 && v_cnt >= 280 && v_cnt <= 325)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'h0ac;
//        else if(h_cnt >= 100 && h_cnt <= 130 && v_cnt >= 325 && v_cnt <= 330)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'h0ac;
        else if(h_cnt >= 90 && h_cnt <= 135 && v_cnt >= 280 && v_cnt <= 330)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'h0ac;
//        else if(h_cnt >= 100 && h_cnt <= 125 && v_cnt >= 290 && v_cnt <= 310)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'h0bd;
             
        //block_red
        else if(h_cnt >= 350 && h_cnt <= 530 && v_cnt >= 290 && v_cnt <= 300)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 350 && h_cnt <= 530 && v_cnt >= 450 && v_cnt <= 460)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 350 && h_cnt <= 360 && v_cnt >= 290 && v_cnt <= 460)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;            
        else if(h_cnt >= 520 && h_cnt <= 530 && v_cnt >= 290 && v_cnt <= 460)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 360 && h_cnt <= 365 && v_cnt >= 300 && v_cnt <= 450)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hdaa;
        else if(h_cnt >= 350 && h_cnt <= 530 && v_cnt >= 460 && v_cnt <= 465)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hdaa;
        else if(h_cnt >= 530 && h_cnt <= 535 && v_cnt >= 290 && v_cnt <= 465)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hdaa;
        else if(h_cnt >= 510 && h_cnt <= 560 && v_cnt >= 280 && v_cnt <= 325)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'heab;
//        else if(h_cnt >= 125 && h_cnt <= 550 && v_cnt >= 290 && v_cnt <= 310)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'h0bd;
//        else if(h_cnt >= 95 && h_cnt <= 130 && v_cnt >= 280 && v_cnt <= 325)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'heaa;
//        else if(h_cnt >= 85 && h_cnt <= 95 && v_cnt >= 280 && v_cnt <= 325)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'heaa;
//             else if(h_cnt >= 95 && h_cnt <= 100 && v_cnt >= 280 && v_cnt <= 325)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'heab;
//        else if(h_cnt >= 100 && h_cnt <= 130 && v_cnt >= 325 && v_cnt <= 330)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'heab;
//        else if(h_cnt >= 90 && h_cnt <= 135 && v_cnt >= 280 && v_cnt <= 330)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'heab;
       
        //A
        else if(h_cnt >= 55 && h_cnt <= 60 && v_cnt >= 350 && v_cnt <= 390)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 64 && h_cnt <= 71 && v_cnt >= 350 && v_cnt <= 355)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 64 && h_cnt <= 71 && v_cnt >= 365 && v_cnt <= 370)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 75 && h_cnt <= 80 && v_cnt >= 350 && v_cnt <= 390)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        else if(h_cnt >= 65 && h_cnt <= 67 && v_cnt >= 350 && v_cnt <= 390)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'h0ac;
             
        //B
        else if(h_cnt >= 550 && h_cnt <= 555 && v_cnt >= 350 && v_cnt <= 390)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 560 && h_cnt <= 575 && v_cnt >= 368 && v_cnt <= 373)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 560 && h_cnt <= 575 && v_cnt >= 385 && v_cnt <= 390)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 560 && h_cnt <= 575 && v_cnt >= 350 && v_cnt <= 355)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 570 && h_cnt <= 575 && v_cnt >= 360 && v_cnt <= 365)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 570 && h_cnt <= 575 && v_cnt >= 377 && v_cnt <= 382)//-
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
           
        // time_num
//        // left_0
//        else if(h_cnt >= 265 && h_cnt <= 270 && (v_cnt >= 100 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 && h_cnt <= 310 && (v_cnt >= 100 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 && h_cnt <= 310 && (v_cnt >= 100 && v_cnt <= 105)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 && h_cnt <= 310 && (v_cnt >= 170 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
       
//        // right_0
//        else if(h_cnt >= 265 + 70 && h_cnt <= 270 + 70 && (v_cnt >= 100 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 100 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 100 && v_cnt <= 105)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 170 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
       
//        // left_1
//        else if(h_cnt >= 300 && h_cnt <= 310 && (v_cnt >= 100 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // right_1
//        else if(h_cnt >= 300 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 100 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
       
//        // right_2
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && ((v_cnt >= 100 && v_cnt <= 105) || (v_cnt >= 170 && v_cnt <= 175) || (v_cnt >= 135 && v_cnt <= 140))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 270 + 70 && v_cnt >= 140 && v_cnt <= 170) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 + 70 && h_cnt <= 310 + 70 && v_cnt >= 105 && v_cnt <= 135) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // left_2
//        else if(h_cnt >= 265 && h_cnt <= 310 && ((v_cnt >= 100 && v_cnt <= 105) || (v_cnt >= 170 && v_cnt <= 175) || (v_cnt >= 135 && v_cnt <= 140))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 && h_cnt <= 270 && v_cnt >= 140 && v_cnt <= 170) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 && h_cnt <= 310 && v_cnt >= 105 && v_cnt <= 135) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        // left_3
//        else if(h_cnt >= 265 && h_cnt <= 310 && ((v_cnt >= 100 && v_cnt <= 105) || (v_cnt >= 170 && v_cnt <= 175) || (v_cnt >= 135 && v_cnt <= 140))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 && h_cnt <= 310 && v_cnt >= 140 && v_cnt <= 170) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 && h_cnt <= 310 && v_cnt >= 105 && v_cnt <= 135) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // right_3
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && ((v_cnt >= 100 && v_cnt <= 105) || (v_cnt >= 170 && v_cnt <= 175) || (v_cnt >= 135 && v_cnt <= 140))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 + 70 && h_cnt <= 310 + 70 && v_cnt >= 140 && v_cnt <= 170) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 + 70 && h_cnt <= 310 + 70 && v_cnt >= 105 && v_cnt <= 135) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        // left_4
//        else if(h_cnt >= 265 && h_cnt <= 310 && v_cnt >= 140 && v_cnt <= 145) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 && h_cnt <= 270 && v_cnt >= 100 && v_cnt <= 140) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 290 && h_cnt <= 295 && v_cnt >= 100 && v_cnt <= 175) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // right_4
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && v_cnt >= 140 && v_cnt <= 145) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 270 + 70 && v_cnt >= 100 && v_cnt <= 140) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 290 + 70 && h_cnt <= 295 + 70 && v_cnt >= 100 && v_cnt <= 175) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
       
//        // right_5
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && ((v_cnt >= 100 && v_cnt <= 105) || (v_cnt >= 170 && v_cnt <= 175) || (v_cnt >= 135 && v_cnt <= 140))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 + 70 && h_cnt <= 310 + 70 && v_cnt >= 140 && v_cnt <= 170) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 270 + 70 && v_cnt >= 105 && v_cnt <= 135) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        // right_6
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && ((v_cnt >= 100 && v_cnt <= 105) || (v_cnt >= 170 && v_cnt <= 175) || (v_cnt >= 135 && v_cnt <= 140))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 + 70 && h_cnt <= 310 + 70 && v_cnt >= 140 && v_cnt <= 170) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 270 + 70 && v_cnt >= 105 && v_cnt <= 170) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
       
//        // right_7
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && v_cnt >= 100 && v_cnt <= 105) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 + 70 && h_cnt <= 310 + 70 && v_cnt >= 100 && v_cnt <= 175) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
       
//        // right_8
//        else if(h_cnt >= 265 + 70 && h_cnt <= 270 + 70 && (v_cnt >= 100 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 100 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 100 && v_cnt <= 105)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 135 && v_cnt <= 140)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 170 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
       
//        // right 9
//        else if(h_cnt >= 265 + 70 && h_cnt <= 270 + 70 && (v_cnt >= 100 && v_cnt <= 135)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 305 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 100 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 100 && v_cnt <= 105)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end                                                                                                                          
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 135 && v_cnt <= 140)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 265 + 70 && h_cnt <= 310 + 70 && (v_cnt >= 170 && v_cnt <= 175)) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        // pointA_0
//        else if(h_cnt >= 170 && h_cnt <= 176 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 && h_cnt <= 231 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 && h_cnt <= 231 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // pointB_0
//        else if(h_cnt >= 170 + 240 && h_cnt <= 176 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 + 240 && h_cnt <= 231 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 + 240 && h_cnt <= 231 + 240 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        // pointA_1
//        else if(h_cnt >= 195 && h_cnt <= 205 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // pointB_1
//        else if(h_cnt >= 195 + 240 && h_cnt <= 205 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        //  pointA_2
//        else if(h_cnt >= 170 && h_cnt <= 176 && v_cnt >= 377 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 && h_cnt <= 231 && v_cnt >= 325 && v_cnt <= 372) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 && h_cnt <= 231 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // pointB_2
//        else if(h_cnt >= 170 + 240 && h_cnt <= 176 + 240 && v_cnt >= 377 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 + 240 && h_cnt <= 231 + 240 && v_cnt >= 325 && v_cnt <= 372) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 + 240 && h_cnt <= 231 + 240 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
       
//        //  pointA_3
//        else if(h_cnt >= 225 && h_cnt <= 231 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 && h_cnt <= 231 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // pointB_3
//        else if(h_cnt >= 225 + 240 && h_cnt <= 231 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 + 240 && h_cnt <= 231 + 240 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        // pointA_4
//        else if(h_cnt >= 170 && h_cnt <= 176 && v_cnt >= 325 && v_cnt <= 385) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 208 && h_cnt <= 213 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 && h_cnt <= 231 && v_cnt >= 380 && v_cnt <= 385) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        //  pointB_4
//        else if(h_cnt >= 170 + 240 && h_cnt <= 176 + 240 && v_cnt >= 325 && v_cnt <= 385) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 208 + 240 && h_cnt <= 213 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 + 240 && h_cnt <= 231 + 240 && v_cnt >= 380 && v_cnt <= 385) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        // pointA_5
//        else if(h_cnt >= 170 && h_cnt <= 176 && v_cnt >= 325 && v_cnt <= 372) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 && h_cnt <= 231 && v_cnt >= 377 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 && h_cnt <= 231 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        //  pointB_5
//        else if(h_cnt >= 170 + 240 && h_cnt <= 176 + 240 && v_cnt >= 325 && v_cnt <= 372) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 + 240 && h_cnt <= 231 + 240 && v_cnt >= 377 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 + 240 && h_cnt <= 231 + 240 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
        
//        // pointA_6
//        else if(h_cnt >= 170 && h_cnt <= 176 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 && h_cnt <= 231 && v_cnt >= 377 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 && h_cnt <= 231 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // pointB_6
//        else if(h_cnt >= 170 + 240 && h_cnt <= 176 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 + 240 && h_cnt <= 231 + 240 && v_cnt >= 377 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 + 240 && h_cnt <= 231 + 240 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
        
//        // pointA_7
//        else if(h_cnt >= 225 && h_cnt <= 231 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 && h_cnt <= 231 && v_cnt >= 325 && v_cnt <= 330) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // pointB_7
//        else if(h_cnt >= 225 + 240 && h_cnt <= 231 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 + 240 && h_cnt <= 231 + 240 && v_cnt >= 325 && v_cnt <= 330) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        // pointA_8
//        else if(h_cnt >= 170 && h_cnt <= 176 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 && h_cnt <= 231 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 && h_cnt <= 231 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // pointB_8
//        else if(h_cnt >= 170 + 240 && h_cnt <= 176 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 + 240 && h_cnt <= 231 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 + 240 && h_cnt <= 231 + 240 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end

//        // pointA_9
//        else if(h_cnt >= 170 && h_cnt <= 176 && v_cnt >= 325 && v_cnt <= 372) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 && h_cnt <= 231 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 && h_cnt <= 231 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        // pointB_9
//        else if(h_cnt >= 170 + 240 && h_cnt <= 176 + 240 && v_cnt >= 325 && v_cnt <= 372) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 225 + 240 && h_cnt <= 231 + 240 && v_cnt >= 325 && v_cnt <= 425) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
//        else if(h_cnt >= 170 + 240 && h_cnt <= 231 + 240 && ((v_cnt >= 325 && v_cnt <= 330) || (v_cnt >= 420 && v_cnt <= 425) || (v_cnt >= 372 && v_cnt <= 377))) begin
//            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
//        end
        

       

       
        else
             {vgaRed, vgaGreen, vgaBlue} = 12'h0;
   end
endmodule
