----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:32:21 03/30/2009 
-- Design Name: 
-- Module Name:    test_uart - Behavioral 
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

entity test_uart is
end test_uart;

architecture Behavioral of test_uart is
	constant t_wait_1 : time := 1 ns; 
	constant t_wait_10 : time := 10 ns; 
	constant t_wait_100 : time := 100 ns; 
	
	component uart_tx 
    Port (            data_in : in std_logic_vector(7 downto 0);
                 write_buffer : in std_logic;
                 reset_buffer : in std_logic;
                 en_16_x_baud : in std_logic;
                   serial_out : out std_logic;
                  buffer_full : out std_logic;
             buffer_half_full : out std_logic;
                          clk : in std_logic);
    end component;
	 
	signal	data_in_tb :  std_logic_vector(7 downto 0);
   signal   write_buffer_tb :  std_logic;
   signal   reset_buffer_tb :  std_logic;
   signal   en_16_x_baud_tb :  std_logic;
   signal   serial_out_tb :  std_logic;
   signal   buffer_full_tb :  std_logic;
   signal   buffer_half_full_tb :  std_logic;
   signal   clk_tb :  std_logic;
	
begin

	UART1	:	uart_tx	port map	(
						data_in 		=>		data_in_tb,
                 write_buffer =>		write_buffer_tb,
                 reset_buffer	=>		reset_buffer_tb,
                 en_16_x_baud => 	en_16_x_baud_tb,
                   serial_out =>		serial_out_tb,
                  buffer_full =>		buffer_full_tb,
             buffer_half_full =>		buffer_half_full_tb,
                          clk =>		clk_tb
										);

	CLOCK_STIM	:	process
	begin	
		clk_tb <= '0';
		wait for t_wait_1;
		
		clk_tb <= '1';
		wait for t_wait_1;
	end process;
	
	RESET_STIM	:	process
	begin
		reset_buffer_tb <= '1';
		wait for t_wait_1;
		reset_buffer_tb <= '0';
		wait;	
	end process;

	DATA_IN_STIM	:	process
	begin
		data_in_tb <= x"57";	--W
		wait for t_wait_100;
		
		data_in_tb <= x"53";	--S
		wait for t_wait_100;
		
		data_in_tb <= x"45";	--E
		wait for t_wait_100;
		
		data_in_tb <= x"4E";	--N
		wait for t_wait_100;
		
		data_in_tb <= x"43";	--C
		wait for t_wait_100;
	end process;
	
	BAUD_STIM	:	process
	begin
		en_16_x_baud_tb <= '1';
		wait;
	end process;
	
	WRITE_STIM	:	process
	begin
		if(buffer_full_tb = '0')then
			write_buffer_tb	<=	'1';
		else
			write_buffer_tb	<=	'0';
		end if;
		
		if(write_buffer_tb = '1')then
			wait for t_wait_1;
			write_buffer_tb	<= '0';
		end if;
			
		wait for t_wait_10;
	end process;

end Behavioral;

