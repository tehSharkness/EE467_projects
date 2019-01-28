vhdl "ROM_form.vhd", "prog_rom.vhd", "prog_rom"
; ***************************************************************
; **                                                            *
; ** Using Starter Code from Xilinx, written by Ken Chapman     *
; **															*
; ***************************************************************


LCD_output_port     EQU       	$01                   ; LCD character module output data and control
RAM_data_present_input_port	EQU	$20			; RAM data is present when high
RAM_input_port	    EQU		$10					; input from the NEWSC buttons
LCD_EN              EQU       	$01                   ; active High Enable        E - bit0
LCD_RW              EQU       	$02                   ; Read=1 Write=0           RW - bit1
LCD_RS              EQU       	$04                   ; Instruction=0 Data=1     RS - bit2
LCD_DB4             EQU       	$10                  ; 4-bit              Data DB4 - bit4
LCD_DB5             EQU       	$20                  ; interface          Data DB5 - bit5
LCD_DB6             EQU       	$40                  ; Data DB6 - bit6
LCD_DB7             EQU       	$80                 ; Data DB7 - bit7

; *********************************************
; Useful data constants TAKEN FROM STARTER KIT*
; *********************************************
; The main operation of the program uses 1ms delays to set the shift rate
; of the LCD display. A 16-bit value determines how many milliseconds
; there are between shifts
; 
; Tests indicate that the fastest shift rate that the LCD display supports is
; 500ms. Faster than this and the display becomes less clear to read.
; 
shift_delay_msb     EQU       $01                   ; delay is 500ms (01F4 hex)
shift_delay_lsb     EQU       $F4

; Constant to define a software delay of 1us. This must be adjusted to reflect the
; clock applied to KCPSM3. Every instruction executes in 2 clock cycles making the
; calculation highly predictable. The '6' in the following equation even allows for
; 'CALL delay_1us' instruction in the initiating code.
; delay_1us_constant =  (clock_rate - 6)/4       Where 'clock_rate' is in MHz
; Example: For a 50MHz clock the constant value is (10-6)/4 = 11  (0B Hex).
; For clock rates below 10MHz the value of 1 must be used and the operation will
; become lower than intended.
; 
delay_1us_constant  EQU       $1B

; ************
; ASCII table*
; ************
character_a         EQU       $61
character_b         EQU       $62
character_c         EQU       $63
character_d         EQU       $64
character_e         EQU       $65
character_f         EQU       $66
character_g         EQU       $67
character_h         EQU       $68
character_i         EQU       $69
character_j         EQU       $6A
character_k         EQU       $6B
character_l         EQU       $6C
character_m         EQU       $6D
character_n         EQU       $6E
character_o         EQU       $6F
character_p         EQU       $70
character_q         EQU       $71
character_r         EQU       $72
character_s         EQU       $73
character_t         EQU       $74
character_u         EQU       $75
character_v         EQU       $76
character_w         EQU       $77
character_x         EQU       $78
character_y         EQU       $79
character_z         EQU       $7A
character_Aa        EQU       $41
character_Bb        EQU       $42
character_Cc        EQU       $43
character_Dd        EQU       $44
character_Ee        EQU       $45
character_Ff        EQU       $46
character_Gg        EQU       $47
character_Hh        EQU       $48
character_Ii        EQU       $49
character_Jj        EQU       $4A
character_Kk        EQU       $4B
character_Ll        EQU       $4C
character_Mm        EQU       $4D
character_Nn        EQU       $4E
character_Oo        EQU       $4F
character_Pp        EQU       $50
character_Qq        EQU		  $51
character_Rr        EQU       $52
character_Ss        EQU       $53
character_Tt        EQU       $54
character_Uu        EQU       $55
character_Vv        EQU       $56
character_Ww        EQU       $57
character_Xx        EQU       $58
character_Yy        EQU       $59
character_Zz        EQU       $5A
character_0         EQU       $30
character_1         EQU       $31
character_2         EQU       $32
character_3         EQU       $33
character_4         EQU       $34
character_5         EQU       $35
character_6         EQU       $36
character_7         EQU       $37
character_8         EQU       $38
character_9         EQU       $39
character_colon     EQU       $3A
character_tick      EQU       $27
character_stop      EQU       $2E
character_semi_colon EQU      $3B
character_minus     EQU       $2D
character_divide    EQU       $2F                 ; '/'
character_plus      EQU       $2B
character_comma     EQU       $2C
character_less_than EQU       $3C
character_greater_than EQU    $3E
character_equals    EQU       $3D
character_space     EQU       $20
character_CR        EQU       $0D                  ; carriage return
character_question  EQU       $3F                  ; '?'
character_dollar    EQU       $24
character_exclaim   EQU       $21                  ; '!'
character_BS        EQU       $08                   ; Back Space command character
; 

