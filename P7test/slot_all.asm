.ktext 0x4180

_entry:	
	mfc0	$1, $14				# get EPC
	mfc0	$1, $13				# get CAUSE
	ori	$k0, $0, 0x1000			# stack bottom
	sw	$sp, -4($k0)			# store sp

	addi	$k0, $k0, -256		# stack top
	add 	$sp, $k0, $0		# set sp
	# move	$sp, $k0			# set sp
	
	beq $0, $0,	_save_context
	nop
	
_main_handler:
	mfc0	$k0, $13				# k0 <- CAUSE
	andi	$k0, $k0, 0x00ff		# k0 <- exception code << 2

	ori $k1, $0, 0x4				
	div $k0, $k1
	mflo $k0						# k0 <- exception code
	
	ori	$k1, $0, 0x0000				
	beq	$k0, $k1, int_handler		# if k0 == 0, interrupt
	nop
	ori	$k1, $0, 0x0004
	beq	$k0, $k1, adel_handler		# if k0 == 4, address error (load/im)
	nop
	ori	$k1, $0, 0x0005
	beq	$k0, $k1, ades_handler		# if k0 == 5, address error (store)
	nop
	ori	$k1, $0, 0x000a
	beq	$k0, $k1, ri_handler		# if k0 == 10, unknown instruction
	nop
	ori	$k1, $0, 0x000c
	beq	$k0, $k1, ov_handler		# if k0 == 12, arithmetic overflow
	nop
	
int_handler:
	sw	$ra, 0($sp)
	addi	$sp, $sp, -16
	mfc0	$v0, $12
	sw	$v0, 0($sp)
	mfc0	$v0, $13
	sw	$v0, 4($sp)
	
	# check INT[3]
	lw	$v0, 0($sp)
	lw	$v1, 4($sp)
	and	$v0, $v1, $v0
	andi	$v0, $v0, 0x800
	bne	$v0, $0, timer1_handler
	nop
	
	# check INT[2]
	lw	$v0, 0($sp)
	lw	$v1, 4($sp)
	and	$v0, $v1, $v0
	andi	$v0, $v0, 0x400
	bne	$v0, $0, timer0_handler
	nop

timer0_handler:
	# first we load the global variable cnt0:
	# ++cnt0, then save to global variable cnt0
	ori $fp, $0, 0x8
	# li 	$fp, 0x8
	lw	$t0, 0($fp)			# get cnt0
	addi    $s6, $0 , 1
	beq	$t0, $s6, skip0
	nop
	
	addi 	$t0, $t0, 1			# add cnt0
skip0:	sw 	$t0, 0($fp)			# update cnt0
	jal	restart_timer
	nop
	
	# mask INT[2]
	mfc0 	$t0, $12
	andi 	$t0, $t0, 0x03ff
	ori 	$t0, $t0, 0x800
	mtc0 	$t0, $12
	
	beq $0, $0,	_restore_context
	nop
	
timer1_handler:
	# first we load the global variable cnt1:
	# ++cnt1, then save to global variable cnt1
	ori $fp, $0, 0xc
	# li 	$fp, 0xc
	lw 	$t0, 0($fp)			# get cnt1
	addi    $s6, $0 , 1
	beq	$t0, $s6, skip1
	nop
	
	addi 	$t0, $t0, 1			# add cnt1
skip1:	sw 	$t0, 0($fp)			# update cnt1
	jal	restart_timer
	nop
	
	# mask INT[3]
	mfc0 	$t0, $12
	andi 	$t0, $t0, 0x03ff
	ori 	$t0, $t0, 0x400
	mtc0 	$t0, $12
	
	beq $0, $0,	_restore_context
	nop
	
restart_timer:
	# swap two PRESET
	ori $t0, $0, 0x0
	# li	$t0, 0x0
	lw	$t0, 0($t0)
	lw	$t5, 4($t0)
	ori $t2, $0, 0x4
	# li	$t2, 0x4
	lw	$t2, 0($t2)
	lw	$t6, 4($t2)
	
	# restart Timer 0
	ori $t1, $0, 0x0
	# li 	$t1, 0x0
	lw 	$t1, 0($t1)
	lw 	$t0, 0($t1)		# $t0 is the CTRL Reg of Timer 0
	sw 	$0, 0($t1)		# disable Timer 0
	
	ori $t2, $0, 0x8
	# li 	$t2, 0x8
	lw	$t2, 0($t2)
	
	addi    $s6, $0 , 5
	beq	$t2, $s6, f0		# check Timer0 pause times
	nop
	
	sw	$t6, 4($t1)		# refill the count number
	addi 	$t0, $0, 9		# set Timer0.CTRL
	sw 	$t0, 0($t1)		# Timer 0 restart count
	f0:	
	# restart Timer 1
	ori $t1, $0, 0x4
	# li 	$t1, 0x4
	lw 	$t1, 0($t1)
	lw 	$t0, 0($t1)		# $t0 is the CTRL Reg of Timer 1
	sw 	$0, 0($t1)		# disable Timer 1
	
	ori $t2, $0, 0xc
	# li 	$t2, 0xc
	lw	$t2, 0($t2)
	
	addi    $s6, $0 , 5
	beq	$t2, $s6, f1		# check Timer1 pause times
	nop

	sw	$t5, 4($t1)		# refill the count number
	addi 	$t0, $0, 9		# set Timer1.CTRL
	sw 	$t0, 0($t1)		# Timer 0 restart count
	f1:	
	jr 	$ra
	nop	

