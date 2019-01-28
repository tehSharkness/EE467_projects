----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:00:53 04/28/2008 
-- Design Name: 
-- Module Name:    PS2_Keyboard - PS2_Keyboard_arch 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PS2_Keyboard is

	port(	Clock			:	in		STD_LOGIC;
			Data			:	in		STD_LOGIC;
			Reset			:	in		STD_LOGIC;
			ascii_out		:	out		STD_LOGIC_VECTOR(7 downto 0)
			Parity_Bit		:	out		STD_LOGIC);
			
end PS2_Keyboard;

architecture PS2_Keyboard_arch of PS2_Keyboard is

	type		state_type	is (	Start,
										Data0,
										Data1,
										Data2,
										Data3,
										Data4,
										Data5,
										Data6,
										Data7,
										Parity,
										Stop);
									
	signal	Current_State  : 	State_Type;
	signal   Next_State     : 	State_Type;

	signal	Received_Data	:	STD_LOGIC_VECTOR(7 downto 0) := x"00";
	
begin

	STATE_MEMORY    	: 	process 	(Clock)
		begin   
			if		(Reset = '0')then
				Current_State <= Start;			 -- Reset Operation
			elsif (Clock'event and Clock='1')then
            Current_State <= Next_State;   -- Normal Operation
         end if;
   end process STATE_MEMORY;

	NEXT_STATE_LOGIC	:	process	(Current_State, Clock, Data)
	begin
		case(Current_State)is
			when Start =>	Next_State <= Data0;
			
			when Data0 =>	Next_State <= Data1;		
			
			when Data1 =>	Next_State <= Data2;
			
			when Data2 =>	Next_State <= Data3;
			
			when Data3 =>	Next_State <= Data4;
			
			when Data4 =>	Next_State <= Data5;
			
			when Data5 =>	Next_State <= Data6;
			
			when Data6 =>	Next_State <= Data7;
			
			when Data7 =>	Next_State <= Parity;
			
			when Parity =>	Next_State <= Stop;
			
			when Stop =>	Next_State <= Start;
			
			when others => Next_State <= Start;
								
		end case;	
	end process NEXT_STATE_LOGIC;
	
	INPUT_LOGIC			:	process	(Current_State, Clock)
	begin
		case(Current_State)is
			when Start => 	Received_Data <= Received_Data;
								Parity_Bit <= '0';
								
			when Data0 => 	Received_Data(0) <= Data;
								Parity_Bit <= '0';
								
			when Data1 => 	Received_Data(1) <= Data;
								Parity_Bit <= '0';
								
			when Data2 => 	Received_Data(2) <= Data;
								Parity_Bit <= '0';
								
			when Data3 => 	Received_Data(3) <= Data;
								Parity_Bit <= '0';
								
			when Data4 => 	Received_Data(4) <= Data;
								Parity_Bit <= '0';
								
			when Data5 => 	Received_Data(5) <= Data;
								Parity_Bit <= '0';
								
			when Data6 => 	Received_Data(6) <= Data;
								Parity_Bit <= '0';
								
			when Data7 => 	Received_Data(7) <= Data;
								Parity_Bit <= '0';
								
			when Parity => Received_Data <= Received_Data;
								Parity_Bit <= Data;
								
			when Stop => 	Received_Data <= Received_Data;
								Parity_Bit <= '0';
								
			when others => Received_Data <= Received_Data;
								Parity_Bit <= '0';
		
		end case;
	end process INPUT_LOGIC;
	
	OUTPUT_LOGIC		:	process	(Current_State, Data, Received_Data)
	begin		
		case(Current_State)is
			when Start => 	if Parity_Bit = '1' then
						ascii_out <= Received_Data;
					end if;
				
			when others =>  ascii_out <= (others => 'X');
		end case;
	end process OUTPUT_LOGIC;
end PS2_Keyboard_arch;