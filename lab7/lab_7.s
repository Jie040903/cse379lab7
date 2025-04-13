	.data

	.global prompt
	.global end_game_score
	.global pause
	.global user1_win_string
	.global user2_win_string
	.global keep_play_or_end
	.global play_or_end
	.global game_board_Gray
	.global game_pause_text
	.global mydata
	.global game_board_White
	.global game_board_black
	.global game_board_blue
	.global game_board_red
	.global game_board_move
	.global cursor_Line
	.global cursor_Column
	.global game_board_line
	.global play1_p_size
	.global play2_p_size
	.global ball_start_place
	.global player1_score_place
	.global player2_score_place
	.global timer_place
	.global timer_text
	.global timer_number
	.global player1_number
	.global player2_number
	.global text_White
	.global ball_up_down
	.global ball_up_down_speed
	.global ball_R_L
	.global ball_R_L_speed


prompt: .string "Your prompt with instructions is place here", 0
game_pause_text: .string "The game is now paused...", 0
user1_win_string: .string "Player 1 won.",0
user2_win_string: .string "Player 2 won.",0
keep_play_or_end: .string "Push 1 to keep playing or 2 to end the game", 0
game_board_Gray: .string 27, "[100m ", 0
game_board_White: .string 27, "[47m ", 0
text_White: .string 27, "[37m", 0
game_board_black: .string 27, "[40m ", 0
game_board_blue: .string 27, "[44m ", 0
game_board_red: .string 27, "[41m ", 0
game_board_move: .string 27, "[", 0					; after game_board_move, user output character for the amount of space want to move
													; output character "A" for up
													; output character "B" for down
													; output character "C" for right
													; output character "D" for down
ball_start_place: .string 27, "[15;40H", 0
player1_score_place: .string 27, "[2;2H", 0
player2_score_place: .string 27, "[2;74H", 0
timer_place: .string 27, "[2;32H", 0
timer_text: .string "Time: ", 0
timer_number: .string "0", 0
player1_number: .string "0", 0
player2_number: .string "0", 0



end_game_score: .byte	0x20		; the score the user want to end the game :
									; if it is 2 = sw2 is push and so on
pause:	.byte	0x21				; 0x21 = see if game is pause, if it 1, 0 it not
play_or_end: .byte 0x24				; 1 = keep playing, 2 = end the game
mydata: .byte 0x25					; w,s or up down
cursor_Line: .byte 0x01				; the line cursor is at
cursor_Column: .byte 0x01			; the Column cursor is at
play1_p_size: .byte 0x04			; the size of player1 penalties size
play2_p_size: .byte 0x04			; the size of player2 penalties size
ball_up_down: .byte 0x00			; if 0x00, ball moves up
									; 0x01, ball moves down
ball_up_down_speed: .byte 0x01		; the amount of space the ball move up or down
ball_R_L: .byte 0x00				; if 0x00, ball moves right
									; 0x01, ball moves left
ball_R_L_speed: .byte 0x00		; the amount of space the ball move right or left


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
ptr_to_game_pause_text:	.word game_pause_text
ptr_to_user1_win_string:		.word user1_win_string
ptr_to_user2_win_string:		.word user2_win_string
ptr_to_keep_play_or_end:		.word keep_play_or_end
ptr_to_play_or_end:		.word play_or_end
ptr_to_game_board_Gray:		.word game_board_Gray
ptr_to_mydata:		.word mydata
ptr_to_game_board_White: .word game_board_White
ptr_to_game_board_black: .word game_board_black
ptr_to_game_board_blue: .word game_board_blue
ptr_to_game_board_red: .word game_board_red
ptr_to_game_board_move: .word game_board_move
ptr_to_cursor_Column: .word cursor_Column
ptr_to_cursor_Line: .word cursor_Line
ptr_to_play1_p_size: .word play1_p_size
ptr_to_play2_p_size: .word play2_p_size
ptr_to_ball_start_place: .word ball_start_place
ptr_to_player1_score_place: .word  player1_score_place
ptr_to_player2_score_place: .word  player2_score_place
ptr_to_timer_place: .word  timer_place
ptr_to_timer_text: .word  timer_text
ptr_to_timer_number: .word  timer_number
ptr_to_player1_number: .word  player1_number
ptr_to_player2_number: .word  player2_number
ptr_to_text_White: .word text_White
ptr_to_ball_up_down: .word ball_up_down
ptr_to_ball_up_down_speed: .word ball_up_down_speed
ptr_to_ball_R_L: .word ball_R_L
ptr_to_ball_R_L_speed: .word ball_R_L_speed


