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

# # stable leakage: (s0 ^ m) & (s1 & m)
# bn.xor w0, w2, w0
# bn.xor w1, w2, w1
# bn.and w4, w1, w0

# # transient leakage
# bn.sel  w4, w1, w0, FG0.C

# # no leakage; clear ACC before using a different flagset
# bn.xor        w9, w9, w9 # create a zero register
# bn.mulqacc.wo w6, w4.0, w0.0, 0, FG0
# bn.wsrw       0x3 /* ACC */, w9 # clear ACC
# bn.wsrw       0x3 /* ACC */, w9 # dummy instruction
# bn.mulqacc.wo w7, w5.0, w1.0, 0, FG1

# # no leakage; clear ACC and flags before using the same flagset
# bn.xor        w9, w9, w9 # create a zero register
# bn.mulqacc.wo w6, w4.0, w0.0, 0, FG0
# bn.wsrw       0x3 /* ACC */, w9 # clear ACC
# bn.mulqacc.wo w9, w9.0, w9.0, 0, FG0 # clear flags and also works as a dummy instruction
# bn.mulqacc.wo w7, w5.0, w1.0, 0, FG0

ecall
