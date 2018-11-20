-- Used to test VGA 
-- Author: Hunter R

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY vga_test IS
    PORT(
        clk                       :   IN STD_LOGIC;
        sw                        :   IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        led                       :   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
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
            fifo_rd                               : OUT STD_LOGIC;
            address                               : OUT INTEGER RANGE 0 TO 307199);
    END COMPONENT;
    
    COMPONENT blk_rom is
      port (
        -- input side
        clk    : in std_logic;
        rst    : in std_logic;
        addr    : in INTEGER RANGE 0 TO 307199; -- address bits
        --output side
        data_o    : out std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    
    COMPONENT blk_ram is
      port (
           -- input side
           clk      : in  std_logic;
           rst      : in  std_logic;
           wr_address     : in integer;
           rd_address   : in integer;
           we : in std_logic; -- Write enable
           data_i : in std_logic_vector(7 downto 0);
           data_o : out std_logic_vector(7 downto 0)
           );
       END COMPONENT;
       
       COMPONENT scale_down_two is
         port (
              -- input side
              clk, rst       : in  std_logic;
              -- output side
              data_out       : out std_logic_vector (7 downto 0);
              out_valid      : out std_logic
              );
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
    SIGNAL rd_address : INTEGER RANGE 0 TO 307199;
    SIGNAL wr_address : INTEGER RANGE 0 TO 307199;
    SIGNAL pixel_in : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL fifo_rd : STD_LOGIC;
    -- TEST ARRAY
    SIGNAL wr_data : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL wr_en : STD_LOGIC;
    SIGNAL fifo_full, fifo_empty : STD_LOGIC;
    SIGNAL addr : STD_LOGIC_VECTOR(17 DOWNTO 0);
    SIGNAL SDT_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL SDT_out_valid : STD_LOGIC;
    SIGNAL ram_addr : INTEGER;
    SIGNAL ram_we : STD_LOGIC := '1';
    SIGNAL ram_din : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ram_dout : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL done : STD_LOGIC := '0';
    SIGNAL cnt : INTEGER RANGE 0 TO 307199 := 0;
    --TYPE m IS ARRAY (0 TO 360000) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    --SIGNAL et : m := (OTHERS => (OTHERS => '1'));
BEGIN
    -- Generate test fifo data
--    PROCESS(clk)
--        VARIABLE px : STD_LOGIC_VECTOR(3 DOWNTO 0);
--        VARIABLE flag : STD_LOGIC := '0';
--    BEGIN
--        IF (clk'EVENT AND clk = '1') THEN
--            IF (fifo_rd = '1') THEN
--                pixel_in <= "1111";
--            ELSE
--                pixel_in <= "0000";
--            END IF;
--        END IF
--    END PROCESS;

    PROCESS (pixel_clk)
    BEGIN
        IF (pixel_clk'EVENT AND pixel_clk = '1') THEN
            IF (cnt <= 307198) THEN
                ram_we <= '1';
                cnt <= cnt + 1;
            ELSE
                ram_we <= '0';
            END IF;
        END IF;
    END PROCESS;
    --ram_we <= sw(0);
    led(0) <= ram_we;
    --addr <= STD_LOGIC_VECTOR(TO_UNSIGNED(address, 18));
    
    u1 : COMPONENT vga PORT MAP(clk, sw(0), sw(1), sw(2), pixel_in(7 DOWNTO 4), 200, 300, pixel_clk, Hsync, Vsync, vgaRed, vgaGreen, vgaBlue, nblanck, nsync, fifo_rd, rd_address);
    --u2 : COMPONENT blk_rom PORT MAP(clk, '0', address, pixel_in);
    u3 : COMPONENT scale_down_two PORT MAP(pixel_clk, '0', SDT_data_out, SDT_out_valid);
    u4 : COMPONENT blk_ram PORT MAP(pixel_clk, '0', wr_address, rd_address, ram_we, ram_din, ram_dout);
    
    pixel_in <= ram_dout;
    ram_din <= SDT_data_out;
    --ram_addr <= rd_address;
    
--    u2 : COMPONENT fifo GENERIC MAP(4, 5)
--                        PORT MAP(clk, pixel_clk, fifo_rd, wr_data, wr_en, fifo_full, fifo_empty, pixel_in);
END vga_test;