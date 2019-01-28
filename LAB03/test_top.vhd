------------------------------------------------------------------------------------------------------------
-- File name   : test_top.vhd
--
-- Project     : EE367 - Logic Design (Spring 2008)
--               Lab #3
--
-- Description : VHDL testbench of the LCD Black Box
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
     port  (Clock         : in   STD_LOGIC;
            Reset         : in   STD_LOGIC;
            Direction     : in   STD_LOGIC;
				EN            : out  STD_LOGIC;
            RS            : out  STD_LOGIC;
            RW            : out  STD_LOGIC;
            DB7           : out  STD_LOGIC;
            DB6           : out  STD_LOGIC;
            DB5           : out  STD_LOGIC;
            DB4           : out  STD_LOGIC;
            B             : in   STD_LOGIC_VECTOR (3 downto 0) );
   end component;

   signal    Clock_TB       : STD_LOGIC;
   signal    Reset_TB       : STD_LOGIC;
   signal    Direction_TB   : STD_LOGIC;
   signal    EN_TB          : STD_LOGIC;
   signal    RS_TB          : STD_LOGIC;
   signal    RW_TB          : STD_LOGIC;
   signal    DB7_TB         : STD_LOGIC;
   signal    DB6_TB         : STD_LOGIC;
   signal    DB5_TB         : STD_LOGIC;
   signal    DB4_TB         : STD_LOGIC;
   
   signal    B_TB           : STD_LOGIC_VECTOR (3 downto 0);

   begin
      UUT1 : TOP
         port map (Clock     => Clock_TB, 
                   Reset     => Reset_TB,
                   Direction => Direction_TB,
      			         	EN        => EN_TB,
                   RS        => RS_TB,
                   RW        => RW_TB,
                   DB7       => DB7_TB,
                   DB6       => DB6_TB,
                   DB5       => DB5_TB,
                   DB4       => DB4_TB,
                   B         => B_TB);
                   
                   
                   
                   
                   

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
      B_STIM : process
       begin
          B_TB <= "1011"; wait; 
       end process B_STIM;
-----------------------------------------------   

end architecture test_TOP_arch;