# skip exception code (include the delay slot)
adel_handler:
	ori $t0, 0xff10			# adel
	mfc0	$t0, $14
	mfc0	$k0, $13
	lui	$t2, 0x8000
	and	$t3, $k0, $t2
	addi	$t0, $t0, 4
	bne	$t3, $t2, adel_nxt
	nop
	addi	$t0, $t0, 4
	adel_nxt:
	mtc0	$t0, $14
	beq $0, $0,	_restore_context
	nop

# skip exception code (include the delay slot)
ades_handler:
	ori $t0, 0xff20			# ades
	mfc0	$t0, $14
	mfc0	$k0, $13
	lui	$t2, 0x8000
	and	$t3, $k0, $t2
	addi	$t0, $t0, 4
	bne	$t3, $t2, ades_nxt
	nop
	addi	$t0, $t0, 4
	ades_nxt:
	mtc0	$t0, $14
	beq $0, $0,	_restore_context
	nop
	
# skip exception code (include the delay slot)
ri_handler:
	ori $t0, 0xff30			# ri
	mfc0	$t0, $14				# t0 <- EPC
	mfc0	$k0, $13				# k0 <- CAUSE
	lui	$t2, 0x8000					
	and	$t3, $k0, $t2				# t3 <- BD
	addi	$t0, $t0, 4				# t0 <- EPC + 4
	bne	$t3, $t2, ri_nxt			# if BD != 1, skip
	nop
	addi	$t0, $t0, 4				# if BD == 1, t0 <- EPC + 4
	ri_nxt:
	mtc0	$t0, $14				# EPC <- t0
	beq $0, $0,	_restore_context
	nop

# skip exception code (include the delay slot)
ov_handler:
	ori $t0, 0xff40			# ov
	mfc0	$t0, $14				# t0 <- EPC
	mfc0	$k0, $13				# k0 <- CAUSE
	lui	$t2, 0x8000					
	and	$t3, $k0, $t2				# t3 <- BD
	addi	$t0, $t0, 4				# t0 <- EPC + 4
	bne	$t3, $t2, ov_nxt			# if BD != 1, skip
	nop
	addi	$t0, $t0, 4				# if BD == 1, t0 <- EPC + 4
	ov_nxt:
	mtc0	$t0, $14				# EPC <- t0
	beq $0, $0,	_restore_context
	nop

_restore:
	eret

_save_context:
    	sw  	$2, 8($sp)    
    	sw  	$3, 12($sp)    
    	sw  	$4, 16($sp)    
    	sw  	$5, 20($sp)    
    	sw  	$6, 24($sp)    
    	sw  	$7, 28($sp)    
    	sw  	$8, 32($sp)    
    	sw  	$9, 36($sp)    
    	sw  	$10, 40($sp)    
    	sw  	$11, 44($sp)    
    	sw  	$12, 48($sp)    
    	sw  	$13, 52($sp)    
    	sw  	$14, 56($sp)    
    	sw  	$15, 60($sp)    
    	sw  	$16, 64($sp)    
    	sw  	$17, 68($sp)    
    	sw  	$18, 72($sp)    
    	sw  	$19, 76($sp)    
    	sw  	$20, 80($sp)    
    	sw  	$21, 84($sp)    
    	sw  	$22, 88($sp)    
    	sw  	$23, 92($sp)    
    	sw  	$24, 96($sp)    
    	sw  	$25, 100($sp)    
    	sw  	$28, 112($sp)    
    	sw  	$29, 116($sp)    
    	sw  	$30, 120($sp)    
    	sw  	$31, 124($sp)
	mfhi 	$k0
	sw 	$k0, 128($sp)
	mflo 	$k0
	sw 	$k0, 132($sp)
	beq $0, $0,	_main_handler
	nop

