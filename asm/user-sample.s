.set noreorder
.set noat
.globl __start
.section text

__start:
.text
    ori $t0, $zero, 0x2
    ori $t1, $zero, 0x1
    ori $t3, $zero, 0x100
    ori $t4, $zero, 100
    lui $a0, 0x8040
loop:
    addu $t1, $t1, $t0
    bne  $t0, $t3, loop
    addiu $t0, $t0, 0x1
    sw $t0, 0($a0)
    sw $t1, 4($a0)
    jr $ra
    ori $zero, $zero, 0

//     ori $t0, $zero, 0x1   # t0 = 1
//     ori $t1, $zero, 0x1   # t1 = 1
//     xor $v0, $v0,   $v0   # v0 = 0
//     ori $v1, $zero, 8     # v1 = 8
//     lui $a0, 0x8040       # a0 = 0x80400000
// loop:
//     addu  $t2, $t0, $t1   # t2 = t0+t1
//     ori   $t0, $t1, 0x0   # t0 = t1
//     ori   $t1, $t2, 0x0   # t1 = t2
//     sw    $t1, 0($a0)
//     addiu $a0, $a0, 4     # a0 += 4
//     addiu $v0, $v0, 1     # v0 += 1
//     bne   $v0, $v1, loop
//     ori   $zero, $zero, 0 # nop
//     jr    $ra
//     ori   $zero, $zero, 0 # nop
