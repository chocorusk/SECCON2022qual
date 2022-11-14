local_28 = 0x380a41
local_58 = 0x3032204e
local_48 = 0x202f2004
uStack68 = 0x591e2320
uStack64 = 0x357f1a44
uStack60 = 0x2b2d3675
local_54 = 0x3232
local_38 = 0x35a1711
uStack52 = 0x736506d
uStack48 = 0x1093c15
uStack44 = 0x362b4704
local_52 = 0
local_68 = 0x636c6557
uStack100 = 0x20656d6f
uStack96 = 0x53206f74
uStack92 = 0x4f434345

x=[local_48, uStack68, uStack64, uStack60, local_38, uStack52, uStack48, uStack44, local_28]
s=[]
for v in x:
    for i in range(4):
        s.append((v>>(i*8))&0xff)

key = "Welcome to SECCON 2022Welcome to SECCON 2022"

for i in range(len(s)):
    s[i]^=ord(key[i])

print(bytes(s))
