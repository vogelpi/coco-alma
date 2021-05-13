# We start with
# - secret X in x6 and x7 (A and B share)
# - secret Y in x8 and x9 (A and B share)
#
# We end up with
# - Secret Q in x11 and x12 (A and B share)
#
# Where Q = X & Y
#
.org 0x80
nop
# Load randomness from address 0 into x10
li x30, 0x0
lw x10, (x30)
# Compute inner-domain terms.
and x1, x6, x8
and x16, x17, x18 # dummy op to flush ALU
and x2, x7, x9
# Compute cross-domain terms.
and x16, x17, x18 # dummy op to flush ALU
and x3, x6, x9
and x16, x17, x18 # dummy op to flush ALU
and x4, x7, x8
# Resharing of cross-domain terms.
and x16, x17, x18 # dummy op to flush ALU
xor x14, x4, x10
and x16, x17, x18 # dummy op to flush ALU
xor x13, x3, x10
# Integration
and x16, x17, x18 # dummy op to flush ALU
xor x11, x1, x13
and x16, x17, x18 # dummy op to flush ALU
xor x12, x2, x14
nop
nop
nop
nop
nop
