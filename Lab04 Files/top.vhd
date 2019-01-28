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


entity top is
Port
( 
	NEWSC 	: in 	STD_LOGIC_VECTOR(4 downto 0);   	-- value of GPIO buttons pressed
	LCD_DB 	: inout STD_LOGIC_VECTOR(7 downto 4); 		-- LCD data bus
	LCD_RS 	: out 	STD_LOGIC;							-- LCD RS line ('1'- Data Mode, '0'- Command Mode)
	LCD_RW 	: out 	STD_LOGIC;							-- LCD R/W line ('1'- Read from LCD, '0'- Write to LCD)
	LCD_EN 	: out 	STD_LOGIC;							-- LCD enable line
	CLK 	: in 	STD_LOGIC;							-- clock
	RST 	: in 	STD_LOGIC							-- reset
);								
end top;



architecture Behavioral of top is

	component kcpsm3 
	Port
	(      
		address 		: out 	STD_LOGIC_VECTOR(9 downto 0);
		instruction 	: in 	STD_LOGIC_VECTOR(17 downto 0);
		port_id 		: out 	STD_LOGIC_VECTOR(7 downto 0);
		write_strobe 	: out 	STD_LOGIC;
		out_port 		: out 	STD_LOGIC_VECTOR(7 downto 0);
		read_strobe 	: out 	STD_LOGIC;
		in_port 		: in 	STD_LOGIC_VECTOR(7 downto 0);
		interrupt 		: in 	STD_LOGIC;
		interrupt_ack 	: out 	STD_LOGIC;
		reset 			: in 	STD_LOGIC;
		clk 			: in 	STD_LOGIC
	);
	end component;
--
-- declaration of program ROM
--
	component prog_rom
    Port
	(      
		address 	: in 	STD_LOGIC_VECTOR(9 downto 0);
		instruction : out 	STD_LOGIC_VECTOR(17 downto 0);
		clk 		: in 	STD_LOGIC
	);
    end component;
--
------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
	signal address          : STD_LOGIC_VECTOR(9 downto 0);
	signal instruction      : STD_LOGIC_VECTOR(17 downto 0);
	signal port_id          : STD_LOGIC_VECTOR(7 downto 0);
	signal out_port         : STD_LOGIC_VECTOR(7 downto 0);
	signal in_port          : STD_LOGIC_VECTOR(7 downto 0);
	signal write_strobe     : STD_LOGIC;
	signal read_strobe      : STD_LOGIC;
	signal interrupt        : STD_LOGIC :='0';
	signal interrupt_ack    : STD_LOGIC;
	signal kcpsm3_RST     	: STD_LOGIC;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin


	PicoBlaze : kcpsm3
    port map
	(      
			address 		=> address,
			instruction 	=> instruction,
			port_id 		=> port_id,
			write_strobe 	=> write_strobe,
			out_port 		=> out_port,
			read_strobe 	=> read_strobe,
			in_port 		=> in_port,
			interrupt 		=> interrupt,
			interrupt_ack 	=> interrupt_ack,
			reset 			=> kcpsm3_RST,
			clk 			=> CLK
	);
 
	ROM	: prog_rom
    port map
	(      
			address 	=> address,
			instruction => instruction,
			clk 		=> CLK
	);
  
	kcpsm3_RST <= not RST;	

	NEWSC_input: process(CLK)
	begin
		if(CLK'event and CLK='1')then
			if(port_id(3) = '1')then
				in_port	<=	"000" & NEWSC;
			else
				in_port	<=	(others=>'X');
			end if;
		end if;
	end process NEWSC_input;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  -- adding the output registers to the processor
   
	PicoBlaze_output: process(CLK)
	begin
		if(CLK'event and CLK='1')then
			if(write_strobe='1')then -- write strobe set during output
				if(port_id(0)='1')then --THIS IS LCD OUTPUT PORT ID
					LCD_DB <= out_port(7 downto 4); -- LCD data bus
					LCD_RS <= out_port(2);         -- LCD RS line ('1'- Data Mode, '0'- Command Mode)
					LCD_RW <= out_port(1);         -- LCD R/W line ('1'- Read from LCD, '0'- Write to LCD)
					LCD_EN <= out_port(0);          -- LCD enable line
				end if;
			end if;
		end if; 
	end process PicoBlaze_output;
	
end Behavioral;