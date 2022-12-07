#Colin McGough
#11/16/2022
#Objective: To create a Sudoku grid
#Things to do: make a help section or like maybe a rules area of how to play, maybe make a level select for a couple of puzzles, 

.data

gridOne: .byte 2 1 4 3    4 3 2 1    3 2 1 4    1 4 3 2

gridPuzzle: .byte 2 1 0 0    0 3 2 0   0 0 0 4   1 0 0 0

pipe: .asciiz "|"

newLine: .asciiz "\n"

space: .asciiz " "

lineOne: .asciiz "    1 2   3 4\n   -----------"

end: .asciiz "|\n   -----------\n"

mid: .asciiz "|\n  |-----+-----|"

rowIn: .asciiz "Please input row number: "

colIn: .asciiz "Please input column number: "

numIn: .asciiz "Please input number: "

wrong: .asciiz "Incorrect value, please try again"

correct: .asciiz "Correct value"

.macro pSpace
	li $v0, 4
	la $a0, space
	syscall
.end_macro 


.text
main: 
	li $t0, 0 #offset for the array to increment
	li $t1, 1 #numbers to be printed on the left for row numberes
	j begin
	

begin: 
	li $v0, 4
	la $a0, lineOne #print first two lines
	syscall
	j newline

#
createPuzzle: 
	li $v0 1
	lb $a0, gridPuzzle($t0) #load byte from array and offset
	syscall
	pSpace
	addi $t0, $t0, 1 #increment offset by 1 because these are bytes, not words
	#all of these are branch statements at different values to print the board
	beq $t0, 2, line
	beq $t0, 4, pipes
	beq $t0, 6, line
	beq $t0, 8, middle
	beq $t0, 10, line
	beq $t0, 12, pipes
	beq $t0, 14, line
	beq $t0, 16, endLine
	j createPuzzle
	
line: 
	li $v0 4
	la $a0, pipe #print a pipe character
	syscall
	pSpace
	j createPuzzle
	
pipes: 
	beq $t1, 1 newline #if it is first line, skip printing pipe
	li $v0 4
	la $a0, pipe #print pipe
	syscall
	j newline
	
	
newline: 
	li $v0, 4
	la $a0, newLine #print a new line character
	syscall
	li $v0, 1
	move $a0, $t1 #print row number
	syscall 
	addi $t1, $t1, 1 #increment row number
	li $v0, 4
	la $a0, space #print space
	syscall
	j line

middle:
	li $v0 4
	la $a0, mid #print middle line
	syscall
	j newline
	
endLine: 
	li $v0, 4
	la $a0, end #print end dashes and jump to user input
	syscall
	j user

user: 
	la $a0, rowIn #print out input message and get row input
	syscall
	li $v0, 5 
	syscall
	move $t0, $v0
	li $v0, 4
	la $a0, colIn #print out input message and get col input
	syscall
	li $v0, 5
	syscall
	move $t1, $v0
	
	sub $t0, $t0, 1 #for row calc, minus 1 then mul 4 to get start of row
	mul $t0, $t0, 4
	add $t0, $t0, $t1 #add 1 for column number
	sub $t0, $t0, 1 #sub 1 again to account for starting at 0 instead of 1 aka first position is $t0 = 0 not $t0 = 1
	
	li $v0, 4
	la $a0, numIn #get user input for their number to replace with
	syscall
	li $v0, 5
	syscall
	move $t1, $v0
	
	lb $t2, gridOne($t0)#load byte with array offset to get the same position number
	
	bne $t1, $t2 incorrect
	
	sb $t1 gridPuzzle($t0) #storing the user input value into the array memory position to replace it on the board
	
	j main

incorrect: 
	li $v0, 4
	la $a0, wrong
	syscall
	j main


exit:
	li $v0, 10
	syscall
