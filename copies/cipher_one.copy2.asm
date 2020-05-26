#a0 = phrase to decipher
#a1 = key_word
	.data
	.text
	.globl cipher_one
cipher_one:
	#saving registers
	add $sp, $sp, -20
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s1 8($sp)
	sw $s2 12($sp)
	sw $fp 16($sp)
	addi $fp, $sp, 16
	
	move $s0, $a0 # phrase
	move $s1, $a1 # key_word
	
	#temporary solution for keyword extraction
	lb $a1 0($s1)
	jal char_val#takes a1 key char and returns v1 = key_value; v1 = -1 if char is invalid
	move $t8, $v1
	
	loop:
		lb $a1 0($s0)#char(phrase[i])
		beq $a1, $zero, end_loop#if char(phrase[i]) == null terminator end
		move $s3, $a1#s3 = char_Ascii_value
		
		jal char_val#takes a1 char and returns v1 = char_value; v1 = -1 if char is invalid
		beq $v1, -1, not_a_letter
		#cipher formula
		#c(x) = (x+key)%26 ---> v1+$t8 %26 ### reverse version c(x) = (x-key)%26
		add $t9, $v1, $t8# x+key
		li $t7, 26
		div $t9, $t7#(x+key)%26
		mfhi $t3 # -->c(x) = ciphered value
		move $s5, $t3##########################
		
		#checks if the letter to be ciphered is lowercase or uppercase
		move $a0, $s3 # $a0 = char_ASCII_value
		jal is_upper# a0= byte char; #returns v0 = 0 if lowercase; v0 = 1 if uppercase; v0 = -1 if not a letter
		beq $v0, $zero, lowercase
		#beq $t4, -1, not_a_letter
		
		#Uppercase cipher
		addi $t3, $t3, 65
		j advance
		
		#Lowercase cipher
		lowercase:
		addi $t3, $t3, 97
		
		advance:
		sb $t3 0($s0)
		not_a_letter:
		addi $s0, $s0, 1
		j loop
		
	end_loop:
		
	
	#restoring registers
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s1 8($sp)
	lw $s2 12($sp)
	lw $fp 16($sp)
	add $sp, $sp, 20
	
	jr $ra
	
	

