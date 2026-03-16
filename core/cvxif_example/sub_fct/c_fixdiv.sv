// -----------------------------------------------------------------------------
// Project      : RISCV Contest
// File         : c_fixdiv.sv
// Author       : BELLIER Lucas <lucas.bellier@imt-atlantique.net>
// Created      : 2026-03-11
// Description  : Ce module permet la division d'un nombre complexe par un
//                scalaire fix égalà 2 ou à 4. 
// -----------------------------------------------------------------------------
// Modification History:
// Date        By          Description
// 2026-03-11    BELLIER Lucas     Initial release
// -----------------------------------------------------------------------------

module c_fixdiv (
    input  logic [31:0]  operand_a,
    input  logic div_type, // 1'b0 : 2 | 1'b1 : 4
    output logic [31:0]  res
);
    logic signed [15:0] a, b, c;
    // Nombre complexe
    assign a = $signed(operand_a[15:0]);
    assign b = $signed(operand_a[31:16]);
    // Nombre scalaire
    assign c = div_type ? 16'h1FFF : 16'h3FFF; 

    logic signed [31:0] res_r_full, res_i_full;
    // 2 multiplications
    assign res_r_full = a * c;
    assign res_i_full = b * c;

    // Arrondi
    logic signed [15:0] res_r, res_i;
    assign res_r = 16'( (res_r_full + 32'sd16384) >>> 15 );
    assign res_i = 16'( (res_i_full + 32'sd16384) >>> 15 );

    assign res = {res_i, res_r};

endmodule : c_fixdiv