lab7:				; This is your main routine which is called from
				; your C wrapper.
	PUSH {r4-r12,lr}   	; Preserve registers to adhere to the AAPCS

 	bl uart_init

	LDR r0, ptr_to_game_board_Gray
	BL output_string
	MOV r0, #0x0c
	BL output_character

	LDR r0, ptr_to_game_board_move
	BL output_string

	MOV r0, #0x31
	Bl output_character

	MOV r0, #0x42
	Bl output_character

	LDR r0, ptr_to_game_board_move
	BL output_string

	MOV r0, #0x31
	Bl output_character

	MOV r0, #0x42
	Bl output_character

	LDR r0, ptr_to_cursor_Column
	LDRB r1, [r0]
 	ADD r2, r2, #1
 	STRB r2, [r1]


white_loop:
	LDR r4, ptr_to_cursor_Line
 	LDRB r5, [r4]
 	ADD r5, r5, #1
	STRB r5, [r4]

	CMP r5, #81
	BEQ white_done


	LDR r0, ptr_to_game_board_White
	BL output_string

	B white_loop

white_done:
	LDR r0, ptr_to_cursor_Line
 	MOV r2, #0
 	STRB r2, [r0]

 	MOV r0, #0x0D
 	Bl output_character

 	LDR r0, ptr_to_game_board_move
	BL output_string

	MOV r0, #0x31
	Bl output_character

	MOV r0, #0x42
	Bl output_character

	LDR r0, ptr_to_cursor_Column
	LDRB r2, [r0]
 	ADD r2, r2, #1
 	STRB r2, [r0]

black_loop:
	LDR r0, ptr_to_cursor_Line
 	LDRB r4, [r0]
	ADD r4, r4, #1
	STRB r4, [r0]

	LDR r0, ptr_to_game_board_black
	BL output_string

	LDR r0, ptr_to_cursor_Line
 	LDRB r4, [r0]

	CMP r4, #79
	BEQ black_down_loop

	B black_loop

black_down_loop:

	LDR r0, ptr_to_cursor_Column
 	LDRB r2, [r0]

	CMP r2, #26
	BEQ White2

	B white_done


White2:
	MOV r0, #0x0D
 	Bl output_character

 	LDR r0, ptr_to_game_board_move
	BL output_string

	MOV r0, #0x31
	Bl output_character

	MOV r0, #0x42
	Bl output_character

	LDR r0, ptr_to_cursor_Column
	LDRB r2, [r0]
 	ADD r2, r2, #1
 	STRB r2, [r0]

 	LDR r4, ptr_to_cursor_Line
 	MOV r5, #1
 	STRB r5, [r4]

White2_part2:
	LDR r4, ptr_to_cursor_Line
 	LDRB r5, [r4]
 	ADD r5, r5, #1
	STRB r5, [r4]

	CMP r5, #81
	BEQ playerP

	LDR r0, ptr_to_game_board_White
	BL output_string

	B White2_part2

playerP:
	MOV r0, #0x0D
 	Bl output_character

 	LDR r0, ptr_to_game_board_move
	BL output_string

	MOV r0, #0x31
	Bl output_character
	MOV r0, #0x34
	Bl output_character
	MOV r0, #0x41
	Bl output_character

playerer_p_print:
	LDR r0, ptr_to_play1_p_size
	LDRB r0, [r0]
	CMP r0, #0
	BEQ draw_ball

	LDR r0, ptr_to_game_board_White
	BL output_string

	LDR r0, ptr_to_game_board_move
	BL output_string
	MOV r0, #0x37
	Bl output_character
	MOV r0, #0x37
	Bl output_character
	MOV r0, #0x43
	Bl output_character

	LDR r0, ptr_to_game_board_blue
	BL output_string

	LDR r0, ptr_to_game_board_move
	BL output_string

	MOV r0, #0x31
	Bl output_character

	MOV r0, #0x42
	Bl output_character

	MOV r0, #0x0D
 	Bl output_character

	;decrease play1 size by 1
	LDR r0, ptr_to_play1_p_size
	LDRB r1, [r0]
	SUB r1, r1, #1
	STRB r1, [r0]
	B playerer_p_print

draw_ball:
	LDR r0, ptr_to_play1_p_size
	MOV r1, #4
	STRB r1, [r0]

	LDR r0, ptr_to_player1_score_place
	BL output_string

	LDR r0, ptr_to_game_board_Gray
	BL output_string

	LDR r0, ptr_to_text_White
	BL output_string

	LDR r0, ptr_to_player1_number
	BL output_string

	LDR r0, ptr_to_player2_score_place
	BL output_string

	LDR r0, ptr_to_player2_number
	BL output_string

	LDR r0, ptr_to_timer_place
	BL output_string

	LDR r0, ptr_to_timer_text
	BL output_string

	LDR r0, ptr_to_timer_number
	BL output_string

	LDR r0, ptr_to_ball_start_place
	BL output_string

	LDR r0, ptr_to_game_board_red
	BL output_string

	LDR r0, ptr_to_cursor_Column
 	MOV r2, #14
 	STRB r2, [r0]

	LDR r4, ptr_to_cursor_Line
 	LDRB r5, [r4]
 	MOV r5, #40
	STRB r5, [r4]

	BL timer_interrupt_init