_restore_context:
	ori $sp, $0, 0x1000
	addi	$sp, $sp, -256
    	lw  	$2, 8($sp)    
    	lw  	$3, 12($sp)    
    	lw  	$4, 16($sp)    
    	lw  	$5, 20($sp)    
    	lw  	$6, 24($sp)    
    	lw  	$7, 28($sp)    
    	lw  	$8, 32($sp)    
    	lw  	$9, 36($sp)    
    	lw  	$10, 40($sp)    
    	lw  	$11, 44($sp)    
    	lw  	$12, 48($sp)    
    	lw  	$13, 52($sp)    
    	lw  	$14, 56($sp)    
    	lw  	$15, 60($sp)    
    	lw  	$16, 64($sp)    
    	lw  	$17, 68($sp)    
    	lw  	$18, 72($sp)    
    	lw  	$19, 76($sp)    
    	lw  	$20, 80($sp)    
    	lw  	$21, 84($sp)    
    	lw  	$22, 88($sp)    
    	lw  	$23, 92($sp)    
    	lw  	$24, 96($sp)    
    	lw  	$25, 100($sp)    
    	lw  	$28, 112($sp)   
    	lw  	$30, 120($sp)    
    	lw  	$31, 124($sp)    
	lw 	$k0, 128($sp)
	mthi 	$k0
	lw 	$k0, 132($sp)
	mtlo 	$k0
    	lw  	$29, 116($sp) 
	ori     $1,$0,1
    	beq $0, $0, 	_restore	
	nop	
	

.text

# init begin

    # set $gp, $sp, SR
	ori	$28, $0, 0x0000
	ori	$29, $0, 0x0f00
	mtc0	$0, $12
	
	#save start address 
	ori 	$t0, $0, 0x7f00
	sw 	$t0, 0($0)
	ori 	$t1, $0, 0x7f10
	sw 	$t1, 4($0)
	
	#set SR included IM(interupt, TC1), IE(1), EXL(0)
	ori 	$t0,$0, 0x0c01
	mtc0 	$t0,$12


# init end
# ov begin


# test add positive overflow in beq db
	lui	$8, 0x7fff
	lui	$9, 0x7fff
	ori	$8, $8, 0xffff
	beq $0, $0,	slot_ov1
	add	$10, $8, $9	
slot_ov1:

# test add negative overflow in jal db
    lui	$8, 0x8000
    lui	$9, 0x8000
    ori	$8, $8, 0x0001
    jal slot_ov2
    add	$10, $8, $9
slot_ov2:

# test sub positive overflow in jal db
    lui	$8, 0x7fff
    lui	$9, 0xffff
    ori	$9, $9, 0xffff
    jal	slot_ov3
    sub	$10, $8, $9
slot_ov3:

# test sub negative overflow in beq db
    lui	$8, 0x8000
    lui	$9, 0x7fff
    ori	$8, $8, 0x0001
    beq $0, $0,	slot_ov4
    sub	$10, $8, $9
slot_ov4:

# test addi positive overflow in beq db
    lui	$8, 0x7fff
    ori	$8, $8, 0x0001
    beq $0, $0,	slot_ov5
    addi $9, $8, 0xffff
slot_ov5:

# test addi negative overflow in jal db
    lui	$8, 0x8000
    jal slot_ov6
    addi $9, $8, -1
slot_ov6:

# test ov in db
	ori     $t2, $0, 0x5daa
	lui	$8, 0x7fff
	lui	$9, 0x8000
	sub	$10, $8, $9
	lui	$8, 0x8111
	lui	$9, 0x8111
	add     $10, $8, $9
	addi    $10, $8,-2
	beq     $0, $0, slot_ov7
	addi    $10, $8,-3
	add     $10, $8, $9
	sub	$10, $8, $9
slot_ov7:


# ov end
# adel begin


# test lw adel in db
	ori $8, $0, 0x801
	beq $0, $0, lw_slot_adel1
	lw $9, 0($8)
lw_slot_adel1:

	ori $8, $0, 0x532
	jal lw_slot_adel2
	lw $9, 0($8)
lw_slot_adel2:

	ori $8, $0, 0x203
	beq $0, $0, lw_slot_adel3
	lw $9, 0($8)
lw_slot_adel3:

# test lh adel in db
	ori $8, $0, 0x801
	jal lh_slot_adel1
	lh $9, 0($8)
lh_slot_adel1:

	ori $8, $0, 0x293
	beq $0, $0, lh_slot_adel2
	lh $9, 0($8)
lh_slot_adel2:

# test lh,lb timer in db
	ori $8, $0, 0x7f02
	beq $0, $0, lh_slot_timer
	lh $9, 0($8)
lh_slot_timer:

	ori $8, $0, 0x7f1b
	beq $0, $0, lb_slot_timer
	lb $9, 0($8)
lb_slot_timer:

# test load, ov in db
	lui $8, 0x7fff
	ori $8, $8, 0xffff
	beq $0, $0, load_slot_ov1
	lw $9, 1($8)
load_slot_ov1:

