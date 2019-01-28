------------------------------------------------------------------------------------------------------------
-- File name   : lcd_blkbx.vhd
--
-- Project     : EE367 - Logic Design (Spring 2007)
--               LCD Black Box Output Port
--
-- Description : VHDL model LCD Controller Using State Machines
--
-- Author(s)   : Clint Gauer
--               Montana State University
--
-- Date        : January 28, 2008
--
-- Note(s)     : This file contains the Entity and Architecture
--               
--
------------------------------------------------------------------------------------------------------------
library IEEE;                    -- this library adds additional capability for VHDL
use IEEE.std_logic_1164.all;     -- this package has "STD_LOGIC" data types
use IEEE.STD_LOGIC_ARITH.ALL;    --  
use IEEE.STD_LOGIC_UNSIGNED.ALL; --


entity lcd_blkbx is
    port   (Clock            : in   STD_LOGIC;
            Reset            : in   STD_LOGIC;
            EN               : out  STD_LOGIC;
            RS               : out  STD_LOGIC;
            RW               : out  STD_LOGIC;
            DB7              : out  STD_LOGIC;
            DB6              : out  STD_LOGIC;
            DB5              : out  STD_LOGIC;
            DB4              : out  STD_LOGIC;
            A                : in   STD_LOGIC_VECTOR (3 downto 0);
            B                : in   STD_LOGIC_VECTOR (4 downto 0));         
end lcd_blkbx;

architecture lcd_blkbx_arch of lcd_blkbx is

    constant   wait_40ms: STD_LOGIC_VECTOR(11 downto 0) := x"3d0";
    constant   wait_2ms: STD_LOGIC_VECTOR(11 downto 0) := x"030";
    type State_Type is (S1,POWER_ON,F_SET_1,F_SET_2,F_SET_3,
                         WAIT_1,D_CONTROL_1,D_CONTROL_2,WAIT_2,
                         WAIT_3,D_CLEAR_1,D_CLEAR_2,
                         E_MODE_1,E_MODE_2,WAIT_4,
								 END_STATE,
								 PRINT_B_1,PRINT_B_2
                         );
    signal Current_State   :State_Type;
    signal Next_State      :State_Type;
    signal Count           :STD_LOGIC_VECTOR(11 downto 0);
	 signal Count_Reset	   :STD_LOGIC;
	 signal Clock_Out			:STD_LOGIC;
	 signal EN_Clock        :STD_LOGIC;
	 signal EN_enable       :STD_LOGIC;
	 signal A_VECT				:STD_LOGIC_VECTOR(7 downto 0);
	 signal B_VECT_Current,B_VECT_Next	:STD_LOGIC_VECTOR(7 downto 0);
	 signal A_DATA   			:STD_LOGIC_VECTOR(3 downto 0);
	 signal B_DATA   			:STD_LOGIC_VECTOR(4 downto 0);
   
   component lcd_counter
       Port ( Clock     : in  STD_LOGIC;
              Reset     : in  STD_LOGIC;
              Count_Out : out STD_LOGIC_VECTOR (11 downto 0));
   end component;
	
	component lcd_clock_div	
		port   (	Clock_In     : in   STD_LOGIC;
					Reset        : in   STD_LOGIC;
					Clock_Out    : out  STD_LOGIC;
					Clock_Out2   : out  STD_LOGIC);
	end component;
				
   
