------------------------------------------------------------------------------------------------------------
-- File name   : top.vhd
--
-- Project     : EE367 - Logic Design
--               PicoBlaze LCD Controller
--
-- Description : VHDL model of the top level of the PicoBlaze controller. 
--						Controls input to the PicoBlaze and Output from the PicoBlaze.
--					  Reads from GPIO buttons and displays what is pressed on the LCD
--               
--
-- Author(s)   : Erwin D. Dunbar
--               Montana State University
--					  edd@montana.edu
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
    Port ( news_buttons : in std_logic_vector (4 downto 0);   	-- value of GPIO buttons pressed
                  lcd_d : inout std_logic_vector(7 downto 4); 	-- LCD data bus
                 lcd_rs : out std_logic;								-- LCD RS line ('1'- Data Mode, '0'- Command Mode)
                 lcd_rw : out std_logic;								-- LCD R/W line ('1'- Read from LCD, '0'- Write to LCD)
                  lcd_e : out std_logic;								-- LCD enable line
                    clk : in std_logic);								-- clock
    end top;



architecture Behavioral of top is

  component kcpsm3 
    Port (      address : out std_logic_vector(9 downto 0);
            instruction : in std_logic_vector(17 downto 0);
                port_id : out std_logic_vector(7 downto 0);
           write_strobe : out std_logic;
               out_port : out std_logic_vector(7 downto 0);
            read_strobe : out std_logic;
                in_port : in std_logic_vector(7 downto 0);
              interrupt : in std_logic;
          interrupt_ack : out std_logic;
                  reset : in std_logic;
                    clk : in std_logic);
    end component;
--
-- declaration of program ROM
--
  component control
    Port (      address : in std_logic_vector(9 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                    clk : in std_logic);
    end component;
--
------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
signal address          : std_logic_vector(9 downto 0);
signal instruction      : std_logic_vector(17 downto 0);
signal port_id          : std_logic_vector(7 downto 0);
signal out_port         : std_logic_vector(7 downto 0);
signal in_port          : std_logic_vector(7 downto 0);
signal write_strobe     : std_logic;
signal read_strobe      : std_logic;
signal interrupt        : std_logic :='0';
signal interrupt_ack    : std_logic;
signal kcpsm3_reset     : std_logic;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin


  processor: kcpsm3
    port map(      address => address,
               instruction => instruction,
                   port_id => port_id,
              write_strobe => write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     reset => kcpsm3_reset,
                       clk => clk);
 
  program_rom: control
    port map(      address => address,
               instruction => instruction,
                       clk => clk);


  button_input: process(clk)
  begin
    if clk'event and clk='1' then
		case port_id (3) is 								-- Hex x04 is BUTTON INPUT PORT ID
			when '1' => 									-- When this port is selected, 
					in_port <= "000" & news_buttons; --- output GPIO button values to PicoBlaze input
			when others =>
					in_port <= (others=>'X');			-- Otherwise do nothing
		end case;
    end if;

  end process button_input;


  --
  ----------------------------------------------------------------------------------------------------------------------------------
  -- KCPSM3 output ports 
  ----------------------------------------------------------------------------------------------------------------------------------
  --

  -- adding the output registers to the processor
   
  output_ports: process(clk)
  begin

    if clk'event and clk='1' then
      if write_strobe='1' then -- write strobe set during output
        if port_id(0)='1' then --THIS IS LCD OUTPUT PORT ID
          lcd_d <= out_port(7 downto 4); -- LCD data bus
          lcd_rs <= out_port(2);         -- LCD RS line ('1'- Data Mode, '0'- Command Mode)
          lcd_rw <= out_port(1);         -- LCD R/W line ('1'- Read from LCD, '0'- Write to LCD)
          lcd_e <= out_port(0);          -- LCD enable line
        end if;

      end if;

    end if; 

  end process output_ports;
	
end Behavioral;