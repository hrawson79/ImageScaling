
--Engineer     : Navdeep Dahiya 
--Date         : 11/27/2018
--Name of file : tb_scale_down_two.vhd
--Description  : test bench for simple scale up by two image stored in rom
--		 Gets the output from scale_up_by_two.vhd file pixel by pixel
--		 using the out_valid signal and writes one pixel per row to 
--		 output_img.txt. The pixels are in row major form.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_scale_up_two is
  generic (
    output_file_str : string := "output_img.txt"
            );
end tb_scale_up_two;

architecture tb_arch of tb_scale_up_two is
  component scale_up_two
    port (
           -- input side
       clk, rst       : in  std_logic;
       rd_addr        : in integer range 0 to 59999;
       -- output side
       data_out       : out std_logic_vector (7 downto 0);
       ram_data_out   : out std_logic_vector (7 downto 0);
       out_valid      : out std_logic
          );
  end component;
  -- signals local only to the present ip
  signal clk, rst     : std_logic;
  signal data_out       : std_logic_vector (7 downto 0);
  signal ram_data_out       : std_logic_vector (7 downto 0);
  signal out_valid       : std_logic;
  signal rd_addr	: integer range 0 to 239999;
  -- signals related to the file operations
  file output_file      : text;
  -- time
  constant T: time      := 20 ns;
  signal cycle_count    : integer;
  constant rows	        : integer := 15; -- Loops are 0 indexed
  constant cols	      : integer := 15;
  constant num_cycles : integer := 240010;
begin
  DUT: scale_up_two
  port map (
            -- input side
            clk       => clk,
            rst       => rst,
            rd_addr   => rd_addr,
            -- output side
            data_out    => data_out,
            ram_data_out => ram_data_out,
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
      if (cycle_count > num_cycles) then
        file_close(output_file);
        report "Test completed";
        stop(0);
      end if;
    end if;
  end process;
  
end tb_arch;