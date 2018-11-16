
--Engineer     : Navdeep Dahiya 
--Date         : 11/15/2018
--Name of file : tb_blk_rom.vhd
--Description  : test bench for simple block rom

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_blk_rom is
  generic (
    output_file_str : string := "output_img.txt"
            );
end tb_blk_rom;

architecture tb_arch of tb_blk_rom is
  component blk_rom
    port (
          -- input side
          clk           : in std_logic;
          rst           : in std_logic;
          addr  	: in std_logic_vector(7 downto 0); -- address bits
          -- output side
          data_o        : out std_logic_vector(7 downto 0)
          );
  end component;
  -- signals local only to the present ip
  signal clk, rst     : std_logic;
  signal data_o       : std_logic_vector (7 downto 0);
  -- signals related to the file operations
  file output_file      : text;
  -- time
  constant T: time      := 20 ns;
  signal cycle_count    : integer;
  signal addr           : std_logic_vector(7 downto 0) := (others => '0');
  constant rows	        : integer := 15; -- Loops are 0 indexed
  constant cols	      : integer := 15;
begin
  DUT: blk_rom
  port map (
            -- input side
            clk       => clk,
            rst       => rst,
            addr      => addr,
            -- output side
            data_o    => data_o
            );
  p_clk: process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process;
  
  -- counting cycles
  p_cycle: process (clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        cycle_count <= 0;
      else
        cycle_count <= cycle_count + 1;
      end if;
    end if;
  end process;
  
  -- SIMULATION STARTS
  p_read_data: process
 
    variable char_comma       : character;
    variable output_line      : line;
  begin
    file_open(output_file, output_file_str, write_mode);
    
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';
    
    -- Main logic
    -- Read all values from ROM
    addr <= "00000000";
    wait until rising_edge(clk);
    for r in 0 to rows loop -- Number of rows 
      for c in 0 to cols loop -- Number of columns
        -- drive the DUT
       
        addr <= std_logic_vector(to_unsigned(r,4)) & std_logic_vector(to_unsigned(c,4));
        wait until rising_edge(clk);
        if (not (c = 0 and r = 0)) then -- to deal with 1 cycle latency
          write(output_line, to_integer(unsigned(data_o)));
          writeline(output_file, output_line); 
        end if;
      end loop; -- Column loop
    end loop; -- Row loop
    wait until rising_edge(clk);
    write(output_line, to_integer(unsigned(data_o)));
    writeline(output_file, output_line); 
    wait;
  end process;
   
  -- end simulation
  p_end_sim: process (clk)
  begin
    if (rising_edge(clk)) then
      if (cycle_count > 256) then
        file_close(output_file);
        report "Test completed";
        stop(0);
      end if;
    end if;
  end process;
  
end tb_arch;












































