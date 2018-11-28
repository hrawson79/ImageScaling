--Engineer     : Navdeep Dahiya 
--Date         : 11/18/2018
--Name of file : scale_up_two.vhd
--Description  : simple scale up image saved in block rom by two
--               by copying every row and column twice
-- Modified
-- Date	       : 11/27/2018
-- Engineer    : Navdeep Dahiya

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scale_up_two is
  port (
       -- input side
       clk, rst       : in  std_logic;
       rd_addr        : in integer range 0 to 59999; -- RAM address; TB or VGA uses to read the output stored in ram
       -- output side
       data_out       : out std_logic_vector (7 downto 0);
       ram_data_out   : out std_logic_vector (7 downto 0);
       out_valid      : out std_logic
       );
end scale_up_two;

architecture arch of scale_up_two is
signal data_o  : std_logic_vector(7 downto 0);

signal data_p  : std_logic_vector(7 downto 0);
signal valid_p : std_logic;
signal delay : integer;
signal done  : std_logic;
signal done_p  : std_logic;
signal done_ram : std_logic;

constant w : integer := 299; -- 0 indexed width of input
constant h : integer := 199; -- 0 indexed height of input
constant max_rom_addr : integer := 59999; -- max input image linear address 300x200 - 1
constant max_ram_addr : integer := 239999; -- max output image linear address 600x400 - 1
signal r : integer := 0; -- row number for input rom
signal c : integer := 0; -- col number for input rom
signal addr    : INTEGER RANGE 0 TO max_rom_addr; -- Input rom linear address index 
signal t_addr  : integer range 0 to max_ram_addr;  -- Target RAM linear address index 
signal we      : std_logic; -- Ram we enable
signal col_repeated : std_logic; -- Each row and column needs to be duplicated
signal row_repeated : std_logic; -- These keep track of duplication

component blk_rom
  port (
        -- input side
        clk           : in std_logic;
        rst           : in std_logic;
        addr  	      : in INTEGER RANGE 0 TO max_rom_addr; -- address bits
        -- output side
        data_o        : out std_logic_vector(7 downto 0)
        );
end component;

component blk_ram
  port (
       -- input side
       clk      	: in  std_logic;
       rst      	: in  std_logic;
       wr_address 	: in integer range 0 to max_ram_addr;
       rd_address   	: in integer range 0 to max_ram_addr;
       we 		: in std_logic; 
       data_i 		: in std_logic_vector(7 downto 0);
       data_o 		: out std_logic_vector(7 downto 0)
       );
end component;

begin

-- Map input clk/rst to ROM and local address and data out to ROM
ROM : blk_rom
  port map (
            -- input side
            clk       => clk,
            rst       => rst,
            addr      => addr,
            -- output side
            data_o    => data_o
            );

RAM : blk_ram
   port map (
            -- input side
            clk       		=> clk,
            rst       		=> rst,
            wr_address     	=> t_addr,
            rd_address		=> rd_addr,
            we			=> we,
            data_i              => data_o,
            -- output side
            data_o    => ram_data_out
            );

-- Controller 1: Generate input image (row,col) indexes
-- Goes through input image indexes
-- (row, col) in row major fashion. example:
-- row 0: col 0 to width - 1
-- row 1: col 0 to width - 1 
-- and so on for r = height - 1
cntrl_1 : process (clk)
begin
  if (rising_edge(clk)) then
    if (rst = '1') then
      r <= 0;
      c <= 0;
      done <= '0';
      col_repeated <= '0';
      row_repeated <= '0';
    else
      if (r <= h) then
        if (c < w) then -- Not yet reached end of row
          if (col_repeated = '1') then
            c <= c + 1;
            col_repeated <= '0';
          else
            col_repeated <= '1';
          end if;
        end if;
        if (c = w) then -- Reached end of row: reset col to 0 and increment row
          if (col_repeated = '1') then
           c <= 0;
           col_repeated <= '0';
	   if (row_repeated = '1') then 
             if (r < h) then
	       r <= r + 1;
             else
               done <= '1';
             end if;
             row_repeated <= '0';
           else
             row_repeated <= '1';
           end if;
          else
           col_repeated <= '1';
         end if;
        end if;
      end if;
    end if;
  end if;
end process;

-- generate address for ROM

PROCESS(clk)
BEGIN
    IF (clk'EVENT AND clk = '1') THEN
        --if (done <= '0') then
          addr <= (r * (w+1)) + c;
       -- end if;
    END IF;
END PROCESS;

-- ram/rom each has latency of 1 clock cycle so introduce a delay of 2 cycles
p_delay : process (clk)
begin
  if (rising_edge(clk)) then
    if (rst = '1') then
      delay <= 0;
      we <= '0';
    else
      if (delay = 0) then
        delay <= 1;
        we <= '0';
      elsif (delay <= 1) then
	delay <= 2;
        we <= '1';
      else
        delay <= 2;
        if (t_addr < max_ram_addr) then
	  we <= '1';
        else
          we <= '0';
        end if;
      end if;
    end if;
  end if;
end process;

p : process (clk)
begin
  if (rising_edge(clk)) then
    if (rst = '1') then
      valid_p <= '0';
      done_p <= '0';
      t_addr <= 0;
    else
      if (delay = 2) then
        valid_p <= '1';
      else
        valid_p <= '0';
      end if;
      if (delay = 2) then
        data_p <= data_o;
        if (t_addr < max_ram_addr) then
	   t_addr <= t_addr + 1;
        else
           done_p <= '1';
        end if;
      end if;
    end if;
  end if;
end process;

-- Writing to ram takes one cycle longer
p_ram_done : process (clk)
begin
  if (rising_edge(clk)) then
    if (rst = '1') then
      done_ram <= '0';
    else
      if (done_p = '1') then
        done_ram <= '1';
      else
        done_ram <= '0';
      end if;
    end if;
  end if;
end process;

--out_valid <= valid_p and (not done_p);
out_valid <= valid_p and (not done_ram);
data_out <= data_p;

end arch;



































