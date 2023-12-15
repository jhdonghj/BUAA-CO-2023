`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:02:34 08/29/2023 
// Design Name: 
// Module Name:    cpu_checker 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define upd_ti      state <= ti;                                                \
                    ti_num <= (ti_num << 3) + (ti_num << 1) + number;           \
                    ti_cnt <= ti_cnt + 1;
`define upd_pc      state <= pc;                                                \
                    pc_num <= (pc_num << 4) | number;                           \
                    pc_cnt <= pc_cnt + 1;
`define upd_grf     state <= grf;                                               \
                    grf_num <= (grf_num << 3) + (grf_num << 1) + number;        \
                    grf_cnt <= grf_cnt + 1;
`define upd_addr    state <= addr;                                              \
                    addr_num <= (addr_num << 4) | number;                       \
                    addr_cnt <= addr_cnt + 1;
`define upd_data    state <= data;                                              \
                    data_num <= (data_num << 4) | number;                       \
                    data_cnt <= data_cnt + 1;
`define init        reg_or_sto <= 2'b0;                                         \
                    ti_num <= 64'b0; ti_cnt <= 64'b0;                           \
                    pc_num <= 64'b0; pc_cnt <= 64'b0;                           \
                    grf_num <= 64'b0; grf_cnt <= 64'b0;                         \
                    addr_num <= 64'b0; addr_cnt <= 64'b0;                       \
                    data_num <= 64'b0; data_cnt <= 64'b0;
