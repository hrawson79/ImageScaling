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
signal addr_reg : integer := 0;

begin

process(clk)
begin
  if (rising_edge(clk)) then
    if (we = '1') then
        ram(address) <= data_i;
    end if;
    if (rst = '1') then
      addr_reg <= 0;
    else
      addr_reg <= address;
    end if;
  end if;
end process;
data_o <= ram(addr_reg);
end arch;