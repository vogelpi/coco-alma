# We don't expect any leakage at all in stable or transient modes

.section .text.start

lw x2, 32(x0) # share 0
lw x30, 96(x0) # dummy op
lw x3, 64(x0) # share 0

ecall