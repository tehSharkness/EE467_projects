------------------------------------------------------------------------------------------------------------
-- File name   : lcd_counter.vhd
--
-- Project     : EE367 - Logic Design (Spring 2007)
--
-- Description : VHDL model of a counter
--
-- Author(s)   : Brock J. LaMeres
--               Montana State University
--               lameres@ece.montana.edu
--
-- Date        : January 10, 2007
-- 
-- Modified for lcd by : 
--					  Clint Gauer
--					  January 28, 2008
--
-- Note(s)     : This file contains the Entity and Architecture
--               
--
------------------------------------------------------------------------------------------------------------
library IEEE;                    -- this library adds additional capability for VHDL
use IEEE.std_logic_1164.all;     -- this package has "STD_LOGIC" data types
use IEEE.STD_LOGIC_ARITH.ALL;    --  
use IEEE.STD_LOGIC_UNSIGNED.ALL; --


entity lcd_counter is
    Port ( Clock     : in  STD_LOGIC;
           Reset     : in  STD_LOGIC;
           Count_Out : out STD_LOGIC_VECTOR (11 downto 0));
end lcd_counter;

architecture lcd_counter_arch of lcd_counter is

signal count_int : std_logic_vector(11 downto 0) := x"000";

begin


process (Clock, Reset) 
begin
    
   if (Reset = '0') then 
         count_int <= x"000";
         
   elsif (Clock='1' and Clock'event) then
   		count_int <= count_int + 1;
   end if;
end process;
 
Count_Out <= count_int;
						
end lcd_counter_arch;

