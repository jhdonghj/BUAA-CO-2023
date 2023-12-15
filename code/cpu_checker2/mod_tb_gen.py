from random import randint

for i in range(10):
    a, m = randint(1, 2**64 - 1), randint(1, 2**16 - 1)
    print('a = {}; m = {}; #10; // {}'.format(a, m, a % m))
