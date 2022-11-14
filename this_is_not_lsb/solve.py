import socket
from Crypto.Util.number import *
import random

def recvuntil(client, delim=b'\n'):
    buf = b''
    while delim not in buf:
        buf += client.recv(1)
    return buf

host = 'this-is-not-lsb.seccon.games'
port = 8080
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((host, port))

n=int(recvuntil(client).replace(b'n = ', b'').strip().decode())
e=int(recvuntil(client).replace(b'e = ', b'').strip().decode())
flag_length=int(recvuntil(client).replace(b'flag_length = ', b'').strip().decode())
c=int(recvuntil(client).replace(b'c = ', b'').strip().decode())

def query(k):
    c1=pow(k, e, n)*c%n
    recvuntil(client, b'c = ')
    client.send(str(c1).encode()+b'\n')
    res = recvuntil(client)
    return (b'True' in res)

k=0
for _ in range(2048):
    k=random.randrange(n//(2**439), n//(2**438))
    res = query(k)
    if res:
        break

kl=k-2**(n.bit_length()-10-438)
kr=k
while kr-kl>1:
    km=(kl+kr)//2
    res = query(km)
    if res:
        kr=km
    else:
        kl=km

for i in range(2):
    m=(i*n+(2**(n.bit_length()-10))*255)//kl
    print(long_to_bytes(m))
    