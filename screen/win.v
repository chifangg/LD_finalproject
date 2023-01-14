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
             
       //spots
       else if(h_cnt >= 315 && h_cnt <= 325 && v_cnt >= 85 && v_cnt <= 95)
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;//|
       else if(h_cnt >= 315 && h_cnt <= 325 && v_cnt >= 385 && v_cnt <= 395)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 120 && h_cnt <= 130 && v_cnt >= 235 && v_cnt <= 245)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 510 && h_cnt <= 520 && v_cnt >= 235 && v_cnt <= 245)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 412 && h_cnt <= 422 && v_cnt >= 150 && v_cnt <= 160)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 412 && h_cnt <= 422 && v_cnt >= 315 && v_cnt <= 325)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 235 && h_cnt <= 245 && v_cnt >= 150 && v_cnt <= 160)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 235 && h_cnt <= 245 && v_cnt >= 315 && v_cnt <= 325)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
          
          //p
       else if(h_cnt >= 200 && h_cnt <= 202 && v_cnt >= 200 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 202 && h_cnt <= 217 && v_cnt >= 200 && v_cnt <= 202)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;      
       else if(h_cnt >= 215 && h_cnt <= 217 && v_cnt >= 202 && v_cnt <= 215)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;    
       else if(h_cnt >= 202 && h_cnt <= 217 && v_cnt >= 213 && v_cnt <= 215)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
             
       //L
       else if(h_cnt >= 222 && h_cnt <= 224 && v_cnt >= 200 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
       else if(h_cnt >= 222 && h_cnt <= 239 && v_cnt >= 228 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
             
       //a
       else if(h_cnt >= 244 && h_cnt <= 246 && v_cnt >= 200 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
       else if(h_cnt >= 246 && h_cnt <= 258 && v_cnt >= 200 && v_cnt <= 202)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
       else if(h_cnt >= 259 && h_cnt <= 261 && v_cnt >= 200 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;       
       else if(h_cnt >= 244 && h_cnt <= 261 && v_cnt >= 213 && v_cnt <= 215)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
             
       //y
       else if(h_cnt >= 283-17 && h_cnt <= 285-17 && v_cnt >= 200 && v_cnt <= 213)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
       else if(h_cnt >= 285-17 && h_cnt <= 300-17 && v_cnt >= 213 && v_cnt <= 215)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
       else if(h_cnt >= 298-17 && h_cnt <= 300-17 && v_cnt >= 200 && v_cnt <= 213)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;       
       else if(h_cnt >= 291-17 && h_cnt <= 293-17 && v_cnt >= 215 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
       
       //e
       else if(h_cnt >= 305-17 && h_cnt <= 307-17 && v_cnt >= 200 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
       else if(h_cnt >= 307-17 && h_cnt <= 322-17 && v_cnt >= 200 && v_cnt <= 202)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
       else if(h_cnt >= 307-17 && h_cnt <= 322-17 && v_cnt >= 214 && v_cnt <= 216)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;       
       else if(h_cnt >= 307-17 && h_cnt <= 322-17 && v_cnt >= 228 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff; 
             
       //r
       else if(h_cnt >= 327-17 && h_cnt <= 329-17 && v_cnt >= 200 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
       else if(h_cnt >= 329-17 && h_cnt <= 344-17 && v_cnt >= 200 && v_cnt <= 202)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
       else if(h_cnt >= 342-17 && h_cnt <= 344-17 && v_cnt >= 202 && v_cnt <= 215)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;       
       else if(h_cnt >= 329-17 && h_cnt <= 344-17 && v_cnt >= 213 && v_cnt <= 215)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff; 
       else if(h_cnt - v_cnt >= 98 && v_cnt >= 215 && v_cnt <= 230 && h_cnt - v_cnt <= 100)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff; 
             
       //a
//       else if(h_cnt >= 359+50 && h_cnt <= 361+50 && v_cnt >= 200 && v_cnt <= 230)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
//       else if(h_cnt >= 361+50 && h_cnt <= 376+50 && v_cnt >= 200 && v_cnt <= 202)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
//       else if(h_cnt >= 374+50 && h_cnt <= 376+50 && v_cnt >= 200 && v_cnt <= 230)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;       
//       else if(h_cnt >= 361+50 && h_cnt <= 376+50 && v_cnt >= 213 && v_cnt <= 215)//-
//             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
             
       //w  

       else if(h_cnt >= 305-10 && h_cnt <= 308-10 && v_cnt >= 260 && v_cnt <= 290)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
       else if(h_cnt >= 303-15 && h_cnt <= 305-10 && v_cnt >= 287 && v_cnt <= 290)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
       else if(h_cnt >= 300-15 && h_cnt <= 303-15 && v_cnt >= 280 && v_cnt <= 290)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;       
       else if(h_cnt >= 298-20 && h_cnt <= 300-15 && v_cnt >= 287 && v_cnt <= 290)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 295-20 && h_cnt <= 298-20 && v_cnt >= 260 && v_cnt <= 290)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
             
        //i
       else if(h_cnt >= 318 && h_cnt <= 322 && v_cnt >= 260 && v_cnt <= 290)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
       //n
          
       else if(h_cnt >= 332+10 && h_cnt <= 335+10 && v_cnt >= 260 && v_cnt <= 290)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;       
       else if(2*h_cnt - v_cnt >= 160 && v_cnt >= 260+10 && v_cnt <= 290 && 2*h_cnt - v_cnt <= 163)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 350+10 && h_cnt <= 353+10 && v_cnt >= 260 && v_cnt <= 290)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff; 
       
       //B
       else if(h_cnt >= 359+50 && h_cnt <= 361+50 && v_cnt >= 200 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;  
       else if(h_cnt >= 361+50 && h_cnt <= 376+50 && v_cnt >= 200 && v_cnt <= 202)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;   
       else if(h_cnt >= 374+50 && h_cnt <= 376+50 && v_cnt >= 200 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;       
       else if(h_cnt >= 361+50 && h_cnt <= 376+50 && v_cnt >= 213 && v_cnt <= 215)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       else if(h_cnt >= 361+50 && h_cnt <= 376+50 && v_cnt >= 227 && v_cnt <= 230)//-
             {vgaRed, vgaGreen, vgaBlue} = 12'hfff;
       
        
        else
             {vgaRed, vgaGreen, vgaBlue} = 12'h0;
   end
endmodule

