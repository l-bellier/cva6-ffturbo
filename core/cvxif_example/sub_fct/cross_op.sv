// -----------------------------------------------------------------------------
// Project      : RISCV Contest
// File         : cross_op.sv
// Author       : BELLIER Lucas <lucas.bellier@imt-atlantique.net>
// Created      : 2026-03-12
// Description  : Ce modile permet d'effectuer les bonnes additions et 
//                soustraction à la fin d'un papillon de taille 4 en fonction 
//                du sens de la FFT. 
// -----------------------------------------------------------------------------
// Modification History:
// Date        By          Description
// 2026-03-12    BELLIER Lucas     Initial release
// -----------------------------------------------------------------------------

module cross_op #(
    parameter logic cross_sub = 1'b0
) (
    input  logic        inv,
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    output logic [31:0] res
);

    logic signed [15:0] a_r, a_i;
    logic signed [15:0] b_r, b_i;

    assign a_r = $signed(operand_a[15:0]);
    assign a_i = $signed(operand_a[31:16]);
    
    assign b_r = $signed(operand_b[15:0]);
    assign b_i = $signed(operand_b[31:16]);

    logic signed [15:0] res_r, res_i;

    always_comb begin
        if (inv == cross_sub) begin
            res_r = a_r - b_i;
            res_i = a_i + b_r;
        end else begin
            res_r = a_r + b_i;
            res_i = a_i - b_r;
        end
    end

    assign res = {res_i, res_r};

endmodule : cross_op