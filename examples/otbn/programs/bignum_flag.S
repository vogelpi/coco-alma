# This is a specific program to show a possible leakage and a fix for that 

# Don't forget to label LSB 2 bits not only the LSB. Do this by setting width
# parameter to 2 when running generate_bignum_rf_labels.py script

# w0[1:0]: secret 0[1:0]
# w1[1:0]: secret 1[1:0]
# w2[1:0]: static_random[1:0]
# w3[1:0]: volatile_random[1:0]

# w31 = 0
bn.xor   w31, w31, w31

# w6 = {mask, 0}
bn.rshi  w6, w2, w31 >> 1
bn.rshi  w6, w31, w6 >> 254

# w4[0] = s0[0]
bn.rshi  w4, w0, w31 >> 1
bn.rshi  w4, w31, w4 >> 255

# w4[1] = mask
bn.xor   w4, w6, w4
bn.xor   w31, w31, w31 # dummy

# w6 = {0, mask}
bn.rshi  w6, w2, w31 >> 1
bn.rshi  w6, w31, w6 >> 255

# w5[0] = s1[0] ^ mask
bn.xor   w5, w6, w1

# w5[1] = s1[1]

# w7 = w4 ^ w5 = {s1[1] ^ mask, s1[0] ^ mask ^ s0[0]}

# uncomment to see glitch based transient leakage on bignum flag computation logic
bn.xor   w7, w5, w4

# uncomment to remove transient leakage by aplying masking
# # w8 = fresh_mask
# bn.xor   w8, w31, w3
# # w5 = w5 ^ fresh_mask = {s1[1] ^ f_m[1], s1[0] ^ mask ^ f_m[0]}
# bn.xor   w5, w5, w8
# bn.xor   w31, w31, w31 # dummy instruction
# # w7 = w4 ^ w5 = {s1[1] ^ mask ^ f_m[1], s1[0] ^ mask ^ f_m[0] ^ s0[0]}
# bn.xor   w7, w5, w4
# bn.xor   w31, w31, w31
# # w7 = w7 ^ fresh_mask = {s1[1] ^ mask, s1[0] ^ mask ^ s0[0]}
# bn.xor   w7, w7, w8