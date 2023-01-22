##############################################################

#Dynamic array

##############################################################

#   4 Bytes - Capacity

#	4 Bytes - Size

#   4 Bytes - Address of the Elements

##############################################################
##############################################################

#Song

##############################################################

#   4 Bytes - Address of the Name (name itself is 64 bytes)

#   4 Bytes - Duration

##############################################################
.data

space: .asciiz " "

newLine: .asciiz "\n"

tab: .asciiz "\t"

menu: .asciiz "\To add a song to the list-> \t\t enter 1\nTo delete a song from the list-> \t enter 2\nTo list all the songs-> \t\t enter 3\nTo exit-> \t\t\t enter 4\n"

menuWarn: .asciiz "Please enter a valid input!\n"

name: .asciiz "Enter the name of the song: "

duration: .asciiz "Enter the duration: "

name2: .asciiz "Song name: "

duration2: .asciiz "Song duration: "

emptyList: .asciiz "List is empty!\n"

noSong: .asciiz "\nSong not found!\n"

songAdded: .asciiz "\nSong added.\n"

songDeleted: .asciiz "\nSong deleted.\n"

copmStr: .space 64

sReg: .word 3, 7, 1, 2, 9, 4, 6, 5

songListAddress: .word 0 #the address of the song list stored here!

capacity: .asciiz "capacity: "  #just used for controlling 
size: .asciiz "size: "  #just used for controlling

.text 

main:

	jal initDynamicArray

	sw $v0, songListAddress
 

	la $t0, sReg

	lw $s0, 0($t0)

	lw $s1, 4($t0)

	lw $s2, 8($t0)

	lw $s3, 12($t0)

	lw $s4, 16($t0)

	lw $s5, 20($t0)

	lw $s6, 24($t0)

	lw $s7, 28($t0)



menuStart:

	la $a0, menu    
    	li $v0, 4
        syscall	



	li $v0,  5
    	syscall
	
	li $t0, 1

	beq $v0, $t0, addSong

	li $t0, 2

	beq $v0, $t0, deleteSong

	li $t0, 3

	beq $v0, $t0, listSongs

	li $t0, 4

	beq $v0, $t0, terminate

	

	la $a0, menuWarn    

    li $v0, 4

    syscall

	b menuStart

	

addSong:

	jal createSong

	lw $a0, songListAddress

	move $a1, $v0

	jal putElement

	b menuStart

	

deleteSong:

	lw $a0, songListAddress

	jal findSong

	lw $a0, songListAddress

	move $a1, $v0

	jal removeElement

	b menuStart


listSongs:

	lw $a0, songListAddress

	jal listElements

	b menuStart

	
terminate:

	la $a0, newLine		

	li $v0, 4

	syscall

	syscall

	
	li $v0, 1

	move $a0, $s0

	syscall

	move $a0, $s1

	syscall

	move $a0, $s2

	syscall

	move $a0, $s3

	syscall

	move $a0, $s4

	syscall

	move $a0, $s5

	syscall

	move $a0, $s6

	syscall

	move $a0, $s7

	syscall

	

	li $v0, 10

	syscall


initDynamicArray:


        li      $v0,9              # allocate 12 bytes memory
        li      $a0,12            
        syscall     
        move    $t1,$v0            # dynamic array address
        
        
	li      $v0,9              # allocate 8 bytes memory
        li      $a0,8            
        syscall         	
        move    $t2,$v0            	  # song array address
	
        
        addi    $t0,$zero, 2              # store capacity
        sw      $t0,0($t1)         
	addi    $t0,$zero, 0              # store size
        sw      $t0,4($t1)         
        move    $t0,$t2           	  # store song address 
        sw      $t0,8($t1)         
	
	move $v0, $t1		#address of the dynamic array
	
	
	jr $ra



