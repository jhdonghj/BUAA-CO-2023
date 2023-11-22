`define IM SR[15:10]
`define EXL SR[1]
`define IE SR[0]
`define BD Cause[31]
`define IP Cause[15:10]
`define ExcCode Cause[6:2]

module M_CP0(
        input clk,//! Clock
        input reset,//! Reset
        input WE,//! Write Enable
        input [4: 0] CP0Addr,//! CP0 Address
        input [31: 0] CP0In,//! CP0 Input
        output [31: 0] CP0Out,//! CP0 Output
        input [31: 0] VPC,//! VPC
        input BDIn,//! Branch Delay
        input [4: 0] ExcCodeIn,//! Exception Code
        input [5: 0] HWInt,//! Hardware Interrupt
        input EXLClr,//! EXL Clear
        output [31: 0] EPCOut,//! EPC Output
        output Req//! Request
    );

    reg [31: 0] SR;
    reg [31: 0] Cause;
    reg [31: 0] EPC;

    wire IntReq = ( | (HWInt & `IM)) & !`EXL & `IE; // 允许当前中断 且 不在中断异常中 且 允许中断发生
    wire ExcReq = ( | ExcCodeIn) & !`EXL; // 存在异常 且 不在中断中
    assign Req = IntReq | ExcReq;

    wire [31: 0] tempEPC =
         Req ?
         BDIn ? VPC - 4 :
     VPC :
         EPC;

    assign EPCOut = EPC;

    initial begin
        SR <= 0;
        Cause <= 0;
        EPC <= 0;
    end

    assign CP0Out =
           (CP0Addr == 12) ? SR :
           (CP0Addr == 13) ? Cause :
           (CP0Addr == 14) ? EPCOut :
           1919810;

    always@(posedge clk or posedge reset) begin
        if (reset) begin
            SR <= 0;
            Cause <= 0;
            EPC <= 0;
        end
        else begin
            if (EXLClr)
                `EXL <= 1'b0;
            if (Req) begin
                `EXL <= 1'b1;
                `BD <= BDIn;
                `ExcCode <= IntReq ? 5'b0 : ExcCodeIn;
                EPC <= tempEPC;
            end
            else if (WE) begin
                if (CP0Addr == 12)
                    SR <= CP0In;
                else if (CP0Addr == 13)
                    Cause <= CP0In;
                else if (CP0Addr == 14)
                    EPC <= CP0In;
            end
            `IP <= HWInt;
        end
    end

endmodule
