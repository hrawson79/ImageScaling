
--Engineer     : Navdeep Dahiya 
--Date         : 11/11/2018
--Name of file : tb_blk_ram.vhd
--Description  : test bench for simple block ram

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_blk_ram is
  generic (
    input_file_str  : string := "input_img.txt";
    output_file_str : string := "output_img.txt"
            );
end tb_blk_ram;

architecture tb_arch of tb_blk_ram is
  component blk_ram
    port (
          -- input side
          clk, rst    : in std_logic;
          we          : in std_logic;
          data_i      : in std_logic_vector (7 downto 0);
          address     : in integer;--unsigned (7 downto 0);
          -- output side
          data_o      : out std_logic_vector (7 downto 0)
          );
  end component;
  -- signals locl only to the present ip
  signal clk, rst     : std_logic;
  signal we           : std_logic;
  signal data_i       : std_logic_vector (7 downto 0);
  signal data_o       : std_logic_vector (7 downto 0);
  -- signals related to the file operations
  file input_data_file  : text;
  file output_file      : text;
  -- time
  constant T: time    := 20 ns;
  signal cycle_count  : integer;
  signal address      : integer := 0;
  constant rows	      : integer := 15; -- Loops are 0 indexed
  constant cols	      : integer := 15;
begin
  DUT: blk_ram
  port map (
            -- input side
            clk       => clk,
            rst       => rst,
            we        => we,
            data_i    => data_i,
            address   => address,
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
    variable input_data_line  : line;
    variable data_in          : integer;
    --variable data_in          : std_logic_vector (7 downto 0);
    variable char_comma       : character;
    variable output_line      : line;
  begin
    file_open(input_data_file, input_file_str, read_mode);
    file_open(output_file, output_file_str, write_mode);
    
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '1';
    wait until rising_edge(clk);
    rst <= '0';
    
    -- Main logic
    -- Store input image to RAM
    we <= '1'; -- Write enable
    for r in 0 to rows loop -- Number of rows 
      readline(input_data_file, input_data_line); -- Read entire row
      for c in 0 to cols loop -- Number of columns
        read(input_data_line, data_in);	-- Read each pixel value in row
        if (c < cols) then              -- Last column doesn't have a comma at end
          read(input_data_line, char_comma);
        end if;        
        
        -- drive the DUT
        data_i  <= std_logic_vector(to_unsigned(data_in,data_i'length));
        wait until rising_edge(clk);
        address <= address + 1;
      end loop; -- Column loop
    end loop; -- Row loop
    
    -- Read all values from RAM
    we <= '0'; -- Write disable
    address <= 0;
    wait until rising_edge(clk);
    
    for r in 0 to rows loop
      for c in 0 to cols loop
        address <= address + 1;
        wait until rising_edge(clk);        
        write(output_line, to_integer(unsigned(data_o)));
        if (c < cols) then
          write(output_line, string'(",")); -- Last column doesn't have a comma at end       
        end if;
      end loop; -- column loop
      writeline(output_file, output_line);
    end loop; -- row loop
    wait;
  end process;
   
  -- end simulation
  p_end_sim: process (clk)
  begin
    if (rising_edge(clk)) then
      if (cycle_count > 511) then
        file_close(input_data_file);
        file_close(output_file);
        report "Test completed";
        stop(0);
      end if;
    end if;
  end process;
  
end tb_arch;












































