#Name:
#Date:
#Objective: Create a sudoku game

.data
puzzle1: .asciiz "+-----+-----+\n| 1 * | * 4 |\n| * 3 | * 4 |\n+-----+-----+\n| * * | 4 * |\n| 4 2 | * 1 |\n+-----+-----+\n"

.text
main:
	li $v0, 4
	la $a0, puzzle1
	syscall
	
	li $v0, 10
	syscall