; **********************
; Initialize the system*
; **********************

init:               CALL      LCD_reset           ; initialise LCD display
                    DINT      INTERRUPT
					
; *************
; Main program*
; *************
main: 
                    CALL      check_data_present       ; constantly , check buttons
                    JUMP      main



check_data_present: 

                    IN        s0, RAM_data_present_input_port
                    LOAD      s1, $01
                    SUB       s1, s0
                    JUMP      Z, read_RAM
                    
                    RET
                    
read_RAM:

		IN	s5, RAM_input_port
		CALL	LCD_write_data
		CALL	delay_500ms
		RET


; **********************************
; Software delay routines          *
; Taken From Xilinx S3E Starter Kit*
; **********************************
delay_1us:          LOAD      s0, delay_1us_constant
wait_1us:           SUB       s0, $01
                    JUMP      NZ, wait_1us
                    RET       
; 
; Delay of 40us.
; 
; Registers used s0, s1
; 
delay_40us:         LOAD      s1, $28              ; 40 x 1us = 40us
wait_40us:          CALL      delay_1us
                    SUB       s1, $01
                    JUMP      NZ, wait_40us
                    RET       
; 
; 
; Delay of 1ms.
; 
; Registers used s0, s1, s2
; 
delay_1ms:          LOAD      s2, $19              ; 25 x 40us = 1ms
wait_1ms:           CALL      delay_40us
                    SUB       s2, $01
                    JUMP      NZ, wait_1ms
                    RET       
; 
; Delay of 20ms.
; 
; Delay of 20ms used during initialisation.
; 
; Registers used s0, s1, s2, s3
; 
delay_20ms:         LOAD      s3, $14                ; 20 x 1ms = 20ms
wait_20ms:          CALL      delay_1ms
                    SUB       s3, $01
                    JUMP      NZ, wait_20ms
                    RET
					
;
; Delay of approximately 500ms.
;
; Registers used s0, s1, s2, s3, s4
;
delay_500ms:        LOAD      s4, $19              ; 25 x 20ms = 500ms
wait_500ms:         CALL      delay_20ms
                    SUB       s4, $01
                    JUMP      NZ, wait_500ms
                  	RET
					   
; 
; Delay of approximately 1 second.
; 
; Registers used s0, s1, s2, s3, s4
; 
delay_1s:           LOAD      s4, $32              ; 50 x 20ms = 1000ms
wait_1s:            CALL      delay_20ms
                    SUB       s4, $01
                    JUMP      NZ, wait_1s
                    RET       


; **************************************************************************************
; LCD Character Module Routines
; **************************************************************************************
; Pulse LCD enable signal 'E' high for greater than 230ns (1us is used).
; 
; Register s4 should define the current state of the LCD output port.
; 
; Registers used s0, s4
; Taken From Xilinx S3E Starter Kit
LCD_pulse_E:        XOR       s4, LCD_EN           ; E=1
                    OUT       s4, LCD_output_port
                    CALL      delay_1us
                    XOR       s4, LCD_EN           ; E=0
                    OUT       s4, LCD_output_port
                    RET       





