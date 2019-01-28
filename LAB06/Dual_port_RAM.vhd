------------------------------------------------------------------------------------------------------------
-- File name   : top.vhd
--
-- Project     : EE367 - Logic Design
--               PicoBlaze LCD Controller
--
-- Description : 	VHDL model of the top level of the PicoBlaze controller. 
--					Controls input to the PicoBlaze and Output from the PicoBlaze.
--					Reads from GPIO buttons and displays what is pressed on the LCD
--               
--
-- Author(s)   : 	Samuel Harkness, Jay Lamb
--               	Montana State University
--					samuel.harkness@gmail.com, jaylamb@gmail.com
--
-- Note(s)     : This file contains the Entity and Architecture
--               
--
------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Dual_port_RAM is

Port
( 
	read_in 	: in 	STD_LOGIC;			   				-- set this high to read data into RAM 
	write_out 	: in 	STD_LOGIC;							-- set this high to write data from RAM
	data_in 	: in 	STD_LOGIC_VECTOR(7 downto 0);					-- entering the RAM
	CLK		: in 	STD_LOGIC;							-- clock¿!?
	RST	 	: in 	STD_LOGIC;							-- reset?!¿
	data_out 	: out 	STD_LOGIC_VECTOR(7 downto 0);					-- leaving the RAM
	data_present	: out	STD_LOGIC							-- flag that a new byte has been entered
);			

end Dual_port_RAM;



architecture Behavioral of Dual_port_RAM is

	signal data	:	STD_LOGIC_VECTOR(7 downto 0);
	

-- Start of circuit description
--
begin

	
------------------------------------------------------
	process(CLK)
	begin
		if (CLK'event and CLK = '1')then
			if(RST = '0')then
				data = x"00";
			end if;
			
			if(read_in = '1')then
				data <= data_in;
				data_present <= '1';
			end if;
			
			if(write_out ='1')then
				data_out <= data;
				data_present <= '0';
			 end if;
		end if;	
	end process;
		
end Behavioral;