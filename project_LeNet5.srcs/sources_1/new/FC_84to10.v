`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/27 14:25:12
// Design Name: 
// Module Name: FC_84to10
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



module FC_84to10(clk, rst, start,dout);
input clk, rst, start;
output[31:0] dout;
reg [6:0] addr_in;
reg [9:0] addr_w;
//reg [3:0] addr_b;
reg [9:0] addr_mul;
wire signed [15:0] out_in, out_w;// out_b;
reg [9:0] cnt_mul;
reg wea;
reg [31:0] din_mul;
wire [31:0] data_out;
in_84 u0(.clka(clk), .addra(addr_in), .douta(out_in));
weights_840 u1(.clka(clk), .addra(addr_w), .douta(out_w));
//bias_10 u2(.clka(clk), .addra(addr_b), .douta(out_b));
mult_gen_0 u3(.CLK(clk), .A(out_in), .B(out_w), .P(data_out));
mul_reg10 u4(.clka(clk), .wea(wea), .addra(addr_mul), .dina(din_mul), .douta(dout));

reg [31:0] dout_mul;
reg [3:0] state;
localparam IDLE = 4'd0, DELAY_1 = 4'd1, DELAY_2 = 4'd2, DELAY_3 = 4'd3, DELAY_4 = 4'd4, DELAY_5 = 4'd5,  FC_1 = 4'd6,  BIAS = 4'd7, DONE = 4'd8;


//state
always@(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        case(state)
             IDLE : if(start) state <= DELAY_1; else state <= IDLE;
             DELAY_1 : state <= DELAY_2;
             DELAY_2 : state <= DELAY_3;
             DELAY_3 : state <= DELAY_4;
             DELAY_4 : state <= DELAY_5;
             DELAY_5 : state <= FC_1;
             FC_1 :if(addr_mul == 10) state <= BIAS; else state <= FC_1;
             BIAS : state <= DONE;
             DONE : state <= IDLE;
             default : state <= IDLE;
             endcase
end
// input 
always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_in <= 7'd0;
    else
        case(state)
            DELAY_1 : addr_in <= addr_in + 1'd1;
            DELAY_2 : addr_in <= addr_in + 1'd1;
            DELAY_3 : addr_in <= addr_in + 1'd1;
            DELAY_4 : addr_in <= addr_in + 1'd1;
            DELAY_5 : addr_in <= addr_in + 1'd1;
            FC_1 :if(addr_in == 83) addr_in <= 0; else addr_in <= addr_in + 1'd1;
            default : addr_in <= 0;
            endcase
end
// weights
always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_w <= 7'd0;
    else
        case(state)
            DELAY_1 : addr_w <= addr_w + 1'd1;
            DELAY_2 : addr_w <= addr_w + 1'd1;
            DELAY_3 : addr_w <= addr_w + 1'd1;
            DELAY_4 : addr_w <= addr_w + 1'd1;
            DELAY_5 : addr_w <= addr_w + 1'd1;
            FC_1 :if(addr_w == 839) addr_w <= 0; else addr_w <= addr_w + 1'd1;
            default : addr_w <= 0;
            endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        cnt_mul <= 10'd0;
    else
        case(state)
            FC_1 :if(cnt_mul == 83) cnt_mul <= 0; else cnt_mul <= cnt_mul + 1'd1;
            default : cnt_mul <= 0;
            endcase
end


// Multiplier sum
always@(posedge clk or posedge rst)
begin
    if(rst)
        dout_mul <= 32'd0;
    else
        case(state)
            FC_1 :if(cnt_mul == 83) dout_mul <= 32'd0; else dout_mul <= dout_mul + data_out;
            default : dout_mul <= 32'd0;
            endcase
end

// 10 dout_mul reg
always@(posedge clk or posedge rst)
begin
    if(rst)
        din_mul <= 32'd0;
    else
        case(state)
            FC_1 :if(cnt_mul == 83) din_mul <= dout_mul; else din_mul <= din_mul;
            default : din_mul <= 32'd0;
            endcase
end

// 10 dout_mul addr
always@(posedge clk or posedge rst)
begin
    if(rst)
        addr_mul <= 10'd0;
    else
        case(state)
            FC_1 :if(cnt_mul == 83) addr_mul <= addr_mul + 1'd1; else addr_mul <= addr_mul;
            default : addr_mul <= 32'd0;
            endcase
end

// wea
always@(posedge clk or posedge rst)
begin
    if(rst)
        wea <= 0;
    else
        case(state)
            FC_1 : if(addr_mul == 10) wea <= 0; else wea <= 1;
            default : wea <= 0;
            endcase
end
endmodule