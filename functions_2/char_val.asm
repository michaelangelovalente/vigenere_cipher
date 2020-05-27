#fixed it, but check if it works with edge case scenarios

#a1 = letter(byte)
#return v1 = new_value; v1 = -1 if not a letter
	.text
	.globl char_val
char_val:
	#replace with heap usage
	addi $sp, $sp, -12
	sw $ra 0($sp)
	sw $s1 4($sp)
	sw $fp 8($sp)
	addi $fp, $sp, 8
	
	
	move $s1, $a1
		
	move $a0 $s1 #a1 = s1 = letter[0]
	

	#generating char_value
	jal is_upper# is_upper returns v0 = 0: Lowercase; v0 = 1: UpperCase; v0 = -1 if not a letter
	#if uppercase 65 - char_value
	beq $v0, -1, invalid_char
	
	bne $v0, 1, lowercase
	addi $s1, $s1, -65 # (A) 65 - s1 = char_value
	move $v1, $s1
	j char_found
	
	
	lowercase:
	addi $s1, $s1, -97 # (a)97 - s1 = char_value
	move $v1, $s1
	j char_found
	
	invalid_char:
	move $v1, $v0
	
	char_found:
	
	lw $ra 0($sp)
	lw $s1 4($sp)
	lw $fp 8($sp)
	addi $sp, $sp, 12
	
	
	jr $ra
