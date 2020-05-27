#is_upper
# takes a0 byte(letter) and sets v0 = 1 if the byte maps to an upper_case letter on the ASCII TABLE or v0 = 0 if the byte maps to a lower_case letter on the ASCII TABLE v0 = -999
#Input:
#	a0 : letter
#Output:
#	v0 = 0 (lowercase); v0 = 1(uppercase); v0=-1 (not_a_char)
	.text
	.globl is_upper
is_upper:
	#saving registers
	add $sp, $sp, -8
	sw $ra 0($sp)
	sw $fp 4($sp)
	addi $fp, $sp, 4
	
	li $v0, -1
	

	#checks if upper
	# if (a0 >= 65 && lett <= 90)
	#checks if a0 >= 65 if not then its not a letter
	li $t0, 65
	bne $a0, $t0, mightB_grtr# a0 == 65? 
	j is_up
	mightB_grtr:
	slt $t1, $t0, $a0##  a0 > 65?
	bne $t1, 1, end# if v0 != 1 then  not_letter
	

	#checks if lett <= 90 if not; then-->lower_case or not_letter
	li $t0, 90
	bne $a0, $t0, mightB_lesser
	j is_up
	mightB_lesser:
	slt $t1, $a0, $t0 #if lett<90	 -- v0 = 1
	beq $t1, 1, is_up
	


	#checks if lower
	# if (a0 >= 97 && lett <= 122)
	#checks if a0 >= 97 if not then its not a letter
	li $t0, 97
	bne $a0, $t0, mightB_grtr2# a0 == 97? 
	j is_low
	mightB_grtr2:
	slt $t1, $t0, $a0##  a0 > 97?
	bne $t1, 1, end# if v0 != 1 then  not_letter
	

	#checks if lett <= 122 if not; then-->lower_case or not_letter
	li $t0, 122
	bne $a0, $t0, mightB_lesser2
	j is_low
	mightB_lesser2:
	slt $t1, $a0, $t0 #if lett<90 then is_low
	beq $t1, 1, is_low



	end:
	#restoring registers
	lw $ra  0($sp)
	lw $fp 4($sp)
	addi $sp, $sp, 8
	
		
	jr $ra
	


	is_up:
	li $v0, 1
	j end


	is_low:
	li $v0, 0
	j end
