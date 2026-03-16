/*******************************************************************************
 * Project      : RISCV Contest
 * File         : bfly_instr.h
 * Author       : Bellier Lucas
 * Created      : 16/03/2026
 * Description  : Fichier définissant les instructions customs
 *******************************************************************************/

#ifndef BFLY_INSTR_H
#define BFLY_INSTR_H

// Opcode de custom 3 pôur toutes les instructions liées au copro
#define OPC_CUSTOM3 "0x7b"

#define BFLY_CFG_FILL_BUFF  0x01
#define BFLY_CFG_RST_BUFF   0x02
#define BFLY_CFG_INV_FFT    0x04
#define BFLY_CFG_BFLY4      0x08

// Ecriture sur le copro
// BFLY_CFG : rs1 = config_val
#define BFLY_CFG(rs1_val) \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x01, x0, %0, x0" : : "r"(rs1_val))

// BFLY_SET_F0F2 : rs1 = F0, rs2 = F2
#define BFLY_SET_F0F2(rs1_val, rs2_val) \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x02, x0, %0, %1" : : "r"(rs1_val), "r"(rs2_val))

// BFLY_SET_F1F3 : rs1 = F1, rs2 = F3
#define BFLY_SET_F1F3(rs1_val, rs2_val) \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x03, x0, %0, %1" : : "r"(rs1_val), "r"(rs2_val))

// BFLY_SET_W1W3 : rs1 = W1, rs2 = W3
#define BFLY_SET_W1W3(rs1_val, rs2_val) \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x04, x0, %0, %1" : : "r"(rs1_val), "r"(rs2_val))

// BFLY_SET_W2 : rs1 = W2
#define BFLY_SET_W2(rs1_val) \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x05, x0, %0, x0" : : "r"(rs1_val))


// Lecture sur le copro
// BFLY_GET_F0 : rd = résultat
#define BFLY_GET_F0(rd_var) \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x06, %0, x0, x0" : "=r"(rd_var))

// BFLY_GET_F1 : rd = résultat
#define BFLY_GET_F1(rd_var) \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x07, %0, x0, x0" : "=r"(rd_var))

// BFLY_GET_F2 : rd = résultat
#define BFLY_GET_F2(rd_var) \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x08, %0, x0, x0" : "=r"(rd_var))

// BFLY_GET_F3 : rd = résultat
#define BFLY_GET_F3(rd_var) \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x09, %0, x0, x0" : "=r"(rd_var))

// NOP
#define BFLY_NOP() \
  __asm__ volatile (".insn r " OPC_CUSTOM3 ", 0x0, 0x00, x0, x0, x0")

#endif // BFLY_INSTR_H