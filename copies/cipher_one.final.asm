#cipher_one modifies a0(phrase_to_decipher)
#a0 = phrase to decipher  
#a1 = key_word
#a2 = cipher or decipher

	.data
	    .align 2	
key_values: .space 120 #longest word in the italian language (Precipitevolissimevolmente) has 26 chars ---> space 26*4 +16buffer
	.text
	.globl cipher_one
cipher_one:
	#saving registers
	add $sp, $sp, -24
	sw $ra 0($sp)
	sw $s0 4($sp)
	sw $s2 8($sp)
	sw $s3 12($sp)
	sw $s4 16($sp)
	sw $fp 20($sp)
	addi $fp, $sp, 20
	
	move $s0, $a0 # phrase
	move $s2, $a1 # key_word
	
	
	
	#key extraction
	#########################################################
	la $t4, key_values
	li $s4, 0	
	
	#loads an array with all the key values
	#and returns t9 with the number of elements inside the array
	find_key:
	lb $t0 0($s2)# t0 = key_word[ith_byte]
	beq $t0, 10, all_keys_found
	add $s2, $s2, 1# &key_word[ith_byte]+1byte
	
	#char_val(t0) --> key_value
	move $a1, $t0
	jal char_val
	#if key_word is not an ASCII CHAR other than \0 or \n then end cipher  and v0 = -9
	beq $v1, -1, invalid_key
	move $t0, $v1
	
	
	sw $t0 0($t4)#t0 -->k_values[i]		
	addi $t4, $t4, 4
	addi $s4, $s4, 1#number of elements inside key_word
	
	j find_key
	all_keys_found:
	# k_values[n0,n1...ni]
	#s4 = number_of_elements(k_values)
	############################################################
	
	
	
	la $t4, key_values
	li $t5, 0 #nth_key_value
	#li $t6, 1

	#ciphering loop
	loop:
		######################################################################
		#cycles to key[0..n-1] until loop ends
		div $t5, $s4 #i mod (#_key_values)
		mfhi $t0
		la $t4, key_values

		addi $t5, $t5,1
		sll $t6, $t0,2
		add $t4,$t4,$t6
		lw $t8 0($t4)#t8=key_value[nth_key_value*4]
		
	
		#################################################################
				
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
		move $s5, $t3
		
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
		addi $s0, $s0, 1
		j loop
		
		
		not_a_letter:
		addi $s0, $s0, 1
		addi $t5, $t5, -1
		j loop
		
	end_loop:
		
	

	#restoring registers
	lw $ra 0($sp)
	lw $s0 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $fp 20($sp)
	add $sp, $sp, 24
	
	jr $ra
	
	invalid_key:
	
	li $v0, -9
	j end_loop

