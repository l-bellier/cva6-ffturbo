// -----------------------------------------------------------------------------
// Project      : RISCV Contest
// File         : bfly.sv
// Author       : BELLIER Lucas <lucas.bellier@imt-atlantique.net>
// Created      : 2026-03-11
// Description  : Moodule intégrant les papillons 2 et 4 pour un coprocesseur
// -----------------------------------------------------------------------------
// Modification History:
// Date        By          Description
// 2026-03-11    BELLIER Lucas     Initial release
// -----------------------------------------------------------------------------


module bfly 
    import cvxif_instr_pkg::*;
#(
    parameter int unsigned NrRgprPorts = 2,
    parameter int unsigned XLEN = 32,
    parameter type hartid_t = logic,
    parameter type id_t = logic,
    parameter type registers_t = logic

) (
    input  logic                  clk_i,
    input  logic                  rst_ni,
    input  registers_t            registers_i,
    input  opcode_t           opcode_i,
    input  hartid_t               hartid_i,
    input  id_t                   id_i,
    input  logic       [     4:0] rd_i,
    output logic       [XLEN-1:0] result_o,
    output hartid_t               hartid_o,
    output id_t                   id_o,
    output logic       [     4:0] rd_o,
    output logic                  valid_o,
    output logic                  we_o
);
    