; Write 4-bit instruction to LCD display.
LCD_write_inst4:    AND       s4, $F8             ; Enable=1 RS=0 Instruction, RW=0 Write, E=0
                    OUT       s4, LCD_output_port ; set up RS and RW >40ns before enable pulse
                    CALL      LCD_pulse_E
                    RET       
; 
; 
; Write 8-bit instruction to LCD display.
; 
; The 8-bit instruction should be provided in register s5.
; Instructions are written using the following sequence
LCD_write_inst8:    LOAD      s4, s5
                    AND       s4, $F0             ; Enable=0 RS=0 Instruction, RW=0 Write, E=0
                    CALL      LCD_write_inst4     ; write upper nibble
                    CALL      delay_1us           ; wait >1us
                    LOAD      s4, s5              ; select lower nibble with
                    SL1       s4                  ; Enable=1
                    SL0       s4                  ; RS=0 Instruction
                    SL0       s4                  ; RW=0 Write
                    SL0       s4                  ; E=0
                    CALL      LCD_write_inst4     ; write lower nibble
                    CALL      delay_40us          ; wait >40us
                    LOAD      s4, $F0             ; Enable=0 RS=0 Instruction, RW=0 Write, E=0
                    OUT       s4, LCD_output_port ; Release master enable
                    RET       


; Write 8-bit data to LCD display.
LCD_write_data:     LOAD      s4, s5
                    AND       s4, $F0             ; Enable=0 RS=0 Instruction, RW=0 Write, E=0
                    OR        s4, $0C              ; Enable=1 RS=1 Data, RW=0 Write, E=0
                    OUT       s4, LCD_output_port ; set up RS and RW >40ns before enable pulse
                    CALL      LCD_pulse_E         ; write upper nibble
                    CALL      delay_1us           ; wait >1us
                    LOAD      s4, s5              ; Load again and shift up lower nibble to write
                    SL1       s4                  ; Enable=1
                    SL1       s4                  ; RS=1 Data
                    SL0       s4                  ; RW=0 Write
                    SL0       s4                  ; E=0
                    OUT       s4, LCD_output_port ; set up RS and RW >40ns before enable pulse
                    CALL      LCD_pulse_E         ; write lower nibble
                    CALL      delay_40us          ; wait >40us
                    LOAD      s4, $F0             ; Enable=0 RS=0 Instruction, RW=0 Write, E=0
                    OUT       s4, LCD_output_port ; Release master enable
                    RET       


LCD_reset:          CALL      delay_20ms          ; wait more that 15ms for display to be ready
                    LOAD      s4, $30

; following lines taken from S3 starter kit
                    CALL      LCD_write_inst4     ; send '3'
                    CALL      delay_20ms          ; wait >4.1ms
                    CALL      LCD_write_inst4     ; send '3'
                    CALL      delay_1ms           ; wait >100us
                    CALL      LCD_write_inst4     ; send '3'
                    CALL      delay_40us          ; wait >40us
                    LOAD      s4, $20
                    CALL      LCD_write_inst4     ; send '2'
                    CALL      delay_40us          ; wait >40us

; following code mine
                    LOAD      s5, $28              ; 28 = '001 DL NFXX' Function set, DL='0' 4-bit mode, N='1' 2-line mode, F='0' 5x11 dot matrix, 'xx' don't care
                    CALL      LCD_write_inst8
                    LOAD      s5, $0F              ; 0F = '0000 1DCB' Display control, D='1' display on, C='1' cursor on, B='1' cursor blink on
                    CALL      LCD_write_inst8
                    LOAD      s5, $06               ; 06 = '0000 0 1 I/D SH' Entry Mode Set, I/D='1' Move Cursor Right, SH='0' Shift off
                    CALL      LCD_write_inst8


LCD_clear:          LOAD      s5, $01                 ; 01 = '0000 0001' Display clear
                    CALL      LCD_write_inst8
                    CALL      delay_1ms           ; wait >1.64ms for display to clear
                    CALL      delay_1ms
                    RET       


; Character position
; 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
; 
; Line 1 - 80 81 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F
; Line 2 - C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 CA CB CC CD CE CF
