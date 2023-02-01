# We expect to see leakage in stable or transient modes

.section .text.start

# uncomment this line to remove stable leak by masking it
bn.xor w6, w6, w10

bn.xor w8, w6, w7

ecall