# Bitmap Display Configuration:

# - Unit width in pixels: 8                         

# - Unit height in pixels: 8

# - Display width in pixels: 256

# - Display height in pixels: 256

# - Base Address for Display: 0x10008000 ($gp)

#

.data

    displayAddress:    .word    0x10008000

    background: .word 0xfbfbf0

    plat: .word 0x00ff00

    player: .word 0x0000ff

    height: .word 256

    width: .word 256

    jump: .word 20

    EndColor1: .word 0x2775e3

    EndColor2: .word 0x274ce3 

    ScoreColor: .word 0x000000

    

    Player: .space 8

    	# Position {Middle pixel} : 4 bytes

    	# Height {Middle pixel}: 4 bytes

    BottomPlat: .space 4

    	#Postion {Left pixel}: 4 bytes

    	

    MiddlePlat: .space 4

    	#Postion {Left pixel}: 4 bytes

    	

    TopPlat: .space 4

    	#Postion {Left pixel}: 4 bytes

    

.text 

    lw $s0, displayAddress    # $s0 stores the base address for display

    li $s1, 0 #flag

    li $s2, 0 #flag2

    li $s3, 0 # Position of player

    li $s4, 1 #Jump Direction

    li $s5, 0 #Score

    li $s6, 0 # Ones digit of score

    li $s7, 0 # Tens digit of score

    li $k1, 10 # Timer

    li $a3, 1 # Check

    



Main:

    # Initialize game

    jal FillBackground

    jal DrawPlatform

    jal DrawPlayer

    #---------------#

    

    

    # Refresh Loop {3 fps}

    fpsWHILE:

    	li $t1, 1

    	beq $s5, $zero, S

    	div $t1, $s5, 10

    	mfhi $t1

    	beq $t1, $zero, W

    	div $t1, $s5, 5

    	mfhi $t1

    	beq $t1, $zero, N

    	li $k1, 10

    	li $a3, 1

    	j S

    	K:

    		jal EraseNice

    		jal EraseWow

    		j S

    	W:

    		beq $k1, $zero, K

    	    	addi $k1, $k1, -1

    		bne $a3, $zero, bro

    		jal Wow

    		j S

    		bro:

    		    li $a3, 0

    		    li $k1, 10

    		    jal Wow

    		    j S	

    	N:

    		beq $k1, $zero, K

    	    addi $k1, $k1, -1

    		bne $a3, $zero, bro2

    		jal Nice

    		j S

    		bro2:

    			li $a3, 0

    		    li $k1, 10

    		    jal Nice

    			j S

    			

    	S:

    	la $t1, Player

    	lw $t3, 0($t1)

    	li $t5, 3968

		bge $t3, $t5, Exit

    	jal MoveHorizontal

    	la $t5, Player

    	lw $t0, jump

    	lw $t1, 4($t5)

    	lw $t4 0($t5)

    	

    	la $t2, BottomPlat

    	lw $t3, 0($t2)

    	addi $t3, $t3, -132

    	ble $t3, $t4, SecondCheck

    	j STOP1

    	SecondCheck:

    	bne $s4, $zero, STOP1

    	addi $t3, $t3, 32

    	bge $t3, $t4, Switch

    	STOP1:

    		la $t2, MiddlePlat

    		lw $t3, 0($t2)

    		addi $t3, $t3, -132

    		ble $t3, $t4, ThirdCheck

    		j STOP

    	ThirdCheck:

    		bne $s4, $zero, STOP

    		addi $t3, $t3, 32

    		bge $t3, $t4, SwitchScreen

    	STOP:

    	

    	beq $t1, $t0, Switch

    	SD:

    	beq $s4, $zero PlayerDown

    	PD:

    	bne $s4, $zero PlayerUP

    	PU:

    	jal DrawMiddle

    	#SLEEP

    	li $v0, 32 

    	li $a0, 40

    	syscall

    	la $t5, Player

    	lw $t1, 4($t5)

    	addi $t1, $t1, 1

    	sw $t1, 4($t5)

    	j fpsWHILE

    	#-------------#	

    fpsEND:

    #---------------#

    j Exit

    

SwitchScreen: 

	addi $s5, $s5, 1

	li $t0, 10

	div $s5, $t0

	mflo $s7

	mfhi $s6

	jal UpdateScore

	beq $s4, $zero, ONE

	addi $s4, $zero, 0

	li $t1, -20 

	sw $t1, 4($t5)

	j MoveScreen

	ONE:

		addi $s4, $zero, 1

		sw $zero, 4($t5)

		j MoveScreen

		

UpdateScore:

	# Show numbers on screen

    jr $ra



