vhdl "ROM_form.vhd", "prog_rom.vhd", "prog_rom"
; ***************************************************************
; **                                                            *
; ** Using Starter Code from Xilinx, written by Ken Chapman     *
; **															*
; ***************************************************************

UART_output_port    EQU			$02					 ;  UART character module output data and control
RAM_output_port     EQU       	$01                   ; LCD character module output data and control
UART_input_port		EQU         $20					  ; input from UART
NEWSC_input_port	EQU			$10					; input from the NEWSC buttons
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

init:               DINT      INTERRUPT
					
; *************
; Main program*
; *************
main: 
                    CALL      check_buttons       ; constantly , check buttons
                    CALL	check_UART_rx
                    JUMP      main



check_buttons: 
; TAKE IN INPUT THEN CHECK WHICH BUTTON WAS PRESSED, ONE HOT FLAGS

                    IN        s0, NEWSC_input_port
                    LOAD      s1, $08
                    SUB       s1, s0
                    JUMP      Z, disp_North

                    LOAD      s1, $04
                    SUB       s1, s0
                    JUMP      Z, disp_East

                    LOAD      s1, $02
                    SUB       s1, s0
                    JUMP      Z, disp_South

                    LOAD      s1, $01
                    SUB       s1, s0
                    JUMP      Z, disp_West

                    LOAD      s1, $10
                    SUB       s1, s0
                    JUMP      Z, disp_Center

                    
                    RET       

; *************************************************

check_UART_rx:

		IN	s5, UART_input_port
		LOAD	s1, $00
		SUB	s1, s5
		JUMP	Z, return_UART_rx
		CALL	RAM_write_data
		
return_UART_rx:	
		RET

; ******************
; LCD text messages*
; ******************

disp_Center:        LOAD      s5, character_Cc     ; Write "C" to LCD
                    CALL      RAM_write_data
					LOAD	  s5, character_Cc
					CALL 	  UART_write_data
                    CALL      delay_500ms
                    RET

disp_North:         LOAD      s5, character_Nn     ; Write "N" to LCD
                    CALL      RAM_write_data
                    LOAD	  s5, character_Nn
					CALL 	  UART_write_data
                    CALL      delay_500ms
                    RET

disp_South:         LOAD      s5, character_Ss     ; Write "S" to LCD
                    CALL      RAM_write_data
                    LOAD	  s5,character_Ss
					CALL 	  UART_write_data
                    CALL      delay_500ms
                    RET       

disp_East:          LOAD      s5, character_Ee     ; Write "E" to LCD
                    CALL      RAM_write_data
                    LOAD	  s5, character_Ee
					CALL 	  UART_write_data
                    CALL      delay_500ms
                    RET       

disp_West:          LOAD      s5, character_Ww     ; Write "W" to LCD
                    CALL      RAM_write_data
                    LOAD	  s5, character_Ww
					CALL 	  UART_write_data
                    CALL      delay_500ms
                    RET
                    
; ******************
; Custom UART Ouptut
; ******************
UART_write_data:
					OUT		  s5, UART_output_port ; ouptut ASCII character to HyperTerminal
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
