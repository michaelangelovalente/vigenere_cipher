	.data
init_msg:	  .asciiz "Welcome to Vigenere's Cipher;\nVigenere's Cipher uses a method of encryption based on a key word made of letters(A-Z a-z),\nonce these letters are available, the program will \"add\" them to the phrase.\nIf the user wants to decipher a Vigenere encrypted message then\nthe program will \"subtract \" the key word.\n"
continuos_msg: .asciiz  "\nChoose (1)for the cipher function  (2)for the decipher function or (0)to end the program:"
cipher_msg:    .asciiz "Enter a phase to cipher:"
decipher_msg:  .asciiz "Enter a phrase to decipher:"
not1or2:	  .asciiz "Invalid input!"
key_inv_prompt:	  .asciiz "Invalid key!\nYour key must not contain space or special characters."
key_w_prompt:  .asciiz "Enter key a keyword:"
result:   .asciiz "Result:"


	
	.align 2
phrase:	.space 1000
key:	.space 100 

	.text
	.globl main
main:
	#Welcome message /w explanation on how Vigenere's cipher works
	la $a0, init_msg
	li $v0, 4
	syscall
	
	#lets user choose from cipher or decipher function.
	restart:
	la $a0, continuos_msg#explains how program works
	syscall
	
	li $v0, 5#read integer; if userInput == 1 then cipher; if userInput == 2 then decipher ; if userInput == 0 then end program else retrun to 0xrestart
	syscall
	
	#user chose 1 --> cipher message
	li $t0, 1
	bne $t0, $v0, check2 #if userInput != 1 --> decipher? else continue down
	
	la $a0, cipher_msg
	li $v0, 4
	syscall
	j prompt
	
	
	#decipher message
	check2:
	li $t0, 2
	bne $t0,$v0, inv_input # if userInput == v0 != 1 || v0 != 2 re_prompt user to choose a valid input or 0
	la $a0, decipher_msg
	li $v0, 4
	syscall
	j prompt
	
	#invalid user input message --> program restarts until user enters 1, 2 or 0
	inv_input:
	beq $v0, 0, end_program#if userInput == 0 --> program ends
	la $a0, not1or2
	li $v0, 4
	syscall
	j restart
	
	##requirements before ciphering/deciphering ########################
	#prompts user for phrase to cipher/decipher
	prompt:
	la $a0, phrase
	li $a1, 900 
	li $v0, 8
	syscall
	
	#prompts user for key word 
	la $a0, key_w_prompt
	li $v0, 4
	syscall
	la $a0,	key
	li $a1, 90
	li $v0, 8
	syscall

		
	
	#cipher/decipher procedure access;
	#cipher_one(a0=phrase,a1=key,a2=1(cipher)/2(decipher)) ---> a0=deciphered_phrase	
	la $a0, phrase
	la $a1, key
	move $a2, $t0 # user decision 1==cipher 2===decipher
	jal cipher_one
	
	#if v0 == -9 --> the key entered was invalid
	bne $v0, -9, vK#validkey  #-9 is being used to differntiate it from invalid_char in phrase
	
	li $v0, 4
	la $a0, key_inv_prompt
	syscall
	j restart
	vK:
	#print result
	li $v0, 4
	la $a0, result
	syscall
	la $a0, phrase
	syscall
	j restart
	
	end_program:	
	li $v0, 10
	syscall



################################################################
#cipher_one modifies a0(phrase_to_decipher)
#Input:
#	a0 = phrase to decipher  
#	a1 = key_word
#	a2 = cipher  or decipher a=2
	.data
	    .align 2	
	    #used to store letter position value relative to the alphabet (a=0, B=1,C=2.... z=25)
key_values: .space 120 #longest word in the italian language (Precipitevolissimevolmente) has 26 chars ---> space (26*4)104 +16buffer

	.text
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
	
	move $s0, $a0 # &phrase
	move $s2, $a1 # &key_word
	
	
	
	#key values extraction
	#########################################################
	la $t4, key_values
	li $s4, 0 #s4 = len(key_word)//#elements in key_word	
	
	#loads an array with all the key values
	#and returns t9 with the number of elements inside the array
	find_key:
	lb $t0 0($s2)# t0 = key_word[ith_byte]
	beq $t0, 10, all_keys_found# if key_word[ith_byte] == ASCII(\n) --> done
	add $s2, $s2, 1# &key_word[ith_byte]+1byte
	
	#char_val(t0) --> key_value
	move $a1, $t0
	jal char_val #char_val(a1==ASCII_char) --> if char is alphabet returns v1 = absolute position of letter(a=0, B=1, C=1 ... Z=25) ; if special char v1 = -1
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
	
	
	
	#REMOVEDla $t4, key_values# refresh address t4 = &key_values[0]
	li $t5, 0 #nth_key_value --> will be used to count position(i) in key_values
	

	#ciphering loop
	loop:
		######################################################################
		#cycles to key[0..n-1] until loop ends
		div $t5, $s4 #i mod (#_key_values)
		mfhi $t0# i position for key_values
		la $t4, key_values# refresh address t4 = &key_values[0] note: key_values will only be from 0 to 25

		addi $t5, $t5,1# i++
		sll $t6, $t0,2# i_position_for_key_values * 4
		add $t4,$t4,$t6#&key_values[0] + (i_position_for_key_values * 4)
		lw $t8 0($t4)#t8=key_value[nth_key_value*4]
		
	
		#################################################################
				
		lb $a1 0($s0)#char(phrase[i])
		beq $a1, $zero, end_loop#if char(phrase[i]) == null terminator end
		move $s3, $a1#s3 = char_Ascii_value
		
		jal char_val#takes a1 char and returns v1 = char_value; v1 = -1 if char is invalid
		beq $v1, -1, not_a_letter####################### <-----
		
		#formulas
		#c(x) = (x+key)%26 ---> v1+$t8 %26 ### reverse version d(x) = (x-key)%26
		#c(phrase[i]] = (char_val(phrase[i]) + char_val(key_word[i%(#_elements_in_key_values)])##### reverse version d(phrase[i]] = (char_val(phrase[i]) - char_val(key_word[i%(#_elements_in_key_values)])
		
		bne $a2, 2, cipher#if a2 != 2 --> cipher
		sub $t9, $v1, $t8# a2 = 2 -->decipher(phrase[i]) = char_val(phrase[i]) - char_val(key_word[i%(#_elements_in_key_values)
		
		
		#(in some cases MIPS calculates negative mod of a Number instead of the mod itself
		#e.g.: (-4)Mod(26) == -4, should be 22.)
		#If t9 <0 --> t9+26
		li $t2, 0
		slt $t2, $t9, $zero
		beq $t2, $zero, not_neg
		addi $t9, $t9, 26
		not_neg:
		j deciphered
		cipher:
		add $t9, $v1, $t8# x+key
		deciphered:
		
		
		
		
						
		li $t7, 26
		div $t9, $t7#(x+key)%26 // if decipher (x-key)%26
		mfhi $t3 # -->c(x) = ciphered value // d(x) = deciphered value
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
	
	li $v0, -9#-9 is being used to differntiate it from invalid_char in phrase(-1)
	j end_loop

