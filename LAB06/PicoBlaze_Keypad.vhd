------------------------------------------------------------------------------------------------------------
-- File name   : top.vhd
--
-- Project     : EE367 - Logic Design
--               PicoBlaze LCD Controller
--
-- Description : 	
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


entity PicoBlaze_Keypad is

Port
( 
	port_id 	: out 	STD_LOGIC_VECTOR(7 downto 0);
	write_strobe 	: out 	STD_LOGIC;
	out_port 	: out 	STD_LOGIC_VECTOR(7 downto 0);
	read_strobe 	: out 	STD_LOGIC;
	in_port 	: in 	STD_LOGIC_VECTOR(7 downto 0);
	interrupt 	: in 	STD_LOGIC;
	interrupt_ack 	: out 	STD_LOGIC;
	reset 		: in 	STD_LOGIC;
	clk 		: in 	STD_LOGIC
);			

end PicoBlaze_Keypad;



architecture Behavioral of PicoBlaze_Keypad is

	component	KCPSC3
	Port(
		address 	: out 	STD_LOGIC_VECTOR(9 downto 0);
		instruction 	: in 	STD_LOGIC_VECTOR(17 downto 0);
		port_id 	: out 	STD_LOGIC_VECTOR(7 downto 0);
		write_strobe 	: out 	STD_LOGIC;
		out_port 	: out 	STD_LOGIC_VECTOR(7 downto 0);
		read_strobe 	: out 	STD_LOGIC;
		in_port 	: in 	STD_LOGIC_VECTOR(7 downto 0);
		interrupt 	: in 	STD_LOGIC;
		interrupt_ack 	: out 	STD_LOGIC;
		reset 		: in 	STD_LOGIC;
		clk 		: in 	STD_LOGIC
	);
	
	component	prog_rom_Keypad
	Port(
		address 	: in 	STD_LOGIC_VECTOR(9 downto 0);
		instruction 	: out 	STD_LOGIC_VECTOR(17 downto 0);
		clk 		: in 	STD_LOGIC
	);

	signal	address		:	STD_LOGIC_VECTOR(9 downto 0);
	signal	instruction	:	STD_LOGIC_VECTOR(17 downto 0);

begin
	
	KCPSM3_1 :	kcpsm3
    	port map
	(      
			address 	=> address,
			instruction 	=> instruction,
			port_id 	=> port_id,
			write_strobe 	=> write_strobe,
			out_port 	=> out_port,
			read_strobe 	=> read_strobe,
			in_port 	=> in_port,
			interrupt 	=> interrupt,
			interrupt_ack 	=> interrupt_ack,
			reset 		=> reset,
			clk 		=> clk
	);
	
	ROM	:	prog_rom_Keypad
	port map
	(      
			address 	=> address,
			instruction 	=> instruction,
			clk 		=> CLK
	);
	
end Behavioral;