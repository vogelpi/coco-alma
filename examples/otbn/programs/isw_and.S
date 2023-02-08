# We start with
# - secret X in w6 and w7 (A and B share) - 0011 = 1010 ^ 1001
# - secret Y in w8 and w9 (A and B share) - 0101 = 1110 ^ 1011
# - fresh mask in w10 - 0110
# - expected result w11 ^ w12 == 0110 ^ 0111 = 0001 == 0011 & 0101
#
# We end up with
# - Secret Q in x11 and x12 (A and B share)
#
# Where Q = X & Y
#
.section .text.start

# # Set initial values
# # Uncomment here when checking the result
# bn.xor w0, w0, w0
# bn.xor w6, w6, w6
# bn.addi w6, w6, 10
# bn.xor w7, w7, w7
# bn.addi w7, w7, 9
# bn.xor w8, w8, w8
# bn.addi w8, w8, 14
# bn.xor w9, w9, w9
# bn.addi w9, w9, 11
# bn.xor w10, w10, w10
# bn.addi w10, w10, 6

# Compute inner-domain terms.
bn.and w1, w6, w8
bn.and w0, w0, w0 # dummy
bn.and w0, w0, w0 # dummy
bn.and w2, w7, w9
bn.and w0, w0, w0 # dummy
bn.and w0, w0, w0 # dummy

# Compute cross-domain terms.
bn.and w3, w6, w9
bn.and w0, w0, w0 # dummy
bn.and w0, w0, w0 # dummy
bn.and w4, w7, w8
bn.and w0, w0, w0 # dummy
bn.and w0, w0, w0 # dummy

# Resharing of cross-domain terms.
bn.xor w14, w4, w10
bn.and w0, w0, w0 # dummy
bn.and w0, w0, w0 # dummy
bn.xor w13, w3, w10
bn.and w0, w0, w0 # dummy
bn.and w0, w0, w0 # dummy

# Integration
bn.xor w11, w1, w13
bn.and w0, w0, w0 # dummy
bn.and w0, w0, w0 # dummy
bn.xor w12, w2, w14
bn.and w0, w0, w0 # dummy
bn.and w0, w0, w0 # dummy

# # Compute result and compare it with the expected result
# # If the result is different than the expected one,
# # otbn cannot exit from the infinite loop
# bn.xor w15, w11, w12
# li x31, 15
# bn.sid x31, 0(x0)
# lw x31, 0(x0)
# li x30, 1
# inf_loop:
# bne x31, x30, inf_loop

ecall