################################################################
#is_upper
# takes a0 byte(letter) and sets v0 = 1 if the byte maps to an upper_case letter on the ASCII TABLE or v0 = 0 if the byte maps to a lower_case letter on the ASCII TABLE v0 = -999
#Input:
#	a0 : letter
#Output:
#	v0 = 0 (lowercase); v0 = 1(uppercase); v0=-1 (not_a_char)
	
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
	li $t0, 65#ASCII(A)
	bne $a0, $t0, mightB_grtr# a0 == 65? --> yes then a0 is A and is UPPERCASE 
	j is_up#A is UPPERCASE
	mightB_grtr:
	slt $t1, $t0, $a0##  a0/lett > 65? yes---> t1 = 1  no --> not a letter
	bne $t1, 1, end# if v0 != 1 then  not_letter v0 = -1
	

	#checks if lett <= 90 if not; then-->lower_case or not_letter
	li $t0, 90#ASCII(Z)
	bne $a0, $t0, mightB_lesser #if a0/lett == 90 then a0 == Z and is UPPERCASE
	j is_up# Z is UPPERCASE
	mightB_lesser:
	slt $t1, $a0, $t0 #if lett<90	 -->t1 =1 --> v0 = 1
	beq $t1, 1, is_up#if ( !(lett <= 65) && !(lett >=90)) --> UPPERCASE; else lett > 90
	


	#checks if lower
	# if (a0 >= 97 && lett <= 122)
	#checks if a0 >= 97 if not then its not a letter
	li $t0, 97#ASCII(a)
	bne $a0, $t0, mightB_grtr2# a0 == 97? --> yes a0 is a and is lowercase 
	j is_low#a is lowercase
	mightB_grtr2:
	slt $t1, $t0, $a0##  a0 > 97? --> t1 ==1 no --> values is between  90 and 97 and not a letter 
	bne $t1, 1, end# if v0 != 1 then  not_letter  v0 = -1 (already loaded)
	

	#checks if lett <= 122 if not; then-->lower_case or not_letter
	li $t0, 122#ASCII(z)
	bne $a0, $t0, mightB_lesser2#if a0/lett == 122 then a0 == z and is lowercase
	j is_low#z is lowercase
	mightB_lesser2:
	slt $t1, $a0, $t0 #if a0/lett<122 -->t1=1 is_low
	beq $t1, 1, is_low# if ( !(lett <= 97) && !(lett >=122)) --> lowercase; else lett > 122 --> not a letter --> v0 = -1



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


###########################################################################
#char_val
#INPUT:
#a1 = letter(byte)
#OUTPUT:
# v1 = new_value; v1 = -1 if not a letter
	
char_val:
	#replace with heap usage??
	addi $sp, $sp, -12
	sw $ra 0($sp)
	sw $s1 4($sp)
	sw $fp 8($sp)
	addi $fp, $sp, 8
	
	
	move $s1, $a1
		
	move $a0 $s1 #a1 = s1 = letter[0]
	

	#generating char_value
	jal is_upper# is_upper returns v0 = 0: Lowercase; v0 = 1: UpperCase; v0 = -1 if not a letter
	#if uppercase 65 - char_value?????????????????????????????????
	beq $v0, -1, invalid_char #if v0 == -1 --> v1 == v0 =-1
	
	#UPPERCASE
	bne $v0, 1, is_lower# v0 != 1 -->  v0 == 0 --> s1 is !UPPERCASE
	addi $s1, $s1, -65 #  s1 - 65(A)  = char_position_value
	move $v1, $s1
	j char_found
	
	#LOWERCASE v1 != 1 && v1 != -1 --> v0 == 0 --> s1 is lowercase
	is_lower:
	addi $s1, $s1, -97 #  s1 - (a)97  = char_position_value
	move $v1, $s1
	j char_found
	
	invalid_char:
	move $v1, $v0
	
	char_found:
	#restores modified registers
	lw $ra 0($sp)
	lw $s1 4($sp)
	lw $fp 8($sp)
	addi $sp, $sp, 12
	
	
	jr $ra
