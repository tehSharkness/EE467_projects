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
	PS2_data_in	: in	STD_LOGIC;
	PS2_Clock	:	in	STD_LOGIC;
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

	component PS2_Keyboard
	
	port(		Clock			:	in		STD_LOGIC;
			Data			:	in		STD_LOGIC;
			Reset			:	in		STD_LOGIC;
			ascii_out		:	out		STD_LOGIC_VECTOR(7 downto 0);		
			Parity_Bit		:	inout		STD_LOGIC);
	end component;
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
	
-- Signals used to connect UART to PicoBlaze
	signal data_in 			: std_logic_vector(7 downto 0);
	signal write_buffer 	: std_logic;
	signal UART_RST 		: std_logic;
	signal en_16_x_baud 	: std_logic;
	signal buffer_full_tx 		: std_logic;
	signal buffer_half_full_tx : std_logic;
	
	signal data_out : std_logic_vector(7 downto 0);
	signal read_buffer : std_logic;
	signal buffer_data_present : std_logic;
	signal buffer_full_rx : std_logic;
	signal buffer_half_full_rx : std_logic;	
	
	signal baud_count		: integer range 0 to 650 := 0;
	
-- Signals used for the PS2 Keyboard

	signal PS2_Parity	: STD_LOGIC;
	signal PS2_ascii	: STD_LOGIC_VECTOR( 7 downto 0 );
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin
	Keyboard : PS2_Keyboard
	port map
	(
			Clock		=>	PS2_Clock,	
			Data		=>	PS2_data_in,
			Reset		=>	RST,	
			ascii_out	=>	PS2_ascii,
			Parity_Bit	=>	PS2_Parity		
	);

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
	

------------------------------------------------------
	KCPSM3_input: process(CLK)
	begin
		if(CLK'event and CLK='1')then
			case(port_id)is
				--when	x"10" =>
									--in_port	<=	"000" & NEWSC;	
				when	x"20" =>
									if(buffer_data_present = '1')then
										in_port	<= data_out;
										read_buffer <= '1';			--send in the next byte of data
									else
										in_port	<= x"00";
										read_buffer <= '0';
									end if;
				when	x"30" =>			
									in_port <= "0000000" & PS2_Parity;
									
				when	x"40" =>		
									in_port <= PS2_ascii;
				when others =>
									in_port <= (others => 'X');
									read_buffer <= '0';
			end case;
		end if;
	end process KCPSM3_input;
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
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  -- adding the output registers to the processor
   
	write_buffer <= port_id(1) and write_strobe;
	data_in <= out_port;
	
	KCPSM3_output: process(CLK)
	begin
		if(CLK'event and CLK='1')then
			if(write_strobe='1')then -- write strobe set during output
				case(port_id)is
					when	x"01" =>
										LCD_DB <= out_port(7 downto 4); -- LCD data bus
										LCD_RS <= out_port(2);         -- LCD RS line ('1'- Data Mode, '0'- Command Mode)
										LCD_RW <= out_port(1);         -- LCD R/W line ('1'- Read from LCD, '0'- Write to LCD)
										LCD_EN <= out_port(0);          -- LCD enable line
										
					when others =>	LCD_DB <=	(others => 'X');
					
				end case;
			end if;
		end if; 
	end process KCPSM3_output;
	
end Behavioral;