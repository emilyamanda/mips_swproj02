# File:    proj_sw02.s
# Author:  Emily Beiser
# Purpose: To perform printInts, printWords, and bubbleSort if their 
# values loaded in are 1. The first prints out integers in the order they're
# given to the program. The next takes in a string of words, picks
# out the spaces and replaces them with null terminators. The latter
# task implements a bubble sort on the array of integers read in, then
# alerts the user which indices were swapped in via a series of print
# statements.

.data
# print messages for printInts
PRINT_INTS_MSG: 	.asciiz "printInts: About to print an unknown number of elements. "
PRINT_INTS_MSG1:	.asciiz	" Will stop at a zero element.\n"
ABOUT_TO:		.asciiz	"printInts: About to print " 
ELEMENTS: 		.asciiz " elements.\n"
	
# print messages for printWords
PRINT_WORDS_MSG:	.asciiz "printWords: There were "
WORDS_NEWLINE:		.asciiz " words.\n"

# print messages for bubbleSort
SWAP_MSG:		.asciiz "Swap at: "
	
NEWLINE:  		.asciiz "\n"
SPACE:    		.asciiz " "

LEN:    		.asciiz "Length of intsArray: "
	
ONE: 			.byte 1
TWO:			.byte 2
i:			.byte 0
	

.text	
.globl studentMain
studentMain:
	# prologue
	addiu $sp, $sp, -24 # allocate stack space -- default of 24 here
	sw $fp, 0($sp) # save caller’s frame pointer
	sw $ra, 4($sp) # save return address
	addiu $fp, $sp, 20 # setup main’s frame pointer
	
	# load control variables
	la  $s0, printInts 
      	lb  $s0, 0($s0) 	# printInts == $s0
      	la  $s1, printWords
      	lb  $s1, 0($s1) 	# printWords == $s1
      	la  $s2, bubbleSort
      	lb  $s2, 0($s2) 	# bubbleSort == $s2
      	
      	la  $s3, printInts_howToFindLen
      	lh  $s3, 0($s3) 	# printInts_howToFindLen == $s3
      	
      	la  $s4, intsArray  	# address of intsArray is in $s4
      	lw  $s4, 0($s4)		# $s4 == intsArray
      	
      	la  $t0, i
	lb  $t0, 0($t0) 	# i == $t0 == 0
	
	la  $t1, intsArray	# temp for address of intsArray, t1 = &intsArray
	lw  $t1, 0($t1)		# t1 = intsArrays
      	
      	la  $t4, ONE
      	lb  $t4, 0($t4) 	# t4 == 1
      	
      	la  $t5, TWO
      	lb  $t5, 0($t5) 	# t5 == 2
      	
	# check values of $s0-3 to figure out which commands we want to run
	# if printInts != zero, jump to printIntsMethod
      	bne $s0, $zero, printIntsMethod 
printIntsExit:
	# if printWords != zero, jump to printWordsMethod
      	bne $s1, $zero, printWordsMethod    	
printWordsExit:
	# if bubbleSort != zero, jump to bubbleSortMethod
      	bne $s2, $zero, bubbleSortMethod 
bubbleExit:
      	j Done # after carrying out assigned tasks, if any, jump to epilogue

# if we enter this label, printInts == 1
printIntsMethod:
	# check value of $s3 (printInts_howToFindLen):	
	# if printInts_howToFindLen == zero, jump to readNum	
	beq $s3, $zero, readNum
	# if printInts_howToFindLen == 1, jump to pointerSub
	beq $s3, $t4, pointerSub
	# if printInts_howToFindLen == 2, jump to nullTerminator
	beq $s3, $t5, nullTerminator

# if we enter this label, printInts_howToFindLen == 0 
readNum: 
	la   $t6, intsArray_len	# &intsArray_len == $t6
	lh   $t6, 0($t6) 	# intsArray_len == $t6
	j    printLen		# jump to print the length/values
	
