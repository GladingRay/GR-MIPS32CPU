.set noreorder
.set noat
.globl __start
.section text
#define swap_if_lt(a,b) \
    slt  $t0, a   , b    ; \
    beq  $t0, $zero, swapend; \
    nop                   ; \
    xor  b  , b  , a     ; \
    xor  a  , a  , b     ; \
    xor  b  , b  , a     ; \

#define swap(a,b) \
    slt  $t0, a   , b    ; \
    beq  $t0, $zero, swapend1; \
    nop                   ; \
    xor  b  , b  , a     ; \
    xor  a  , a  , b     ; \
    xor  b  , b  , a     ; \

__start:
.text
    ori $v0, $zero, 2999 # people num
    ori $v1, $zero, 9    # epoch num
    ori $t1, $zero, 7    # score num
    lui $a0, 0x8040

    ori $a1, $zero, 0
loop1:
    ori $t0, $zero, 80
    mul $s0, $a1, $t0 
    ori $t6, 0    # sum
    ori $a2, $zero, 0
    
loop2:
    ori $t0, $zero, 8
    mul $s1, $a2, $t0 
    addu $s1, $s0, $s1 
    
process_score:
    
    addu $a3, $a0, $s1
    addiu $t1, $a3, 7
    addiu $t5, $a3, 6
    
loop3:
    lb $t2, 0($a3)
    addiu $t3, $a3, 1
loop4:
    lb $t4, 0($t3)
    swap_if_lt($t2, $t4)

swapend:
    sb $t2, 0($a3)
    sb $t4, 0($t3)
    bne $t3, $t1, loop4
    addiu $t3, $t3, 1

loop3end:
    bne $a3, $t5, loop3
    addiu $a3, $a3, 1
    lb $t2, -2($a3)
    lb $t3, -3($a3)
    lb $t4, -4($a3)
    lb $t5, -5($a3)
    addu $t7, $t2, $t3
    addu $t7, $t7, $t4
    addu $t7, $t7, $t5
    srl  $t7, $t7, 4
    addu $t6, $t6, $t7

loop2end:
    bne $a2, $v1, loop2
    addiu $a2, $a2, 1
    mul $t2, $a2, 4
    lui $t1, 0x8060
    addu $t1, $t1, $t2
    sw $t6, 0($t1)
loop1end:
    bne $a1, $v0, loop1
    addiu $a2, $a2, 1



    lui $a0, 0x8060
    ori $s1, $a0 , 0;
    ori $v1, 2998
    ori $t1, $zero, 4
    mul $v1, $v1, $t1
    addu $v1, $v1, $a0;
    mul $v0, $v0, $t1
    addu $v0, $v0, $a0
sortloop1:

    lw $t1, 0($s2)
    addiu $s3, $s1, 4
sortloop2:
    lw $t2, 0($s3)
    swap($t1, $t2)
swapend1:
    sw $t1, 0($s2)
    sw $t2, 0($s3)
    bne $s3 , $v0, sortloop2
    addiu $s3, $s3, 4
    bne $s1, $v1, sortloop1
    addiu $s1, $s1, 4 

    jr $ra
    ori $zero, $zero, 0
