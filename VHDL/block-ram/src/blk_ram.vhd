--Engineer     : Navdeep Dahiya
--Date         : 11/15/2018
--Name of file : block_ram.vhd
--Description  : module RAM as block ram (need to change sizes as desired)
library ieee;
use ieee.std_logic_1164.all;

entity blk_ram is
  port (
       -- input side
       clk      : in  std_logic;
       rst      : in  std_logic;
       address 	: in integer;
       we : in std_logic; -- Write enable
       data_i : in std_logic_vector(7 downto 0);
       data_o : out std_logic_vector(7 downto 0)
       );
end blk_ram;

architecture arch of blk_ram is

type ram_t is array(0 to 255) of std_logic_vector(7 downto 0);
signal ram : ram_t := (others => (others => '0'));

begin

process(clk)
begin
  if (rising_edge(clk)) then
    if (we = '1') then
        ram(address) <= data_i;
    end if;
    if (rst = '1') then
      data_o <= "00000000";
    else
      data_o <= ram(address);
    end if;
  end if;
end process;
end arch;