play_game:
	LDR r4, ptr_to_end_game_score
	LDRB r4, [r4]		; r4 is the ending score

	LDR r5, ptr_to_player1_number
	LDRB r5, [r5]		; r5 is user1 score

	LDR r6, ptr_to_player2_number
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
	STRB r5, [r4]
	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return

sw3:
	;save a 3 in end_game_score
	LDR r4, ptr_to_end_game_score
	MOV r5, #3
	STRB r5, [r4]
	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return

sw4:
	;save a 4 in end_game_score
	LDR r4, ptr_to_end_game_score
	MOV r5, #4
	STRB r5, [r4]
	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return

sw5:
	;save a 2 in end_game_score
	LDR r4, ptr_to_end_game_score
	MOV r5, #5
	STRB r5, [r4]
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

	LDR r0, ptr_to_game_pause_text
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
	LDR r4, ptr_to_mydata	; store  w  in mydata
	MOV r5, #0x77
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr

is_a:
	LDR r4, ptr_to_mydata	; store  a  in mydata
	MOV r5, #0x61
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr

is_s:
	LDR r4, ptr_to_mydata	; store  s  in mydata
	MOV r5, #0x73
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr

is_d:
	LDR r4, ptr_to_mydata	; store  d  in mydata
	MOV r5, #0x64
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr

Timer_Handler:
	PUSH {r4-r12,lr}	; Spill registers to stack
	MOV r4, #0x0000
	MOVT r4, #0x4003

	LDRB r5, [r4, #0x024]
	ORR r5, r5, #1		; 0001
	STRB r5, [r4, #0x024]

	;THE SPACE OF ball now is black
	LDR r0, ptr_to_game_board_move
	BL output_string

	MOV r0, #0x31
	Bl output_character

	MOV r0, #0x44
	Bl output_character

	LDR r0, ptr_to_game_board_black
	BL output_string

	LDR r0, ptr_to_ball_up_down
	LDRB r1, [r0]

	LDR r0, ptr_to_ball_up_down_speed
	LDRB r2, [r0]

	CMP r2, #0
	BEQ see_ball_move_RL

	CMP r1, #0x00
	BNE ball_down

	; move the ball up
	LDR r0, ptr_to_game_board_move
	BL output_string

	ADD r2, r2, #0x30
	MOV r0, r2
	Bl output_character

	MOV r0, #0x41
	Bl output_character

	LDR r0, ptr_to_cursor_Column
	LDRB r1, [r0]
 	SUB r1, r1, #1
 	STRB r1, [r0]

 	CMP r1, #3 ; changed from r2 to r1
 	BNE see_ball_move_RL

 	; if column is 3, move ball down
 	LDR r0, ptr_to_ball_up_down
	LDRB r1, [r0]
	ADD r1, r1, #1
	STRB r1, [r0]
	B see_ball_move_RL

ball_down:
	LDR r0, ptr_to_game_board_move
	BL output_string

	ADD r2, r2, #0x30
	MOV r0, r2
	Bl output_character

	MOV r0, #0x42
	Bl output_character

	LDR r0, ptr_to_cursor_Column
	LDRB r1, [r0]
 	ADD r1, r1, #1
 	STRB r1, [r0]

 	CMP r1, #22
 	BNE see_ball_move_RL

 	; if column is 25, move ball up
 	LDR r0, ptr_to_ball_up_down
	LDRB r1, [r0]
	SUB r1, r1, #1
	STRB r1, [r0]

see_ball_move_RL:
	LDR r0, ptr_to_ball_R_L
	LDRB r0, [r0]
	LDRB r1, [r0]

	LDR r0, ptr_to_ball_R_L_speed
	LDRB r0, [r0]
	LDRB r2, [r0]

	CMP r2, #0
	BEQ ball_moving_done

	CMP r1, #0x00
	BNE ball_left

	; move the ball right
	LDR r0, ptr_to_game_board_move
	BL output_string

	ADD r2, r2, #0x30
	MOV r0, r2
	Bl output_character

	MOV r0, #0x43
	Bl output_character

	LDR r4, ptr_to_cursor_Line
 	LDRB r5, [r4]
 	ADD r5, r5, #1
	STRB r5, [r4]

	B ball_moving_done
ball_left:
	LDR r0, ptr_to_game_board_move
	BL output_string

	ADD r2, r2, #0x30
	MOV r0, r2
	Bl output_character

	MOV r0, #0x44
	Bl output_character

	LDR r4, ptr_to_cursor_Line
 	LDRB r5, [r4]
 	SUB r5, r5, #1
	STRB r5, [r4]

ball_moving_done:
	; draw ball on new space
	LDR r0, ptr_to_game_board_move
	BL output_string

	MOV r0, #0x31
	Bl output_character

	MOV r0, #0x44
	Bl output_character

	LDR r0, ptr_to_game_board_red
	BL output_string

	POP {r4-r12,lr}  	; Restore registers from stack
	BX lr       	; Return
end_game:
	.end
