------------------------------------------------------------------------------------------------------------
-- File name   : counter.vhd
--
-- Project     : EE367 - Logic Design
--        
--
-- Description : VHDL model of a 4-bit Up/Down Comparator
--
-- Author(s)   : Brock J. LaMeres
--               Montana State University
--               lameres@ece.montana.edu
--
-- Date        : 
--
-- Note(s)     : This file contains the Entity and Architecture
--               
--
------------------------------------------------------------------------------------------------------------
library IEEE;                    -- this library adds additional capability for VHDL
use IEEE.std_logic_1164.all;     -- this package has "STD_LOGIC" data types
use IEEE.STD_LOGIC_ARITH.ALL;    --  
use IEEE.STD_LOGIC_UNSIGNED.ALL; --


entity counter is
    Port ( Clock     : in  STD_LOGIC;
           Reset     : in  STD_LOGIC;
           Direction : in  STD_LOGIC;
           Count_Out : out STD_LOGIC_VECTOR (3 downto 0));
end counter;

architecture counter_arch of counter is

signal count_int : std_logic_vector(3 downto 0) := "0000";

begin


process (Clock, Reset) 
begin
    
   if (Reset = '0') then 
         count_int <= "0000";
         
   elsif (Clock='1' and Clock'event) then
      if (Direction='0') then   
         count_int <= count_int + 1;
      else
         count_int <= count_int - 1;
      end if;
   end if;
end process;
 
Count_Out <= count_int;
						
end counter_arch;

