	.data

	.global ball_color
	.global p1_color
	.global p2_color

ball_color: .byte	0x01
p1_color: .byte	0x02
p2_color: .byte	0x3

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
	.global FPS_goal
	.global game_board_Gray
	.global penalties_txt_space
	.global clear_txt
	.global color_ball
	.global color_p1
	.global color_p2
	.global print_ball
	.global print_p1
	.global print_p2
	.global p1_win_RGB
	.global p2_win_RGB
	.global cursor_Line
	.global cursor_Column
	.global end_game_score
	.global play1_head
	.global play2_head
	.global player1_number
	.global player2_number
	.global timer_number
	.global game_board_move
	.global num_place_hold
	.global play1_p_size
	.global play2_p_size
	.global see_sw2_5_push
	.global LED_winner



ptr_to_FPS_goal: .word FPS_goal
ptr_to_penalties_txt_space: .word penalties_txt_space
ptr_to_game_board_Gray: .word game_board_Gray
ptr_to_cursor_Line: .word cursor_Line
ptr_to_cursor_Column: .word cursor_Column
ptr_to_end_game_score: .word end_game_score
ptr_to_play1_head: .word play1_head
ptr_to_play2_head: .word play2_head
ptr_to_player1_number: .word player1_number
ptr_to_player2_number: .word player2_number
ptr_to_timer_number: .word timer_number
ptr_to_board_move: .word game_board_move
ptr_to_play1_p_size: .word play1_p_size
ptr_to_play2_p_size: .word play2_p_size
ptr_to_num_place_hold: .word num_place_hold
ptr_to_ball_color: .word ball_color
ptr_to_p1_color: .word p1_color
ptr_to_p2_color: .word p2_color
ptr_to_see_sw2_5_push: .word see_sw2_5_push

U0FR: 	.equ 0x18	; UART0 Flag Register

