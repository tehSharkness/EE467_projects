 ------------------------------------------------------------------------------------------------------------
-- File name   : lcd_clock_div.vhd
--
-- Project     : EE367 - Logic Design (Spring 2007)
--               
-- Description : VHDL model of a clock divider
--
-- Author(s)   : Brock J. LaMeres
--               Montana State University
--               lameres@ece.montana.edu
--
-- Date        : January 10, 2007

-- Modified for lcd by : 
--					  Clint Gauer
--					  January 28, 2008
--
-- Note(s)     : This file contains the Entity and Architecture
--               
--               This will divide the clock by a power of 2 to slow it down
--               so that the LEDs are visible on an eval board.
--
--               The way this divider works is that the input clock runs an 
--               n-bit binary counter.  The MSB of the counter is the output clock
--               The amount of the division is 2^n.
--
--               ex)  divide clock by 8, this would take a 2-bit counter
--                      
--                      000    - the LSB    (n-3) would represent a divide by 2
--                      001    - the middle (n-2) would represent a divide by 4
--                      010    - the MSB    (n-1) would represent a divide by 8
--                      011
--                      100    - the counter width "n" we need for a given division is:
--                      101
--                      110                  n=  log(Divider) / log(2)
--                      111
--
--
--
------------------------------------------------------------------------------------------------------------
library IEEE;                    -- this library adds additional capability for VHDL
use IEEE.std_logic_1164.all;     -- this package has "STD_LOGIC" data types
use IEEE.STD_LOGIC_ARITH.ALL;    --  
use IEEE.STD_LOGIC_UNSIGNED.ALL; --

entity lcd_clock_div is
   
    generic (n : integer := 12);               -- this is the width of the counter n, the divider = 2^n

    port   (Clock_In     : in   STD_LOGIC;
            Reset        : in   STD_LOGIC;
            Clock_Out    : out  STD_LOGIC;
            Clock_Out2   : out  STD_LOGIC);
            
end entity lcd_clock_div;

architecture lcd_clock_div_arch of lcd_clock_div is
  constant DIVISOR   : integer := (2**n)-1;
  signal   count_int : integer range 0 to DIVISOR-1;
  signal   count_std : STD_LOGIC_VECTOR (n-1 downto 0);
  signal   Clock2    : STD_LOGIC;

    begin

      process (Clock_In, Reset) 
      begin
         
         if (Reset = '0') then
             count_int <= 0;
             count_std <= (others => '0');
             Clock2 <= '0';
              
         elsif (Clock_In = '1' and Clock_In'event) then
             if (count_int = DIVISOR-1) then
               count_int <= 0;
               count_std <= (others => '0');
               Clock2 <= '0';
            else
              count_int <= count_int + 1;
              count_std <= count_std + 1;
                 if(count_int > 3*DIVISOR/5)then
                  Clock2 <= '1';
               else
                  Clock2 <= '0';
              end if;
            end if;
         end if;
end process;
 
-- Clock_Out <= '1' when  count_int = DIVISOR-1 else '0';     -- this is how we assign the MSB to the output clock
Clock_Out <= count_std(n-1);
Clock_Out2 <= Clock2;


end architecture lcd_clock_div_arch;


