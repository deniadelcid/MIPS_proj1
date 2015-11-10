# main.s
# Tests the operation of of the fmult function by comparing its result
# to that of a mul.s instruction.

.text 
.globl  main

# Checks multiple test cases
# then prompts for input of additional test cases.

main:	addi	$sp, $sp, -12	# make space on stack
	sw	$ra, 0($sp)	# preserve return address
	sw	$s0, 4($sp)	# preserve registers used by this function
	sw	$s1, 8($sp)

	la	$s0, f1		# address of first floating point number
	la	$s1, fn		# address of last floating point number

loop1:	
	lw	$a0, 0($s0)
	lw	$a1, 4($s0)
	jal	test
	addi	$s0, $s0, 4
	bne	$s0, $s1, loop1

loop2:	
	la	$a0, prompt	# parameter = prompt
	li	$v0, 4		# load the "print string" syscall number
	syscall

	li	$v0, 6		# load the "read float" syscall number
	syscall
	mfc1	$s0, $f0	# s0 = floating-point multiplicand

	la	$a0, prompt	# parameter = prompt
	li	$v0, 4		# load the "print string" syscall number
	syscall

	li	$v0, 6		# load the "read float" syscall number
	syscall
	mfc1	$s1, $f0	# s1 = floating-point multiplier

	move	$a0, $s0
	move	$a1, $s1
	jal	test

	j	loop2		# loop forever

	li	$v0, 0		# return value

	lw	$ra, 0($sp)	# restore return address
	lw	$s0, 4($sp)	# restore registers used by this function
	lw	$s1, 8($sp)
	addi	$sp, $sp, 12	# restore stack pointer

	jr	$ra		# return

.globl	test

# Tests the fmult function.
#	li	$a0,0xbf400000	#  1st parameter (a0) single precision floating point multiplicand
#	li 	$a1,0xbf400000	#  2nd parameter (a1) single precision floating point multiplier

test:   addi	$sp, $sp, -16	# make space on stack
	sw	$ra, 0($sp)	# preserve return address
	sw	$s0, 4($sp)	# preserve registers s0 through s2
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)

	move	$s0, $a0	# save multiplicand in $s0
	move	$s1, $a1	# save multiplier in $s1
	jal	fmultopt		# call multiplication function
	move	$s2, $v0	# save result in s2

	mtc1	$s0, $f12	# parameter = multiplicand
	li	$v0, 2		# load the "print float" syscall number
	syscall

	la	$a0, str1	# parameter = str1
	li	$v0, 4		# load the "print string" syscall number
	syscall

	mtc1	$s1, $f12	# parameter = multiplier
	li	$v0, 2		# load the "print float" syscall number
	syscall

	la	$a0, str2	# parameter = str2
	li	$v0, 4		# load the "print string" syscall number
	syscall

	mtc1	$s0, $f2
	mtc1	$s1, $f4
	mul.s	$f0, $f2, $f4	# multiply
	
	mov.s	$f12, $f0	# parameter = product
	li	$v0, 2		# load the "print float" syscall number
	syscall

	la	$a0, endl	# parameter = endl
	li	$v0, 4		# load the "print string" syscall number
	syscall

	la	$a0, str3	# parameter = str3
	li	$v0, 4		# load the "print string" syscall number
	syscall

	mtc1	$s2, $f12	# parameter = product
	li	$v0, 2		# load the "print float" syscall number
	syscall

	la	$a0, endl	# parameter = endl
	li	$v0, 4		# load the "print string" syscall number
	syscall
	
	lw	$ra, 0($sp)	# restore return address
	lw	$s0, 4($sp)	# restore registers s0 through s2
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	addi	$sp, $sp, 16	# restore stack pointer

	jr	$ra		# return

.data 

# Test cases:
# Check all 4 combinations of signs
# Check zero as either operand (or both)
# Check one as an operand
# Check normalization of results with 01, 10, 11 to left of binary point
# Check for exponents greater than 1
# (so that there will be overflow for intermediate biased exponent)
# Check for results with even and odd exponents
# Check for negative exponents
# Check result with 1 in least significant bit
	
f1:	.float	  1.0		#  1.0000 x 2^0
	.float	 -2.0		# -1.0000 x 2^1
	.float	 -5.0		# -1.2500 x 2^2
	.float	 12.0		#  1.5000 x 2^3
	.float	-14.0		# -1.7500 x 2^3
	.float	  0.0	
	.float	  0.0	
	.float	 62.0		#  1.9375 x 2^5
	.float	112.0		#  1.7500 x 2^6
fn:	.word	0xBE000004	# result will have 1 in least significant bit

prompt:	.asciiz	"Enter a floating-point number: "
str1:	.asciiz " multiplied by "
str2:	.asciiz " is "
str3:	.asciiz "Your answer was "
endl:	.asciiz	"\n" 