MoveScreen:

	jal MoveHorizontal

	la $t1, MiddlePlat

    	lw $t3, 0($t1)

    	li $t5, 3968

	bge $t3, $t5, CreateNewTop

	

    	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    	

    	#Erase Bot Platform 

    	lw $t0, background #loads the color of background

    	la $t1, BottomPlat

    	lw $t3, 0($t1)

    	add $s0, $s0, $t3

    	sw $t0, 0($s0)

    	sw $t0, 4($s0)

    	sw $t0, 8($s0) 

    	sw $t0, 12($s0)

    	sw $t0, 16($s0)

    	sw $t0, 20($s0)

    	sw $t0, 24($s0)

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

    	

    	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    	

    	#Erase Middle Platform

    	lw $t0, background #loads the color of background

    	la $t1, MiddlePlat

    	lw $t3, 0($t1)

    	add $s0, $s0, $t3

    	sw $t0, 0($s0)

    	sw $t0, 4($s0)

    	sw $t0, 8($s0) 

    	sw $t0, 12($s0)

    	sw $t0, 16($s0)

    	sw $t0, 20($s0)

    	sw $t0, 24($s0)

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

    	

    	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    	

    	#Erase Top Platform

    	lw $t0, background #loads the color of background

    	la $t1, TopPlat

    	lw $t3, 0($t1)

    	add $s0, $s0, $t3

    	sw $t0, 0($s0)

    	sw $t0, 4($s0)

    	sw $t0, 8($s0) 

    	sw $t0, 12($s0)

    	sw $t0, 16($s0)

    	sw $t0, 20($s0)

    	sw $t0, 24($s0)

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

    	

    	#Stack

   		addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    	li $t0, 25

    	li $t3, 100

    	bge $s5, $t3, Smallest3

    	bge $s5, $t0, Smaller3

    	#Draw Middle to Bottom Platform 

    	lw $t0, plat #loads the color of platform

    	la $t1, MiddlePlat

    	lw $t3, 0($t1)

    	addi $t3, $t3, 128

    	add $s0, $s0, $t3

    	sw $t0, 0($s0)

    	sw $t0, 4($s0)

    	sw $t0, 8($s0) 

    	sw $t0, 12($s0)

    	sw $t0, 16($s0)

    	sw $t0, 20($s0)

    	sw $t0, 24($s0)

    	sw $t3, 0($t1)

    	#---------------#

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

    	

    	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    	

    	#Draw Top to Middle Platform 

    	lw $t0, plat #loads the color of platform

    	la $t1, TopPlat

    	lw $t3, 0($t1)

    	addi $t3, $t3, 128

    	add $s0, $s0, $t3

    	sw $t0, 0($s0)

    	sw $t0, 4($s0)

    	sw $t0, 8($s0) 

    	sw $t0, 12($s0)

    	sw $t0, 16($s0)

    	sw $t0, 20($s0)

    	sw $t0, 24($s0)

    	sw $t3, 0($t1)

    	#---------------#

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

    	

    	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    

    	

       	#SLEEP

        li $v0, 32 

        li $a0, 40

        syscall

        la $t5, Player

        lw $t1, 4($t5)

        addi $t1, $t1, 1

        sw $t1, 4($t5)

        li $s1, 0

    	jal EraseNumbers

    	jal NumbersInGame

        j MoveScreen

    	#Create Platform

    	

    	Smaller3:

    	#Draw Middle to Bottom Platform 

    	lw $t0, plat #loads the color of platform

    	la $t1, MiddlePlat

    	lw $t3, 0($t1)

    	addi $t3, $t3, 128

    	add $s0, $s0, $t3

    	sw $t0, 4($s0)

    	sw $t0, 8($s0) 

    	sw $t0, 12($s0)

    	sw $t0, 16($s0)

    	sw $t0, 20($s0)

    	sw $t3, 0($t1)

    	#---------------#

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

    	

    	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    	

    	#Draw Top to Middle Platform 

    	lw $t0, plat #loads the color of platform

    	la $t1, TopPlat

    	lw $t3, 0($t1)

    	addi $t3, $t3, 128

    	add $s0, $s0, $t3

    	sw $t0, 4($s0)

    	sw $t0, 8($s0) 

    	sw $t0, 12($s0)

    	sw $t0, 16($s0)

    	sw $t0, 20($s0)

    	sw $t3, 0($t1)

    	#---------------#

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

    	

    	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    

    	

       	#SLEEP

        li $v0, 32 

        li $a0, 40

        syscall

        la $t5, Player

        lw $t1, 4($t5)

        addi $t1, $t1, 1

        sw $t1, 4($t5)

        li $s1, 0

    	jal EraseNumbers

    	jal NumbersInGame

        j MoveScreen

    	#Create Platform

    	

    	Smallest3:

    	

    	#Draw Middle to Bottom Platform 

    	lw $t0, plat #loads the color of platform

    	la $t1, MiddlePlat

    	lw $t3, 0($t1)

    	addi $t3, $t3, 128

    	add $s0, $s0, $t3

    	sw $t0, 12($s0)

    	sw $t3, 0($t1)

    	#---------------#

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

    	

    	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    	

    	#Draw Top to Middle Platform 

    	lw $t0, plat #loads the color of platform

    	la $t1, TopPlat

    	lw $t3, 0($t1)

    	addi $t3, $t3, 128

    	add $s0, $s0, $t3

    	sw $t0, 12($s0)

    	sw $t3, 0($t1)

    	#---------------#

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

    	

    	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

    

    	

       	#SLEEP

        li $v0, 32 

        li $a0, 40

        syscall

        la $t5, Player

        lw $t1, 4($t5)

        addi $t1, $t1, 1

        sw $t1, 4($t5)

        li $s1, 0

    	jal EraseNumbers

    	jal NumbersInGame

        j MoveScreen

    	#Create Platform

    	

    

