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
       -- output side
       data_out       : out std_logic_vector (7 downto 0);
       out_valid      : out std_logic
       );
end scale_down_two;
-- DO NOT MODIFY PORT NAMES ABOVE

architecture arch of scale_down_two is
signal data_o  : std_logic_vector(7 downto 0);
signal addr    : std_logic_vector(7 downto 0);
signal data_p  : std_logic_vector(7 downto 0);
signal valid_p : std_logic;
signal delay : std_logic;
signal done  : std_logic;
signal done_p  : std_logic;

signal r : integer := 0; -- row number
signal c : integer := 0; -- col number
constant w : integer := 15; -- 0 indexed
constant h : integer := 15; -- 0 indexed

component blk_rom
  port (
        -- input side
        clk           : in std_logic;
        rst           : in std_logic;
        addr  	      : in std_logic_vector(7 downto 0); -- address bits
        -- output side
        data_o        : out std_logic_vector(7 downto 0)
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

-- index through all data (256)
-- simply pass all data from ROM to output
--gen_index : process (clk)
--begin
--  if (rising_edge(clk)) then
--    if (rst = '1') then
--      r <= 0;
--      c <= 0;
--      done <= '0';
--    else
--      if (r <= h) then
--        if (c < w) then
--          c <= c + 1;
--        end if;
--        if (c = w) then
--          r <= r + 1;
--          c <= 0;
--        end if;
--      else
--        done <= '1';
--      end if;
--    end if;
--  end if;
--end process;

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
          r <= r + 2;
          c <= 0;
        end if;
      else
        done <= '1';
      end if;
    end if;
  end if;
end process;

-- generate address for ROM
addr <= std_logic_vector(to_unsigned(r,4)) & std_logic_vector(to_unsigned(c,4));

-- ram has latency of 1 clock cycle so introduce a delay of 1 cycle
p_delay : process (clk)
begin
  if (rising_edge(clk)) then
    if (rst = '1') then
      delay <= '0';
    else
      if (delay = '0') then
        delay <= '1';
      else
	delay <= '1';
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
    else
      if (delay = '1') then
        valid_p <= '1';
      else
        valid_p <= '0';
      end if;
      if (delay = '1') then
        data_p <= data_o;
        done_p <= done;
      end if;
    end if;
  end if;
end process;

out_valid <= valid_p and (not done_p);
data_out <= data_p;

end arch;































