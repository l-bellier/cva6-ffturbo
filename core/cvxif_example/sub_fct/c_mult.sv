// -----------------------------------------------------------------------------
// Project      : RISCV Contest
// File         : c_mult.sv
// Author       : BELLIER Lucas <lucas.bellier@imt-atlantique.net>
// Created      : 2026-03-11
// Description  : Ce module permet la multiplication de 2 nombres complexes
//                dont la partie réelle est sur les x premier bits et la partie
//                complexe sur les x dernier.
// -----------------------------------------------------------------------------
// Modification History:
// Date        By          Description
// 2026-03-11    BELLIER Lucas     Initial release
// -----------------------------------------------------------------------------


module c_mult (
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
  

    logic signed [31:0] ac, bd, ad, bc;
    // multiplications
    assign ac = a * c;
    assign bd = b * d;
    assign ad = a * d;
    assign bc = b * c;

    // Rassemblement des parties imaginaires et réelles
    logic signed [31:0] res_r_full, res_i_full;
    assign res_r_full = ac - bd;
    assign res_i_full = ad + bc;

    // Arrondi
    logic signed [15:0] res_r, res_i;
    assign res_r = 16'( (res_r_full + 32'sd16384) >>> 15 );
    assign res_i = 16'( (res_i_full + 32'sd16384) >>> 15 );

    assign res = {res_i, res_r};

endmodule : c_mult