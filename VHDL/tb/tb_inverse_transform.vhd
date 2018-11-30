LIBRARY ieee;
--LIBRARY ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

ENTITY tb_inverse_transform IS
END tb_inverse_transform;

ARCHITECTURE tb_inverse_transform OF tb_inverse_transform IS
  COMPONENT bilinear_interpolation IS
    PORT(clk, rst   : IN    STD_LOGIC;
         a,b,c,d    : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
         x_h        : IN    INTEGER RANGE 0 TO 599;
         y_h        : IN    INTEGER RANGE 0 TO 399;
         scale      : IN    STD_LOGIC_VECTOR(5 DOWNTO 0);
         in_valid   : IN    STD_LOGIC;
         address    : OUT   INTEGER RANGE 0 TO 239999;
         we         : OUT   STD_LOGIC;
         x_p        : OUT   INTEGER RANGE 0 TO 299;
         y_p        : OUT   INTEGER RANGE 0 TO 199;
         pixel      : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0));
  END COMPONENT;

  SIGNAL a,b,c,d    : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL x_h        : INTEGER RANGE 0 TO 599;
  SIGNAL y_h        : iNTEGER RANGE 0 TO 399;
  SIGNAL scale      : STD_LOGIC_VECTOR(5 DOWNTO 0);
  SIGNAL in_valid   : STD_LOGIC := '0';
  SIGNAL address    : INTEGER RANGE 0 TO 239999;
  SIGNAL we         : STD_LOGIC;
  SIGNAL x_p        : INTEGER RANGE 0 TO 299;
  SIGNAL  y_p        : INTEGER RANGE 0 TO 199;
  SIGNAL  pixel      : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL stage : INTEGER RANGE 1 TO 10 := 1;
  SIGNAL clk : STD_LOGIC := '0';
BEGIN

  u1 : COMPONENT bilinear_interpolation PORT MAP(clk, '0', a, b, c, d, x_h, y_h, scale, in_valid);

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
	in_valid <= '1';
        x_h <= 20;
        y_h <= 40;
        scale <= "000100";
        stage <= stage + 1;
      ELSIF (stage = 2) THEN
	stage <= stage + 1;
      ELSIF (stage = 3) THEN
        a <= "00000000";
	b <= "00000010";
	c <= "00000100";
	d <= "00000001";
        stage <= stage + 1;
      ELSE
	stage <= 5;
      
--      stage <= stage + 1;
      END IF;
    END IF;
  END PROCESS;

END tb_inverse_transform;