------------------------------------------------------------------------------------------------------------
-- File name   : top.vhd
--
-- Project     : EE367 - Logic Design
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
				EN               : out  STD_LOGIC;
            RS               : out  STD_LOGIC;
            RW               : out  STD_LOGIC;
            DB7              : out  STD_LOGIC;
            DB6              : out  STD_LOGIC;
            DB5              : out  STD_LOGIC;
            DB4              : out  STD_LOGIC;
            B                : in   STD_LOGIC_VECTOR (4 downto 0));
            
end entity TOP;

architecture TOP_arch of TOP is
   
-- student design goes here.  Things needed...
-- 1) signal definition
  signal clock_slow :STD_LOGIC;
  signal counter_sig :STD_LOGIC_VECTOR (3 downto 0);

-- 2) component declaration for clock_div, counter, & lcd_blkbx
component clock_div
    port   (Clock_In     : in   STD_LOGIC;
            Reset        : in   STD_LOGIC;
            Clock_Out    : out  STD_LOGIC);
end component;
           
component counter
    Port ( Clock     : in  STD_LOGIC;
           Reset     : in  STD_LOGIC;
           Direction : in  STD_LOGIC;
           Count_Out : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component lcd_blkbx
    port   (Clock            : in   STD_LOGIC;
            Reset            : in   STD_LOGIC;
            EN               : out  STD_LOGIC;
            RS               : out  STD_LOGIC;
            RW               : out  STD_LOGIC;
            DB7              : out  STD_LOGIC;
            DB6              : out  STD_LOGIC;
            DB5              : out  STD_LOGIC;
            DB4              : out  STD_LOGIC;
            A                : in   STD_LOGIC_VECTOR (3 downto 0);
            B                : in   STD_LOGIC_VECTOR (4 downto 0));
end component;

-- 3) begin statement
begin

-- 4) component instantiation with port map defining how each block is connected
D1: clock_div port map(    Clock_In=>Clock,
                           Reset=>Reset,
                           Clock_Out=>clock_slow );
C1: counter port map(      Clock=>clock_slow,
                           Reset=>Reset,
                           Direction=>Direction,
                           Count_Out=> counter_sig);
LCD1: lcd_blkbx port map(  Clock=>Clock,
                           Reset=>Reset,
                           EN=>EN,
                           RS=>RS,
                           RW=>RW,
                           DB7=>DB7,
                           DB6=>DB6,
                           DB5=>DB5,
                           DB4=>DB4,
                           A=>counter_sig,
                           B=>B );
   
end architecture TOP_arch;


