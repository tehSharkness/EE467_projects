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
	LCD_DB 	: inout STD_LOGIC_VECTOR(7 downto 4); 	-- LCD data bus
	LCD_RS 	: out 	STD_LOGIC;							-- LCD RS line ('1'- Data Mode, '0'- Command Mode)
	LCD_RW 	: out 	STD_LOGIC;							-- LCD R/W line ('1'- Read from LCD, '0'- Write to LCD)
	LCD_EN 	: out 	STD_LOGIC;							-- LCD enable line
	CLK 	: in 	STD_LOGIC;									-- clock
	RST 	: in 	STD_LOGIC;									-- reset
	SER_OUT	: out	STD_LOGIC;								-- serial bitstream to HyperTerminal
	SER_IN	: in	STD_LOGIC								-- serial bitstream from HyperTerminal
);			

end top;



architecture Behavioral of top is

	component	Dual_port_RAM
	Port
	(
		read_in 	: in 	STD_LOGIC;			   				-- set this high to read data into RAM 
		write_out 	: in 	STD_LOGIC;							-- set this high to write data from RAM
		data_in 	: in 	STD_LOGIC_VECTOR(7 downto 0);					-- entering the RAM
		CLK		: in 	STD_LOGIC;							-- clock¿!?
		RST	 	: in 	STD_LOGIC;							-- reset?!¿
		data_out 	: out 	STD_LOGIC_VECTOR(7 downto 0)					-- leaving the RAM
	);

	component	PicoBlaze_Keypad
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
	end component;
	
	component	PicoBlaze_LCD
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
	end component;
	
	component uart_tx
    Port(             data_in : in std_logic_vector(7 downto 0);
                 write_buffer : in std_logic;
                 reset_buffer : in std_logic;
                 en_16_x_baud : in std_logic;
                   serial_out : out std_logic;
                  buffer_full : out std_logic;
             buffer_half_full : out std_logic;
                          clk : in std_logic);
    end component;

	component uart_rx
   Port (            serial_in  : in std_logic;
                       data_out : out std_logic_vector(7 downto 0);
                    read_buffer : in std_logic;
                   reset_buffer : in std_logic;
                   en_16_x_baud : in std_logic;
            buffer_data_present : out std_logic;
                    buffer_full : out std_logic;
               buffer_half_full : out std_logic;
                            clk : in std_logic);
    end component;

--
------------------------------------------------------------------------------------
--

-- Signal for the Dual_port_RAM
	signal Buffer_read_in 		: in 	STD_LOGIC;			   				-- set this high to read data into RAM 
	signal Buffer_write_out 	: in 	STD_LOGIC;							-- set this high to write data from RAM

-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
	signal Keypad_port_id          	: STD_LOGIC_VECTOR(7 downto 0);
	signal Keypad_out_port         	: STD_LOGIC_VECTOR(7 downto 0);
	signal Keypad_in_port          	: STD_LOGIC_VECTOR(7 downto 0);
	signal Keypad_write_strobe     	: STD_LOGIC;
	signal Keypad_read_strobe      	: STD_LOGIC;
	
	signal kcpsm3_RST     	: STD_LOGIC;
	
	signal LCD_port_id          	: STD_LOGIC_VECTOR(7 downto 0);
	signal LCD_out_port         	: STD_LOGIC_VECTOR(7 downto 0);
	signal LCD_in_port          	: STD_LOGIC_VECTOR(7 downto 0);
	signal LCD_write_strobe     	: STD_LOGIC;
	signal LCD_read_strobe      	: STD_LOGIC;

	
-- Signals used to connect UART to PicoBlaze
	signal data_in 			: std_logic_vector(7 downto 0);
	signal write_buffer 	: std_logic;
	signal UART_RST 		: std_logic;
	
	signal en_16_x_baud 	: std_logic;
	
	signal data_out : std_logic_vector(7 downto 0);
	signal read_buffer : std_logic;
	signal buffer_data_present : std_logic;
	
	
	signal baud_count		: integer range 0 to 650 := 0;
	
