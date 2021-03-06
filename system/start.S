/* Xinu for STM32
 *
 * Original license applies
 * Modifications for STM32 by Robin Krens
 * Please see LICENSE and AUTHORS 
 * 
 * $LOG$
 * 2019/11/11 - ROBIN KRENS
 * Initial version 
 * 
 * $DESCRIPTION$
 *
 * */

/* start.S - start, bzero */

#include <cortexm3.h>

/*------------------------------------------------------------------------
 * start  -  Initial entry point for a Xinu image (ARM Cortex-M3)
 *------------------------------------------------------------------------
 */
	.text
	.equ STACK_TOP, MAXADDR /* 64kB SRAM Top */
	.globl start	/* entry point */
	.globl reset		
	.code 16
	.syntax unified
start:
	/* Load the stack pointer with end of memory */
	.word STACK_TOP, reset
	.type reset, function

reset:
	/* Disable interrupts */
	cpsid	i

	/* Use bzero (below) to zero out the BSS area */
	ldr	r0, =edata
	ldr	r1, =end
	bl	bzero 
	
	/* Since the OS is directly running from flash */
	/* we need to load the .data segment in SRAM */
	/* See nulluser (initialize.c) */

	/* Call nulluser to initialize the Xinu system  */
	/*    (Note: the call never returns)		*/

	b	nulluser

/* Function to zero memory (r0 is lowest addr; r1 is highest)	*/

bzero:
	mov	r2, #0			/* Round address to multiple	*/
	add	r0, r0, #3		/*   of four by adding 3 and	*/
	and	r0, r0, #0xFFFFFFFC	/*   taking the result module 4	*/
bloop:	cmp	r0, r1			/* Loop until last address	*/
	bhs	bexit			/*   has been reached		*/
	str	r2, [r0]		/* Zero four-byte word of memory*/
	add	r0, r0, #4		/* Move to next word		*/
	b	bloop			/* Continue to iterate		*/
bexit:	mov	pc, lr			/* Return to caller		*/
	
	.end
