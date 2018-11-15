-- Used to test VGA 
-- Author: Hunter R

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY vga_test IS
    PORT(
        clk                       :   IN STD_LOGIC;
        sw                        :   IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Hsync, Vsync              :   OUT STD_LOGIC;
        vgaRed, vgaGreen, vgaBlue : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));        
END vga_test;

ARCHITECTURE vga_test OF vga_test IS
    COMPONENT vga IS
        GENERIC(
            Ha : INTEGER := 96;     -- Hpulse
            Hb : INTEGER := 144;    -- Hpulse+HBP
            Hc : INTEGER := 784;    -- Hpulse+HBP+Hactive
            Hd : INTEGER := 800;    -- Hpulse+HBP+Hactive+HFP
            Va : INTEGER := 2;      -- Vpulse
            Vb : INTEGER := 35;     -- Vpulse+VBP
            Vc : INTEGER := 515;    -- Vpulse+VBP_Vactive
            Vd : INTEGER := 525);    -- Vpulse+VBP+Vactive+VFP
        PORT(
            clk                                   : IN STD_LOGIC; -- 100MHz
            red_switch, green_switch, blue_switch : IN STD_LOGIC;
            pixel_in                              : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            rows                                  : IN INTEGER RANGE 1 TO 480;  -- Controller controls size of image
            cols                                  : IN INTEGER RANGE 1 TO 640;  -- Controller controls size of image
            pixel_clk                             : BUFFER STD_LOGIC;
            Hsync, Vsync                          : BUFFER STD_LOGIC;
            R, G, B                               : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);   -- Only have 4 bits each on basys3 board
            nblanck, nsync                        : OUT STD_LOGIC;
            fifo_rd                               : OUT STD_LOGIC);
    END COMPONENT;
    
--    COMPONENT fifo IS
--        GENERIC(
--            WIDTH : INTEGER := 8;  -- should be the width of a row of pixels for output image
--            DEPTH : INTEGER := 4); -- should be large enough to prevent stalling
--        PORT(
--            wr_clk        : IN    STD_LOGIC;
--            rd_clk        : IN    STD_LOGIC;
--            rd_en         : IN    STD_LOGIC;
--            wr_data       : IN    STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0);
--            wr_en         : IN    STD_LOGIC;
--            fifo_full     : OUT   STD_LOGIC;
--            fifo_empty    : OUT   STD_LOGIC;
--            rd_data       : OUT   STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0));
--    END COMPONENT;
    
    SIGNAL pixel_clk : STD_LOGIC;
    SIGNAL nblanck, nsync : STD_LOGIC;
    SIGNAL address : INTEGER RANGE 0 TO 300;
    SIGNAL pixel_in : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL fifo_rd : STD_LOGIC;
    -- TEST ARRAY
    SIGNAL wr_data : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL wr_en : STD_LOGIC;
    SIGNAL fifo_full, fifo_empty : STD_LOGIC;
BEGIN
    -- Generate test fifo data
    PROCESS(clk)
        VARIABLE px : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE flag : STD_LOGIC := '0';
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN
            IF (fifo_rd = '1') THEN
                pixel_in <= "1111";
            ELSE
                pixel_in <= "0000";
            END IF;
        END IF;
    END PROCESS;
    
    u1 : COMPONENT vga PORT MAP(clk, sw(0), sw(1), sw(2), pixel_in, 10, 10, pixel_clk, Hsync, Vsync, vgaRed, vgaGreen, vgaBlue, nblanck, nsync, fifo_rd);
--    u2 : COMPONENT fifo GENERIC MAP(4, 5)
--                        PORT MAP(clk, pixel_clk, fifo_rd, wr_data, wr_en, fifo_full, fifo_empty, pixel_in);
END vga_test;