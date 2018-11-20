--Engineer     : Navdeep Dahiya 
--Date         : 11/17/2018
--Name of file : scale_down_two.vhd
--Description  : Scale down image saved in block rom by two

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scale_down_two is
  port (
       -- input side
       clk, rst       : in  std_logic;
       rd_addr        : in integer range 0 to 63;
       -- output side
       data_out       : out std_logic_vector (7 downto 0);
       ram_data_out   : out std_logic_vector (7 downto 0);
       out_valid      : out std_logic
       );
end scale_down_two;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of scale_down_two is
signal data_o  : std_logic_vector(7 downto 0);

signal data_p  : std_logic_vector(7 downto 0);
signal valid_p : std_logic;
signal delay : integer;
signal done  : std_logic;
signal done_p  : std_logic;

constant w : integer := 15; -- 0 indexed width of input
constant h : integer := 15; -- 0 indexed height of input
signal r : integer := 0; -- row number for input rom
signal c : integer := 0; -- col number for input rom
signal addr    : INTEGER RANGE 0 TO 255; -- Input rom linear address index
signal t_addr  : integer range 0 to 63;  -- Target RAM linear address index
signal we      : std_logic; -- Ram we enable

component blk_rom
  port (
        -- input side
        clk           : in std_logic;
        rst           : in std_logic;
        addr  	      : in INTEGER RANGE 0 TO 255; -- address bits
        -- output side
        data_o        : out std_logic_vector(7 downto 0)
        );
end component;

component blk_ram
  port (
       -- input side
       clk      	: in  std_logic;
       rst      	: in  std_logic;
       wr_address 	: in integer range 0 to 63;
       rd_address   	: in integer range 0 to 63;
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
           
-- index to alternate row and col
-- effectively scale down data by 2
gen_index : process (clk)
begin
  if (rising_edge(clk)) then
    if (rst = '1') then
      r <= 0;
      c <= 0;
      done <= '0';
    else
      if (r <= h) then
        if (c < (w-1)) then
          c <= c + 2;
        end if;
        if ((c = w) or (c = (w-1))) then
          if (r < (h-1)) then
            r <= r + 2;
            c <= 0;
          else
            done <= '1';
          end if;
        end if;
      --else
     --   done <= '1';
      end if;
    end if;
  end if;
end process;

-- generate address for ROM
--addr <= std_logic_vector(to_unsigned(r,4)) & std_logic_vector(to_unsigned(c,4));
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
        if (t_addr < 63) then
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
        if (t_addr < 63) then
	   t_addr <= t_addr + 1;
        else
           done_p <= '1';
        end if;
        done_p <= done;
      end if;
    end if;
  end if;
end process;

out_valid <= valid_p and (not done_p);
data_out <= data_p;

end arch;
