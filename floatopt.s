# float.s
# floating-point multiplication

# Student Name: Denia L. Del Cid	
# Date: November 8, 2015

.text 
.globl fmultopt 

# Preconditions:	
#   1st parameter (a0) single precision floating point multiplicand
#   2nd parameter (a1) single precision floating point multiplier
# Postconditions:
#   result (v0) single precision floating point product

fmultopt:and $v0,$v0,$zero			# v0 = 0, the default result
	beq $a0,$zero,return 			# return if multiplicand is zero
	beq $a1,$zero,return			# return if multiplier is zero
	
	# place mask for leftmost bit in t5
	li $t5,0x80000000			# t5 = 0x80000000
	
	# place sign of product into t5
	# OPTIMIZATION: went from a 3 step instruction to a 2 step by switching the order in
	# which the operations ran, and using 1 temporary register instead of 2.
	xor $t2,$a0,$a1				# t2 = xor of operands
	and $t2,$t2,$t5				# t2 = xor of signs after significand is masked
	
	# place (biased) exponent of product in t3
	# OPTIMIZATION: reduced the number of instructions from 8 to 5. Removed the need of shifting the 
	# exponent by isolating the exponent by placing a mask and adding the masked numbers instead of the
	# shifted ones. By loading the mask into $t4 (and not using it directly on the and/andi instruction)
	# the compiler runs 2 less instructions.
	li $t4,0x7f800000			# OPTIMIZATION 0x7f800000 isolates the 8 bit long exponent portion
	and $t0,$a0,$t4				# isolating exponent portion of a0
	and $t1,$a1,$t4				# isolating exponent portion of a1
	add $t1,$t1,-0x3f800000			# removing extra bias t1 = t1 - 127 (<- shifted 23 bits)
	add $t3,$t0,$t1				# adding biased exponents
	
	# place significand of multiplicand in t0
	sll $t0,$a0,8				# shift to remove exponent
	or $t0,$t0,$t5				# restore implicit 1 to left of significand

	# place significand of multiplier in t1
	sll $t1,$a1,8				# shift to remove exponent
	or $t1,$t1,$t5				# restore implicit 1 to left of significand
	
	# place significand of product in t4
	# ignore rounding and overflow
	multu $t0,$t1				# multiply significands (unsigned)
	mfhi $t4				# t4  = high word of product
loop3:	srl $t6,$t4,31				# OPTIMIZATION: removed unnecessary reasignment
	bnez $t6,norm				# OPTIMIZATION: bnez requires less instructions to run
						# branch if already normalized
	sll $t4,$t4,1				# shift significand to normalize
	add $t3,$t3,-0x800000			# OPTIMIZATION: adjust exponent with add instead of sub
	j loop3

norm:	sll $t4,$t4,1				# shift to remove implicit 1
	# assemble product in v0
	add $t3,$t3,0x800000			# add 1 to exponent to compensate after normalization
						# no need to shift exponent into position
	srl $t4,$t4,9				# shift significand into proper position
	move $v0,$t2				# place sign in v0
	or $v0,$v0,$t3				# place exponent in v0
	or $v0,$v0,$t4				# place significand in v0

return:	jr $ra					# return
