`timescale 1ns / 1ps
`include "defines.v"

module E_HILO (
    input Req,
    input clk,
    input rst,
    input [31:0] A,
    input [31:0] B,
    input [4:0] HILOOp,
    output [31:0] HILOout,
    output HILObusy
    );
    
    reg [31:0] stage, hi, lo, nxt_hi, nxt_lo;
    wire mult, multu, div, divu, mflo, mfhi, mtlo, mthi, start;

    assign mult  = HILOOp == `HILO_MULT;
    assign multu = HILOOp == `HILO_MULTU;
    assign div   = HILOOp == `HILO_DIV;
    assign divu  = HILOOp == `HILO_DIVU;
    assign mfhi  = HILOOp == `HILO_MFHI;
    assign mflo  = HILOOp == `HILO_MFLO;
    assign mthi  = HILOOp == `HILO_MTHI;
    assign mtlo  = HILOOp == `HILO_MTLO;
    
    assign start = mult | multu | div | divu;
    assign HILObusy = start | stage > 0;
    assign HILOout = mflo ? lo :
                     mfhi ? hi :
                     32'b0;

    always @(posedge clk) begin
        if(rst) begin
            stage <= 0;
            hi <= 0;
            lo <= 0;
        end else begin
            if(stage == 0) begin
                if(Req) begin
                    stage <= 0;
                end else if(mult) begin
                    {nxt_hi, nxt_lo} <= $signed(A) * $signed(B);
                    stage <= 5;
                end else if(multu) begin
                    {nxt_hi, nxt_lo} <= A * B;
                    stage <= 5;
                end else if(div) begin
                    nxt_lo <= $signed(A) / $signed(B);
                    nxt_hi <= $signed(A) % $signed(B);
                    stage <= 10;
                end else if(divu) begin
                    nxt_lo <= A / B;
                    nxt_hi <= A % B;
                    stage <= 10;
                end else if(mtlo) begin
                    lo <= A;
                end else if(mthi) begin
                    hi <= A;
                end else begin
                    stage <= stage;
                end
/*
madd
{temp_hi, temp_lo} <= {hi, lo} + $signed($signed(64'd0) + $signed(rs) * $signed(rt));
// 或者
{temp_hi, temp_lo} <= {hi, lo} + $signed({{32{rs[31]}}, rs[31:0]} * $signed({{32{rt[31]}}, rt[31:0]})); // 手动进行符号位扩展
*/
            end else if(stage == 1) begin
                stage <= stage - 1;
                {hi, lo} <= {nxt_hi, nxt_lo};
            end else begin
                stage <= stage - 1;
            end
        end
    end

endmodule