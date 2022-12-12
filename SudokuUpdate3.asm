#Colin McGough, Evan Cheng, Loc Nguyen, Bryce Lam
#Date: 11/16/2022
#Objective: To create a Sudoku game

.data
#main menu
	mainMenu: .asciiz "\n|--------------- Main Menu ---------------|\n1: Play Sudoku\n2: Exit Program\n\nHow to play:"
	
#how to play
	objective: .asciiz "\n\tObjective: Completely fill the grid so that each vertical row, horizontal row, \n\tand sub grid has only one of a kind number from 1 to 4."
	howtoplay1: .asciiz "\n\tTo fill in an empty space, indicated by a 0, input the row number and column number of the space."
	howtoplay2: .asciiz "\n\tAfterward, input the number you want that is in the range of 1 to 4."
	howtoplay3: .asciiz "\n\tYou will repeat this process until you complete the objective!\n"
	choice: .asciiz "\nSelect 1 to play and 2 to exit\nYour choice: "

#puzzle
	gridOne: .byte 2 1 4 3    4 3 2 1    3 2 1 4    1 4 3 2
	gridPuzzle: .byte 2 1 0 0   0 3 2 0   0 0 0 4   1 0 0 0
	oldGridPuzzle: .byte 2 1 0 0   0 3 2 0   0 0 0 4   1 0 0 0
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
	attemptsMsg: .asciiz "\nThe amount of attempts to solve this puzzle: "
	winMsg: .asciiz "\nGood job! You win!\n\t1: Return to Main Menu\n\t2: Exit Program\n"
	efficient: .asciiz "\nThe most efficient way to solve uses 10 attempts\n"
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
	print(objective)
	print(howtoplay1)
	print(howtoplay2)
	print(howtoplay3)
	print(choice)
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

howToPlay:
	
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
	print(lineOne)		#    1 2   3 4\n   -----------#
	j newline		#\n 1 | #

#building the puzzle every loop
createPuzzle: 
	li $v0 1
	lb $a0, gridPuzzle($t0) #load byte from array and offset
	syscall
	pSpace
	addi $t0, $t0, 1 #increment offset by 1 because these are bytes, not words
	#all of these are branch statements at different values to print the board
				# element 1 and 2
	beq $t0, 2, line	#| # then element 3 and 4
	beq $t0, 4, pipes	#| \n 2 | # then 5 and 6
	beq $t0, 6, line	#| # then 7 and 8
	beq $t0, 8, middle	#|\n   -----------\n# then #| \n 3 | # then element 9 and 10
	beq $t0, 10, line	#| # then element 11 and 12
	beq $t0, 12, pipes	#| \n 4 | # then element 13 and 14
	beq $t0, 14, line	#| # then element 15 and 16
	beq $t0, 16, endLine	#|\n   -----------\n# then asks user row and column
	j createPuzzle
	
line: 
	print(pipe)
	pSpace
	j createPuzzle
	
pipes: 
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
	
	add $t3, $t3, 1 #add 1 to number of attempts
	
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
	print(attemptsMsg)
	
	li $v0, 1
	move $a0, $t3 #prints num of attempts
	syscall
	li $v0, 4
	la $a0, efficient
	syscall
	li $t3, 0 #reset num of attempts to 0
	
	print(winMsg)
	print(choice)
	#reset $t0 to 0
	li $t0, 0
	
	#take user input for return to main or exit
	li $v0, 5
	syscall
	move $s6, $v0
	
	#error handle if out of range 1-2
	blt $s7, 1, invalidM
	bgt $s7, 2, invalidM
	
	#take care of input
	beq $s7, 1, resetGridPuzzle
	beq $s7, 2, exit
	
	j resetGridPuzzle
resetGridPuzzle:
	#load byte with array offset to get the same position number
	lb $t1, oldGridPuzzle($t0)
	
	#overwrite element of oldgridPuzzle to gridPuzzle
	sb $t1, gridPuzzle($t0)
	
	#loop until all elements were overwritten
	addi $t0, $t0, 1
	
	beq $t0, 16, main
	j resetGridPuzzle

exit:
	li $v0, 10
	syscall
