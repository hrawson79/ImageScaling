-- Used to test VGA 
-- Author: Hunter R

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY bilinear_top IS
    PORT(
        clk                       :   IN STD_LOGIC;
        sw                        :   IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        btnC                      :   IN STD_LOGIC;
        led                       :   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        Hsync, Vsync              :   OUT STD_LOGIC;
        vgaRed, vgaGreen, vgaBlue : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));        
END bilinear_top;

ARCHITECTURE bilinear_top OF bilinear_top IS
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
            fifo_rd                               : OUT STD_LOGIC;
            address                               : OUT INTEGER RANGE 0 TO 59999);
    END COMPONENT;
    
    COMPONENT bilinear_controller IS
        PORT (clk, rst      : IN    STD_LOGIC;
              begin_trig    : IN    STD_LOGIC;
              rd_address    : IN    INTEGER RANGE 0 TO 59999;
              size_ctrl     : IN    STD_LOGIC;
              w             : BUFFER INTEGER RANGE 0 TO 599;
              h             : BUFFER INTEGER RANGE 0 TO 399;
              px_out        : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT;
    SIGNAL width : INTEGER RANGE 0 TO 599;
    SIGNAL height : INTEGER RANGE 0 TO 399;
    SIGNAL w_p_1 : INTEGER RANGE 0 TO 599;
    SIGNAL h_p_1 : INTEGER RANGE 0 TO 399;
    SIGNAL pixel_clk : STD_LOGIC;
    SIGNAL nblanck, nsync : STD_LOGIC;
    SIGNAL rd_address : integer range 0 to 59999;
    --SIGNAL wr_address : INTEGER RANGE 0 TO 307199;
    SIGNAL pixel_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL fifo_rd : STD_LOGIC;
BEGIN
    h_p_1 <= height+1;
    w_p_1 <= width+1;
    u1 : vga PORT MAP(clk, sw(0), sw(1), sw(2), pixel_in(7 DOWNTO 4), h_p_1, w_p_1, pixel_clk, Hsync, Vsync, vgaRed, vgaGreen, vgaBlue, nblanck, nsync, fifo_rd, rd_address);
    u2 : bilinear_controller PORT MAP (pixel_clk, '0', btnC, rd_address, sw(0), width, height, pixel_in);

END bilinear_top;