CreateNewTop:

	jal MoveHorizontal

	#Set Mid to Bot

    	la $t1, MiddlePlat

    	lw $t3, 0($t1)

    	la $t2,	BottomPlat

    	sw $t3, 0($t2)

    	

	#Set Top to Mid

	la $t1, TopPlat

    	lw $t3, 0($t1)

    	la $t2, MiddlePlat

    	sw $t3, 0($t2)

    	

    	li $t0, 25

    	li $t4, 100

    	bge $s5, $t4, Smallest

    	bge $s5, $t0, Smaller

 	#Generate Top Platform

    	lw $t0, plat #loads the color of platform

    	la $t6, TopPlat

    	li $t4, 4

    	

    	#Randint

    	li $v0, 42

    	li $a1, 25

    	syscall

   	#---------------# 

   	

    	move $t1, $a0

    	mult $t1, $t4

    	mflo $t1

    	addi $t1, $t1, 0

    	add $s0, $s0, $t1

	sw $t1, 0($t6)

   	sw $t0, 0($s0)

   	sw $t0, 4($s0)

    	sw $t0, 8($s0)

    	sw $t0, 12($s0)

    	sw $t0, 16($s0)

    	sw $t0, 20($s0)

    	sw $t0, 24($s0)

    	#---------------#

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

	j PD

	

	Smaller:

 	#Generate Top Platform

    	lw $t0, plat #loads the color of platform

    	la $t6, TopPlat

    	li $t4, 4

    	

    	#Randint

    	li $v0, 42

    	li $a1, 25

    	syscall

   	#---------------# 

   	

    	move $t1, $a0

    	mult $t1, $t4

    	mflo $t1

    	addi $t1, $t1, 0

    	add $s0, $s0, $t1

		sw $t1, 0($t6)

   		sw $t0, 4($s0)

    	sw $t0, 8($s0)

    	sw $t0, 12($s0)

    	sw $t0, 16($s0)

    	sw $t0, 20($s0)

    	#---------------#

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

		j PD

		

	Smallest:

 	#Generate Top Platform

    	lw $t0, plat #loads the color of platform

    	la $t6, TopPlat

    	li $t4, 4

    	

    	#Randint

    	li $v0, 42

    	li $a1, 25

    	syscall

   	#---------------# 

   	

    	move $t1, $a0

    	mult $t1, $t4

    	mflo $t1

    	addi $t1, $t1, 0

    	add $s0, $s0, $t1

    	sw $t0, 8($s0)

    	sw $t0, 12($s0)

    	#---------------#

    	

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

    	#---------------#

		j PD

		

       

