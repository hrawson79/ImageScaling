
LIBRARY ieee;
--LIBRARY ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

ENTITY tb_bilinear_controller IS
  generic (
    output_file_str : string := "output_img.txt";
    output_cycle_str: string := "output_cycle.txt"
            );
END tb_bilinear_controller;

ARCHITECTURE tb_bilinear_controller OF tb_bilinear_controller IS
  COMPONENT bilinear_controller IS
    PORT (clk, rst      : IN    STD_LOGIC;
          begin_trig    : IN    STD_LOGIC;
          rd_address    : IN    INTEGER RANGE 0 TO 239999;
          size_ctrl     : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
          px_out        : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
  END COMPONENT;
  
  SIGNAL begin_trig : STD_LOGIC := '0';
  SIGNAL rd_address : INTEGER RANGE 0 TO 239999 := 0;
  SIGNAL size_ctrl : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
  SIGNAL stage : INTEGER RANGE 1 TO 10 := 1;
  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL rst : STD_LOGIC;
  signal cycle_count    : integer;
  signal delay		: integer := 0;
   constant num_cycles : integer := 241000; -- Expected number of cycles based on output image size
  file output_file      : text;
  file output_cycle_file : text;
  signal pix_out       : std_logic_vector (7 downto 0);
signal  stop_reading : std_logic := '1';
constant max_ram_size : integer := 59999;
BEGIN

  u1 : COMPONENT bilinear_controller PORT MAP (clk, '0', begin_trig, rd_address, size_ctrl, pix_out);

  PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR 10 ns;
    clk <= '1';
    WAIT FOR 10 ns;
  END PROCESS;
 
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
    file_open(output_cycle_file, output_cycle_str, write_mode);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';
    
    wait;
  end process;

  PROCESS (clk)
    
  BEGIN
    IF (clk'EVENT AND clk = '1') THEN
      if (rst = '0') then
      IF (stage = 1) THEN
	begin_trig <= '1';
	stage <= 2;
      ELSE
	begin_trig <= '0';
	stage <= 5;
      END IF;
     end if;
    END IF;
  END PROCESS;

  p_delay: process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '0') then
        if (delay < 9) then
          delay <= delay + 1;
        else
          if (rd_address <= max_ram_size) then
            rd_address <= rd_address + 1;
            stop_reading <= '0'; 
          else
            stop_reading <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
 
-- sampling the output
  p_sample: process (clk)
  variable output_line : line;
  variable output_cycle_line : line; 
  begin
    if (rising_edge(clk)) then
      if (rst = '0') then
        if (delay = 9) then
          if (stop_reading = '0') then
          write(output_line, to_integer(unsigned(pix_out)));
          writeline(output_file, output_line);
          write(output_cycle_line, cycle_count, left, 11);
          writeline(output_cycle_file, output_cycle_line);
          end if;
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
END tb_bilinear_controller;