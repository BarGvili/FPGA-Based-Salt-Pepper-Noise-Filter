library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.project.all; 


entity Lena is
port (
      clk    : in    std_logic; 
      rst    : in    std_logic;  
      start  : in    std_logic;   
      done   : out   std_logic
);
     attribute altera_chip_pin_lc : string;
     attribute altera_chip_pin_lc of clk  : signal is "Y2";
     attribute altera_chip_pin_lc of rst  : signal is "AB28";
     attribute altera_chip_pin_lc of start: signal is "AC28";
     attribute altera_chip_pin_lc of done : signal is "E21";
	  
 
end entity Lena;



---- The actual Process of the Project ----------

architecture behav of Lena is 

component ROM is
	generic (init_rom_name : string);
	port(
	aclr		: IN STD_LOGIC  := '0';
	address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	clock		: IN STD_LOGIC  := '1';
	q		: OUT STD_LOGIC_VECTOR (1279 DOWNTO 0)
	);
end component;

component RAM is
	generic (inst_name : string);
	port(
		aclr		: IN STD_LOGIC  := '0';
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (1279 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (1279 DOWNTO 0)
	);
end component;

component new_buffer is
port(
	clk : in std_logic ;
	rst : in std_logic ; 
	ST_push: in std_logic;
	new_row : in std_logic_vector ( (pic_w*color_depth-1) downto 0 );
	
	row1 : out std_logic_vector ( ((pic_w+2)*color_depth-1) downto 0 );
	row2 : out std_logic_vector ( ((pic_w+2)*color_depth-1) downto 0 );
	row3 : out std_logic_vector ( ((pic_w+2)*color_depth-1) downto 0 )
);
end component;

component filter_new is
port(
		--rst : in std_logic;
		--clk : in std_logic;
		row1: in std_logic_vector((pic_w+2)*color_depth-1 downto 0);
		row2: in std_logic_vector((pic_w+2)*color_depth-1 downto 0);
		row3: in std_logic_vector((pic_w+2)*color_depth-1 downto 0);
		fixed_row : out std_logic_vector((pic_w)*color_depth-1 downto 0)
	);
end component;

component FSM is 
port(
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
end component;
----------TYPES-------------------
	type mem_row		is array (natural range <>) of std_logic_vector(1279 downto 0); 	
	type buf_row		is array (natural range <>) of std_logic_vector(1289 downto 0); 
---------ROM-------------
	constant mif_file_name_format: string := "x.mif";
	type     rom_str_arr is array (0 to 2) of string(mif_file_name_format'range);
	constant rom_arr : rom_str_arr := ("r.mif", "g.mif", "b.mif");
---------RAM---------------------
	constant ram_file_name_format: string := "xRAM";
	type     ram_str_arr is array (0 to 2) of string(ram_file_name_format'range);
	constant ram_arr : ram_str_arr := ("rRAM", "gRAM", "bRAM");
-----------------Signals----------
	signal	s_push,s_ram_en			:	std_logic;
	signal	s_rom_address,s_ram_address	:	std_logic_vector(7 downto 0);
	signal	s_r1,s_r2,s_r3	:	buf_row (2 downto 0);
	signal	s_fixed_row,s_new_row				:	mem_row (2 downto 0);

begin

u1: FSM
port map(
	clk => clk,
	start => start,
	rom_address => s_rom_address,
	ram_address =>s_ram_address,
	done => done,
	reset => rst,
	--buffer_enable 
	ram_en => s_ram_en,
    push => s_push
);

L1: for i in 0 to 2 generate
	u2: new_buffer

	port map (
	clk => clk,
	rst => rst,
	ST_push => s_push,
	new_row => s_new_row(i),
	row1 => s_r1(i),
	row2 => s_r2(i),
	row3 => s_r3(i)
);
end generate L1;	
	
L2: for i in 0 to 2 generate
	u3: filter_new
	port map (
		--clk		=>	clk,
		--rst  	=>	rst,
		row1 =>	s_r1(i),
		row2 =>	s_r2(i),
		row3 =>	s_r3(i),
		fixed_row	=>	s_fixed_row(i)
		);
end generate L2;	
	
	
L3: for i in 0 to 2 generate
	u4: entity work.ROM
	generic map (
	init_rom_name => rom_arr(i)
	)
	port map (
		aclr	=>	rst,
		address =>	s_rom_address,
		clock	=>	clk,
		q   	=>	s_new_row(i)

		);
end generate L3;

L4: for i in 0 to 2 generate
	u5: entity work.RAM
	generic map (
	inst_name => ram_arr(i)
	)
	port map (
		aclr	=>	rst,	
		address	=>	s_ram_address,
		clock	=>	clk,
		data	=>	s_fixed_row(i),
		wren	=>	s_ram_en,	
		q		=>	open
		);
end generate L4;
	
end architecture behav;	
	
	
	
	

