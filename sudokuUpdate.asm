#Colin McGough, Evan Cheng, Loc Nguyen, Bryce Lam
#11/16/2022
#Objective: To create a Sudoku grid
#Things to do: make a help section or like maybe a rules area of how to play, maybe make a level select for a couple of puzzles, 

.data
#main menu
	mainMenu: .asciiz "\n|--------------- Main Menu ---------------|\n\n\n\n\n\n\n\n\n\n\n\nType 1 to play and 2 to exit: "
	
#puzzle
	gridOne: .byte 2 1 4 3    4 3 2 1    3 2 1 4    1 4 3 2
	gridPuzzle: .byte 2 1 0 0    0 3 2 0   0 0 0 4   1 0 0 0

#formatting
	pipe: .asciiz "|"
	newLine: .asciiz "\n"
	space: .asciiz " "
	lineOne: .asciiz "    1 2   3 4\n   -----------"
	end: .asciiz "|\n   -----------\n"
	mid: .asciiz "|\n  |-----+-----|"

#prompts
	rowIn: .asciiz "Please input row number: "
	colIn: .asciiz "Please input column number: "
	numIn: .asciiz "Please input number: "
	
#output and error messages
	wrong: .asciiz "Incorrect value, please try again"
	correct: .asciiz "Correct value"
	wrongSpace: .asciiz "Invalid space value, please try again\n"
	usedSpace: .asciiz "Invalid space, part of original puzzle, please try again\n"
	wrongInput: .asciiz "     *Invalid input value, please try again\n"
	winMsg: .asciiz "Good Job! You Win!\n\n\n\n\n\n"

.macro pSpace
	li $v0, 4
	la $a0, space
	syscall
.end_macro 

.macro print(%x)
	li $v0, 4
	la $a0, %x
	syscall
.end_macro 


.text
main: 
	#print main menu options
	print(mainMenu)
	li $v0, 5
	syscall
	move $s7, $v0
	print(newLine)
	
	#error handle if out of range 1-2
	blt $s7, 1, invalidM
	bgt $s7, 2, invalidM
	
	#take care of input
	beq $s7, 1, setup
	beq $s7, 2, exit

	#invalid menu input
	invalidM:
		print(wrongInput)
		j main

setup:	
	li $t0, 0 #offset for the array to increment
	li $t1, 1 #numbers to be printed on the left for row numberes
	
	j begin

begin: 
	print(newLine)
	print(newLine)
	print(newLine)
	print(newLine)
	print(lineOne)
	j newline

#building the puzzle every loop
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
	print(pipe)
	pSpace
	j createPuzzle
	
pipes: 
	beq $t1, 1 newline #if it is first line, skip printing pipe (this is for the pipe at the end of the line
	print(pipe)
	j newline
	
	
newline: 
	print(newLine)
	li $v0, 1
	move $a0, $t1 #print row number
	syscall 
	addi $t1, $t1, 1 #increment row number
	pSpace
	j line

middle:
	print(mid)
	j newline
	
endLine: 
	print(end)
	j user

user: 
	#make t0 0 and go to check win
	li $t0 0
	jal checkWin
	#print row and col input messages and take input
	print(rowIn)
	li $v0, 5 
	syscall
	move $t0, $v0
	print(colIn)
	li $v0, 5
	syscall
	move $t1, $v0
	#check if this is a valid space
	jal spaceCheck
	#get user input
	print(numIn)
	li $v0, 5
	syscall
	move $t2, $v0
	#check if it is a valid input
	jal inputCheck
	
	sub $t0, $t0, 1 #for row calc, minus 1 then mul 4 to get start of row
	mul $t0, $t0, 4
	add $t0, $t0, $t1 #add 1 for column number
	sub $t0, $t0, 1 #sub 1 again to account for starting at 0 instead of 1 aka first position is $t0 = 0 not $t0 = 1
	
	lb $t1, gridOne($t0)#load byte with array offset to get the same position number
	
	
	sb $t2 gridPuzzle($t0) #storing the user input value into the array memory position to replace it on the board
	
	print(newLine)
	j setup
	
spaceCheck: 
	#check if row and col are between 1-4
	bgt $t0 4, incorrectSpace
	blt $t0, 1 incorrectSpace
	bgt $t1 4, incorrectSpace
	blt $t1, 1 incorrectSpace
	
	#check if space is part of original puzzle part 1
	beq $t0, 1, check1
	beq $t0, 2, check2
	beq $t0, 3, check3
	beq $t0, 4, check4

return1:
	#save this return address for later
	move $t7 $ra
	
	jr $ra

inputCheck: 
	#check if input is bewteen 1-4
	bgt $t2 4, incorrectInput
	blt $t2, 1 incorrectInput
	
	jr $ra

incorrectSpace:
	#print error msg and reprint board
	print(newLine)
	print(wrongSpace)
	j setup
	
#check if the space is used in original puzzle
	check1:
		beq $t1, 1, usedSpaceError
		beq $t1, 2, usedSpaceError
		j return1
	check2:
		beq $t1, 2, usedSpaceError
		beq $t1, 3, usedSpaceError
		j return1
	check3:
		beq $t1, 4, usedSpaceError
		j return1
	check4:
		beq $t1, 1, usedSpaceError
		j return1

usedSpaceError: 
	#print error msg and reprint board
	print(newLine)
	print(usedSpace)
	j setup

incorrectInput:
	#print error message and reprompt user for input
	print(wrongInput)
	jr $t7
	
checkWin: 
	#load byte with array offset to get the same position number
	lb $t1, gridOne($t0)
	lb $t2, gridPuzzle($t0)
	#if they aren't equal, return to game
	bne $t1 $t2 return
	#if all values are equal then jump to win messgae
	beq $t0 15 win
	#for incrementing array and win condition
	addi $t0, $t0 1
	
	j checkWin
	
#simply a return statement
return:
	jr $ra

#win message
win:
	print(winMsg)
	j main

exit:
	li $v0, 10
	syscall
