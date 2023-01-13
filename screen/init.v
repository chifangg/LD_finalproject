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
             ///s
        else if(h_cnt >= 50 && h_cnt <= 55 && v_cnt >= 87 && v_cnt <= 122)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 60 && h_cnt <= 85 && v_cnt >= 87 && v_cnt <= 92)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 60 && h_cnt <= 75 && v_cnt >= 117 && v_cnt <= 122)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 80 && h_cnt <= 85 && v_cnt >= 117 && v_cnt <= 147)//|
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;              
        else if(h_cnt >= 50 && h_cnt <= 75 && v_cnt >= 142 && v_cnt <= 147)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;


             ///o
        else if(h_cnt >= 105 && h_cnt <= 120 && v_cnt >= 87 && v_cnt <= 92)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 95 && h_cnt <= 100 && v_cnt >= 87 && v_cnt <= 147)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
         else if(h_cnt >= 105 && h_cnt <= 120 && v_cnt >= 142 && v_cnt <= 147)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 125 && h_cnt <= 130 && v_cnt >= 87 && v_cnt <= 147)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        
        //c
        else if(h_cnt >= 150 && h_cnt <= 175 && v_cnt >= 87 && v_cnt <= 92)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 140 && h_cnt <= 145 && v_cnt >= 87 && v_cnt <= 147)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
         else if(h_cnt >= 150 && h_cnt <= 175 && v_cnt >= 142 && v_cnt <= 147)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
        
         //c
        else if(h_cnt >= 195 && h_cnt <= 220 && v_cnt >= 87 && v_cnt <= 92)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 185 && h_cnt <= 190 && v_cnt >= 87 && v_cnt <= 147)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
         else if(h_cnt >= 195 && h_cnt <= 220 && v_cnt >= 142 && v_cnt <= 147)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
        
              ///e
        else if(h_cnt >= 230 && h_cnt <= 235 && v_cnt >= 87 && v_cnt <= 147)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 240 && h_cnt <= 265 && v_cnt >= 87 && v_cnt <= 92)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 240 && h_cnt <= 265 && v_cnt >= 115 && v_cnt <= 120)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;            
        else if(h_cnt >= 240 && h_cnt <= 265 && v_cnt >= 142 && v_cnt <= 147)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
             
             
                   ///r
        else if(h_cnt >= 275 && h_cnt <= 280 && v_cnt >= 87 && v_cnt <= 147)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 285 && h_cnt <= 300 && v_cnt >= 87 && v_cnt <= 92)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 305 && h_cnt <= 310 && v_cnt >= 87 && v_cnt <= 120)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 285 && h_cnt <= 300 && v_cnt >= 115 && v_cnt <= 120)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;            
        else if(h_cnt - v_cnt >= 158 && v_cnt >= 125 && v_cnt <= 147 && h_cnt - v_cnt <= 165)///
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        
        
             ///g
        else if(h_cnt >= 395 && h_cnt <= 400 && v_cnt >= 87 && v_cnt <= 147)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 405 && h_cnt <= 430 && v_cnt >= 87 && v_cnt <= 92)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 413 && h_cnt <= 420 && v_cnt >= 115 && v_cnt <= 120)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 425 && h_cnt <= 430 && v_cnt >= 115 && v_cnt <= 147)//|
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;              
        else if(h_cnt >= 405 && h_cnt <= 420 && v_cnt >= 142 && v_cnt <= 147)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
             
             ///a
        else if(h_cnt >= 450 && h_cnt <= 465 && v_cnt >= 87 && v_cnt <= 92)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 440 && h_cnt <= 445 && v_cnt >= 87 && v_cnt <= 147)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
         else if(h_cnt >= 450 && h_cnt <= 465 && v_cnt >= 115 && v_cnt <= 120)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 470 && h_cnt <= 475 && v_cnt >= 87 && v_cnt <= 147)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
            
             ///m
        else if(h_cnt >= 492 && h_cnt <= 498 && v_cnt >= 87 && v_cnt <= 92)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 485 && h_cnt <= 490 && v_cnt >= 87 && v_cnt <= 147)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
         else if(h_cnt >= 506 && h_cnt <= 512 && v_cnt >= 87 && v_cnt <= 92)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//-
         else if(h_cnt >= 500 && h_cnt <= 503 && v_cnt >= 87 && v_cnt <= 115)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
         else if(h_cnt >= 515 && h_cnt <= 520 && v_cnt >= 87 && v_cnt <= 147)
            {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|  
              
         ///e
        else if(h_cnt >= 530 && h_cnt <= 535 && v_cnt >= 87 && v_cnt <= 147)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 540 && h_cnt <= 565 && v_cnt >= 87 && v_cnt <= 92)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 540 && h_cnt <= 565 && v_cnt >= 115 && v_cnt <= 120)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;            
        else if(h_cnt >= 540 && h_cnt <= 565 && v_cnt >= 142 && v_cnt <= 147)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        
         ///?
        else if(h_cnt >= 575 && h_cnt <= 580 && v_cnt >= 87 && v_cnt <= 147)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
        else if(h_cnt >= 540 && h_cnt <= 565 && v_cnt >= 87 && v_cnt <= 92)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
        else if(h_cnt >= 540 && h_cnt <= 565 && v_cnt >= 115 && v_cnt <= 120)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;            
        else if(h_cnt >= 540 && h_cnt <= 565 && v_cnt >= 142 && v_cnt <= 147)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;       
                       
        else
             {vgaRed, vgaGreen, vgaBlue} = 12'h0;
   end
endmodule

