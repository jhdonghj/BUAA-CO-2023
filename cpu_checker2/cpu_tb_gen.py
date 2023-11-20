from random import *

d = "0123456789"
h = d + "abcdef"
a = h + "`~!@#$%&*()_-=+ "

pc_min = 0x0000_3000 // 4
pc_max = 0x0000_4fff // 4
addr_min = 0x0000_0000 // 4
addr_max = 0x0000_2fff // 4

for i in range(20):
    ti = str(randint(1, 9999))
    pc = hex(4 * randint(pc_min, pc_max))[2:]
    addr = hex(4 * randint(addr_min, addr_max * 2))[2:]
    data = hex(randint(0x0000_0000, 0xffff_ffff))[2:]
    out = '^{}@{}:{}*{}{}<={}{}#'.format(
                    "0" * (4 - len(ti)) + ti,
                    "0" * (8 - len(pc)) + pc,
                    " " * randint(0, 4),
                    "0" * (8 - len(addr)) + addr,
                    " " * randint(0, 4),
                    " " * randint(0, 4),
                    "0" * (8 - len(data)) + data
                    )
    # flag = randint(0, 3)
    flag = 1
    for ch in out:
        print('#2 char = "{}";'.format(ch))
        t = randint(0, 3)
        if flag == 0 and t:
            while t:
                print('#2 char = "{}";'.format(choice(a)))
                t -= 1
    