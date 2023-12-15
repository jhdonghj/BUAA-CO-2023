`include "definations.v"

module CTRL (
        input [5: 0] op,    //! Opcode
        input [5: 0] func,    //! Function
        output RegWrite,    //! Register Write Enable
        output [1: 0] RegDst,    //! Register Destination
        output [1: 0] WDsel,    //! Write Data Select
        output MemWrite,    //! Memory Write Enable
        output [3: 0]ALUOp,    //! ALU Operation
        output ALUSrc,    //! ALU Source Select
        output EXTOp,    //! Extend Operation
        output [2: 0] Br //! Branch Control
    );

    wire R; //! R-Type
    wire store; //! Store Instruction
    wire load; //! Load Instruction
    wire link; //! Link Instruction

    assign R = (op == `OP_Rtype);
    assign store = (op == `OP_sw);
    assign load = (op == `OP_lw);
    assign link = (op == `OP_jal);

    assign RegWrite = R ? 1 :
           store ? 0 :
           (Br && !link) ? 0 :
           1;
    assign RegDst =
           R ? `A3_rd :
           (op == `OP_jal) ? `A3_ra :
           `A3_rt;
    assign WDsel =
           R ? `WD_alu :
           load ? `WD_mem :
           link ? `WD_pc4 :
           `WD_alu;
    assign MemWrite = store;
    assign ALUOp =
           R ?
           (func == `FUNC_add) ? `ALU_add :
           (func == `FUNC_sub) ? `ALU_sub :
       `ALU_add :
           (op == `OP_beq) ? `ALU_sub :
           (op == `OP_ori) ? `ALU_or :
           (op == `OP_lui) ? `ALU_lui :
           `ALU_add;
    assign ALUSrc =
           R ? `ALU_RD2 :
           (Br == `Br_beq) ? `ALU_RD2 :
           `ALU_imm;
    assign EXTOp =
           R ? `EXT_unsigned :
           (store || load) ? `EXT_signed :
           `EXT_unsigned;
    assign Br =
           R ? (func == `FUNC_jr) ? `Br_jr :
       `Br_default :
           (op == `OP_beq) ? `Br_beq :
           (op == `OP_j) ? `Br_j :
           (op == `OP_jal) ? `Br_j :
           `Br_default;
    
endmodule