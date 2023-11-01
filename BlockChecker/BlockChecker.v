`timescale 1ns / 1ps

module BlockChecker(
    input clk,
    input reset,
    input [7:0] in,
    output result
    );

    wire begin_ap, end_ap, begin_re, end_re;
    wire [7:0] ch;
    reg [7:0] st_begin [5:0], st_end [3:0];
    reg [31:0] i, begin_cnt, end_cnt, isMismatch;

    assign ch = "A" <= in && in <= "Z" ? in - "A" + "a" : in;
    assign begin_ap = st_begin[4] == " " &&
                        st_begin[3] == "b" &&
                        st_begin[2] == "e" &&
                        st_begin[1] == "g" &&
                        st_begin[0] == "i" &&
                        ch == "n";
    assign begin_re = st_begin[5] == " " &&
                        st_begin[4] == "b" &&
                        st_begin[3] == "e" &&
                        st_begin[2] == "g" &&
                        st_begin[1] == "i" &&
                        st_begin[0] == "n" &&
                        ch != " ";
    assign end_ap = st_end[2] == " " &&
                        st_end[1] == "e" &&
                        st_end[0] == "n" &&
                        ch == "d";
    assign end_re = st_end[3] == " " &&
                        st_end[2] == "e" &&
                        st_end[1] == "n" &&
                        st_end[0] == "d" &&
                        ch != " ";
    assign result = isMismatch == 0 && begin_cnt == end_cnt;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            isMismatch <= 0;
            begin_cnt <= 0;
            end_cnt <= 0;
            st_begin[0] <= " ";
            for (i = 1; i < 6; i = i + 1) begin
                st_begin[i] <= 0;
            end
            st_end[0] <= " ";
            for (i = 1; i < 4; i = i + 1) begin
                st_end[i] <= 0;
            end
        end else begin
            st_begin[0] <= ch;
            for (i = 1; i < 6; i = i + 1) begin
                st_begin[i] <= st_begin[i - 1];
            end
            st_end[0] <= ch;
            for (i = 1; i < 4; i = i + 1) begin
                st_end[i] <= st_end[i - 1];
            end
            if (begin_ap) begin
                begin_cnt <= begin_cnt + 1;
            end else if (end_ap) begin
                end_cnt <= end_cnt + 1;
                isMismatch <= isMismatch + (begin_cnt == end_cnt);
            end else if (begin_re) begin
                begin_cnt <= begin_cnt - 1;
            end else if (end_re) begin
                end_cnt <= end_cnt - 1;
                isMismatch <= isMismatch - (begin_cnt + 1 == end_cnt);
            end else begin
                begin_cnt <= begin_cnt;
                end_cnt <= end_cnt;
                isMismatch <= isMismatch;
            end
        end
    end

endmodule
