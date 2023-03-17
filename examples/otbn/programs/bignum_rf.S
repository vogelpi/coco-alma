# w0[0]: secret 0
# w1[0]: secret 1
# w2[0]: static_random
# w3[0]: volatile_random

.section .text.start

# # no leakage
# bn.xor w6, w4, w5

# # no leakage
# bn.and w4, w0, w0

# # no leakage
# bn.sid x0, 0(x0)

# # transient leakage
# # violation: a register or memory location which contains one
# # share must not be overwritten with its counterpart.
# bn.and w1, w0, w0

# # stable leakage
# bn.xor w4, w1, w0

# # transient leakage
# # violation: shares of the same secret must not be accessed within
# # two successive instructions
# bn.xor w4, w0, w0
# bn.xor w5, w1, w1

# # no leakage
# # use dummy instructions between the instructions that use shares of the same
# # secret
# bn.xor w4, w0, w0
# bn.xor w9, w9, w9 # dummy
# bn.xor w5, w1, w1

# # transient leakage
# # violation: shares of the same secret must not be accessed within
# # two successive instructions
# bn.and w4, w0, w0
# bn.and w5, w1, w1

# # no leakage
# # use dummy instructions between the instructions that use shares of the same
# # secret
# bn.and w4, w0, w0
# bn.xor w9, w9, w9 # dummy
# bn.and w5, w1, w1

# # stable leakage
# # violation: shares of the same secret cannot be in a register even in
# # different indexes
# bn.xor  w9, w9, w9
# bn.rshi w1, w1, w9 >> 254
# bn.xor  w4, w1, w0

# # no leakage
# bn.xor w0, w2, w0
# bn.xor w9, w9, w9 # dummy
# bn.xor w4, w1, w0

# # stable leakage
# # add operation in lsb bits removes the mask
# bn.xor w0, w2, w0
# bn.add w0, w2, w0
# bn.xor w9, w9, w9 # dummy
# bn.xor w4, w1, w0

ecall