begin
    U1: lcd_counter   port map(Clock_Out,Count_Reset,Count);
	 U2: lcd_clock_div port map(Clock,Reset,Clock_Out,EN_Clock);
    
	 A_DATA <= A;	 
	 B_DATA <= B;
	 
	STATE_MEMORY: process(Clock_Out,Reset)
	begin
		if(Reset = '0')then
			Current_State <= S1;
			B_Vect_Current <= "00100000";
		elsif(Clock_Out'event and Clock_Out = '1')then
			Current_State <= Next_State; 
			B_Vect_Current <= B_Vect_Next;
		end if;
	end process;
		
	NEXT_STATE_LOGIC: process(Current_State,A_DATA,B_DATA,Count)
	begin    
		case(Current_State)is
			when S1		=>			  Next_State <= POWER_ON;
			when POWER_ON =>       if(Count = wait_40ms)then Next_State <= F_SET_1;
								        else   Next_State <= POWER_ON;end if;
			when F_SET_1 =>        Next_State <= F_SET_2;			                       
			when F_SET_2 =>        Next_State <= F_SET_3;			                       
			when F_SET_3 =>        Next_State <= WAIT_1;			                       
			when WAIT_1  =>        if(Count = wait_2ms) then
			                          Next_State <= D_CONTROL_1;
										  else Next_State <= WAIT_1;end if;			    
			when D_CONTROL_1  => 		Next_State <= D_CONTROL_2;
			when D_CONTROL_2  =>   Next_State <= WAIT_2;
			when WAIT_2       =>   if(Count = wait_2ms) then
			                          Next_State <= D_CLEAR_1;
									     else Next_State <= WAIT_2;end if;
			when D_CLEAR_1    =>   Next_State <= D_CLEAR_2;
			when D_CLEAR_2    =>   Next_State <= WAIT_3;
			when WAIT_3       =>   if(Count = wait_2ms) then
			                           Next_State <= E_MODE_1;
										  else Next_State <= WAIT_3;end if;
			when E_MODE_1     =>   Next_State <= E_MODE_2;
			when E_MODE_2     =>   Next_State <= WAIT_4;
			when WAIT_4  =>        if(Count = wait_2ms) then
			                           Next_State <= END_STATE; 
										  else Next_State <= WAIT_4;end if;
										  
			when END_STATE		=>	if(B_VECT_Current = B_VECT_Next)then
											Next_State <= END_STATE;
										else
											Next_State <= PRINT_B_1;
										end if;
			
			when PRINT_B_1 => Next_State <= PRINT_B_2;
			when PRINT_B_2 => Next_State <= END_STATE;
								                            		
		end case;
		case(A_DATA)is
			when "0000" => A_VECT <= "00110000";
			when "0001" => A_VECT <= "00110001";
			when "0010" => A_VECT <= "00110010";
			when "0011" => A_VECT <= "00110011";
			when "0100" => A_VECT <= "00110100";
			when "0101" => A_VECT <= "00110101";
			when "0110" => A_VECT <= "00110110";
			when "0111" => A_VECT <= "00110111";
			when "1000" => A_VECT <= "00111000";
			when "1001" => A_VECT <= "00111001";
			when "1010" => A_VECT <= "01000001";
			when "1011" => A_VECT <= "01000010";
			when "1100" => A_VECT <= "01000011";
			when "1101" => A_VECT <= "01000100";
			when "1110" => A_VECT <= "01000101";
			when "1111" => A_VECT <= "01000110";
			when others => A_VECT <= "00110000";
		end case;
		CASE(B_DATA)is
			when "00001" => B_VECT_Next <= "01001110";	--N
			when "00010" => B_VECT_Next <= "01000101";	--E
			when "00100" => B_VECT_Next <= "01010011";	--S
			when "01000" => B_VECT_Next <= "01010111";	--W
			when "10000" => B_VECT_Next <= "01000011";	--C
			when others  => B_VECT_Next <= "00100000";	--Blank
		end case;
   end process;
	
	START_LOGIC: process(Current_State,EN_Clock)
	begin
		case(Current_State)is
			when S1       =>     RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '0';
										Count_Reset <= '0';
			--wait for more than 20ms after power on							
			when POWER_ON =>     RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '0';
										Count_Reset <= '1';
			--set 4 bit mode    
			when F_SET_1 =>      RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '1';
										DB4 <= '0';
										EN_enable  <= '1';
										Count_Reset <= '0';
										
			--set 4 bit mode again    
			when F_SET_2 =>      RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '1';
										DB4 <= '0';
										EN_enable  <= '1';
										Count_Reset <= '0';                              
			--set 2 line mode    
			when F_SET_3 =>      RS  <= '0';
										RW  <= '0';
										DB7 <= '1';
										DB6 <= '1';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '1';
										Count_Reset <= '0';
			--wait for more than 39us    
			when WAIT_1  =>      RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '0';
										Count_Reset <= '1';
			--display control first nibble                     
			when D_CONTROL_1 =>  RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '1';
										Count_Reset <= '0';
			--display controll - display on, cursor on, blink on                     
			when D_CONTROL_2 =>  RS  <= '0';
										RW  <= '0';
										DB7 <= '1';
										DB6 <= '1';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '1';
										Count_Reset <= '0';
			--wait for more than 39 us           
			when WAIT_2  =>      RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '0';
										Count_Reset <= '1';
			--clear display                     
			when D_CLEAR_1 =>    RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '1';
										Count_Reset <= '0';
										
			when D_CLEAR_2 =>    RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '1';
										EN_enable  <= '1';
										Count_Reset <= '0';
			--wait for more than 1.53 ms                     
			when WAIT_3  =>      RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '0';
										Count_Reset <= '1';
			--entry mode first nibble                     
			when E_MODE_1  =>    RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '1';
										Count_Reset <= '0';
			--increment on, display shift off                     
			when E_MODE_2  =>    RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '1';
										DB5 <= '1';
										DB4 <= '0';
										EN_enable  <= '1';
										Count_Reset <= '0';
			--wait for more than 39 us                     
			when WAIT_4  =>      RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '0';
										Count_Reset <= '1';
										
			when END_STATE  =>   RS  <= '0';
										RW  <= '0';
										DB7 <= '0';
										DB6 <= '0';
										DB5 <= '0';
										DB4 <= '0';
										EN_enable  <= '0';
										Count_Reset <= '1';
										
			when PRINT_B_1	  =>  EN_enable  <= '1';
										RS  <= '1';
                              RW  <= '0';
                              DB7 <= B_VECT_Current(7);
                              DB6 <= B_VECT_Current(6);
                              DB5 <= B_VECT_Current(5);
                              DB4 <= B_VECT_Current(4);
										Count_Reset <= '0';
										
			when PRINT_B_2	  =>  EN_enable  <= '1';
										RS  <= '1';
                              RW  <= '0';
                              DB7 <= B_VECT_Current(3);
                              DB6 <= B_VECT_Current(2);
                              DB5 <= B_VECT_Current(1);
                              DB4 <= B_VECT_Current(0);
										Count_Reset <= '0';
																				
		end case;
		EN <= EN_Clock and EN_enable;
	end process;
	
end lcd_blkbx_arch;