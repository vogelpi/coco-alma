# We expect to see leakage in stable or transient modes

.section .text.start

# x2 = 6
li x2, 6
# *x2 == w6 = dmem[1] # share 0
bn.lid x2, 32(x0)
# x2 = 7
li x2, 7
# *x2 == w7 = dmem[2] # share 0
bn.lid x2, 64(x0)

# uncomment this line to remove stable leak by masking it
# x2 = 10
li x2, 10
# *x2 == w10 = dmem[3] # share 0
bn.lid x2, 96(x0)
bn.xor w6, w6, w10

bn.xor w8, w6, w7

ecall