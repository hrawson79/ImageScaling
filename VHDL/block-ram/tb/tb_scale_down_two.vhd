
--Engineer     : Navdeep Dahiya 
--Date         : 11/15/2018
--Name of file : tb_blk_rom.vhd
--Description  : test bench for simple scale down by two image stored in rom

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_scale_down_two is
  generic (
    output_file_str : string := "output_img.txt"
            );
end tb_scale_down_two;

architecture tb_arch of tb_scale_down_two is
  component scale_down_two
    port (
          -- input side
          clk           : in std_logic;
          rst           : in std_logic;
          -- output side
          data_out        : out std_logic_vector(7 downto 0);
          out_valid        : out std_logic
          );
  end component;
  -- signals local only to the present ip
  signal clk, rst     : std_logic;
  signal data_out       : std_logic_vector (7 downto 0);
  signal out_valid       : std_logic;
  
  -- signals related to the file operations
  file output_file      : text;
  -- time
  constant T: time      := 20 ns;
  signal cycle_count    : integer;
  constant rows	        : integer := 15; -- Loops are 0 indexed
  constant cols	      : integer := 15;
begin
  DUT: scale_down_two
  port map (
            -- input side
            clk       => clk,
            rst       => rst,
            -- output side
            data_out    => data_out,
            out_valid => out_valid
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
  --variable output_line : line;
  begin
    file_open(output_file, output_file_str, write_mode);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';
    
    wait;
  end process;
  
  -- sampling the output
  p_sample: process (clk)
  variable output_line : line; 
  begin
    if (rising_edge(clk)) then
      if (rst = '0') then
        if (out_valid = '1') then
          write(output_line, to_integer(unsigned(data_out)));
          writeline(output_file, output_line);
        end if;
      end if;
    end if;
  end process;

  -- end simulation
  p_end_sim: process (clk)
  begin
    if (rising_edge(clk)) then
      if (cycle_count > 270) then
        file_close(output_file);
        report "Test completed";
        stop(0);
      end if;
    end if;
  end process;
  
end tb_arch;