MoveHorizontal: 

    lw $t0, 0xffff0000 

    beq $t0, 1, keyboard_input

    j Done

    

    keyboard_input:    

        lw $t2, 0xffff0004 # get input (j or k)

        beq $t2, 0x6a, moveLeft

        beq $t2, 0x6b, moveRight

        j Done

    moveLeft:

	la $t5, Player # Get Struct

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

    	lw $t1, 0($t5) #the position of the lowest green block

    	subi $t1, $t1, 4 

    	lw $t2, background #loads the color of player

    	

    	#Un-Draw player

    	add $s0, $s0, $t1

    	sw $t2, 0($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 128

    	sw $t2, 0($s0)

    	sw $t2, 4($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 124

    	sw $t2, 0($s0)

    	#---------------#

    	

    	#Stack free

    	lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#



	

	la $t5, Player # Get Struct

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

	

    	lw $t1, 0($t5) #the position of the lowest green block

    	subi $t1, $t1, 8

    	add $t6, $zero, $t1

    	addi $t6, $t6, 4

    	sw $t6, 0($t5)

    	lw $t2, player #loads the color of player

    	

    	#Draw player

    	add $s0, $s0, $t1

    	sw $t2, 0($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 128

    	sw $t2, 0($s0)

    	sw $t2, 4($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 124

    	sw $t2, 0($s0)

    	#---------------#

    	

    	#Stack free

    	lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#

        

        

        j Done

    moveRight:

	la $t5, Player # Get Struct

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

    	lw $t1, 0($t5) #the position of the lowest green block

    	subi $t1, $t1, 4 

    	lw $t2, background #loads the color of player

    	

    	#Un-Draw player

    	add $s0, $s0, $t1

    	sw $t2, 0($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 128

    	sw $t2, 0($s0)

    	sw $t2, 4($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 124

    	sw $t2, 0($s0)

    	#---------------#

    	

    	#Stack free

    	lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#



	

	la $t5, Player # Get Struct

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

	

    	lw $t1, 0($t5) #the position of the lowest green block

    	addi $t1, $t1, 0

    	add $t6, $zero, $t1

    	addi $t6, $t6, 4

    	sw $t6, 0($t5)

    	lw $t2, player #loads the color of player

    	

    	#Draw player

    	add $s0, $s0, $t1

    	sw $t2, 0($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 128

    	sw $t2, 0($s0)

    	sw $t2, 4($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 124

    	sw $t2, 0($s0)

    	#---------------#

    	

    	#Stack free

    	lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#

        

        

        j Done

    Done:

    jr $ra





PlayerDown:

	la $t5, Player # Get Struct

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

    	lw $t1, 0($t5) #the position of the lowest green block

    	subi $t1, $t1, 4 

    	lw $t2, background #loads the color of player

    	

    	#Un-Draw player

    	add $s0, $s0, $t1

    	sw $t2, 0($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 128

    	sw $t2, 0($s0)

    	sw $t2, 4($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 124

    	sw $t2, 0($s0)

    	#---------------#

    	

    	#Stack free

    	lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#



	

	la $t5, Player # Get Struct

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

	

    	lw $t1, 0($t5) #the position of the lowest green block

    	addi $t1, $t1, 124

    	add $t6, $zero, $t1

    	addi $t6, $t6, 4

    	sw $t6, 0($t5)

    	lw $t2, player #loads the color of player

    	

    	#Draw player

    	add $s0, $s0, $t1

    	sw $t2, 0($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 128

    	sw $t2, 0($s0)

    	sw $t2, 4($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 124

    	sw $t2, 0($s0)

    	#---------------#

    	

    	#Stack free

    	lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#

        

        

        j PD



Switch:

	beq $s4, $zero, ONE2

	addi $s4, $zero, 0

	li $t1, -20 

	sw $t1, 4($t5)

	j SD

	ONE2:

		addi $s4, $zero, 1

		sw $zero, 4($t5)

		j SD



DrawMiddle:

	li $t0, 25

	li $t4, 100

	bge $s5, $t4, Smallest2

	bge $s5, $t0, Smaller2

	lw $t2 plat

	la $t3, MiddlePlat

    #Stack

    addi $sp, $sp, -4

    sw $s0, 0($sp)

    #---------------#

    

    #Plat 2

    lw $t1, 0($t3)

    add $s0, $s0, $t1

	sw $t1, 0($t3)

    sw $t2, 0($s0)

    sw $t2, 4($s0)

    sw $t2, 8($s0)

    sw $t2, 12($s0)

    sw $t2, 16($s0)

    sw $t2, 20($s0)

    sw $t2, 24($s0)

    #---------------#

    

    #Stack Free

    lw $s0, 0($sp)

    addi $sp, $sp, 4

    #---------------#

    jr $ra

    

    Smaller2:

	lw $t2 plat

	la $t3, MiddlePlat

    #Stack

    addi $sp, $sp, -4

    sw $s0, 0($sp)

    #---------------#

    

    #Plat 2

    lw $t1, 0($t3)

    add $s0, $s0, $t1

	sw $t1, 0($t3)

    sw $t2, 4($s0)

    sw $t2, 8($s0)

    sw $t2, 12($s0)

    sw $t2, 16($s0)

    sw $t2, 20($s0)



    #---------------#

    

    #Stack Free

    lw $s0, 0($sp)

    addi $sp, $sp, 4

    #---------------#

    jr $ra

   	

   	Smallest2:

	lw $t2 plat

	la $t3, MiddlePlat

    #Stack

    addi $sp, $sp, -4

    sw $s0, 0($sp)

    #---------------#

    

    #Plat 2

    lw $t1, 0($t3)

    add $s0, $s0, $t1

	sw $t1, 0($t3)

    sw $t2, 12($s0)



    #---------------#

    

    #Stack Free

    lw $s0, 0($sp)

    addi $sp, $sp, 4

    #---------------#

    jr $ra



    

PlayerUP:

	la $t5, Player # Get Struct

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

    	lw $t1, 0($t5) #the position of the lowest green block

    	subi $t1, $t1, 4 

    	lw $t2, background #loads the color of background

    	

    	#Un-Draw player

    	add $s0, $s0, $t1

    	sw $t2, 0($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 128

    	sw $t2, 0($s0)

    	sw $t2, 4($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 124

    	sw $t2, 0($s0)

    	#---------------#

    	

    	#Stack free

    	lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#



	

	la $t5, Player # Get Struct

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

	

    	lw $t1, 0($t5) #the position of the lowest green block

    	subi $t1, $t1, 132

    	add $t6, $zero, $t1

    	addi $t6, $t6, 4

    	sw $t6, 0($t5)

    	lw $t2, player #loads the color of player

    	

    	#Draw player

    	add $s0, $s0, $t1

    	sw $t2, 0($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 128

    	sw $t2, 0($s0)

    	sw $t2, 4($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 124

    	sw $t2, 0($s0)

    	#---------------#

    	

    	#Stack free

    	lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#

        

        

        j PU

        

FillBackground:

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

	

	    #Fill Background

        lw $t1 background

        li $t3, 4092

        li $t4, 0 #Counter

        backgroundWHILE: 

            sw $t1, 0($s0)

            addi $s0, $s0, 4

            addi $t4, $t4, 4

            blt $t3 , $t4, backgroundSTOP

            j backgroundWHILE

        backgroundSTOP:

        #---------------#

        

        #Stack free

        lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#

        

        jr $ra

        

DrawPlatform:

    li $t7, 0 #Player Position

    la $t3, MiddlePlat

    la $t6, TopPlat

    la $k0, BottomPlat

    

    #Stack

    addi $sp, $sp, -4

    sw $s0, 0($sp)

    #---------------#

    

    #Randint

    li $v0, 42

    li $a1, 25

    syscall

    #---------------#

    

    #Plat 1

    lw $t2 plat

    move $t1, $a0

    li $t4, 4

    mult $t1, $t4

    mflo $t1

    addi $t1, $t1, 3968

    add $s0, $s0, $t1

    sw $t1, 0($k0)

    add $t7, $t7, $t1

    sw $t2, 0($s0)

    sw $t2, 4($s0)

    sw $t2, 8($s0) 

    sw $t2, 12($s0)

    sw $t2, 16($s0)

    sw $t2, 20($s0)

    sw $t2, 24($s0)

    #---------------#

    

    #Stack Free

    lw $s0, 0($sp)

    addi $sp, $sp, 4

    #---------------#

        

    #Player Pos Update

    addi $t7, $t7, 12

    subi $t7, $t7, 128

    la $t5, Player

    sw $t7, 0($t5)

    #---------------#

    

    #Stack

    addi $sp, $sp, -4

    sw $s0, 0($sp)

    #---------------#

    

    #Randint

    li $v0, 42

    li $a1, 24

    syscall

    #---------------#

    

    #Plat 2

    move $t1, $a0

    mult $t1, $t4

    mflo $t1

    addi $t1, $t1, 1920

    add $s0, $s0, $t1

	sw $t1, 0($t3)

    sw $t2, 0($s0)

    sw $t2, 4($s0)

    sw $t2, 8($s0)

    sw $t2, 12($s0)

    sw $t2, 16($s0)

    sw $t2, 20($s0)

    sw $t2, 24($s0)

    #---------------#

    

    #Stack Free

    lw $s0, 0($sp)

    addi $sp, $sp, 4

    #---------------#

    

    #Stack

    addi $sp, $sp, -4

    sw $s0, 0($sp)

    #---------------#

    

    #Randint

    li $v0, 42

    li $a1, 25

    syscall

    #---------------#

    

    #Plat 3

    move $t1, $a0

    mult $t1, $t4

    mflo $t1

    addi $t1, $t1, 0

    add $s0, $s0, $t1

    sw $t1, 0($t6)

    sw $t2, 0($s0)

    sw $t2, 4($s0)

    sw $t2, 8($s0)

    sw $t2, 12($s0)

    sw $t2, 16($s0)

    sw $t2, 20($s0)

    sw $t2, 24($s0)

    #---------------#

    

    #Stack Free

    lw $s0, 0($sp)

    addi $sp, $sp, 4

    #---------------#

    jr $ra

     

DrawPlayer:

	la $t5, Player # Get Struct

	#Stack

	addi $sp, $sp, -4

	sw $s0, 0($sp)

	#---------------#

    	lw $t1, 0($t5) #the position of the lowest green block

    	subi $t1, $t1, 4 

    	lw $t2, player #loads the color of player

    	

    	#Draw player

    	add $s0, $s0, $t1

    	sw $t2, 0($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 128

    	sw $t2, 0($s0)

    	sw $t2, 4($s0)

    	sw $t2, 8($s0)

    	subi $s0, $s0, 124

    	sw $t2, 0($s0)

    	#---------------#

    	

    	#Stack free

    	lw $s0, 0($sp)

        addi $sp, $sp, 4

        #---------------#

        

        

        jr $ra



GameOver:

	lw $t0, EndColor1

	lw $t1, EndColor2

	

	#Row 1 of "Game"

	lw $s0, displayAddress

	addi $s0, $s0, 640 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 4($s0)

	sw $t0, 8($s0)

	sw $t0, 12($s0)

	sw $t0, 20($s0)

	sw $t0, 24($s0)

	sw $t0, 28($s0)

	sw $t0, 32($s0)

	sw $t0, 40($s0)

	sw $t0, 56($s0)

	sw $t0, 64($s0)

	sw $t0, 68($s0)

	sw $t0, 72($s0)

	sw $t0, 76($s0)

	

	#Row 2 of "Game"

	lw $s0, displayAddress

	addi $s0, $s0, 764 # Vertical Distance

	addi $s0, $s0, 32 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 20($s0)

	sw $t0, 32($s0)

	sw $t0, 40($s0)

	sw $t0, 44($s0)

	sw $t0, 52($s0)

	sw $t0, 56($s0)

	sw $t0, 64($s0)

	

	#Row 3 of "Game"

	lw $s0, displayAddress

	addi $s0, $s0, 892 # Vertical Distance

	addi $s0, $s0, 32 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 8($s0)

	sw $t0, 12($s0)

	sw $t0, 20($s0)

	sw $t0, 24($s0)

	sw $t0, 28($s0)

	sw $t0, 32($s0)

	sw $t0, 40($s0)

	sw $t0, 48($s0)

	sw $t0, 56($s0)

	sw $t0, 64($s0)

	sw $t0, 68($s0)

	sw $t0, 72($s0)

	

	#Row 4 of "Game"

	lw $s0, displayAddress

	addi $s0, $s0, 1020 # Vertical Distance

	addi $s0, $s0, 32 # Horizontal Distance

	sw $t1, 0($s0)

	sw $t1, 12($s0)

	sw $t1, 20($s0)

	sw $t1, 32($s0)

	sw $t1, 40($s0)

	sw $t1, 56($s0)

	sw $t1, 64($s0)

	

	#Row 5 of "Game"

	lw $s0, displayAddress

	addi $s0, $s0, 1148 # Vertical Distance

	addi $s0, $s0, 32 # Horizontal Distance

	sw $t1, 0($s0)

	sw $t1, 4($s0)

	sw $t1, 8($s0)

	sw $t1, 12($s0)

	sw $t1, 20($s0)

	sw $t1, 32($s0)

	sw $t1, 40($s0)

	sw $t1, 56($s0)

	sw $t1, 64($s0)

	sw $t1, 68($s0)

	sw $t1, 72($s0)

	sw $t1, 76($s0)



	#Row 1 of "Over"

	lw $s0, displayAddress

	addi $s0, $s0, 1404 # Vertical Distance

	addi $s0, $s0, 32 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 4($s0)

	sw $t0, 8($s0)

	sw $t0, 12($s0)

	sw $t0, 20($s0)

	sw $t0, 36($s0)

	sw $t0, 44($s0)

	sw $t0, 48($s0)

	sw $t0, 52($s0)

	sw $t0, 56($s0)

	sw $t0, 64($s0)

	sw $t0, 68($s0)

	sw $t0, 72($s0)

	sw $t0, 76($s0)



	#Row 2 of "Over"

	lw $s0, displayAddress

	addi $s0, $s0, 1532 # Vertical Distance

	addi $s0, $s0, 32 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 12($s0)

	sw $t0, 20($s0)

	sw $t0, 36($s0)

	sw $t0, 44($s0)

	sw $t0, 64($s0)

	sw $t0, 76($s0)



	#Row 3 of "Over"

	lw $s0, displayAddress

	addi $s0, $s0, 1660 # Vertical Distance

	addi $s0, $s0, 32 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 12($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 44($s0)

	sw $t0, 48($s0)

	sw $t0, 52($s0)

	sw $t0, 64($s0)

	sw $t0, 68($s0)

	sw $t0, 72($s0)

	sw $t0, 76($s0)



	#Row 4 of "Over"

	lw $s0, displayAddress

	addi $s0, $s0, 1788 # Vertical Distance

	addi $s0, $s0, 32 # Horizontal Distance

	sw $t1, 0($s0)

	sw $t1, 12($s0)

	sw $t1, 24($s0)

	sw $t1, 32($s0)

	sw $t1, 44($s0)

	sw $t1, 64($s0)

	sw $t1, 72($s0)



	#Row 5 of "Over"

	lw $s0, displayAddress

	addi $s0, $s0, 1916 # Vertical Distance

	addi $s0, $s0, 32 # Horizontal Distance

	sw $t1, 0($s0)

	sw $t1, 4($s0)

	sw $t1, 8($s0)

	sw $t1, 12($s0)

	sw $t1, 28($s0)

	sw $t1, 44($s0)

	sw $t1, 48($s0)

	sw $t1, 52($s0)

	sw $t1, 56($s0)

	sw $t1, 64($s0)

	sw $t1, 76($s0)



	jr $ra

	

NumbersEND:

	lw $t0, EndColor1

	lw $t1, EndColor2

	li $t3, 0

	#---------------

	#Note: ones column = 56 horizontal distance

	#Note: twos column = 20 more than 56 horizontal distance

	#---------------

		IfTens:	

		beq $s7, $zero, Zero

		li $t7, 1

		beq $s7, $t7, One

		li $t7, 2

		beq $s7, $t7, Two

		li $t7, 3

		beq $s7, $t7, Three

		li $t7, 4

		beq $s7, $t7, Four

		li $t7, 5

		beq $s7, $t7, Five

		li $t7, 6

		beq $s7, $t7, Six

		li $t7, 7

		beq $s7, $t7, Seven

		li $t7, 8

		beq $s7, $t7, Eight

		li $t7, 9

		beq $s7, $t7, Nine

		j IfOnes

		

	IfOnes:

		li $t7, 1

		beq $s2, $t7, End

		li $s2, 1

		addi $t3, $t3, 20

		beq $s6, $zero, Zero

		li $t7, 1

		beq $s6, $t7, One

		li $t7, 2

		beq $s6, $t7, Two

		li $t7, 3

		beq $s6, $t7, Three

		li $t7, 4

		beq $s6, $t7, Four

		li $t7, 5

		beq $s6, $t7, Five

		li $t7, 6

		beq $s6, $t7, Six

		li $t7, 7

		beq $s6, $t7, Seven

		li $t7, 8

		beq $s6, $t7, Eight

		li $t7, 9

		beq $s6, $t7, Nine

		j End

		

	Eight:

		#Number "8" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	

	One:

		#Number "1" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		addi $s0, $s0, 12

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	

	Two:

		#Number "2" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2
		
		sw $t0, 256($s0)
		
		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	

	Three:

		#Number "3" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	

	Four:

		#Number "4" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		addi $s0, $s0, 4

		sw $t0, 256($s0) # Column 2

		addi $s0, $s0, 4

		sw $t0, 256($s0) # Column 3

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	

	Five:

		#Number "5" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	

	Six:

		#Number "6" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	

	Seven:

		#Number "7" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	

	Nine:

		#Number "9" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	

	Zero:

		#Number "0" For 1's Place

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 2300 # Vertical Distance

		addi $s0, $s0, 56 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t1, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t1, 384($s0)

		sw $t1, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

		j IfOnes

	End:

		jr $ra



NumbersInGame:

	lw $t0, ScoreColor

	li $t3, 0

	

	IfTens1:	

		beq $s7, $zero, SmallZero

		li $t7, 1

		beq $s7, $t7, SmallOne

		li $t7, 2

		beq $s7, $t7, SmallTwo

		li $t7, 3

		beq $s7, $t7, SmallThree

		li $t7, 4

		beq $s7, $t7, SmallFour

		li $t7, 5

		beq $s7, $t7, SmallFive

		li $t7, 6

		beq $s7, $t7, SmallSix

		li $t7, 7

		beq $s7, $t7, SmallSeven

		li $t7, 8

		beq $s7, $t7, SmallEight

		li $t7, 9

		beq $s7, $t7, SmallNine

		j IfOnes1

		

	IfOnes1:

		li $t7, 1

		beq $s1, $t7, End4

		li $s1, 1

		addi $t3, $t3, 20

		beq $s6, $zero, SmallZero

		li $t7, 1

		beq $s6, $t7, SmallOne

		li $t7, 2

		beq $s6, $t7, SmallTwo

		li $t7, 3

		beq $s6, $t7, SmallThree

		li $t7, 4

		beq $s6, $t7, SmallFour

		li $t7, 5

		beq $s6, $t7, SmallFive

		li $t7, 6

		beq $s6, $t7, SmallSix

		li $t7, 7

		beq $s6, $t7, SmallSeven

		li $t7, 8

		beq $s6, $t7, SmallEight

		li $t7, 9

		beq $s6, $t7, SmallNine

		j End4

		

	SmallEight:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

	

	SmallOne:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#		

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		addi $s0, $s0, 12

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

	

	SmallTwo:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#	

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

		

	SmallThree:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

		

	SmallFour:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		addi $s0, $s0, 4

		sw $t0, 256($s0) # Column 2

		addi $s0, $s0, 4

		sw $t0, 256($s0) # Column 3

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

		

	SmallFive:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

		

	SmallSix:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

		

	SmallSeven:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

		

	SmallNine:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

	SmallZero:

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		add $s0, $s0, $t3 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		j IfOnes1

   		

	End4:

		jr $ra

		



EraseNumbers:

		lw $t0, background

		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		

   		#Stack

   	 	addi $sp, $sp, -4

    		sw $s0, 0($sp)

    		#---------------#

		lw $s0, displayAddress

		addi $s0, $s0, 128 # Vertical Distance

		addi $s0, $s0, 4 # Horizontal Distance

		addi $s0, $s0, 20 # add offset

		sw $t0, 0($s0) # Column 1

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 2

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 3

		sw $t0, 256($s0)

		sw $t0, 512($s0)

		addi $s0, $s0, 4

		sw $t0, 0($s0) # Column 4

		sw $t0, 128($s0)

		sw $t0, 256($s0)

		sw $t0, 384($s0)

		sw $t0, 512($s0)

		#Stack Free

    		lw $s0, 0($sp)

    		addi $sp, $sp, 4

   		#---------------#

   		jr $ra

Wow:

	lw $t0, ScoreColor

	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 1 of "Wow"

	lw $s0, displayAddress

	addi $s0, $s0, 768 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 28($s0)

	sw $t0, 32($s0)

	sw $t0, 36($s0)

	sw $t0, 44($s0)

	sw $t0, 60($s0)

	sw $t0, 68($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 2 of "Wow"

	lw $s0, displayAddress

	addi $s0, $s0, 896 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 36($s0)

	sw $t0, 44($s0)

	sw $t0, 60($s0)

	sw $t0, 68($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 3 of "Wow"

	lw $s0, displayAddress

	addi $s0, $s0, 1024 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 8($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 36($s0)

	sw $t0, 44($s0)

	sw $t0, 52($s0)

	sw $t0, 60($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 4 of "Wow"

	lw $s0, displayAddress

	addi $s0, $s0, 1152 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 4($s0)

	sw $t0, 12($s0)

	sw $t0, 24($s0)

	sw $t0, 28($s0)

	sw $t0, 32($s0)

	sw $t0, 36($s0)

	sw $t0, 48($s0)

	sw $t0, 56($s0)

	sw $t0, 68($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	jr $ra

   	

EraseWow:

	lw $t0, background

	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 1 of "Wow"

	lw $s0, displayAddress

	addi $s0, $s0, 768 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 28($s0)

	sw $t0, 32($s0)

	sw $t0, 36($s0)

	sw $t0, 44($s0)

	sw $t0, 60($s0)

	sw $t0, 68($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 2 of "Wow"

	lw $s0, displayAddress

	addi $s0, $s0, 896 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 36($s0)

	sw $t0, 44($s0)

	sw $t0, 60($s0)

	sw $t0, 68($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 3 of "Wow"

	lw $s0, displayAddress

	addi $s0, $s0, 1024 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 8($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 36($s0)

	sw $t0, 44($s0)

	sw $t0, 52($s0)

	sw $t0, 60($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 4 of "Wow"

	lw $s0, displayAddress

	addi $s0, $s0, 1152 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 4($s0)

	sw $t0, 12($s0)

	sw $t0, 24($s0)

	sw $t0, 28($s0)

	sw $t0, 32($s0)

	sw $t0, 36($s0)

	sw $t0, 48($s0)

	sw $t0, 56($s0)

	sw $t0, 68($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	jr $ra

   	

EraseNice:

	lw $t0, background

	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 1 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 768 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 36($s0)

	sw $t0, 40($s0)

	sw $t0, 44($s0)

	sw $t0, 52($s0)

	sw $t0, 56($s0)

	sw $t0, 60($s0)

	sw $t0, 64($s0)

	sw $t0, 72($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 2 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 896 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 4($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 52($s0)

	sw $t0, 72($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 3 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 1024 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 8($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 52($s0)

	sw $t0, 56($s0)

	sw $t0, 72($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 4 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 1152 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 12($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 52($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 5 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 1280 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 36($s0)

	sw $t0, 40($s0)

	sw $t0, 44($s0)

	sw $t0, 52($s0)

	sw $t0, 56($s0)

	sw $t0, 60($s0)

	sw $t0, 64($s0)

	sw $t0, 72($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	jr $ra

   	
Nice:

	lw $t0, ScoreColor

	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 1 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 768 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 36($s0)

	sw $t0, 40($s0)

	sw $t0, 44($s0)

	sw $t0, 52($s0)

	sw $t0, 56($s0)

	sw $t0, 60($s0)

	sw $t0, 64($s0)

	sw $t0, 72($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 2 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 896 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 4($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 52($s0)

	sw $t0, 72($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 3 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 1024 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 8($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 52($s0)

	sw $t0, 56($s0)

	sw $t0, 72($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 4 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 1152 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 12($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 52($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

	#Stack

   	addi $sp, $sp, -4

    	sw $s0, 0($sp)

    	#---------------#

	#Row 5 of "Nice"

	lw $s0, displayAddress

	addi $s0, $s0, 1280 # Vertical Distance

	addi $s0, $s0, 28 # Horizontal Distance

	sw $t0, 0($s0)

	sw $t0, 16($s0)

	sw $t0, 24($s0)

	sw $t0, 32($s0)

	sw $t0, 36($s0)

	sw $t0, 40($s0)

	sw $t0, 44($s0)

	sw $t0, 52($s0)

	sw $t0, 56($s0)

	sw $t0, 60($s0)

	sw $t0, 64($s0)

	sw $t0, 72($s0)

    	#Stack Free

    	lw $s0, 0($sp)

    	addi $sp, $sp, 4

   	#---------------#

   	jr $ra


Exit:

    jal EraseNumbers

    jal GameOver

    jal NumbersEND

    li $v0, 10 # terminate the program gracefully

    syscall

