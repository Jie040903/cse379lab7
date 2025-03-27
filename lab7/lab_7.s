	.data

	.global prompt
	.global end_game_score
	.global pause
	.global user1_score
	.global user2_score
	.global user1_win_string
	.global user2_win_string
	.global keep_play_or_end
	.global play_or_end

prompt: .string "Your prompt with instructions is place here", 0
game_pause: .string "The game is now paused...", 0
user1_win_srting: .string "Player 1 won.",0
user2_win_srting: .string "Player 2 won.",0
keep_play_or_end: .string "Push 1 to keep playing or 2 to end the game", 0


end_game_score: .byte	0x20		; the score the user want to end the game :
									; if it is 2 = sw2 is push and so on
pause:	.byte	0x21				; 0x21 = see if game is pause, if it 1, 0 it not
user1_score: .byte 0x22				; user1's score
user2_score: .byte 0x23				; user2's score
play_or_end: .byte 0x24				; 1 = keep playing, 2 = end the game


	.text

	.global uart_init
	.global uart_interrupt_init
	.global gpio_interrupt_init
	.global UART0_Handler
	.global Switch_Handler
	.global Timer_Handler
	.global timer_interrupt_init
	.global simple_read_character
	.global gpio_btn_and_LED_init
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global read_from_push_btns
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global read_tiva_push_button
	.global int2string
	.global lab7

ptr_to_prompt:		.word prompt
ptr_to_pause:		.word pause
ptr_to_end_game_score: .word end_game_score
ptr_to_game_pause:	.word game_pause
ptr_to_user1_score:		.word user1_score
ptr_to_user2_score:		.word user2_score
ptr_to_user1_win_string:		.word user1_win_string
ptr_to_user2_win_string:		.word user2_win_string
ptr_to_keep_play_or_end:		.word keep_play_or_end
ptr_to_play_or_end:		.word play_or_end


lab7:				; This is your main routine which is called from
				; your C wrapper.
	PUSH {r4-r12,lr}   	; Preserve registers to adhere to the AAPCS

 	bl uart_init

play_game:
	LDR r4, ptr_to_end_game_score
	LDRB r4, [r4]		; r4 is the ending score

	LDR r5, ptr_to_user1_score
	LDRB r5, [r5]		; r5 is user1 score

	LDR r6, ptr_to_user2_score
	LDRB r6, [r6]		; r6 is user2 score

	CMP r4, r5
	BEQ user1_win

	CMP r4, r6
	BEQ user2_win

	B play_game