gpio_btn_and_LED_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

    ; Your code is placed here
	; Enable Clock for B, D, and F
	MOV r4, #0xE608
	MOVT r4, #0x400F
	LDRB r5, [r4]
	ORR r5, r5, #0x2A	; 0010 1010
	AND r5, r5, #0x2A
	STRB r5, [r4]

	; Port B
	MOV r4, #0x5000
	MOVT r4, #0x4000

	; Pin Direction
	LDRB r5, [r4, #0x400]
	ORR r5, r5, #0xF	; Enable Pin Direction for port B's 1111
	AND r5, r5, #0xF
	STRB r5, [r4, #0x400]

	; Pin Digital
	LDRB r5, [r4, #0x51C]
	ORR r5, r5, #0xF	; Enable Pin Digital for port B's 1111
	AND r5, r5, #0xF
	STRB r5, [r4, #0x51C]


	; Port D
	MOV r4, #0x7000
	MOVT r4, #0x4000

	; Pin Direction
	LDRB r5, [r4, #0x400]
	ORR r5, r5, #0x0	; Enable Pin Direction for port D's 1111
	AND r5, r5, #0x0
	STRB r5, [r4, #0x400]

	; Pin Digital
	LDRB r5, [r4, #0x51C]
	ORR r5, r5, #0xF	; Enable Pin Digital for port D's 1111
	AND r5, r5, #0xF
	STRB r5, [r4, #0x51C]


	; Port F
	MOV r4, #0x5000
	MOVT r4, #0x4002

	; Pin Direction
	LDRB r5, [r4, #0x400]
	ORR r5, r5, #0xE	; Enable Pin Direction for port F's 0000 1110
	AND r5, r5, #0xE
	STRB r5, [r4, #0x400]

	; Pin Digital
	LDRB r5, [r4, #0x51C]
	ORR r5, r5, #0x1E	; Enable Pin Digital for port F's 0001 1110
	AND r5, r5, #0x1E
	STRB r5, [r4, #0x51C]

	; Pull-Up Resistor
	LDRB r5, [r4, #0x510]
	ORR r5, r5, #0x10	; Enable Pin Digital for port F's 0001 0000
	AND r5, r5, #0x10
	STRB r5, [r4, #0x510]


	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

int2string:
    PUSH {r4-r12, lr}      ; Save registers

    MOV r4, r0             ; r4 = buffer pointer (start)
    MOV r5, #10000
    MOV r11, #0            ; Digit counter (for comma logic)

    ; Handle zero input
    CMP r1, #0
    BNE int2s_loop
    MOV r6, #0x30          ; ASCII '0'
    STRB r6, [r4]          ; Store '0'
    ADD r4, #1             ; Move pointer
    B int2s_done           ; Skip loop for zero

int2s_loop:
    CMP r5, #0
    BEQ int2s_done         ; Exit when no more digits

    UDIV r6, r1, r5        ; r6 = current digit
    CMP r6, #0
    BNE write_digit        ; If digit != 0, write it
    CMP r11, #0            ; If digit == 0, check if we've written anything yet
    BEQ next_place         ; Skip leading zeros

write_digit:
    ADD r8, r6, #0x30      ; Convert to ASCII
    STRB r8, [r4]          ; Store digit
    ADD r4, #1             ; Move pointer
    ADD r11, #1            ; Increment digit count

    MUL r7, r5, r6         ; r7 = digit * place value
    SUB r1, r1, r7         ; Subtract from remaining number

    ; Check if we need a comma (every 3 digits, but not at the end)
    CMP r5, #1             ; Don't add comma if this is the last digit
    BEQ next_place
    MOV r9, r11
    AND r9, r9, #3         ; r9 = r11 % 4 (checks every 3 digits)
    CMP r9, #0             ; If (digit_count % 3 == 0), insert comma
    BNE next_place

    MOV r8, #0x2C          ; ASCII ','
    STRB r8, [r4]          ; Store comma
    ADD r4, #1             ; Move pointer

next_place:
    MOV r10, #10
    UDIV r5, r5, r10       ; Next place value (/10)
    B int2s_loop

int2s_done:
    MOV r7, #0             ; Null terminator
    STRB r7, [r4]
    ; Return original buffer pointer (r0), not r4
    POP {r4-r12, lr}
    MOV pc, lr

timer_interrupt_init:
	PUSH {r4-r12,lr}	; Spill registers to stack
	MOV r1, #0xE000	;connect clock to timer
	MOVT r1, #0x400F
	MOV  r2, #0x1
	LDRB r3, [r1, #0x604]
	ORR r3, r3, r2
	STRB r3, [r1, #0x604]	 ;enable clock

	MOV r3, #0x0000	;configure timer
	MOVT r3, #0x4003	;setup and config occurs when timer is disabled

	MOV r4, #0xFE
	LDRB r5, [r3, #0x00C]
	AND r5, r5, r4
	STRB r5, [r4, #0x00C]

	;general purpose timer configuration register
	MOV r6, #0x8
	LDRB r4, [r3]
	BIC r4, #0x7 ;sets bits 0,1,2 to 1(configuration 0)
	STRB r4, [r3]


	;setting timer in periodic mode
	LDRB r7, [r3, #0x004]
	MOV r8, #0x2		;set bits to enable periodic mode of Timer A mode register
	ORR r7, r7, r8
	STRB r7, [r3, #0x004]

	;setting timer interrupt interval period
	MOV r0, #0x2400		
	MOVT r0, #0xF4
	LDR r1, ptr_to_FPS_goal
	LDRB r1, [r1]
	SDIV r0, r0, r1
	STR r0, [r3, #0x028]

	;setting timer to interrupt processor
	LDRB r8, [r3, #0x018]
	ORR r8, r8, #0x1
	STRB r8, [r3, #0x018]


	;configure processor to allow timer to interrupt processor
	MOV r8, #0xE000
	MOVT r8, #0xE000
	MOV r9, #0xF
	LDR r10, [r8, #0x100]
	BFI r10, r9, #19, #1	;set bit 19 in the interrupt 0-31 set enable register
	STR r10, [r8, #0x100]

	;enable timer
	LDRB r10, [r3, #0x00C]
	ORR r10, r10, #0x1
	STRB r10, [r3, #0x00C]

	POP {r4-r12,lr}
	MOV pc, lr      	; Return

uart_interrupt_init:

	; Your code to initialize the UART0 interrupt goes here
	PUSH {r4-r12,lr}	; Spill registers to stack

	MOV r4, #0xC000
	MOVT r4, #0x4000
	MOV r5, #0x10
	STRB r5, [r4, #0x038]

	MOV r4, #0xE000
	MOVT r4, #0xE000
	MOV r5, #0x20
	STRB r5, [r4, #0x100]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


gpio_interrupt_init:

	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.
	PUSH {r4-r12,lr}	; Spill registers to stack
	; port F
	MOV r4, #0x5000
	MOVT r4, #0x4002
	MOV r5, #0
	STRB r5, [r4, #0x404]

	MOV r5, #0x10			; 0001 0000
	STRB r5, [r4, #0x40C]
	STRB r5, [r4, #0x410]

	MOV r4, #0xE000
	MOVT r4, #0xE000
	LDR r5, [r4, #0x100]
	MOV r6, #0x0000
	MOVT r6, #0x4000
	ORR r5, r5, r6
	STR r5, [r4, #0x100]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


simple_read_character:
	PUSH {r4-r12,lr}

	MOV r6, #0xC000
	MOVT r6, #0x4000	; Load address of U0DR to r6

	LDR r0, [r6]		; Read received byte into r0

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	MOV pc, lr	; Return

uart_init:
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
	MOV r4, #0xE618
	MOVT r4, #0x400F
	MOV r5, #1
	STR r5, [r4]

	MOV r4, #0xE608
	MOVT r4, #0x400F
	MOV r5, #1
	STR r5, [r4]

	MOV r4, #0xC030
	MOVT r4, #0x4000
	MOV r5, #0
	STR r5, [r4]

	MOV r4, #0xC024
	MOVT r4, #0x4000
	MOV r5, #8
	STR r5, [r4]

	MOV r4, #0xC028
	MOVT r4, #0x4000
	MOV r5, #44
	STR r5, [r4]

	MOV r4, #0xCFC8
	MOVT r4, #0x4000
	MOV r5, #0
	STR r5, [r4]

	MOV r4, #0xC02C
	MOVT r4, #0x4000
	MOV r5, #0x60
	STR r5, [r4]

	MOV r4, #0xC030
	MOVT r4, #0x4000
	MOV r5, #0x301
	STR r5, [r4]

	MOV r4, #0x451C
	MOVT r4, #0x4000
	MOV r5, #0x03
	ORR r5, r5, #1
	STR r5, [r4]

	MOV r4, #0x4420
	MOVT r4, #0x4000
	MOV r5, #0x03
	ORR r5, r5, #1
	STR r5, [r4]

	MOV r4, #0x452C
	MOVT r4, #0x4000
	MOV r5, #0x11
	ORR r5, r5, #1
	STR r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

output_character:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
				; that are used in your routine.  Include lr if this
				; routine calls another routine.

		; Your code for your output_character routine is placed here
	MOV r6, #0xC000
	MOVT r6, #0x4000	; Load address of U0DR to r6

Check_Out_Empty:
	LDR r7, [r6, #U0FR]	; read data from U0FR address to r7
	AND r8, r7, #0x20	; And the data with 0010 0000
	CMP r8, #0		; Check if TxFF is 0
	BNE Check_Out_Empty

	STR r0, [r6]		; Store received byte into r6

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	mov pc, lr

read_character:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
				; that are used in your routine.  Include lr if this
				; routine calls another routine.

		; Your code for your read_character routine is placed here
	MOV r6, #0xC000
	MOVT r6, #0x4000	; Load address of U0DR to r6

Check_Read_Empty:
	LDR r7, [r6, #U0FR]	; read data from U0FR address to r7
	AND r8, r7, #0x10	; And the data with 0001 0000
	CMP r8, #0		; Check if RxFE is 0
	BNE Check_Read_Empty

	LDR r0, [r6]		; Read received byte into r0

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	mov pc, lr

read_string:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
				; that are used in your routine.  Include lr if this
				; routine calls another routine.

		; Your code for your read_string routine is placed here
	MOV r4, r0		; r4 = base address of string buffer
	MOV r5, #0		; Counter for storing characters

read_loop:
	BL read_character    	; Read one character into r0
	CMP r0, #0x0D        	; Check if it's the Enter (\n)
	BEQ end_read         	; If Enter, terminate the string

	BL output_character 	; Echo character back to user (Immediate Feedback)

	STRB r0, [r4, r5]    	; Store character at buffer[r5]
	ADD r5, r5, #1       	; Increment buffer index
	B read_loop          	; Read next character

end_read:
	MOV r0, #0		; state the NULL
	STRB r0, [r4, r5]    	; Store NULL at end of string
	MOV r0, r4		; Base address of the string passed into r0

	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	mov pc, lr

output_string:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
				; that are used in your routine.  Include lr if this
				; routine calls another routine.

		; Your code for your output_string routine is placed here
	MOV r8, r0		; r4 = base address of string buffer

out_loop:
	LDRB r0, [r8]		; Load character
	CMP r0, #0		; Check if character is NULL
	BEQ end_out		; End if it is NULL

	BL output_character	; output is not NULL
	ADD r8, r8, #1		; Move to next character
	B out_loop

end_out:
	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	mov pc, lr

read_from_push_btns:
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
	MOV r4, #0x73FC
	MOVT r4, #0x4000

	LDRB r5, [r4]		; load data from r4's address to r5
	AND r6, r5, #0xF	; AND with 1111
	MOV r0, r6


	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

illuminate_LEDs:
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
	MOV r4, #0x53FC
	MOVT r4, #0x4000


	STRB r0, [r4]		; save data in r0 to r4' address

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

illuminate_RGB_LED:
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here

	MOV r5, #0x53FC 	; to access port F, mask bits
	MOVT r5, #0x4002

	CMP r0, #1
	BEQ red

	CMP r0, #2
	BEQ blue

	CMP r0, #3
	BEQ green

	CMP r0, #4
	BEQ purple

	CMP r0, #5
	BEQ yellow

	CMP r0, #6
	BEQ white

	BEQ none

red:
	MOV r4, #2		; 0010
	STRB r4, [r5]
	B end_illuminate

blue:
	MOV r4, #4		; 0100
	STRB r4, [r5]
	B end_illuminate

green:
	MOV r4, #8		; 1000
	STRB r4, [r5]
	B end_illuminate

purple:
	MOV r4, #6		; 0110
	STRB r4, [r5]
	B end_illuminate


yellow:
	MOV r4, #10		; 1010
	STRB r4, [r5]
	B end_illuminate

white:
	MOV r4, #14		; 1110
	STRB r4, [r5]
	B end_illuminate

none:
	MOV r4, #0		; 0000
	STRB r4, [r5]

end_illuminate:

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


read_tiva_push_button:
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
	MOV r4, #0x53FC
	MOVT r4, #0x4002

	LDRB r5, [r4]		; load data from r4's address to r5
	AND r6, r5, #0x10	; 0001 0000 AND pin 4 with 1
	CMP r6, #0
	BEQ pin4_is_one

	MOV r0, #0
	B read_t_end

pin4_is_one:
	MOV r0, #1

read_t_end:
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

clear_txt:
	PUSH {r4-r12,lr}	; Spill registers to stack
	LDR r0, ptr_to_penalties_txt_space
	BL output_string
	MOV r5, #3
clear_next_line:
	LDR r0, ptr_to_game_board_Gray
	BL output_string
	MOV r4, #80
clear_1_line_text:
	MOV r0, #0x20
	BL output_character
	SUB r4, r4, #1
	CMP r4, #0
	BNE clear_1_line_text
	MOV r0, #0x0A
 	Bl output_character
	MOV r0, #0x0D
 	Bl output_character
 	SUB r5, r5, #1
	CMP r5, #0
	BNE clear_next_line
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

color_ball:
	PUSH {r4-r12,lr}	; Spill registers to stack
						; get a number for ball
	LDR r4, ptr_to_end_game_score
	LDRB r5, [r4]
	MOV r6, #31
	MUL r5, r5, r6				;  r5 = end game score *31
	LDR r4, ptr_to_ball_color
	LDRB r6, [r4]
	ADD r6, #13
	UDIV r5, r5, r6				;  r5 = r5 / (ball color+13)
	LDR r4, ptr_to_timer_number
	LDR r6, [r4]
	MUL r5, r5, r6				; r5 = r5 * timer
	MOV r6, #13
	MUL r5, r5, r6				; r5 = r5 *13

	MOV r7, #6
	UDIV r6, r5, r7
	MUL r6, r6, r7
	SUB r5, r5, r6		; should be from 0 to 5
	
	LDR r4, ptr_to_ball_color		; see if the color is the same as before
	LDRB r7, [r4]					; if yes, change a color
	CMP r7, r5
	IT EQ
	ADDEQ r5, r5, #1
	CMP r5, #6
	IT EQ
	MOVEQ r5, #0

	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

color_p1:
	PUSH {r4-r12,lr}	; Spill registers to stack
	LDR r4, ptr_to_play1_head
	LDRB r5, [r4]
	LDR r4, ptr_to_cursor_Column
	LDRB r6, [r4]
	MUL r5, r5, r6				; r5 = game_play1_head * column
	LDR r4, ptr_to_end_game_score
	LDRB r6, [r4]
	MUL r5, r5, r6				;  r5 = r5 * end game score
	LDR r4, ptr_to_p1_color
	LDRB r6, [r4]
	UDIV r5, r5, r6				;  r5 = r5 / p1 color
	LDR r4, ptr_to_timer_number
	LDR r6, [r4]
	MUL r5, r5, r6				; r5 = r5 * timer
	LDR r4, ptr_to_player1_number
	LDR r6, [r4]
	ADD r5, r5, r6				;r5 = r5 + p1's score
	MOV r6, #23
	MUL r5, r5, r6				; r5 = r5 * 23

	MOV r7, #6
	UDIV r6, r5, r7
	MUL r6, r6, r7
	SUB r5, r5, r6		; should be from 0 to 5
	
	LDR r4, ptr_to_p1_color			; see if the color is the same as before
	LDRB r7, [r4]					; if yes, change a color
	CMP r7, r5
	IT EQ
	ADDEQ r5, r5, #1
	CMP r5, #6
	IT EQ
	MOVEQ r5, #0

	LDR r4, ptr_to_ball_color	; get the ball's color
	LDRB r4, [r4]				; if the color is same as ball
	CMP r5, r4					; change the color
	IT EQ
	ADDEQ r5, r5, #1
	CMP r5, #6
	IT EQ
	MOVEQ r5, #0

	LDR r4, ptr_to_p1_color			; see if the color is the same as before
	LDRB r7, [r4]					; if yes, change a color
	CMP r7, r5
	IT EQ
	ADDEQ r5, r5, #1
	CMP r5, #6
	IT EQ
	MOVEQ r5, #0

	LDR r4, ptr_to_p1_color
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr
color_p2:
	PUSH {r4-r12,lr}	; Spill registers to stack
	LDR r4, ptr_to_play2_head
	LDRB r5, [r4]
	LDR r4, ptr_to_cursor_Column
	LDRB r6, [r4]
	MUL r5, r5, r6				; r5 = game_play2_head * column
	LDR r4, ptr_to_end_game_score
	LDRB r6, [r4]
	MUL r5, r5, r6				;  r5 = r5 * end game score
	LDR r4, ptr_to_p2_color
	LDRB r6, [r4]
	UDIV r5, r5, r6				;  r5 = r5 / p2 color
	LDR r4, ptr_to_timer_number
	LDR r6, [r4]
	MUL r5, r5, r6				; r5 = r5 * timer
	LDR r4, ptr_to_player2_number
	LDR r6, [r4]
	ADD r5, r5, r6				;r5 = r5 + p2's score
	MOV r6, #73
	MUL r5, r5, r6				; r5 = r5 * 73

	MOV r7, #6
	UDIV r6, r5, r7
	MUL r6, r6, r7
	SUB r5, r5, r6		; should be from 0 to 5

	LDR r4, ptr_to_p2_color			; see if the color is the same as before
	LDRB r7, [r4]					; if yes, change a color
	CMP r7, r5
	IT EQ
	ADDEQ r5, r5, #1
	CMP r5, #6
	IT EQ
	MOVEQ r5, #0

	LDR r4, ptr_to_ball_color	; get the ball's color
	LDRB r4, [r4]				; if the color is same as ball
	CMP r5, r4					; change the color
	IT EQ
	ADDEQ r5, r5, #1
	CMP r5, #6
	IT EQ
	MOVEQ r5, #0

	LDR r4, ptr_to_p1_color			; see if the color is the same p1
	LDRB r7, [r4]					; if yes, change a color
	CMP r7, r5
	IT EQ
	ADDEQ r5, r5, #1
	CMP r5, #6
	IT EQ
	MOVEQ r5, #0

	LDR r4, ptr_to_p2_color			; see if the color is the same as before
	LDRB r7, [r4]					; if yes, change a color
	CMP r7, r5
	IT EQ
	ADDEQ r5, r5, #1
	CMP r5, #6
	IT EQ
	MOVEQ r5, #0

	LDR r4, ptr_to_p2_color
	STRB r5, [r4]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

print_ball:
	PUSH {r4-r12,lr}	; Spill registers to stack
	LDR r0, ptr_to_board_move
	BL output_string
	
	MOV r0, #0x34		; output 4
	BL output_character

	LDR r4, ptr_to_ball_color
	LDRB r4, [r4]

	CMP r4, #0
	IT EQ
	MOVEQ r4, #0x07		; make r4 equal to 7 if it is 0

	ADD r0, r4, #0x30
	BL output_character

	MOV r0, #0x6D		; output m
	BL output_character

	MOV r0, #0x20		; output space
	BL output_character

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

print_p1:
	PUSH {r4-r12,lr}	; Spill registers to stack

	; move to the head of player1 P
	LDR r0, ptr_to_board_move
	BL output_string

	LDR r0, ptr_to_num_place_hold
	LDR r1, ptr_to_play1_head
	LDRB r1, [r1]
	BL int2string
	BL output_string

	MOV r0, #0x3B			; 0x3b = ;
	BL output_character
	MOV r0, #0x31			; 0x31 = 1
	BL output_character
	MOV r0, #0x48			; 0x48 = H
	BL output_character
	LDR r4, ptr_to_play1_p_size
	LDRB r5, [r4]
p1_P_drawing:
	; draw the new head
	LDR r0, ptr_to_board_move
	BL output_string
	
	MOV r0, #0x34
	BL output_character

	LDR r4, ptr_to_p1_color
	LDRB r4, [r4]

	CMP r4, #0
	IT EQ
	MOVEQ r4, #0x07		; make r4 equal to 7 if it is 0

	ADD r0, r4, #0x30
	BL output_character

	MOV r0, #0x6D		; output m
	BL output_character
	MOV r0, #0x20		; output space
	BL output_character

	MOV r0, #0x0D
 	BL output_character
 	LDR r0, ptr_to_board_move
	BL output_string
	MOV r0, #0x31
	BL output_character
	MOV r0, #0x42
	BL output_character
	SUB r5, r5, #1
	CMP r5, #0
	BNE p1_P_drawing

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

print_p2:
	PUSH {r4-r12,lr}	; Spill registers to stack

	; move to the head of player2 P
	LDR r0, ptr_to_board_move
	BL output_string

	LDR r0, ptr_to_num_place_hold
	LDR r1, ptr_to_play2_head
	LDRB r1, [r1]
	BL int2string
	BL output_string

	MOV r0, #0x3B			; 0x3b = ;
	BL output_character
	MOV r0, #0x38			; 0x38 = 8
	BL output_character
	MOV r0, #0x30			; 0x30 = 0
	BL output_character
	MOV r0, #0x48			; 0x48 = H
	BL output_character

	LDR r4, ptr_to_play2_p_size
	LDRB r5, [r4]
p2_P_drawing:
	; draw the new head
	LDR r0, ptr_to_board_move
	BL output_string

	MOV r0, #0x34
	BL output_character

	LDR r4, ptr_to_p2_color
	LDRB r4, [r4]

	CMP r4, #0
	IT EQ
	MOVEQ r4, #0x07		; make r4 equal to 7 if it is 0

	ADD r0, r4, #0x30
	BL output_character

	MOV r0, #0x6D		; output m
	BL output_character
	MOV r0, #0x20		; output space
	BL output_character

 	LDR r0, ptr_to_board_move
	BL output_string
	MOV r0, #0x31
	BL output_character
	MOV r0, #0x42
	BL output_character

	 LDR r0, ptr_to_board_move
	BL output_string
	MOV r0, #0x31
	BL output_character
	MOV r0, #0x44
	BL output_character

	SUB r5, r5, #1
	CMP r5, #0
	BNE p2_P_drawing

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

p1_win_RGB:
	PUSH {r4-r12,lr}	; Spill registers to stack
	LDR r4, ptr_to_p1_color
	LDRB r4, [r4]

	CMP r4, #1		; light up red
	IT EQ
	MOVEQ r6, #2	; 0000 0010
	BEQ store_p1_RGB

	CMP r4, #2		; light up green
	IT EQ
	MOVEQ r6, #8	; 0000 1000
	BEQ store_p1_RGB

	CMP r4, #3		; light up yellow
	IT EQ
	MOVEQ r6, #10	; 0000 1010
	BEQ store_p1_RGB

	CMP r4, #4		; light up blue
	IT EQ
	MOVEQ r6, #4	; 0000 0100
	BEQ store_p1_RGB

	CMP r4, #5		; light up purple
	IT EQ
	MOVEQ r6, #6	; 0000 0110
	BEQ store_p1_RGB

	CMP r4, #0		; light up white
	IT EQ
	MOVEQ r6, #14	; 0000 1110
	BEQ store_p1_RGB

store_p1_RGB:
	MOV r5, #0x53FC
	MOVT r5, #0x4002
	STRB r6, [r5]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

p2_win_RGB:
	PUSH {r4-r12,lr}	; Spill registers to stack
	LDR r4, ptr_to_p2_color
	LDRB r4, [r4]

	CMP r4, #1		; light up red
	IT EQ
	MOVEQ r6, #2	; 0000 0010
	BEQ store_p2_RGB

	CMP r4, #2		; light up green
	IT EQ
	MOVEQ r6, #8	; 0000 1000
	BEQ store_p2_RGB

	CMP r4, #3		; light up yellow
	IT EQ
	MOVEQ r6, #10	; 0000 1010
	BEQ store_p2_RGB

	CMP r4, #4		; light up blue
	IT EQ
	MOVEQ r6, #4	; 0000 0100
	BEQ store_p2_RGB

	CMP r4, #5		; light up purple
	IT EQ
	MOVEQ r6, #6	; 0000 0110
	BEQ store_p2_RGB

	CMP r4, #0		; light up white
	IT EQ
	MOVEQ r6, #14	; 0000 1110
	BEQ store_p2_RGB

store_p2_RGB:
	MOV r5, #0x53FC
	MOVT r5, #0x4002
	STRB r6, [r5]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

LED_winner:
	PUSH {r4-r12,lr}	; Spill registers to stack
	MOV r3, #0x53FC		;port B
	MOVT r3, #0x4000

	MOV r4, #1	; 0001
	STRB r4, [r3]

	MOV r5, #0x2400
	MOVT r5, #0x24
keep_1_on:
	SUB r5, r5, #1
	CMP r5, #0
	BNE keep_1_on

	MOV r4, #2	; 0010
	STRB r4, [r3]

	MOV r5, #0x2400
	MOVT r5, #0x24
keep_2_on:
	SUB r5, r5, #1
	CMP r5, #0
	BNE keep_2_on

	MOV r4, #4	; 0100
	STRB r4, [r3]

	MOV r5, #0x2400
	MOVT r5, #0x24
keep_3_on:
	SUB r5, r5, #1
	CMP r5, #0
	BNE keep_3_on

	MOV r4, #8	; 1000
	STRB r4, [r3]

	MOV r5, #0x2400
	MOVT r5, #0x24
keep_4_on:
	SUB r5, r5, #1
	CMP r5, #0
	BNE keep_4_on

	MOV r4, #15	; 1111
	STRB r4, [r3]

	MOV r5, #0x2400
	MOVT r5, #0x24
keep_all_on:
	SUB r5, r5, #1
	CMP r5, #0
	BNE keep_all_on

	MOV r4, #0	; 0000
	STRB r4, [r3]
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

	.end







