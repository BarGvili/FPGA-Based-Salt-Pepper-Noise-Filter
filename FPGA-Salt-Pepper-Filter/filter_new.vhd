library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.project.all; 


entity filter_new is
port (    
        --clk         : in std_logic;
       -- rst         : in std_logic;
        row1     : in std_logic_vector (1289 downto 0);
        row2     : in std_logic_vector (1289 downto 0);
        row3     : in std_logic_vector (1289 downto 0);        
        fixed_row     : out std_logic_vector (1279 downto 0)
    );    
end entity filter_new;

architecture arc_filter of filter_new is
signal temp_row : three_rows;
signal temp_result :	row_of_pix (0 to pic_w-1);
begin
	temp_row(0) <= bit_to_row_of_pix(row1);
	temp_row(1) <= bit_to_row_of_pix(row2);
	temp_row(2) <= bit_to_row_of_pix(row3);
	
	temp_result <= median3d(temp_row);
	
	fixed_row <= pix_to_row_of_bit(temp_result);
		
end architecture arc_filter;