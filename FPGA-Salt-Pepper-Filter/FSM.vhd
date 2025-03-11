library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.project.all; 


entity FSM is port(
------ IN -------------
	clk : in std_logic;
	start : in std_logic ; 
	rom_address : out std_logic_vector(7 downto 0 );
	ram_address : out std_logic_vector(7 downto 0 );
---------- OUT ----------	
	done : out std_logic ;
	push : out std_logic;
	reset : in std_logic;
	--buffer_enable : out std_logic; -- ST_push
	ram_en : out std_logic
);	
end entity ; 



architecture FSM_arc of FSM is 


signal s_start,s_done,s_push,s_ram_en,s_rom_en,s_reset,s_enable: std_logic;
signal s_rom_address,s_ram_address: std_logic_vector(7 downto 0);
signal s_firstline,s_lastline:	std_logic		:=	'0';
signal s_rom2buff: std_logic_vector( (pic_w * color_depth-1) downto 0);
signal s_buff2ram: std_logic_vector( (pic_w * color_depth-1) downto 0);
signal s_lena_out : std_logic_vector( (pic_w * color_depth-1) downto 0);

type FSM is (idle, R1, R ,R_end,finish);
signal state : FSM;

--Signals For Delay The Outputs:
signal s_ram_address1, s_ram_address2, s_ram_address3, s_ram_address4:std_logic_vector(ram_address'HIGH downto 0) := (others=>'0');
signal  s_ram_en1, s_ram_en2, s_ram_en3, s_ram_en4,s_ram_en5:std_logic:='0';
signal push_s1:std_logic:= '0';

begin

ram_en <= s_ram_en;
--buffer_enable <= s_enable; -- ST push
rom_address <= s_rom_address;
ram_address <= s_ram_address;

		process(clk,reset)
		begin
		
			if(reset ='1') then
				state <= idle;
				--start <= '0';
				push <= '0';	
				s_ram_en <= '0';
				done <= '0';
				s_rom_address <= (others=>'0');
				s_ram_address <= (others=>'0');
				--buffer_enable <= '0';
				s_ram_en <= '0';
				s_rom_en <= '0';
				s_firstline <= '0';
				s_lastline <= '0';
					
			elsif(rising_edge(clk)) then
			
			
				-- Delay Signals:
			--s_ram_en1	<=	s_ram_en;
			--s_ram_en2	<=	s_ram_en1;
			--s_ram_en3	<=	s_ram_en2;
			--s_ram_en4	<=	s_ram_en3;
			--s_ram_en5	<=	s_ram_en4;
			
			--s_ram_address1	<=	s_ram_address;
			--s_ram_address2	<=	s_ram_address1;
			--s_ram_address3	<=	s_ram_address2;
			--s_ram_address4	<=	s_ram_address3;
			
			push_s1		<=	s_push;
			push		<=	push_s1;
			push 		<=  s_push;


			
			 --	Counters For ROM:
			if (s_rom_en and not(s_firstline) and not(s_lastline)) = '1' then
				s_rom_address	<=	s_rom_address + '1';
			end if;
			
			--	Counter For RAM:
			if (s_ram_en and not(s_firstline) and not(s_lastline)) = '1' then
				s_ram_address	<=	s_ram_address + '1';			
			end if;
			 
			 
			 -- Default Values For Signals:
			state 	<= 	state;
			s_push		<= 	'0';
			s_rom_en	<=	'0';
			s_ram_en	<= 	'0';
			s_firstline	<=	'0';
			s_lastline 	<=	'0';
			 
			 case state is
			 
			 when idle =>  
					if(start ='1') then
					s_push <= '1';
					state <= R1;
					end if;
			 when R1 =>
					s_push <= '1';
					s_ram_en <= '1';
					s_rom_en <= '1';
					s_firstline <= '1';
					state <= R;
			 when R => 
					s_push <= '1';
					s_ram_en <= '1';
					s_rom_en <= '1';					
					if (s_rom_address = 254) then -- the last line before last line
						s_lastline <= '1';
						state <= R_end;
					end if;
			 when R_end => 
					s_push <= '1';
					s_ram_en <= '1';
					s_rom_en <= '1';	
					state <= finish;
			 when finish =>
				if(s_ram_address = 255) then
				done <= '1';
				--state <= idle;	
				end if;
			when others =>
				state <= idle;
				
			end case;
		
		end if;
	end process;
 end architecture;














	