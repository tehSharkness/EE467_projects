----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:46:21 03/30/2009 
-- Design Name: 
-- Module Name:    test_top - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity test_top is
end test_top;

architecture Behavioral of test_top is
	constant t_wait_1 : time := 1 ns; 
	constant t_wait_10 : time := 10 ns; 
	constant t_wait_100 : time := 100 ns; 

	component top
	Port
	( 
		NEWSC 	: in 	STD_LOGIC_VECTOR(4 downto 0);   	-- value of GPIO buttons pressed
		LCD_DB 	: inout STD_LOGIC_VECTOR(7 downto 4); 	-- LCD data bus
		LCD_RS 	: out 	STD_LOGIC;							-- LCD RS line ('1'- Data Mode, '0'- Command Mode)
		LCD_RW 	: out 	STD_LOGIC;							-- LCD R/W line ('1'- Read from LCD, '0'- Write to LCD)
		LCD_EN 	: out 	STD_LOGIC;							-- LCD enable line
		CLK 	: in 	STD_LOGIC;									-- clock
		RST 	: in 	STD_LOGIC;									-- reset
		SER_OUT	: out	STD_LOGIC								-- serial bitstream to HyperTerminal
	);			
	end component;

	signal NEWSC_tb 	:  		STD_LOGIC_VECTOR(4 downto 0);   		-- value of GPIO buttons pressed
	signal LCD_DB_tb 	:  	STD_LOGIC_VECTOR(7 downto 4); 		-- LCD data bus
	signal LCD_RS_tb 	:  	STD_LOGIC;									-- LCD RS line ('1'- Data Mode, '0'- Command Mode)
	signal LCD_RW_tb 	: 	STD_LOGIC;									-- LCD R/W line ('1'- Read from LCD, '0'- Write to LCD)
	signal LCD_EN_tb 	:  	STD_LOGIC;									-- LCD enable line
	signal CLK_tb 		:  		STD_LOGIC;									-- clock
	signal RST_tb 		:  		STD_LOGIC;									-- reset
	signal SER_OUT_tb	: 		STD_LOGIC;									-- serial bitstream to HyperTerminal

begin

	TOP1	:	top	port map	(
									NEWSC		=>	NEWSC_tb,
									LCD_DB	=>	LCD_DB_tb,
									LCD_RS	=>	LCD_RS_tb,
									LCD_RW	=>	LCD_RW_tb,
									LCD_EN	=>	LCD_EN_tb,
									CLK		=>	CLK_tb,
									RST		=>	RST_tb,
									SER_OUT	=>	SER_OUT_tb
									);
									
	CLOCK_STIM	:	process
	begin	
		CLK_tb <= '0';
		wait for t_wait_1;
		
		CLK_tb <= '1';
		wait for t_wait_1;
	end process;
									
	STIMULUS	:	process
	begin
		RST_tb <= '1';
		wait for t_wait_10;
		
		RST_tb <= '0';
		
		NEWSC_tb <= "00001";
		wait for t_wait_100;
		NEWSC_tb <= "00010";
		wait for t_wait_100;
		NEWSC_tb <= "00100";
		wait for t_wait_100;
		NEWSC_tb <= "01000";
		wait for t_wait_100;
		NEWSC_tb <= "10000";
		wait for t_wait_100;
		
		wait;
	
	end process STIMULUS;

end architecture Behavioral;

