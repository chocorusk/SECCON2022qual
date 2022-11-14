import math
from Crypto.Util.number import *
from output import *

p=math.gcd(c1+c2, n)
q=math.gcd(pow(p, e, n)-c1+n, n)
r=n//(p*q)

Rp.<xp>=PolynomialRing(GF(p))
rp=(xp^2-cm).roots()

Rq.<xq>=PolynomialRing(GF(q))
rq=(xq^2-cm).roots()

Rr.<xr>=PolynomialRing(GF(r))
rr=(xr^2-cm).roots()

for i in range(2):
    for j in range(2):
        for k in range(2):
            rp1=int(rp[i][0])
            rq1=int(rq[j][0])
            rr1=int(rr[k][0])
            x=CRT_list([rp1,rq1,rr1],[p,q,r])
            m=pow(int(x), inverse(e//2, (p-1)*(q-1)*(r-1)), n)
            print(long_to_bytes(int(m)))
        