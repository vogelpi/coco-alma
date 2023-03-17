# DMEM Load and store example for formal masking analysis

.section .text.start

start:

  # w0 <= dmem[share0]
  li x2, 0
  la x3, share0
  bn.lid x2, 0(x3)

  # comment this part to see a stable leakage
  # mask w0
  # w0 = w0 ^ rnd
  bn.wsrr w31, 0x1
  bn.xor w0, w0, w31

  # w1 <= dmem[share1]
  li x2, 1
  la x3, share1
  bn.lid x2, 0(x3)

  # w2 <= w0 ^ w1
  bn.xor w2, w0, w1

  # dmem[key] <= w2
  li x2, 2
  la x3, key
  bn.sid x2, 0(x3)

  ecall

.data

.balign 32
.globl share0
share0:
  .word 0x2335f23f
  .word 0x3c174a16
  .word 0x128c1339
  .word 0xc48e8981
  .word 0x7843d9a2
  .word 0xbb6a0205
  .word 0x446984cc
  .word 0xa210c4be

.balign 32
.globl share1
share1:
  .word 0x225596d6
  .word 0x2df4bec0
  .word 0xbeb67c9e
  .word 0x6f2f939a
  .word 0xf7d1a873
  .word 0x99dd9f5a
  .word 0x551f77d1
  .word 0x17bcfeef

.balign 32
.globl key
key:
  .zero 32
