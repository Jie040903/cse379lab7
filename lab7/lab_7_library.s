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


U0FR: 	.equ 0x18	; UART0 Flag Register

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
	MOV r7, #0x2400
	MOVT r7, #0xF4
	STR r7, [r3, #0x028]

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


	.end