# test load, out of range in db
	ori $8, $0, 0x4108
	beq $0, $0, load_slot_or1
	lw $9, 0($8)
load_slot_or1:

	ori $8, $0, 0x7f0c
	beq $0, $0, load_slot_or2
	lb $9, 0($8)
load_slot_or2:

	ori $8, $0, 0x7f26
	beq $0, $0, load_slot_or3
	lh $9, 0($8)
load_slot_or3:


# adel end
# ades begin


# test sw ades in db
	ori $9, $0, 0xf0f0
	ori $8, $0, 0x901
	beq $0, $0, sw_slot_ades1
	sw $9, 0($8)
sw_slot_ades1:

	ori $9, $0, 0xf0f1
	ori $8, $0, 0x102
	beq $0, $0, sw_slot_ades2
	sw $9, 0($8)
sw_slot_ades2:

	ori $9, $0, 0xf0f2
	ori $8, $0, 0x943
	beq $0, $0, sw_slot_ades3
	sw $9, 0($8)
sw_slot_ades3:

# test sh ades in db
	ori $9, $0, 0xf0f3
	ori $8, $0, 0x901
	beq $0, $0, sh_slot_ades1
	sh $9, 0($8)
sh_slot_ades1:

	ori $9, $0, 0xf0f4
	ori $8, $0, 0x3
	beq $0, $0, sh_slot_ades2
	sh $9, 0($8)
sh_slot_ades2:

# test sh,sb timer in db
	ori $9, $0, 0xf0f5
	ori $8, $0, 0x7f06
	beq $0, $0, sh_slot_timer
	sh $9, 0($8)
sh_slot_timer:
	
	ori $9, $0, 0xf0f6
	ori $8, $0, 0x7f15
	beq $0, $0, sb_slot_timer
	sh $9, 0($8)
sb_slot_timer:

# test store ov in db
	ori $9, $0, 0xf0f6
	lui $8, 0x8000
	beq $0, $0, store_slot_ov
	sh $9, -1($8)
store_slot_ov:

# test store clock in db
	ori $9, $0, 0xf0f7
	lui $8, 0x7f08
	beq $0, $0, store_slot_clock1
	sw $9, 0($8)
store_slot_clock1:

	ori $9, $0, 0xf0f7
	lui $8, 0x7f18
	beq $0, $0, store_slot_clock2
	sw $9, 0($8)
store_slot_clock2:

# test store out of range in db
	ori $9, $0, 0xf0f8
	lui $8, 0x3000
	beq $0, $0, store_slot_or1
	sw $9, 0($8)
store_slot_or1:

	ori $9, $0, 0xf0f9
	lui $8, 0x7f00
	beq $0, $0, store_slot_or2
	sb $9, -1($8)
store_slot_or2:

	ori $9, $0, 0xf0fa
	lui $8, 0x7f1d
	beq $0, $0, store_slot_or3
	sh $9, -1($8)
store_slot_or3:


# ades end
# slot comb begin

	lui      $s0,0x8000
	lui      $s1,0x7fff
	ori      $s1,$s1,0xffff
	add     $10,$s0,$s0
	sub     $10,$s0,$s1
	addi    $10,$s1,10
	sw      $10,0x1002($0)
	sh      $10,0x1001($0)
	mult    $10,$10
	lw      $10,0x1002($0)
	lh      $10,0x1001($0)
	mult    $10,$10
	lh      $10,0x1001($0) 		# adel
	# lhu      $10,0x1001($0)
	sub     $10,$s0,$s1
	addi    $10,$s1,10
	sw      $10,0x1002($0)
	sh      $10,0x1001($0)
	mult    $10,$10
	sw      $10,0x1002($0)
	sh      $10,0x1001($0)
	lw      $10,0x1002($0)
	lh      $10,0x1001($0)
	mult    $10,$10
	sh      $10,0x1001($0)
	add     $10,$s0,$s0
	sub     $10,$s0,$s1
	mult    $10,$10
	add     $10,$s0,$s0
	sub     $10,$s0,$s1
	beq $0, $0, label_1
	add     $10,$s0,$s0
	sub     $10,$s0,$s1
label_1:
	mult    $10,$10
	add     $10,$s0,$s0
	sub     $10,$s0,$s1
	mult    $10,$10
	sh      $10,0x1001($0)
	lw      $10,0x1002($0)
	add     $10,$s0,$s0
	bne     $0,$10,label_2
	lw      $10,0x1002($0)
	sh      $10,0x1001($0)
label_2:
	sub     $10,$s0,$s1
	mult    $10,$10
	sh      $10,0x1001($0)
	lw      $10,0x1002($0)
	nop


	ori $13, $0, 0xffff
dead_loop:
	beq $0, $0,	dead_loop
	nop