# if we enter this label, printInts_howToFindLen == 1
pointerSub:
	la   $t6, intsArray_END	# $t6 == pointer to end of array
	la   $t1, intsArray 	# $t1 == pointer to front of array
	sub  $t6, $t6, $t1	# $t6 == end of array - front of array
	sra  $t6, $t6, 2 	# divide the difference stored in $t6 
	j    printLen		# print length and values

printLen:
	addi     $v0, $zero, 4
	la       $a0, ABOUT_TO
    	syscall  # prints about to... message
        
    	addi     $v0, $zero, 1
    	add      $a0, $t6, $zero # length is now stored in count ($t6)
    	syscall  		 # prints amount of numbers in array
      
    	addi    $v0, $zero, 4	
    	la      $a0, ELEMENTS
    	syscall  		 # prints "elements" and newline

	la  	$t1, intsArray   # reload pointer to the front of array
	
printTheInts:
	# if length ($t0) != count ($t6), loop again	
	slt	 $t5, $t0, $t6  # $t5 = 0 if $t0 < $t6
	beq  	 $t5, $zero, printIntsExit # if length < count, exit
	
	lw	 $t8, 0($t1)	# load word at current index into $t8
			
	addi	 $v0, $zero, 1	# print_int(intsArray[$t1])
	add	 $a0, $zero, $t8
	syscall
	
	la   	 $a0, NEWLINE
    	addi 	 $v0, $zero, 4
    	syscall	 # prints newline
	
	addi     $t0, $t0, 1     # increment i by 1
	addi     $t1, $t1, 4     # traverse to the next byte of array after printing
	j printTheInts		
		
		
# if we enter this label, printInts_howToFindLen == 2
nullTerminator:
	la   	 $a0, PRINT_INTS_MSG
      	addi 	 $v0, $zero, 4
      	syscall  # prints out about to print unknown message
      	
      	la   	 $a0, PRINT_INTS_MSG1
      	addi 	 $v0, $zero, 4
      	syscall  # prints out "will stop..." message on same line as msg above
      	
      	la       $t8, intsArray # load address of first byte of array into $t8
      	lw 	 $t9, 0($t8)    # load value @ array's first index into $t9
 Loop:
	beq 	 $t9, $zero, printIntsExit # exit if we hit a null
	
	addi	 $v0, $zero, 1	# print_int(intsArray[$t1])
	add	 $a0, $zero, $t9
	syscall
	
	la   	 $a0, NEWLINE
      	addi 	 $v0, $zero, 4
      	syscall
	
	addi     $t8, $t8, 4 	# increment address we're looking at by 4 bytes
	lw	 $t9, 0($t8)
	# loop again, and we'll be back here in one iteration if $t9 != 0
	j Loop
	
 # now that we've completed the loops, we want to go back to the top of 
 # studentMain() where we continue to check our control variables
 j printIntsExit	
	
# if we enter this label, printWords == 1
printWordsMethod:
	la 	$t1, theString     	# $t1 == &theString[0] (start)
	add	$t2, $zero, $t1    	# $t2 == &theString[0] (cur)
	addi	$t0, $zero, 1      	# $t0 == count == 1
        
fwdLoop:
	lb 	$t3, 0($t2)	        # load val stored in $t2 into $t3 (*cur)
	beq	$t3, $zero, fwdLoopExit	# if $t3 == 0 (null), break out of loop
        
	addi	$t4, $t3, -32 	        # store difference between *cur and ' '  
	bne	$t4, $zero, curPlus     # since 32 is a space in ASCII. 
	# if there is no difference, that means we encountered a space, so we
	# run the code below, which replaces spaces with null terminators
	sb	$zero, 0($t2) # replace ' ' with null terminator AKA zero 
	# we want to store it into memory, hence the sb
	addi	$t0, $t0, 1 # count++ (we know it's a word when a space is hit)
	
	curPlus:
	addi	$t2, $t2, 1  # cur++
	#jump back up to the top of fwdLoop	
	j fwdLoop