-- Unused Signals
	signal Keypad_interrupt        	: STD_LOGIC :='0';
	signal Keypad_interrupt_ack    	: STD_LOGIC;
	signal LCD_interrupt        	: STD_LOGIC :='0';
	signal LCD_interrupt_ack    	: STD_LOGIC;	
	signal buffer_full_rx : std_logic;
	signal buffer_half_full_rx : std_logic;	
	signal buffer_full_tx 		: std_logic;
	signal buffer_half_full_tx : std_logic;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin

	Buffer_RAM	:	Dual_port_RAM
	port map
	(
		read_in 	=>	Buffer_read_in,
		write_out 	=>	Buffer_write_out,
		data_in 	=>	Keypad_out_port,
		CLK		=>	CLK,
		RST	 	=>	RST,
		data_out 	=>	LCD_in_port
	);

	Keypad_PicoBlaze : PicoBlaze_Keypad
    	port map
	(      
			port_id 	=> Keypad_port_id,
			write_strobe 	=> Keypad_write_strobe,
			out_port 	=> Keypad_out_port,
			read_strobe 	=> Keypad_read_strobe,
			in_port 	=> Keypad_in_port,
			interrupt 	=> Keypad_interrupt,
			interrupt_ack 	=> Keypad_interrupt_ack,
			reset 		=> kcpsm3_RST,
			clk 		=> CLK
	);
	
	LCD_PicoBlaze : PicoBlaze_LCD
    	port map
	(      
			port_id 	=> LCD_port_id,
			write_strobe 	=> LCD_write_strobe,
			out_port 	=> LCD_out_port,
			read_strobe 	=> LCD_read_strobe,
			in_port 	=> LCD_in_port,
			interrupt 	=> LCD_interrupt,
			interrupt_ack 	=> LCD_interrupt_ack,
			reset 		=> kcpsm3_RST,
			clk 		=> CLK
	);
	
	UART_Tx1 : uart_tx
    port map(            data_in => data_in,
                 write_buffer => write_buffer,
                 reset_buffer => UART_RST,
                 en_16_x_baud => en_16_x_baud,
                   serial_out => SER_OUT,
                  buffer_full => buffer_full_tx,
             buffer_half_full => buffer_half_full_tx,
                          clk => CLK);
  
	UART_Rx1	:	uart_rx
	port map(            serial_in  =>	SER_IN,
                       data_out =>	data_out,
                    read_buffer =>	read_buffer,
                   reset_buffer =>	UART_RST,
                   en_16_x_baud =>	en_16_x_baud,
            buffer_data_present =>	buffer_data_present,
                    buffer_full =>	buffer_full_rx,
               buffer_half_full =>	buffer_half_full_rx,
                            clk =>	CLK);
  
	kcpsm3_RST 		<= not RST;
	UART_RST		<= not RST;
	
--
----------------------------------------------------------------------------------------------------------------------------------
-- Keypad processes ports 
----------------------------------------------------------------------------------------------------------------------------------
--

	write_buffer <= Keypad_port_id(1) and write_strobe;
	data_in <= Keypad_out_port;
	
------------------------------------------------------
	Keypad_input: process(CLK)
	begin
		if(CLK'event and CLK='1')then
			case(Keypad_port_id)is
				when	x"10" =>
									Keypad_in_port	<=	"000" & NEWSC;	
				when	x"20" =>
									if(buffer_data_present = '1')then
										Keypad_in_port	<= data_out;
										read_buffer <= '1';			--send in the next byte of data
									else
										Keypad_in_port	<= x"00";
										read_buffer <= '0';
									end if;
				when others =>
									Keypad_in_port <= (others => 'X');
									read_buffer <= '0';
			end case;
		end if;
	end process Keypad_input;
	
	Keypad_output: process(CLK)
	begin
		if(CLK'event and CLK='1' and Keypad_write_strobe='1')then
			case(Keypad_port_id)is
				when	x"01" =>	Buffer_read_in <= '1';									
									
				when others =>		Buffer_read_in <= '0';					
			end case;
		end if; 
	end process Keypad_output;
------------------------------------------------------
	
	baud_timer : process(CLK)
	begin
		if(CLK'event and CLK='1')then
			if(baud_count = 650)then
				baud_count <= 0;
				en_16_x_baud <= '1';
			else
				baud_count <= baud_count + 1;
				en_16_x_baud <= '0';
			end if;
		end if;
	end process baud_timer;

--
----------------------------------------------------------------------------------------------------------------------------------
-- LCD Processes
----------------------------------------------------------------------------------------------------------------------------------
--	

  -- adding the output registers to the processor
   
	LCD_input: process(CLK)
	begin
		if(CLK'event and CLK='1')then
			case(LCD_port_id)is
				when	x"10" 	=>	Buffer_write_out <= '1';
				when 	others	=>	Buffer_write_out <= '0';
			end case;
		end if;
	end process LCD_input;
	
	LCD_output: process(CLK)
	begin
		if(CLK'event and CLK='1' and LCD_write_strobe='1')then
			case(LCD_port_id)is
				when	x"01" =>
									LCD_DB <= LCD_out_port(7 downto 4); -- LCD data bus
									LCD_RS <= LCD_out_port(2);         -- LCD RS line ('1'- Data Mode, '0'- Command Mode)
									LCD_RW <= LCD_out_port(1);         -- LCD R/W line ('1'- Read from LCD, '0'- Write to LCD)
									LCD_EN <= LCD_out_port(0);          -- LCD enable line
									
				when others =>	LCD_DB <=	(others => 'X');
				
			end case;
		end if; 
	end process LCD_output;
	
end Behavioral;