putElement:

	#a0 dynamic array address
	#a1 song address
	
	
	
	move $t8, $a0
	
	lw   $t2, 0($t8)   #capacity 
	lw   $t3, 4($t8)   #size
	lw   $t4, 8($t8)   #address
	
	
	mul $t5,$t3, 4
	add  $t4, $t4, $t5	
	 
	sw   $a1, ($t4)	# store song address in elements
	
	sub  $t4, $t4, $t5	
	
	addi $t3, $t3, 1	#increment size
	sw   $t3, 4($t8)    	#update size
	
	
	li $v0, 4
	la $a0, songAdded
	syscall
	
	
	beq  $t3, $t2, increaseCapacity
	bne $t3, $t2, exit2	
	
	increaseCapacity:
		mul $t2, $t2, 2   # capacity x2 
		mul $t7, $t2, 4	
		
		li      $v0,9           
        	move    $a0, $t7     
        	syscall         	
        	move    $t1,$v0            # x2 sized new song array address to replace with old one
		
		sw $t1, 8($t8)
		
		addi $t0, $zero, 0
		
		
		while2:
			beq $t0, $t3, exit2 
		 
			lw $t6, ($t4)    #load from elements
			addi $t4, $t4, 4
			
			
			sw $t6, ($t1)	 #store in new elements
			addi $t1, $t1, 4
			
			addi $t0, $t0, 1
	
			j while2
				
		
	exit2:	

		sw $t2, 0($t8)	
				
		li $v0, 4
		la $a0, capacity
		syscall
		
		li $v0, 1
		move $a0, $t2
		syscall
	
		li $v0, 4
		la $a0, size
		syscall
		
		li $v0, 1
		move $a0, $t3
		syscall
		
		
	jr $ra



removeElement:



	lw $t6, 0($a0)		#capacity
	
	move $t7, $a0  		#dynamic array address
	move $a2, $a1		#index
	
	lw $a1, 4($a0)		#size
	lw $t9, 8($a0)		#elements address
	
	
	addi $t8, $zero, -1
	beq $a2, $t8, exit8	#if song not found go exit
		
	arraydelete:
 		# check whether the index is in bounds
 		blt $a2, $zero, stp1
 		move $t0, $a1 # $t0 stores the size of the array
		blt $a2, $t0, del # see if target index is in range
		
		stp1: li $v0, 0 
		j exit7
 		
 		
 		
 		#shiffting
		del:
 		addi $t0, $t0, -1 
 		move $t1, $a2 
 		beq $t1, $t0, decr 
 		move $t3, $t9 
 		move $t4, $t1
 		sll $t4, $t4, 2
 		add $t3, $t3, $t4 
		
		loop9: lw $t4, 4($t3) 
 		sw $t4, 0($t3) 
 
 		addi $t3, $t3, 4 
 		addi $t1, $t1, 1 
 		blt $t1, $t0, loop9

		decr: sw $t0, 4($a0) # decrement array size


		
		exit7:  
		
		li $v0, 4
		la $a0, songDeleted
		syscall
		
		lw $t6, 0($t7)
		lw $t0, 4($t7)
		
		move $t5, $t6
		
		li $t1, 2
		div $t6, $t6, $t1

		addi $t6, $t6, -1
		
		beq   $t0, $t6 exit9
		
		li $v0, 4
		la $a0, capacity
		syscall
		
		li $v0, 1
		move $a0,  $t5
		syscall
	
		li $v0, 4
		la $a0, size
		syscall
		
		li $v0, 1
		move $a0, $t0
		syscall
		
		
		li $v0, 4
		la $a0, newLine
		syscall
		
		
			
		jr $ra
		
		
		exit9:  #decrease capacity 
		
		move $a0, $t7

		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)
		
		jal decreaseCapacity
		
				
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36
			
		li $v0, 4
		la $a0, capacity
		syscall
		
		li $v0, 1
		lw $a0, 0($t7)
		syscall
	
		li $v0, 4
		la $a0, size
		syscall
		
		li $v0, 1
		move $a0,  $t0
		syscall
		
		
		li $v0, 4
		la $a0, newLine
		syscall
		
		
		
			
		jr $ra
		
		exit8:
		
		li $v0, 4
		la $a0, noSong
		syscall
		jr $ra
		
		
		

listElements:

	
	
	#a0 songlistaddress
	lw   $t0, 0($a0)    
	lw   $t1, 4($a0)    
	lw  $t2, 8($a0)  
		

	li $t4, 0
	
	beq $t1 , $t4, exit78	#if list is empty, just print "list is empty"
	
	while:
		beq $t4, $t1, exit
	
		lw $t5, ($t2)  #song adress
		
		move $a0, $t5
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
	
		jal printElement
				
		lw $ra, 0($sp)
		
		addi $sp, $sp, 4
		
		
		
		add, $t2, $t2, 4
		addi $t4, $t4, 1
		j while
	
	
	exit:
		jr $ra

	exit78:
	
		li $v0, 4
		la $a0, emptyList
		syscall

		jr $ra
	