fwdLoopExit:     	
	la   	 $a0, PRINT_WORDS_MSG
      	addi 	 $v0, $zero, 4
      	syscall  		       # prints out printWords message
      	
      	addi	 $v0, $zero, 1	
	add	 $a0, $zero, $t0       # prints count, stored in $t0
	syscall
	
	la   	 $a0, WORDS_NEWLINE
      	addi 	 $v0, $zero, 4	       # prints "words.\n"
      	syscall
	
backwardsLoop:
   	slt 	$t9, $t2, $t1 	       # $t9 == 1 if $t2 < $t1 (!gt or equal to)
        bne	$t9, $zero, printWordsExit
        
	lb	$t4, 0($t2)            # $t4 == cur ("dereferenced" cur)
		
	addi    $t6, $t2, -1         
	lb	$t6, 0($t6)	       # $t6 = cur-1
		
	# check conditionals
	beq     $t2, $t1, printVals    # if cur == theString, print
	beq 	$t6, $zero, printVals  # if cur-1 == null, print
	j decrementCur
	
	printVals:
	addi 	 $v0, $zero, 4
	add   	 $a0, $t2, $zero    
      	syscall	 #prints out value stored in $t2 (cur)
	
	la   	 $a0, NEWLINE
      	addi 	 $v0, $zero, 4
      	syscall
      	
      	decrementCur:
	addi	 $t2, $t2, -1 # cur = cur--
	
j backwardsLoop # loop again

# if we enter this label, bubbleSort == 1
bubbleSortMethod:
	la   	$t6, intsArray_len  # $t6 == &intsArray_len
	lw	$t6, 0($t6)	    # $t6 == intsArray_len[0]
	addi	$t7, $t6, -1	    # $t7 == intsArray_len-1
	add  	$t0, $zero, $zero   # i == $t0 == 0
	
forLoop1:
	slt 	$t3, $t0, $t6       # $t3 = boolean value of i < intsArray_len
	beq 	$t3, $zero, Done    # if $t3 != 0, (!(i<intsArray_len)), break out
	la  	$t4, intsArray	    # temp for address of intsArray, t4==&intsArray
	add	$t2, $zero, $zero   # j == $t2 == 0
forLoop2:
	slt 	$t9, $t2, $t7       # $t9 = boolean value of j < intsArray_len-1
	beq 	$t9, $zero, iPlus   # if $t9 != 0, !(j < intsArray_len-1), j to i++	
check: 
	lw	$t5, 0($t4) 	    # load word from the array into $t5
	lw	$s7, 4($t4) 	    # load next word from the array into $s7 (@ $t4+4)
	slt	$t8, $s7, $t5 	    # $t8 holds 0 if $s7 < $t5, 1 if !
	beq 	$t8, $zero, jPlus   # if $t8==1, increment j, continue looping
	
	# else, we want to swap
	la   	 $a0, SWAP_MSG
    	addi 	 $v0, $zero, 4
    	syscall  		#print out swap msg
      	
	addi 	 $v0, $zero, 1
	add   	 $a0, $t2, $zero    
    	syscall  		#print out j, AKA the index of the swap
	
	la   	 $a0, NEWLINE
    	addi 	 $v0, $zero, 4
    	syscall
      	
	sw	 $s7, 0($t4)	# $t5 == array[j], $s6 == &array[j+1]
	sw	 $t5, 4($t4)	# $s5 == new larger value
	
jPlus:
	addi 	$t2, $t2, 1 	# j++
	addi 	$t4, $t4, 4	# increment index pointer for next iteration
	
	j forLoop2 		# loop inner loop again

iPlus:
	addi 	$t0, $t0, 1 	# else i++
	j forLoop1 		# loop outer loop again

# epilogue
Done:
	lw $ra, 4($sp)	 	# get return address from stack
	lw $fp, 0($sp) 		# restore the caller’s frame pointer
	addiu $sp, $sp, 24 	# restore the caller’s stack pointer
	jr $ra 			# return to caller’s code
