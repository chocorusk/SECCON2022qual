import socket
from Crypto.Util.number import *
from Crypto.Util.Padding import pad, unpad

def recvuntil(client, delim=b'\n'):
    buf = b''
    while delim not in buf:
        buf += client.recv(1)
    return buf

host = 'witches-symmetric-exam.seccon.games'
port = 8080
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((host, port))

ciphertext = recvuntil(client).replace(b'ciphertext: ', b'').strip().decode()
iv = ciphertext[:32]
print(ciphertext)

def xor(s, t):
    return bytes([x^^y for x,y in zip(s,t)])

def query(s):
    recvuntil(client, b'ciphertext: ')
    client.send(s.encode()+b'\n')
    res = recvuntil(client)
    return res

encivs=[]
for i in range(4):
    enciv=b''
    for j in range(16):
        for k in range(256):
            s=b'\x00'*(16*i)+b'\x00'*(15-j)+bytes([k])+xor(bytes([j+1]*j), enciv)
            res = query(iv+s.hex())
            if b'ofb' not in res:
                enciv = bytes([k^^(j+1)])+enciv
                break
        else:
            print('ng')
            exit()
    encivs.append(enciv)

def encrypt(plain):
    assert len(plain)==16
    enc=b''
    for j in range(16):
        for k in range(256):
            s=b'\x00'*(15-j)+bytes([k])+xor(bytes([j+1]*j), enc)
            res = query(plain.hex()+s.hex())
            if b'ofb' not in res:
                enc = bytes([k^^(j+1)])+enc
                break
        else:
            print('ng')
            exit()
    return enc

tag_nonce_cipher = xor(bytes.fromhex(ciphertext[32:]), b''.join(encivs))
tag = tag_nonce_cipher[:16]
nonce = tag_nonce_cipher[16:32]
cipher = unpad(tag_nonce_cipher[32:], 16)

F.<a> = GF(2^128, modulus=x^128 + x^7 + x^2 + x + 1)
P.<x> = PolynomialRing(F)

def to_poly(b):
    v = int.from_bytes(b, 'big')
    v = int(f"{v:0128b}"[::-1], 2)
    return F.fetch_int(v)

def to_bytes(p):
    v = p.integer_representation()
    v = int(f"{v:0128b}"[::-1], 2)
    return v.to_bytes(16, 'big')

def ghash(H, C):
    return to_bytes(to_poly(C)*to_poly(H)^2 + to_poly(long_to_bytes(8*16,16))*to_poly(H))

def calc_tag(H, enc, c0):
    return to_bytes(to_poly(enc.ljust(16,b"\x00"))*to_poly(H)^2 + to_poly(long_to_bytes(8*len(enc),16))*to_poly(H) + to_poly(encrypt(c0)))

H = encrypt(b'\x00'*16)
c0=ghash(H, nonce)
c1=long_to_bytes((bytes_to_long(c0)+1))
c2=long_to_bytes((bytes_to_long(c0)+2))
e1=encrypt(c1)
e2=encrypt(c2)

secret = xor(cipher[:16],e1)+xor(cipher[16:],e2)

plain = b"give me key"
res = bytes.fromhex(iv)
input = b''
input += calc_tag(H, xor(plain, e1), c0)
input += nonce
input += xor(plain,e1)
input = pad(input, 16)
res += xor(input[:16], encivs[0]) + xor(input[16:32], encivs[1]) + xor(input[32:], encivs[2])

recvuntil(client, b'ciphertext: ')
client.send(res.hex().encode()+b'\n')
print(recvuntil(client, b'ok, please say secret spell:'))
client.send(secret+b'\n')
print(recvuntil(client))
