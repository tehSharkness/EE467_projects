------------------------------------------------------------------------------------------------------------
-- File name   : top.vhd
--
-- Project     : EE367 - Logic Design
--               Lab #1 : Introduction to the Xilinx ML40X Eval Board
--
-- Description : VHDL model of 4-bit counter
--               The TOP module calls the counter and clock_div modules
--
-- Author(s)   : Brock J. LaMeres
--               Montana State University
--               lameres@ece.montana.edu
--
-- Date        :
--
-- Note(s)     : This file contains the Entity and Architecture
--               
--               Note that the standard ">", "<" etc are only defined for integer
--               and enumerated types (such as STD_LOGIC).  They are used 
--               assuming that the arrays are the same length and UNSIGNED.
--
------------------------------------------------------------------------------------------------------------
library IEEE;                    -- this library adds additional capability for VHDL
use IEEE.std_logic_1164.all;     -- this package has "STD_LOGIC" data types
use IEEE.STD_LOGIC_ARITH.ALL;    --  
use IEEE.STD_LOGIC_UNSIGNED.ALL; --

entity TOP is

    port   (Clock         : in   STD_LOGIC;
            Reset         : in   STD_LOGIC;
            Direction     : in   STD_LOGIC;
            Count_Out     : out  STD_LOGIC_VECTOR (3 downto 0) );
            
end entity TOP;

architecture TOP_arch of TOP is
  signal     Clock_Slow   : STD_LOGIC;
  
  component  clock_div  
     port  (Clock_In  : in  STD_LOGIC;   -- component declaration for 
            Reset     : in  STD_LOGIC;
            Clock_Out : out STD_LOGIC); 
  end component;
                            
  component  counter    
     port  (Clock     : in  STD_LOGIC;
            Reset     : in  STD_LOGIC;
            Direction : in  STD_LOGIC;
            Count_Out : out STD_LOGIC_VECTOR (3 downto 0)); 
  end component;
                                

  begin
      
    D1  : clock_div port map (Clock_In => Clock, Reset => Reset, Clock_Out => Clock_Slow); 
    C1  : counter   port map (Clock => Clock_Slow, Reset => Reset, Direction => Direction, Count_Out => Count_Out);   
    
end architecture TOP_arch;