user1_win:
	; disable timer
	MOV r3, #0x0000	;configure timer
	MOVT r3, #0x4003	;setup and config occurs when timer is disabled
	LDRB r10, [r3, #0x00C]
	SUB r10, r10, #1
	STRB r10, [r3, #0x00C]

	LDR r0, ptr_to_user1_win_string
	BL output_string

	MOV r0, #0xA
	BL output_character

	MOV r0, #0xD
	BL output_character

	LDR r0, ptr_to_keep_play_or_end
	BL output_string

play1_wait:
	LDR r0, ptr_to_play_or_end
	LDRB r0, [r0]
	CMP r0, #1
	; this branches to lab7 when you restart you can make a sepreate label for restarting if needed
	BEQ lab7
	CMP r0, #2
	BEQ end_game
	B play1_wait

user2_win:
	; disable timer
	MOV r3, #0x0000	;configure timer
	MOVT r3, #0x4003	;setup and config occurs when timer is disabled
	LDRB r10, [r3, #0x00C]
	SUB r10, r10, #1
	STRB r10, [r3, #0x00C]

	LDR r0, ptr_to_user1_win_string
	BL output_string

	MOV r0, #0xA
	BL output_character

	MOV r0, #0xD
	BL output_character

	LDR r0, ptr_to_keep_play_or_end
	BL output_string

play2_wait:
	LDR r0, ptr_to_play_or_end
	LDRB r0, [r0]
	CMP r0, #1
	; this branches to lab7 when you restart you can make a sepreate label for restarting if needed
	BEQ lab7
	CMP r0, #2
	BEQ end_game
	B play2_wait


Switch_Handler:
	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	PUSH {r4-r12,lr}	; Spill registers to stack
	MOV r5, #0x5000
	MOVT r5, #0x4002

	MOV r4, #0x10			; 0001 0000
	STRB r4, [r5, #0X41C]

	; to do: which button did the user push
	MOV r5, #0x53FC 	; to access port F, mask bits
	MOVT r5, #0x4002
	LDRB r4, [r5]		; r4 is 0001 0000 if sw1 is push
	CMP r4, #16
	BEQ game_pause

	BL read_from_push_btns
	CMP r0, #1			; 0001 = sw5 is push
	BEQ sw5
	CMP r0, #2			; 0010 = sw4 is push
	BEQ sw4
	CMP r0, #4			; 0100 = sw3 is push
	BEQ sw3
	CMP r0, #8			; 1000 = sw2 is push
	BEQ sw2

sw2:
	;save a 2 in end_game_score
	LDR r4, ptr_to_end_game_score
	MOV r5, #2
	SRTB r5, [r4]
	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return

sw3:
	;save a 3 in end_game_score
	LDR r4, ptr_to_end_game_score
	MOV r5, #3
	SRTB r5, [r4]
	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return

sw4:
	;save a 4 in end_game_score
	LDR r4, ptr_to_end_game_score
	MOV r5, #4
	SRTB r5, [r4]
	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return

sw5:
	;save a 2 in end_game_score
	LDR r4, ptr_to_end_game_score
	MOV r5, #5
	SRTB r5, [r4]
	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return

game_pause:
	LDR r4, ptr_to_pause
	LDRB r5, [r4]	; get 0x21, the data about game pause
	CMP r5, #0		; if r5 is 0, the game is not pause
	BEQ game_not_pause

	; if the game is pause, restart the game again
	MOV r5, #0
	STRB r5, [r4]

	bl timer_interrupt_init	; start the timer interrupt again

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return

game_not_pause:
	;we need to pause the game now
	ADD r5, r5, #1
	STRB r5, [r4]

	; disable timer
	MOV r3, #0x0000	;configure timer
	MOVT r3, #0x4003	;setup and config occurs when timer is disabled
	LDRB r10, [r3, #0x00C]
	SUB r10, r10, #1
	STRB r10, [r3, #0x00C]

	; tell user the game is now paused
	MOV r0, #0xA
	BL output_character

	MOV r0, #0xD
	BL output_character

	LDR r0, ptr_to_game_pause
	BL output_string

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return
UART0_Handler:

	; Your code for your UART handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	PUSH {r4-r12,lr}	; Spill registers to stack

 	MOV r4, #0xC000
	MOVT r4, #0x4000
	LDRB r5, [r4]
	ORR r5, #0x10
	STRB r5, [r4, #0x044]

	MOV r5, #0x10			; 0001 0000
	STRB r5, [r4, #0x40C]
	STRB r5, [r4, #0x410]

	BL simple_read_character

	CMP r0, #0x77		; see if enter is "w"
	BEQ is_w

	CMP r0, #0x61		; see if enter is "a"
	BEQ is_a

	CMP r0, #0x73		; see if enter is "s"
	BEQ is_s

	CMP r0, #0x64		; see if enter is "d"
	BEQ is_d

	; if input is not wasd, do nothing
	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr

is_w:
	LDR r4, ptr_to_mydata	; store “w” in mydata
	MOV r5, #0x77
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr

is_a:
	LDR r4, ptr_to_mydata	; store “a” in mydata
	MOV r5, #0x61
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr

is_s:
	LDR r4, ptr_to_mydata	; store “s” in mydata
	MOV r5, #0x73
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr

is_d:
	LDR r4, ptr_to_mydata	; store “d” in mydata
	MOV r5, #0x64
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr
end_game:
	.end
