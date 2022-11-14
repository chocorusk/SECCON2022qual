from Crypto.Util.number import *
import math
from output import *

c1=2**128
c2=2**256

mat=[]
for i in range(3):
    l=[]
    for j in range(4):
        x=shares[j][0][0]
        l.append((x**(i+1))%p)
    l=l+[0]*7
    l[4+i]=c1
    mat.append(l)
for i in range(3):
    l=[]
    for j in range(4):
        y=shares[j][0][1]
        l.append((y**(i+1))%p)
    l=l+[0]*7
    l[7+i]=c1
    mat.append(l)
l=[]
for j in range(4):
    w=shares[j][1]
    l.append(w)
l=l+[0]*7
l[10]=c2
mat.append(l)
for j in range(4):
    l2=[0]*11
    l2[j]=p
    mat.append(l2)

res = Matrix(mat).LLL()

res=[x//c1 for x in res[0][4:10]]

vs=[]
for j in range(4):
    v1=shares[j][1]
    for i in range(3):
        x=shares[j][0][0]
        v1-=res[i]*(x**(i+1))
    for i in range(3):
        y=shares[j][0][1]
        v1-=res[i+3]*(y**(i+1))
    v1%=p
    vs.append(v1)

c=0
for j in range(3):
    c=math.gcd(int(c), int(vs[j+1]-vs[0]))
coeffs=res+[c]+[vs[0]%c]

key = 0
for coeff in coeffs:
    key <<= 128
    key ^^= coeff
flag = ciphertext^^key
print(long_to_bytes(int(flag)))
