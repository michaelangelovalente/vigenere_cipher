#a0 = phrase to decipher
#a1 = key
	.data
	.text
	.globl cipher_one
cipher_one:
	#remember too add saved registers
	
	
	
	move $t2, $a0 # phrase to cipher
	lw $s1 0($a1)
	
	move $a0 $s1 #a1 = key
	

	
	#generating key_value
	jal is_upper# is_upper returns v0 = 0: Lowercase; v0 = 1: UpperCase; v0 = -1 if not a letter
	#if uppercase 65 - key
	
	#li $t0, 0#NULL terminator
	li $t0, 10#\n codice

	
	bne $v0, 1, lowercase
	addi $s1, $s1, -65 # (A) 65 - s1 = key_value
	
	j loop
	lowercase:
	addi $s1, $s1, -97 # (a)97 - s1 = key_value
	
	
	
	#loop from phrase[byte_0...byte_n-1]
	loop:
	
	lb $t1 0($t2)# t1 = a0[byte_i]
	
	beq $t1, 10, end_loop
	#cipher 
	add $t1, $t1, $s1# t1 = a0[byte]+key_value --> ciphered_letter
	sb $t1 0($t2)# a0[byte_i] = t1
	
	addi $t2, $t2, 1# t2 = &a0[byte_i]++
	j loop
	
	end_loop:
	#bne $t1, $t0# a0[byte_i] == 10(\n) --> end of phrase. 
	#(non sto usando questa versione perche riesco a sapere soltanto quando faccio la lw che lettera ho)
	#questo per non rischiare di sostituire \n con value(\n) + 1
	
	jr $ra
	
	
