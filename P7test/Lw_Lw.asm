sw $0 3($0)
lw $1, 0($0)
lw $2 0($1)
lw $3 0($2)
lui $1, 100

.ktext 0x4180
mfc0 $4, $12
mfc0 $5, $13
mfc0 $6, $14
addi $6, $6, 0x4
mtc0 $6, $14
eret