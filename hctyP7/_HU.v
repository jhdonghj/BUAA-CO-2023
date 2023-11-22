`include "constants.v"

module HU (
        input [31: 0] D_check,
        input [31: 0] D_set,
        input [31: 0] E_check,
        input [31: 0] E_set,
        input [31: 0] M_check,
        input [31: 0] M_set,

        input [31: 0] D_Instr,
        input [31: 0] E_Instr,
        input [31: 0] M_Instr,
        input [4: 0] W_RegAddr,
        input W_RegWrite,
        input [31: 0] E_Busy,

        output stall,
        output [31: 0] D_rs_sel,
        output [31: 0] D_rt_sel,
        output [31: 0] E_rs_sel,
        output [31: 0] E_rt_sel,
        output [31: 0] M_rt_sel
    );

    wire [2: 0] Tuse_rs, Tuse_rt; //! Temporary use
    wire [2: 0] Tnew_E, Tnew_M; //! Temporary new

    // ID
    wire [4: 0] D_rs, D_rt; //! Decode_Stage rs, rt
    wire D_Rtype, D_cal_r, D_cal_i, D_load, D_store, D_branch, D_jr, D_md, D_mtc0; //! Decode_Stage calculate
    wire [31: 0] D_Br; //! Decode_Stage Branch
    wire [5: 0] D_op, D_func; //! Decode_Stage opcode, function

    SPLT H_D_SPLT(
             .Instr(D_Instr),
             .op(D_op),
             .func(D_func),
             .rs(D_rs),
             .rt(D_rt)
         );
    CU H_D_CU(
           .Instr(D_Instr),
           .check(D_check),
           .set(D_set),
           .op(D_op),
           .func(D_func),
           .R(D_Rtype),
           .cal_r(D_cal_r),
           .cal_i(D_cal_i),
           .load(D_load),
           .store(D_store),
           .branch(D_branch),
           .md(D_md),
           .Br(D_Br),
           .mfc0(D_mtc0)
       );
    assign D_jr = (D_Br == `Br_jr);
    assign Tuse_rs =
           (D_branch | D_jr) ? 0 :
           (D_Rtype | D_cal_i | D_load | D_store) ? 1 :
           3;
    assign Tuse_rt =
           (D_branch) ? 0 :
           (D_Rtype) ? 1 :
           (D_store | D_mtc0) ? 2 :
           3;

    // EX
    wire [31: 0] E_RegDst; //! Execute_Stage Register Destination
    wire [4: 0] E_RegAddr, E_rs, E_rt, E_rd; //! Execute_Stage Register Address, rs, rt, rd
    wire E_Rtype, E_cal_r, E_cal_i, E_load, E_RegWrite; //! Execute_Stage calculate
    wire [5: 0] E_op, E_func; //! Execute_Stage opcode, function
    wire E_mtc0, E_mfc0;

    SPLT H_E_SPLT(
             .Instr(E_Instr),
             .op(E_op),
             .func(E_func),
             .rs(E_rs),
             .rt(E_rt),
             .rd(E_rd)
         );
    CU H_E_CU(
           .Instr(E_Instr),
           .check(E_check),
           .set(E_set),
           .op(E_op),
           .func(E_func),
           .RegWrite(E_RegWrite),
           .RegDst(E_RegDst),
           .R(E_Rtype),
           .cal_r(E_cal_r),
           .cal_i(E_cal_i),
           .load(E_load),
           .mtc0(E_mtc0),
           .mfc0(E_mfc0)
       );
    assign Tnew_E =
           (E_Rtype | E_cal_i) ? 1 :
           (E_load | E_mfc0) ? 2 :
           0;
    assign E_RegAddr =
           (E_RegDst == `A3_rd) ? E_rd :
           (E_RegDst == `A3_rt) ? E_rt :
           (E_RegDst == `A3_ra) ? 31 :
           0;

    wire stall_rs_E = (Tuse_rs < Tnew_E) && (D_rs && D_rs == E_RegAddr); //! Stall rs for Execute_Stage
    wire stall_rt_E = (Tuse_rt < Tnew_E) && (D_rt && D_rt == E_RegAddr); //! Stall rt for Execute_Stage


    // MEM
    wire [31: 0] M_RegDst; //! Memory_Stage Register Destination
    wire [4: 0] M_RegAddr, M_rs, M_rt, M_rd; //! Memory_Stage Register Address, rs, rt, rd
    wire M_load, M_RegWrite; //! Memory_Stage load
    wire [5: 0] M_op, M_func; //! Memory_Stage opcode, function
    wire M_mtc0, M_mfc0;

    SPLT H_M_SPLT(
             .Instr(M_Instr),
             .op(M_op),
             .func(M_func),
             .rs(M_rs),
             .rt(M_rt),
             .rd(M_rd)
         );
    CU H_M_CU(
           .Instr(M_Instr),
           .check(M_check),
           .set(M_set),
           .op(M_op),
           .func(M_func),
           .RegWrite(M_RegWrite),
           .RegDst(M_RegDst),
           .load(M_load),
           .mtc0(M_mtc0),
           .mfc0(M_mfc0)
       );
    assign Tnew_M =
           (M_load | M_mfc0) ? 1 :
           0;
    assign M_RegAddr =
           (M_RegDst == `A3_rd) ? M_rd :
           (M_RegDst == `A3_rt) ? M_rt :
           (M_RegDst == `A3_ra) ? 31 :
           0;

    wire stall_rs_M = (Tuse_rs < Tnew_M) && (D_rs && D_rs == M_RegAddr); //! Stall rs for Memory_Stage
    wire stall_rt_M = (Tuse_rt < Tnew_M) && (D_rt && D_rt == M_RegAddr); //! Stall rt for Memory_Stage

    wire stall_MD = E_Busy && D_md;
    wire stall_eret = (D_Br == `Br_eret) &&
         ((E_mtc0 && (E_rd == 5'd14)) || (M_mtc0 && (M_rd == 5'd14)));

    assign stall = stall_rs_E | stall_rt_E | stall_rs_M | stall_rt_M | stall_MD | stall_eret;

    assign D_rs_sel =
           (D_rs == 0) ? `FWD_D :
           (D_rs == E_RegAddr && E_RegWrite) ? `FWD_E :
           (D_rs == M_RegAddr && M_RegWrite) ? `FWD_M :
           `FWD_D;

    assign D_rt_sel =
           (D_rt == 0) ? `FWD_D :
           (D_rt == E_RegAddr && E_RegWrite) ? `FWD_E :
           (D_rt == M_RegAddr && M_RegWrite) ? `FWD_M :
           `FWD_D;

    assign E_rs_sel =
           (E_rs == 0) ? `FWD_D :
           (E_rs == M_RegAddr && M_RegWrite) ? `FWD_M :
           (E_rs == W_RegAddr && W_RegWrite) ? `FWD_W :
           `FWD_D;

    assign E_rt_sel =
           (E_rt == 0) ? `FWD_D :
           (E_rt == M_RegAddr && M_RegWrite) ? `FWD_M :
           (E_rt == W_RegAddr && W_RegWrite) ? `FWD_W :
           `FWD_D;

    assign M_rt_sel =
           (M_rt == 0) ? `FWD_D :
           (M_rt == W_RegAddr && W_RegWrite) ? `FWD_W :
           `FWD_D;

endmodule
