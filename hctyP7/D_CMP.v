`include "constants.v"

module D_CMP (
        input [31: 0] rs,   //! Source Register 1
        input [31: 0] rt,   //! Source Register 2
        input [31: 0] CMPType,   //! Compare Type
        output isTrue //! Is True
    );

    assign isTrue =
           (CMPType == `CMP_beq) ? (rs == rt) :
           (CMPType == `CMP_bne) ? (rs != rt) :
           0;

endmodule
