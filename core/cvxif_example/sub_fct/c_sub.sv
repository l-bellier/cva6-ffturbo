// -----------------------------------------------------------------------------
// Project      : RISCV Contest
// File         : c_sub.sv
// Author       : BELLIER Lucas <lucas.bellier@imt-atlantique.net>
// Created      : 2026-03-11
// Description  : Ce module permet la soustraction de 2 nombres complexes
// -----------------------------------------------------------------------------
// Modification History:
// Date        By          Description
// 2026-03-11    BELLIER Lucas     Initial release
// -----------------------------------------------------------------------------

module c_sub (
    input  logic [31:0]  operand_a,
    input  logic [31:0]  operand_b,
    output logic [31:0]  res
);

    logic signed [15:0] a, b, c, d;
    // Premier complexe a+ib
    assign a = $signed(operand_a[15:0]);
    assign b = $signed(operand_a[31:16]);
    // Second complexe c+id
    assign c = $signed(operand_b[15:0]);
    assign d = $signed(operand_b[31:16]);

    logic signed [15:0] res_r, res_i;
    assign res_r = a - c;
    assign res_i = b - d;

    assign res = {res_i, res_r};

endmodule : c_sub