------------------------------------------------------------------------------------------------------------
-- File name   : test_top.vhd
--
-- Project     : EE367 - Logic Design
--               Lab #1
--
-- Description : VHDL testbench of a 4-bit up/down counter w/ clock divide
--
-- Author(s)   : Brock J. LaMeres
--               Montana State University
--               lameres@ece.montana.edu
--
-- Date        : 
--
-- Note(s)     : This file is a test bench
--
------------------------------------------------------------------------------------------------------------
library IEEE;                    -- this library adds additional capability for VHDL
use IEEE.std_logic_1164.all;     -- this package has "STD_LOGIC" data types
use IEEE.STD_LOGIC_ARITH.ALL;    --  
use IEEE.STD_LOGIC_UNSIGNED.ALL; --

entity test_TOP is
end entity test_TOP;

architecture test_TOP_arch of test_TOP is
  constant t_clk_per : time := 10 ns;

  component TOP 
    port   (Clock         : in   STD_LOGIC;
            Reset         : in   STD_LOGIC;
            Direction     : in   STD_LOGIC;
            Count_Out     : out  STD_LOGIC_VECTOR (3 downto 0) );
  end component;
 
 
  signal    Clock_TB       : STD_LOGIC;
  signal    Reset_TB       : STD_LOGIC;
  signal    Direction_TB   : STD_LOGIC;
  signal    Count_TB       : STD_LOGIC_VECTOR (3 downto 0);

  begin
      UUT1 : TOP
         port map (Clock     => Clock_TB, 
                   Reset     => Reset_TB, 
                   Direction => Direction_TB,
                   Count_Out => Count_TB);

-----------------------------------------------      
      CLOCK_STIM : process
       begin
          Clock_TB <= '0'; wait for 0.5*t_clk_per; 
          Clock_TB <= '1'; wait for 0.5*t_clk_per; 
       end process CLOCK_STIM;
-----------------------------------------------      
      RESET_STIM : process
       begin
          Reset_TB <= '0'; wait for 10*t_clk_per; 
          Reset_TB <= '1'; wait; 
       end process RESET_STIM;
-----------------------------------------------      
      DIRECTION_STIM : process
       begin
          Direction_TB <= '0'; wait for 100*t_clk_per; 
          Direction_TB <= '1'; wait; 
       end process DIRECTION_STIM;
-----------------------------------------------      



end architecture test_TOP_arch;
