# float.s
# floating-point multiplication

# Student Name: Denia L. Del Cid	
# Date: November 8, 2015

.text 
.globl fmult 

# Preconditions:	
#   1st parameter (a0) single precision floating point multiplicand
#   2nd parameter (a1) single precision floating point multiplier
# Postconditions:
#   result (v0) single precision floating point product

fmult:	and $v0,$v0,$zero				# v0 = 0, the default result
	beq $a0,$zero,return 				# return if multiplicand is zero
	beq $a1,$zero,return				# return if multiplier is zero
	
	# place mask for leftmost bit in t5
	li $t5,0x80000000			# t5 = 0x80000000
	
	# place sign of multiplicand in t0
	and $t0,$a0,$t5				# mask off exponent and significand

	# place sign of multiplier in t1
	and $t1,$a1,$t5				# mask off exponent and significand

	# place sign of product in t2
	xor $t2,$t0,$t1				# t2 = xor of signs

	# place exponent of multiplicand in t0
	sll $a0,$a0,1				# shift to remove sign bit
	srl $t0,$a0,24				# shift to remove significand bits
	sub $t0,$t0,127				# subract exponent bias

	# place exponent of multiplier in t1
	sll $a1,$a1,1				# shift to remove sign bit
	srl $t1,$a1,24				# shift to remove significand bits
	sub $t1,$t1,127				# subract exponent bias

	# place exponent of product in t3
	# ignore the possibility of overflow or underflow
	add $t3,$t0,$t1				# t3 = sum of exponents
	add $t3,$t3,127				# add exponent bias
	
	# place significand of multiplicand in t0
	sll $t0,$a0,7				# shift to remove exponent
	or $t0,$t0,$t5				# restore implicit 1 to left of significand

	# place significand of multiplier in t1
	sll $t1,$a1,7				# shift to remove exponent
	or $t1,$t1,$t5				# restore implicit 1 to left of significand
	
	# place significand of product in t4
	# ignore rounding and overflow
	multu $t0,$t1				# multiply significands (unsigned)
	mfhi $t4				# t4  = high word of product
#	beq $t4,1,norm				# branch if already normalized
loop3:	srl $t6,$t4,31
	beq $t6,1,norm
	sll $t4,$t4,1				# shift significand to normalize
	sub $t3,$t3,1				# adjust exponent
	j loop3

norm:	sll $t4,$t4,1				# shift to remove implicit 1

	# assemble product in v0
	add $t3,$t3,1
	sll $t3,$t3,23				# shift exponent into proper position
	srl $t4,$t4,9				# shift significand into proper position
	move $v0,$t2				# place sign in v0
	or $v0,$v0,$t3				# place exponent in v0
	or $v0,$v0,$t4				# place significand in v0

return:	jr $ra					# return

