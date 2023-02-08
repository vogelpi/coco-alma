# w0 and w1 have shares

.section .text.start

# # no leakage
# bn.xor w3, w4, w5

# # no leakage
# bn.and w2, w1, w1

# # no leakage
# bn.sid x0, 0(x0)

# # transient leakage but no stable leakage
# # violation: a register or memory location which contains one
# # share must not be overwritten with its counterpart.
# bn.and w1, w0, w0

# # stable and transient leakage
# bn.xor w2, w0, w1

# # transient leakage but no stable leakage
# # violation: shares of the same secret must not be accessed within
# # two successive instructions
# bn.xor w2, w0, w0
# bn.xor w3, w1, w1

# # no leakage
# # use dummy instructions between the instructions that use shares of the same
# # secret
# bn.xor w2, w0, w0
# bn.xor w4, w5, w6
# bn.xor w3, w1, w1

# # transient leakage but no stable leakage
# # violation: shares of the same secret must not be accessed within
# # two successive instructions
# bn.and w2, w0, w0
# bn.and w3, w1, w1

# # no leakage expected -> but there is transient leakage unexpectedly
# # use dummy instructions between the instructions that use shares of the same
# # secret
# bn.and w2, w0, w0
# bn.and w4, w5, w6
# bn.and w3, w1, w1

# no leakage
# use 2 x dummy instructions between the instructions that use shares of the
# same secret
bn.and w2, w0, w0
bn.and w4, w5, w6
bn.and w4, w5, w6
bn.and w3, w1, w1

ecall