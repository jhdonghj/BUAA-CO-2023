`include "constants.v"

module CU (
        input [31: 0] check,
        input [31: 0] set,

        input [5: 0] op,
        input [5: 0] func,
        input [31: 0] Instr,

        output RegWrite,
        output [31: 0] RegDst,
        output [31: 0] WDSel,

        output [31: 0] EXTOp,

        output [31: 0] Br,
        output [31: 0] CMPType,


        output [31: 0] ALUOp,
        output ALUSrc,

        output [31: 0] MDUOp,


        output MemWrite,
        output [31: 0] DMType,

        output CP0Write,


        output R,
        output ext,
        output md,
        output mf,
        output mt,
        output cal_md,
        output cal_r,
        output cal_i,
        output store,
        output load,
        output link,
        output branch,
        output COP0,
        output mfc0,
        output mtc0,
        output eret,
        output syscall,
        output unknow
    );

    assign R = (op == `OP_Rtype);
    assign ext = (op == `OP_lui);
    assign store = (op == `OP_sb) || (op == `OP_sh) || (op == `OP_sw);
    assign load = (op == `OP_lb) || (op == `OP_lh) || (op == `OP_lw);
    assign link = (op == `OP_jal);
    assign branch = (op == `OP_beq) || (op == `OP_bne);

    assign mf = R && ((func == `FUNC_mfhi) || (func == `FUNC_mflo));
    assign mt = R && ((func == `FUNC_mthi) || (func == `FUNC_mtlo));
    assign cal_md = R && ((func == `FUNC_mult) || (func == `FUNC_multu) || (func == `FUNC_div) || (func == `FUNC_divu));
    assign md = cal_md || mf || mt;

    assign COP0 = (op == `OP_COP0);
    assign mfc0 = COP0 && (Instr[25: 21] == `COP0_mfc0);
    assign mtc0 = COP0 && (Instr[25: 21] == `COP0_mtc0);

    assign syscall = R && (func == `FUNC_syscall);
    assign eret = (Instr == `INSTR_eret);

    assign cal_r = (R && func && !(Br == `Br_jr) && !md && !syscall);
    assign cal_i = (op == `OP_addi) || (op == `OP_andi) || (op == `OP_ori);



    assign RegWrite =
           syscall ? 0 :
           (mf || mfc0) ? 1 :
           (mt || cal_md || mtc0) ? 0 :
           (R && !func) ? 0 :
           (cal_r || cal_i) ? 1 :
           link ? 1 :
           store ? 0 :
           (Br && !link) ? 0 :
           1;
    assign RegDst =
           R ? `A3_rd :
           link ? `A3_ra :
           `A3_rt;
    assign WDSel =
           mfc0 ? `WD_cp0 :
           mf ? `WD_mdu :
           ext ? `WD_ext :
           load ? `WD_mem :
           link ? `WD_pc8 :
           cal_r ? `WD_alu :
           cal_i ? `WD_alu :
           `WD_alu;

    assign EXTOp =
           R ? `EXT_unsigned :
           (store || load) ? `EXT_signed :
           (op == `OP_addi) ? `EXT_signed :
           (op == `OP_lui) ? `EXT_lui :
           `EXT_unsigned;

    assign Br =
           eret ? `Br_eret :
           R ? (func == `FUNC_jr) ? `Br_jr :
       `Br_default :
           branch ? `Br_br :
           (op == `OP_j) ? `Br_j :
           (op == `OP_jal) ? `Br_j :
           `Br_default;
    assign CMPType =
           (op == `OP_beq) ? `CMP_beq :
           (op == `OP_bne) ? `CMP_bne :
           0;

    assign ALUOp =
           R ?
           (func == `FUNC_add) ? `ALU_add :
           (func == `FUNC_sub) ? `ALU_sub :
           (func == `FUNC_and) ? `ALU_and :
           (func == `FUNC_or) ? `ALU_or :
           (func == `FUNC_slt) ? `ALU_slt :
           (func == `FUNC_sltu) ? `ALU_sltu :
       `ALU_and :
           (op == `OP_addi) ? `ALU_add :
           (op == `OP_andi) ? `ALU_and :
           (op == `OP_ori) ? `ALU_or :
           (load || store) ? `ALU_add :
           `ALU_and;
    assign ALUSrc =
           R ? `ALU_RD2 :
           `ALU_imm;

    assign MDUOp =
           R ?
           (func == `FUNC_mult) ? `MDU_mult :
           (func == `FUNC_multu) ? `MDU_multu :
           (func == `FUNC_div) ? `MDU_div :
           (func == `FUNC_divu) ? `MDU_divu :
           (func == `FUNC_mfhi) ? `MDU_mfhi :
           (func == `FUNC_mflo) ? `MDU_mflo :
           (func == `FUNC_mthi) ? `MDU_mthi :
           (func == `FUNC_mtlo) ? `MDU_mtlo :
       `MDU_default :
           `MDU_default;

    assign MemWrite = store;
    assign DMType =
           (op == `OP_sb) ? `DM_sb :
           (op == `OP_sh) ? `DM_sh :
           (op == `OP_sw) ? `DM_sw :
           (op == `OP_lb) ? `DM_lb :
           (op == `OP_lh) ? `DM_lh :
           (op == `OP_lw) ? `DM_lw :
           `DM_lw;

    assign CP0Write = mtc0;


    assign unknow =
           (!R &&
            !(op == `OP_lui) &&
            !(op == `OP_sb) &&
            !(op == `OP_sh) &&
            !(op == `OP_sw) &&
            !(op == `OP_lb) &&
            !(op == `OP_lh) &&
            !(op == `OP_lw) &&
            !(op == `OP_jal) &&
            !(op == `OP_beq) &&
            !(op == `OP_bne) &&
            !(op == `OP_j) &&
            !(op == `OP_addi) &&
            !(op == `OP_andi) &&
            !(op == `OP_ori) &&
            !(op == `OP_COP0) &&
            !(Instr == `INSTR_eret)
           ) ||
           (R && func &&
            !(func == `FUNC_add) &&
            !(func == `FUNC_sub) &&
            !(func == `FUNC_and) &&
            !(func == `FUNC_or) &&
            !(func == `FUNC_slt) &&
            !(func == `FUNC_sltu) &&
            !(func == `FUNC_jr) &&
            !(func == `FUNC_mult) &&
            !(func == `FUNC_multu) &&
            !(func == `FUNC_div) &&
            !(func == `FUNC_divu) &&
            !(func == `FUNC_mfhi) &&
            !(func == `FUNC_mflo) &&
            !(func == `FUNC_mthi) &&
            !(func == `FUNC_mtlo) &&
            !syscall
           );

endmodule
