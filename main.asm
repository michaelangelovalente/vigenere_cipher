	.data
phrase:	.space 1000
key:	.space 100 #.asciiz "abc\n"

	.text
	.globl main
main:
	
	la $a0, phrase
	li $a1, 900
	li $v0, 8
	syscall
	

	la $a0,	key
	li $a1, 90
	li $v0, 8
	syscall
	
	
	li $v0, 5
	syscall
	
	
	la $a0, phrase
	la $a1, key
	move $a2, $v0
	
	
	jal cipher_one
	
	move $s6, $v0#########################

	la $a0, phrase
	
	li $v0, 4
	syscall

	
	
		
	
		
	li $v0, 10
	syscall
