# Read and use RND input for fresh masking
# w0 and w1 have shares

.section .text.start

bn.wsrr w0, 0x1
bn.xor w1, w1, w0

bn.wsrr w2, 0x1
bn.xor w3, w3, w2

bn.xor w5, w3, w1

ecall