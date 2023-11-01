#include <bits/stdc++.h>
using namespace std;
unsigned int grf[31];
int mem[3071];
int n;
FILE *code, *std;
int randReg()
{
	return rand() % 32;
}
int randImm16()
{
	return (rand() << 16 | rand()) % 65536;
}
int randOffset()
{
	return rand() % 4096;
}
void add()
{
	int rt = randReg();
	int rs = randReg();
	int rd = randReg();
	fprintf(code, "add $%d, $%d, $%d\n", rd, rs, rt);
	grf[rd] = grf[rs] + grf[rt];
	fprintf(std, "$%d <= %x", rd, grf[rd]);
}
void sub()
{
	int rt = randReg();
	int rs = randReg();
	int rd = randReg();
	fprintf(code, "sub $%d, $%d, $%d\n", rd, rs, rt);
	grf[rd] = grf[rs] - grf[rt];
	fprintf(std, "$%d <= %x", rd, grf[rd]);
}
void ori()
{
	int rt = randReg();
	int rs = randReg();
	int imm = randImm16();
	fprintf(code, "ori $%d, $%d, %d\n", rt, rs, imm);
	grf[rt] = grf[rs] | imm;
	fprintf(std, "$%d <= %x", rt, grf[rt]);
}
void lw()
{
	int rt = randReg();
	int rs = randReg();
	int offset = randOffset();
	if (rand() % 2)
		while (grf[rs] + offset > (3071 << 2))
			offset = randOffset(), rs = randReg();
	else
	{
		int tmp = randReg(), offset2 = rand() % 3071;
		if (grf[tmp] > (3071 << 2))
			tmp = 0;
		for (int i = 0; i < 3072; i++)
			if (mem[((grf[tmp] >> 2) + offset2 + i) % 3072])
			{
				rs = tmp;
				offset = (offset2 + i) << 2;
				break;
			}
	}
	offset -= (grf[rs] + offset) % 4;
	fprintf(code, "lw $%d, %d($%d)\n", rt, offset, rs);
	grf[rt] = mem[(grf[rs] + offset) >> 2];
	fprintf(std, "$%d <= %x", rt, grf[rt]);
}
void sw()
{
	int rt = randReg();
	int rs = randReg();
	int offset = randOffset();
	while (grf[rs] + offset > 3071)
		offset = randOffset(), rs = randReg();
	fprintf(code, "sw $%d, %d($%d)\n", rt, offset, rs);
	mem[grf[rs] + offset] = grf[rt];
	fprintf(std, "mem[%d] <= %x", grf[rs] + offset, grf[rt]);
}
void lui()
{
	int rt = randReg();
	int imm = randImm16();
	fprintf(code, "lui $%d, %d\n", rt, imm);
	grf[rt] = imm << 16;
	fprintf(std, "$%d <= %x", rt, grf[rt]);
}
void nop()
{
	fprintf(code, "nop\n");
}
void beq()
{
	int rs = randReg();
	int rt = randReg();
	int label = rand() % n;
	fprintf(code, "beq $%d, $%d, label%d\n", rs, rt, label);
}
void jal()
{
	int label = rand() % n;
	fprintf(code, "jal label%d\n", label);
}
void jr()
{
	int rs = randReg();
	while ((grf[rs] > (unsigned)n) && rs != 31)
		rs = randReg();
	fprintf(code, "jr $%d\n", rs);
}
int main()
{
	srand(0);
	code = fopen("code.asm", "w");
	std = fopen("std.out", "w");
	void (*func[10])() = {add, sub, ori, lw, sw, lui, beq, jal, jr, nop};
	cin >> n;
	for (int i = 0; i < n; i++)
	{
		fprintf(code, "label%d: ", i);
		int op = rand() % 10;
		if (i < 5)
			op = rand() % 7;
		if (op > 6)
			op = rand() % 10;
		func[op]();
	}
	fprintf(code, "label%d: beq $0 $0 label%d", n, n);
	fclose(code);
	fclose(std);
	return 0;
}