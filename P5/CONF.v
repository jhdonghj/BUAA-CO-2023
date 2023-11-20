`timescale 1ns / 1ps
`include "defines.v"

module CONF ( // conflict & stall
    input [31:0] D_instr,
    input [31:0] E_instr,
    input [31:0] M_instr,
    output stall
    );
    wire [2:0] D_Tuse_RS, D_Tuse_RT, E_Tnew, M_Tnew;
    wire [4:0] D_rs, D_rt, E_Dst, M_Dst;
    // D-stage
    CTRL C1(
        .instr(D_instr),
        .D_Tuse_RS(D_Tuse_RS),
        .D_Tuse_RT(D_Tuse_RT),
        .rs(D_rs),
        .rt(D_rt)
    );
    // E-stage
    CTRL C2(
        .instr(E_instr),
        .E_Tnew(E_Tnew),
        .Dst(E_Dst)
    );
    // M-stage
    CTRL C3(
        .instr(M_instr),
        .M_Tnew(M_Tnew),
        .Dst(M_Dst)
    );
    // Tuse < Tnew

    wire rs_e = (D_Tuse_RS < E_Tnew) && (D_rs == E_Dst && D_rs);
    wire rt_e = (D_Tuse_RT < E_Tnew) && (D_rt == E_Dst && D_rt);
    wire rs_m = (D_Tuse_RS < M_Tnew) && (D_rs == M_Dst && D_rs);
    wire rt_m = (D_Tuse_RT < M_Tnew) && (D_rt == M_Dst && D_rt);

    assign stall = rs_e | rt_e | rs_m | rt_m;

endmodule