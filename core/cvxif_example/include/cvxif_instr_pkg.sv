// Copyright 2021 Thales DIS design services SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon (guillaume.chauvon@thalesgroup.com)
//
// Modified : Lucas Bellier (lucas.bellier@imt-atlantique.net)
// Desciption : Modification des instructions customs vers des instruction 
//              pour les papillons 2 et 4 



package cvxif_instr_pkg;

  typedef enum logic [3:0] {
    ILLEGAL = 4'b0000,
    NOP = 4'b0001,
    BFLY_CFG = 4'b0010,
    BFLY_SET_F0F2 = 4'b0011,
    BFLY_SET_F1F3 = 4'b0100,
    BFLY_SET_W1W3 = 4'b0101,
    BFLY_SET_W2 = 4'b0110,
    BFLY_GET_F0 = 4'b0111,
    BFLY_GET_F1 = 4'b1000,
    BFLY_GET_F2 = 4'b1001,
    BFLY_GET_F3 = 4'b1010
  } opcode_t;


  typedef struct packed {
    logic accept;
    logic writeback;  // TODO depends on dualwrite
    logic [2:0] register_read;  // TODO Nr read ports
  } issue_resp_t;

  typedef struct packed {
    logic        accept;
    logic [31:0] instr;
  } compressed_resp_t;

  typedef struct packed {
    logic [31:0] instr;
    logic [31:0] mask;
    issue_resp_t resp;
    opcode_t     opcode;
  } copro_issue_resp_t;


  typedef struct packed {
    logic [15:0]      instr;
    logic [15:0]      mask;
    compressed_resp_t resp;
  } copro_compressed_resp_t;

  parameter int unsigned NbInstr = 10;
  parameter copro_issue_resp_t CoproInstr[NbInstr] = '{
      '{
          // Custom Nop
          instr:
          32'b0000000_00000_00000_000_00000_1111011,  // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : NOP
      },
      '{
          // BFLY_CFG
          instr:
          32'b0000001_00000_00000_000_00000_1111011,  // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b0, 1'b1}},
          opcode : BFLY_CFG
      },
      '{
          // BFLY_SET_F0F2
          instr:
          32'b0000010_00000_00000_000_00000_1111011,  // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b1, 1'b1}},
          opcode : BFLY_SET_F0F2
      },
      '{
          // BFLY_SET_F1F3
          instr:
          32'b0000011_00000_00000_000_00000_1111011,  // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b1, 1'b1}},
          opcode : BFLY_SET_F1F3
      },
      '{
          // BFLY_SET_W1W3
          instr:
          32'b0000100_00000_00000_000_00000_1111011,  // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b1, 1'b1}},
          opcode : BFLY_SET_W1W3
      },
      '{
          // BFLY_SET_W2
          instr:
          32'b0000101_00000_00000_000_00000_1111011,  // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b0, 1'b1}},
          opcode : BFLY_SET_W2
      },
      '{
          // BFLY_GET_F0
          instr:
          32'b0000110_00000_00000_000_00000_1111011, // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : BFLY_GET_F0
      },
      '{
          // BFLY_GET_F1
          instr:
          32'b0000111_00000_00000_000_00000_1111011, // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : BFLY_GET_F1
      },
      '{
          // BFLY_GET_F2
          instr:
          32'b0001000_00000_00000_000_00000_1111011, // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : BFLY_GET_F2
      },
      '{
          // BFLY_GET_F3
          instr:
          32'b0001001_00000_00000_000_00000_1111011, // custom3 opcode
          mask: 32'b1111111_00000_00000_111_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : BFLY_GET_F3
      }
  };

  parameter int unsigned NbCompInstr = 2;
  parameter copro_compressed_resp_t CoproCompInstr[NbCompInstr] = '{
      // C_NOP
      '{
          instr : 16'b111_0_00000_00000_00,
          mask : 16'b111_1_00000_00000_11,
          resp : '{accept : 1'b1, instr : 32'b00000_00_00000_00000_0_00_00000_1111011}
      },
      '{
          instr : 16'b111_1_00000_00000_00,
          mask : 16'b111_1_00000_00000_11,
          resp : '{accept : 1'b1, instr : 32'b00000_00_00000_00000_0_01_01010_1111011}
      }
  };

endpackage