compareString:

	strcmp:
		add $s0,$zero,$zero
		add $s1,$zero,$a0
		add $s2,$zero,$a1
		
	loop:
		lb $s3($s1)  #load a byte from each string
		lb $s4($s2)
		beqz $s3,check #str1 end
		beqz $s4,missmatch
		bne $s3,$s4 missmatch #compare two bytes
		
		addi $s1,$s1,1  #t1 points to the next byte of str1
		addi $s2,$s2,1
		j loop

	missmatch: 
		addi $v0,$zero, 0 
		j endfunction
	check:
		bnez $s4,missmatch
		add $v0,$zero,1

	endfunction:
	
	jr $ra

	

printElement:

	move $v0, $a0		# return value is address of the song but i did not understand logic behind it
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
		
	jal printSong
				
	lw $ra, 0($sp)
	
	addi $sp, $sp, 4

	jr $ra



createSong:
	
	
	li      $v0,9              # allocate 8 bytes memory for song
        li      $a0,8            
        syscall 
	move    $t0,$v0            # song address
	
	li      $v0,9              # allocate 8 bytes memory for song_name
        li      $a0,63          
        syscall 
	move    $t1,$v0            # song name address


	li $v0, 4
	la $a0, name
	syscall 
	
	li $v0, 8 
	la $a0, ($t1)
	li $a1, 63
	syscall 
	
	sw $a0, 0($t0)    
								
	li $v0, 4
	la $a0, duration
	syscall
	
	li $v0, 5 
	syscall
	
	move $t2, $v0
	
	sw $t2, 4($t0) 
		

	move $v0 , $t0
	jr $ra


findSong:

	#a0= addres of dynamic array
	
	lw $t0, 8($a0)  #address of the elements
	lw $t1, 4($a0)	#size 

	li $v0, 4
	la $a0, name
	syscall
	
	
	li $v0, 8 
	la $a0, copmStr # comparison name address
	li $a1, 63
	syscall
	
	
	move $t2, $a0
	
	li $t9, 1 # to check if compareStr returns 1
	li $t8, 0 # counter
	
	
	
	beq $t8, $t1, exit5
		
	
	for:
		beq $t8, $t1, exit4
		
		lw $t3, ($t0)  #song adress
		move $a0, $t2
		lw $t5, 0($t3) #song name address
		la $a1, ($t5)
		
		la $a2, 63

		
		addi $sp, $sp, -28
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		jal compareString
		
				
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		addi $sp, $sp, 28
		
		move $t7, $v0
		
		beq $t9, $t7, exit3
				
		add $t0, $t0, 4
		addi $t8, $t8, 1
		
		
		j for
	
	
	exit3:
		
		move $v0, $t8	
		
		jr $ra
	
	exit4:
	
		addi $v0, $zero, -1
	
		jr $ra

	exit5:
	
		li $v0,4
		la $a0, noSong
		syscall
		
	
		li $v0,4
		la $a0, emptyList
		syscall
		
		b menuStart
		
printSong:

	move $t5, $a0
	
	
	li $v0, 4
	la $a0, name2
	syscall 
		
	li $v0,4
	lw $a0, 0($t5)	
	syscall			#name of the song
		
	li $v0, 4
	la $a0, duration2
	syscall 
		
	li $v0,1
	lw $a0, 4($t5)	
	syscall			#duration of the song
	
	li $v0, 4
	la $a0, newLine
	syscall 
	
	jr $ra


decreaseCapacity:
		
	move $s0, $a0
	
			
	lw   $s1, 0($s0)   #capacity 
	lw   $s2, 4($s0)   #size
	lw   $s3, 8($s0)   #address
	
	
	li $s4, 2
	div $s1, $s1, $s4		#capacity/2

	blt $s1, $s4, exit99

	sw $s1, 0($s0)
	
	mul $s5 ,$s1, 4		#(capacity/2) * 4 for bytes
		
	li      $v0,9           
        move    $a0, $s5  
        syscall         	
        move    $s6,$v0            # /2 sized new song array address to replace with old one
		
	sw $s6, 8($s0)
		
	addi $s4, $zero, 0
		
		
	while4:
		beq $s4, $s2, exit99
		 
		lw $t6, ($s3)    #load from elements

			
		sw $t6, ($s6)	#store in new elements array
		
		
		addi $s3, $s3, 4
		addi $s6, $s6, 4
			
		addi $s4, $s4, 1
	
		j while4


	exit99:
	jr $ra