// -----------------------------------------------------------------------------
// Bfly 2
// -----------------------------------------------------------------------------
    
    // Buffers et params
    logic bfly_type; // 1'b0 : 2 | 1'b1 : 4
    logic fill_buffer;
    logic inv;
    logic [4:0]  m;
    logic [31:0] tw_index;
    logic [31:0] tw1_buffer [32];
    logic [31:0] tw2_buffer [32];
    logic [31:0] tw3_buffer [32];

    //Etage 1
    logic [31:0] div0, div1;
    logic [31:0] div0_ff, div1_ff, div2_ff, div3_ff;
    
    // Division
    c_fixdiv div_0 (
        .operand_a(registers_i[0]),
        .div_type(bfly_type),
        .res(div0)
    );
    c_fixdiv div_1 (
        .operand_a(registers_i[1]),
        .div_type(bfly_type),
        .res(div1)
    );

    //Etage 2
    logic [31:0] tw1, tw2, tw3;
    logic [31:0] mul1, mul2, mul3;
    logic [31:0] mul0_ff, mul1_ff, mul2_ff, mul3_ff;
    
    assign tw1 = tw1_buffer[tw_index];
    assign tw2 = (fill_buffer) ? registers_i[0] : tw2_buffer[tw_index];
    assign tw3 = tw3_buffer[tw_index];
    
    c_mult c_mul1 (
        .operand_a(div1_ff),
        .operand_b(tw1),
        .res(mul1)
    );
    c_mult c_mul2 (
        .operand_a(div2_ff),
        .operand_b(tw2),
        .res(mul2)
    );
    c_mult c_mul3 (
        .operand_a(div3_ff),
        .operand_b(tw3),
        .res(mul3)
    );

    //Etage 3 additions/soustractions

    logic [31:0] add0, add1, add2, add3;
    logic [31:0] add0_ff, add1_ff, add2_ff, add3_ff;

    c_add c_add0 (
        .operand_a(mul0_ff),
        .operand_b(mul2_ff),
        .res(add0)
    );

    c_sub c_sub0 (
        .operand_a(mul0_ff),
        .operand_b(mul2_ff),
        .res(add1)
    );

    c_add c_add1 (
        .operand_a(mul1_ff),
        .operand_b(mul3_ff),
        .res(add2)
    );

    c_sub c_sub1 (
        .operand_a(mul1_ff),
        .operand_b(mul3_ff),
        .res(add3)
    );

    // Etage 4 : Sortie bfly4
    logic [31:0] bfly4_0_o, bfly4_1_o, bfly4_2_o, bfly4_3_o;

    c_add c_add_o (
        .operand_a(add0_ff),
        .operand_b(add2_ff),
        .res(bfly4_0_o)
    );

    c_sub c_sub_o (
        .operand_a(add0_ff),
        .operand_b(add2_ff),
        .res(bfly4_2_o)
    );

    cross_op #(
        .cross_sub(1'b0)
    ) cross_add (
        .inv(inv),
        .operand_a(add1_ff),
        .operand_b(add3_ff),
        .res(bfly4_1_o)
    );

    cross_op #(
        .cross_sub(1'b1)
    ) cross_sub (
        .inv(inv),
        .operand_a(add1_ff),
        .operand_b(add3_ff),
        .res(bfly4_3_o)
    );


    // Gestion des variables et de la pipeline
    always_ff @(posedge clk_i, negedge rst_ni) begin
        if (~rst_ni) begin            
            // Etage 1 : Divisions fixe
            div0_ff <= '0;
            div1_ff <= '0;
            div2_ff <= '0;
            div3_ff <= '0;

            // Etage 2 : Multiplications            
            mul0_ff <= '0;
            mul1_ff <= '0;
            mul2_ff <= '0;
            mul3_ff <= '0;

            // Etage 3 : Additions / Soustractions
            add0_ff <= '0;
            add1_ff <= '0;
            add2_ff <= '0;
            add3_ff <= '0;

        end else begin
            // Pipeline libre
            add0_ff <= add0;
            add1_ff <= add1;
            add2_ff <= add2;
            add3_ff <= add3;
            // Pipeline piloté
            case (opcode_i)
                cvxif_instr_pkg::BFLY_SET_F0F2: begin
                    div0_ff <= div0;
                    div2_ff <= div1;
                end
                cvxif_instr_pkg::BFLY_SET_F1F3: begin
                    div1_ff <= div0;
                    div3_ff <= div1;
                end
                cvxif_instr_pkg::BFLY_SET_W2: begin
                    mul0_ff <= div0_ff;
                    mul1_ff <= mul1;
                    mul2_ff <= mul2;
                    mul3_ff <= mul3;
                end
            endcase
        end
    end

    // Gestion des buffers
    always_ff @(posedge clk_i, negedge rst_ni) begin
        if (~rst_ni) begin
            fill_buffer <= 1'b1;
            tw_index    <= '0;
            inv         <= '0;
            bfly_type   <= '0;
            m           <= '0;
            tw1_buffer  <= '{default: '0};
            tw2_buffer  <= '{default: '0};
            tw3_buffer  <= '{default: '0};
        end else begin
            case (opcode_i)
                cvxif_instr_pkg::BFLY_CFG: begin
                    fill_buffer <= registers_i[0][0];
                    tw_index    <= registers_i[0][1] ? '0 : tw_index;
                    inv         <= registers_i[0][2];
                    bfly_type   <= registers_i[0][3];
                    m           <= registers_i[0][8:4];
                end
                cvxif_instr_pkg::BFLY_SET_W1W3: begin
                    tw1_buffer[tw_index] <= registers_i[0];
                    tw3_buffer[tw_index] <= registers_i[1];
                end
                cvxif_instr_pkg::BFLY_SET_W2: begin
                    tw2_buffer[tw_index] <= (fill_buffer) ? registers_i[0] : tw2_buffer[tw_index];
                    tw_index <= (tw_index == (m - 1)) ? '0 : tw_index + 1;
                end
            endcase
        end
    end

    // Gestion des sorties
    always_comb begin
        case (opcode_i)
            cvxif_instr_pkg::BFLY_CFG: begin
                result_o = '0;
                hartid_o = hartid_i;
                id_o     = id_i;
                valid_o  = 1'b1;
                rd_o     = '0;
                we_o     = '0;
            end
            cvxif_instr_pkg::BFLY_SET_F0F2: begin
                result_o = '0;
                hartid_o = hartid_i;
                id_o     = id_i;
                valid_o  = 1'b1;
                rd_o     = '0;
                we_o     = '0;
            end
            cvxif_instr_pkg::BFLY_SET_F1F3: begin
                result_o = '0;
                hartid_o = hartid_i;
                id_o     = id_i;
                valid_o  = 1'b1;
                rd_o     = '0;
                we_o     = '0;
            end
            cvxif_instr_pkg::BFLY_SET_W1W3: begin
                result_o = '0;
                hartid_o = hartid_i;
                id_o     = id_i;
                valid_o  = 1'b1;
                rd_o     = '0;
                we_o     = '0;
            end
            cvxif_instr_pkg::BFLY_SET_W2: begin
                result_o = '0;
                hartid_o = hartid_i;
                id_o     = id_i;
                valid_o  = 1'b1;
                rd_o     = '0;
                we_o     = '0;
            end
            cvxif_instr_pkg::BFLY_GET_F0: begin
                result_o = bfly_type ? bfly4_0_o : add0_ff;
                hartid_o = hartid_i;
                id_o     = id_i;
                valid_o  = 1'b1;
                rd_o     = rd_i;
                we_o     = 1'b1;
            end
            cvxif_instr_pkg::BFLY_GET_F1: begin
                result_o = bfly_type ? bfly4_1_o : add1_ff;
                hartid_o = hartid_i;
                id_o     = id_i;
                valid_o  = 1'b1;
                rd_o     = rd_i;
                we_o     = 1'b1;
            end
            cvxif_instr_pkg::BFLY_GET_F2: begin
                result_o = bfly4_2_o;
                hartid_o = hartid_i;
                id_o     = id_i;
                valid_o  = 1'b1;
                rd_o     = rd_i;
                we_o     = 1'b1;
            end
            cvxif_instr_pkg::BFLY_GET_F3: begin
                result_o = bfly4_3_o;
                hartid_o = hartid_i;
                id_o     = id_i;
                valid_o  = 1'b1;
                rd_o     = rd_i;
                we_o     = 1'b1;
            end
            default: begin
                result_o = '0;
                hartid_o = '0;
                id_o     = '0;
                valid_o  = '0;
                rd_o     = '0;
                we_o     = '0;
            end
        endcase
    end

endmodule : bfly