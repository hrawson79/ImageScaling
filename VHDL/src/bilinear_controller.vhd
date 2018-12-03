LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bilinear_controller IS
    PORT (clk, rst      : IN    STD_LOGIC;
          begin_trig    : IN    STD_LOGIC;
          rd_address    : IN    INTEGER RANGE 0 TO 59999;
          size_ctrl     : IN    STD_LOGIC;
          w             : BUFFER INTEGER RANGE 0 TO 299;
          h             : BUFFER INTEGER RANGE 0 TO 199;
          px_out        : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
END bilinear_controller;
    
ARCHITECTURE bilinear_controller OF bilinear_controller IS
    --SIGNAL w : INTEGER RANGE 0 TO 599;
    --SIGNAL h : INTEGER RANGE 0 TO 399;
    SIGNAL scale : STD_LOGIC_VECTOR(5 DOWNTO 0);
    
    SIGNAL x : INTEGER RANGE 0 TO 299;  -- Used to traverse rows and cols
    SIGNAL y : INTEGER RANGE 0 TO 199;
    
    -- fsm structure
    TYPE controller_fsm_type IS (idle, transform, done);
    SIGNAL controller_fsm : controller_fsm_type := idle;
    SIGNAL prev_begin_trig : STD_LOGIC;
    
    -- COMPONENTS
    COMPONENT bilinear_interpolation IS
        PORT(clk, rst   : IN    STD_LOGIC;
             a,b,c,d    : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
             x_h        : IN    INTEGER RANGE 0 TO 299;
             y_h        : IN    INTEGER RANGE 0 TO 199;
             scale      : IN    STD_LOGIC_VECTOR(5 DOWNTO 0);
             in_valid   : IN    STD_LOGIC;
             rows       : IN    INTEGER RANGE 0 TO 299;
             address    : OUT   INTEGER RANGE 0 TO 59999;
             we         : OUT   STD_LOGIC;
             x_p        : OUT   INTEGER RANGE 0 TO 149;
             y_p        : OUT   INTEGER RANGE 0 TO 99;
             pixel      : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
     END COMPONENT;
     SIGNAL in_valid : STD_LOGIC;
     SIGNAL a,b,c,d    : STD_LOGIC_VECTOR(7 DOWNTO 0);
     SIGNAL x_h        : INTEGER RANGE 0 TO 299;
     SIGNAL y_h        : INTEGER RANGE 0 TO 199;
     SIGNAL rows       : INTEGER RANGE 0 TO 299;
     SIGNAL address    : INTEGER RANGE 0 TO 59999;
     SIGNAL we         : STD_LOGIC;
     SIGNAL x_p        : INTEGER RANGE 0 TO 149;
     SIGNAL y_p        : INTEGER RANGE 0 TO 99;
     SIGNAL pixel      : STD_LOGIC_VECTOR(7 DOWNTO 0);
     
     -- BLKROM w/ 4 out
     COMPONENT blk_rom_4 is
       port (
         -- input side
         clk    : in std_logic;
         rst    : in std_logic;
         addr    : in integer range 0 to 14999; -- address bits
         --output side
         data_o_1    : out std_logic_vector(7 downto 0);
         data_o_2    : out std_logic_vector(7 downto 0);
         data_o_3    : out std_logic_vector(7 downto 0);
         data_o_4    : out std_logic_vector(7 downto 0)
         );
     END COMPONENT;
     SIGNAL rom_addr : INTEGER RANGE 0 TO 14999;
     
     -- BLKRAM
     COMPONENT blk_ram is
       port (
         -- input side
         clk    : in std_logic;
         rst    : in std_logic;
         wr_address    : in integer range 0 to 59999;
         rd_address    : in integer range 0 to 59999;
         we    : in std_logic;
         --output side
         data_i    : in std_logic_vector(7 downto 0);
         data_o    : out std_logic_vector(7 downto 0)
         );
     END COMPONENT;
     SIGNAL ram_rd_addr : INTEGER RANGE 0 TO 59999;
     SIGNAL data_i : std_logic_vector(7 downto 0);
     SIGNAL data_o : std_logic_vector(7 downto 0);
BEGIN    
    -- Component port maps
    bilinear : bilinear_interpolation PORT MAP (clk, rst, a, b, c, d, x, y, scale, in_valid, w, address, we, x_p, y_p, pixel);
    rom : blk_rom_4 PORT MAP (clk, rst, rom_addr, a, b, c, d);
    ram : blk_ram PORT MAP (clk, rst, address, rd_address, we, data_i, px_out);
    
    --rom address from x_p, y_p
    rom_addr <= x_p + (y_p * 150);
    
    --ram data
    data_i <= pixel;
    
--    w <= 149 WHEN size_ctrl = '0' ELSE
--         599;
--    h <= 99 WHEN size_ctrl = '0' ELSE
--         399;
    w <= 74 WHEN size_ctrl = '0' ELSE
     299;
    h <= 49 WHEN size_ctrl = '0' ELSE
     199;
    scale <= "001000" WHEN size_ctrl = '1' ELSE
             "100000";
    
    -- Controller for traversing pixels of new image
    PROCESS (clk)        
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN
            IF (rst = '1') THEN
            
            ELSE
                prev_begin_trig <= begin_trig;
                CASE controller_fsm IS
                    WHEN idle =>
                        in_valid <= '0';
                        IF (begin_trig = '1' AND prev_begin_trig = '0') THEN
                            controller_fsm <= transform;
                            x <= 0;
                            y <= 0;
                            in_valid <= '1';
                        END IF;
                    WHEN transform =>
                        IF (x < w-1) THEN
                            x <= x + 1;
                        ELSE
                            IF (y < h-1) THEN
                                y <= y + 1;
                                x <= 0;
                            ELSE
                                controller_fsm <= done;
                            END IF;
                        END IF;
                    WHEN done =>
                        in_valid <= '0';
                        controller_fsm <= idle;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
    
END bilinear_controller;