module cpu_checker #(
        parameter     start   =   5'd0,
        parameter       err   =   5'd1,
        parameter     caret   =   5'd2,
        parameter        ti   =   5'd3,
        parameter        at   =   5'd4,
        parameter        pc   =   5'd5,
        parameter     colon   =   5'd6,
        parameter       pa1   =   5'd7,
        parameter    dollar   =   5'd8,
        parameter       grf   =   5'd9,
        parameter      star   =   5'd10,
        parameter      addr   =   5'd11,
        parameter       pa2   =   5'd12,
        parameter        lo   =   5'd13,
        parameter        eq   =   5'd14,
        parameter       pa3   =   5'd15,
        parameter      data   =   5'd16,
        parameter      _end   =   5'd17,
        parameter  reg_series = 2'b01,
        parameter  sto_series = 2'b10,
        parameter    ti_inval = 4'b0001,
        parameter    pc_inval = 4'b0010,
        parameter  addr_inval = 4'b0100,
        parameter   grf_inval = 4'b1000,
        parameter      pc_min = 32'h0000_3000,
        parameter      pc_max = 32'h0000_4fff,
        parameter    addr_min = 32'h0000_0000,
        parameter    addr_max = 32'h0000_2fff,
        parameter     grf_min = 0,
        parameter     grf_max = 31
    ) (
        input clk,
        input reset,
        input [7:0] char,
        input [15:0] freq,
        output [1:0] format_type,
        output [3:0] error_code
    );
    reg [4:0] state;
    reg [1:0] reg_or_sto;
    reg [63:0] ti_num, ti_cnt, pc_num, pc_cnt, grf_num, grf_cnt;
    reg [63:0] addr_num, addr_cnt, data_num, data_cnt, cnt;
    wire isdigit, ishdigit, ti_val, pc_val, addr_val, grf_val;
    wire [3:0] number;
    wire [63:0] lowbit_freq, lowbit_ti, lowbit_pc, lowbit_addr;

    assign isdigit = "0" <= char && char <= "9";
    assign ishdigit = isdigit || ("a" <= char && char <= "f");
    assign number = isdigit ? char - "0" :
                    ishdigit ? char - "a" + 10 : 0;
    assign format_type = (state == _end && reg_or_sto != 2'b0 &&
                          64'd1 <= ti_cnt && ti_cnt <= 64'd4 &&
                          pc_cnt == 64'd8 &&
                          (reg_or_sto == sto_series || (64'd1 <= grf_cnt && grf_cnt <= 64'd4)) &&
                          (reg_or_sto == reg_series || addr_cnt == 64'd8) &&
                          data_cnt == 64'd8
                          ) ? reg_or_sto : 2'b00;

    assign lowbit_freq = (freq & ((~freq) + 1)) >> 1;
    assign lowbit_ti = (ti_num & ((~ti_num) + 1));
    assign lowbit_pc = (pc_num & ((~pc_num) + 1));
    assign lowbit_addr = (addr_num & ((~addr_num) + 1));
    assign error_code = format_type == 2'b00 ? 4'b0000 :
                        ( ((ti_num & (lowbit_freq - 1)) == 0 ? 0 : ti_inval) |
                          ((pc_num & 3) == 0 && pc_min <= pc_num && pc_num <= pc_max ? 0 : pc_inval) |
                          ( reg_or_sto == reg_series ||
                            ((addr_num & 3) == 0 && addr_min <= addr_num && addr_num <= addr_max)
                            ? 0 : addr_inval) |
                          ( reg_or_sto == sto_series ||
                            (grf_min <= grf_num && grf_num <= grf_max)
                            ? 0 : grf_inval)
                        );

    always @(posedge clk) begin
        if(reset) begin
            cnt <= 0;
            state <= start;
            `init
        end else begin
            cnt <= cnt + 1;
            case (state)
                 start : begin
                    state <= (char == "^" ? caret : start);
                 end
                   err : begin
                    if(char == "#") begin
                        state <= start;
                        `init
                    end else begin
                        state <= err;
                    end
                 end
                 caret : begin
                    if(isdigit) begin
                        `upd_ti
                    end else begin
                        state <= err;
                    end
                 end
                    ti : begin
                    if(isdigit) begin
                        `upd_ti
                    end else begin
                        if(char == "@") begin
                            state <= at;
                        end else begin
                            state <= err;
                        end
                    end
                 end
                    at : begin
                    if(ishdigit) begin
                        `upd_pc
                    end else begin
                        state <= err;
                    end
                 end
                    pc : begin
                    if(ishdigit) begin
                        `upd_pc
                    end else begin
                        if(char == ":") begin
                            state <= colon;
                        end else begin
                            state <= err;
                        end
                    end
                 end
                 colon : begin
                    case (char)
                        " " : state <= pa1;
                        "$" : state <= dollar;
                        8'd42 : state <= star;
                        default: state <= err;
                    endcase
                 end
                   pa1 : begin
                    case (char)
                        " " : state <= pa1;
                        "$" : state <= dollar;
                        8'd42 : state <= star;
                        default: state <= err;
                    endcase
                 end
                dollar : begin
                    reg_or_sto <= reg_series;
                    if(isdigit) begin
                        `upd_grf
                    end else begin
                        state <= err;
                    end
                 end
                   grf : begin
                    if(isdigit) begin
                        `upd_grf
                    end else begin
                        case (char)
                            " " : state <= pa2;
                            "<" : state <= lo;
                            default: state <= err;
                        endcase
                    end
                 end
                  star : begin
                    reg_or_sto <= sto_series;
                    if(ishdigit) begin
                        `upd_addr
                    end else begin
                        state <= err;
                    end
                 end
                  addr : begin
                    if(ishdigit) begin
                        `upd_addr
                    end else begin
                        case (char)
                            " " : state <= pa2;
                            "<" : state <= lo;
                            default: state <= err;
                        endcase
                    end
                 end
                   pa2 : begin
                    case (char)
                        " " : state <= pa2;
                        "<" : state <= lo; 
                        default: state <= err;
                    endcase
                 end
                    lo : begin
                    state <= char == "=" ? eq : err;
                 end
                    eq : begin
                    if(ishdigit) begin
                        `upd_data
                    end else begin
                        if(char == " ") begin
                            state <= pa3;
                        end else begin
                            state <= err;
                        end
                    end
                 end
                   pa3 : begin
                    if(ishdigit) begin
                        `upd_data
                    end else begin
                        if(char == " ") begin
                            state <= pa3;
                        end else begin
                            state <= err;
                        end
                    end
                 end
                  data : begin
                    if(ishdigit) begin
                        `upd_data
                    end else begin
                        if(char == "#") begin
                            state <= _end;
                        end else begin
                            state <= err;
                        end
                    end
                 end
                  _end : begin
                    if(char == "^") begin
                        state <= caret;
                    end else begin
                        state <= start;
                    end
                    `init
                 end
                default: begin
                    state <= state;
                end
            endcase
        end
    end
endmodule
