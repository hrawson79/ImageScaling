
LIBRARY ieee;
--LIBRARY ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

ENTITY tb_bilinear_controller IS
END tb_bilinear_controller;

ARCHITECTURE tb_bilinear_controller OF tb_bilinear_controller IS
  COMPONENT bilinear_controller IS
    PORT (clk, rst      : IN    STD_LOGIC;
          begin_trig    : IN    STD_LOGIC;
          rd_address    : IN    INTEGER RANGE 0 TO 239999;
          size_ctrl     : IN    STD_LOGIC;
          px_out        : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
  END COMPONENT;
  
  SIGNAL begin_trig : STD_LOGIC := '0';
  SIGNAL rd_address : INTEGER RANGE 0 TO 239999 := 0;
  SIGNAL size_ctrl : STD_LOGIC := '1';
  SIGNAL stage : INTEGER RANGE 1 TO 10 := 1;
  SIGNAL clk : STD_LOGIC := '0';
BEGIN

  u1 : COMPONENT bilinear_controller PORT MAP (clk, '0', begin_trig, rd_address, size_ctrl);

  PROCESS
  BEGIN
    clk <= '0';
    WAIT FOR 10 ns;
    clk <= '1';
    WAIT FOR 10 ns;
  END PROCESS;

  PROCESS (clk)
    
  BEGIN
    IF (clk'EVENT AND clk = '1') THEN
      IF (stage = 1) THEN
	begin_trig <= '1';
	stage <= 2;
      ELSE
	begin_trig <= '0';
	stage <= 5;
      END IF;
    END IF;
  END PROCESS;

END tb_bilinear_controller;