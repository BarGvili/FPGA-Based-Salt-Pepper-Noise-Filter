library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;



package project is
------- CONSTANTS -------------
constant pic_w : positive := 256;
constant pic_h : positive := 256;
constant full_color : positive := 8;
constant color_depth : positive :=5;
----- TYPES --------------
subtype  pixel is std_logic_Vector(color_depth-1 downto 0);
type row_of_pix		is array (natural range <>) of pixel; 								
type three_rows		is array (0 to 2) of row_of_pix (0 to (pic_w +1));
type matrix	is array (0 to 2) of row_of_pix (0 to 2);	

----------- FUNCTIONS --------------
	function bit_to_row_of_pix          (arg: std_logic_vector)	    return row_of_pix;
	function median_filter_row			(arg: row_of_pix)			return pixel;
	function median_of_median			(arg: matrix)				return pixel;
	function median3d					(arg: three_rows)			return row_of_pix;
	function pix_to_row_of_bit 			(arg: row_of_pix)			return std_logic_vector;
	
end package project;

package body project is
	function median3d (arg: three_rows) return row_of_pix is
		variable temp_row		:	row_of_pix (0 to pic_w-1);
		variable temp_matrix	:	matrix;
		begin 
			for i in 0 to pic_w-1 loop
				for j in 0 to 2 loop
					temp_matrix(j)	:= arg(j)(i to (i+2));
				end loop;
				temp_row(i) := median_of_median(temp_matrix);
			end loop;
		return temp_row;
	end function median3d;
	
	
	function median_of_median (arg: matrix) return pixel is
		variable temp_row	:	row_of_pix(0 to 2);
		variable temp_pixel	: 	pixel;
		begin 
			for i in 0 to 2 loop
				temp_row(i) := median_filter_row(arg(i));
			end loop;
			temp_pixel := median_filter_row(temp_row);
		return temp_pixel;
	end function median_of_median;
	
	
	function median_filter_row	 (arg: row_of_pix) return pixel is
		variable temp :	pixel;
		begin 
			if (arg(2) >= arg(1) and arg(2) <= arg(0)) then
				temp:= arg(2);
			elsif (arg(2) >= arg(0) and arg(2) <= arg(1)) then
				temp:= arg(2);
			elsif (arg(1) >= arg(0) and arg(1) <= arg(2)) then
				temp:= arg(1);
			elsif (arg(1) >= arg(2) and arg(1) <= arg(0)) then
				temp:= arg(1);
			elsif (arg(0) >= arg(1) and arg(0) <= arg(2)) then
				temp:= arg(0);
			else
				temp:= arg(0);
			end if;
		return temp;
	end function median_filter_row;
	 
	 
	function bit_to_row_of_pix (arg: std_logic_vector)		return row_of_pix is
		variable temp : row_of_pix(257 downto 0);
		begin
		for i in 0 to 257 loop
			temp(i) := arg((i*5+5)-1 downto (i*5));
		end loop;
		return temp;
		
	end function bit_to_row_of_pix;
	
	function pix_to_row_of_bit (arg: row_of_pix)		return std_logic_vector is
		variable temp : std_logic_vector(0 to (color_depth * pic_w)-1); -- 1280
		begin
		for i in 0 to 255 loop
			 temp ((color_depth *i) to ((color_depth*i)+4)):= arg(i);
		end loop;
		return temp;
	end function pix_to_row_of_bit;
	
end package body project;
	
	
	
