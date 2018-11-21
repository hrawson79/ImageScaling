-- vga interface
-- broken into two parts, a control generator and an image generator
-- Author: Hunter R - based off of structure in "Circuit Design and Simulation in VHDL"

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY vga IS
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
END vga;

ARCHITECTURE vga OF vga IS
    SIGNAL Hactive, Vactive, dena : STD_LOGIC;
    SIGNAL registered_pixel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL flag : STD_LOGIC := '0';
BEGIN
    ----------------------------- Control Generator -----------------------------
    -- Static signals for DACs
    nblanck <= '1'; -- No direct blanking
    nsync <= '0'; -- No sync on green
    
    -- Create pixel clock (100MHz -> 25MHz)
    PROCESS(clk)
        VARIABLE cntr : INTEGER RANGE 0 TO 1 := 0;
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN
            IF (cntr = 1) THEN
                pixel_clk <= NOT pixel_clk;
                cntr := 0;
            ELSE
                cntr := cntr + 1;
            END IF;        
        END IF;
    END PROCESS;
    
    -- Horizontal signals generation
    PROCESS (pixel_clk)
        VARIABLE Hcount : INTEGER RANGE 0 TO Hd;
    BEGIN
        IF (pixel_clk'EVENT AND pixel_clk = '1') THEN
            Hcount := Hcount + 1;
            IF (Hcount = Ha) THEN
                Hsync <= '1';
            ELSIF (Hcount = Hb) THEN
                Hactive <= '1';
            ELSIF (Hcount = Hc) THEN
                Hactive <= '0';
            ELSIF (Hcount = Hd) THEN
                Hsync <= '0';
                Hcount := 0;
            END IF;
        END IF;
    END PROCESS;
    
    -- Vertical signals generation
    PROCESS (Hsync)
        VARIABLE Vcount : INTEGER RANGE 0 TO Vd;
    BEGIN
        IF (Hsync'EVENT AND Hsync = '1') THEN
            Vcount := Vcount + 1;
            IF (Vcount = Va) THEN
                Vsync <= '1';
            ELSIF (Vcount = Vb) THEN
                Vactive <= '1';
            ELSIF (Vcount = Vc) THEN
                Vactive <= '0';
            ELSIF (Vcount = Vd) THEN
                Vsync <= '0';
                Vcount := 0;
            END IF;
        END IF;
    END PROCESS;
    
    -- Display enable generation
    dena <= Hactive AND Vactive;
    
    ----------------------------- Image Generator -----------------------------
    PROCESS(clk)
        VARIABLE pixel_cntr : INTEGER RANGE 0 TO 307200;
        VARIABLE row_index : INTEGER RANGE 0 TO 480 := 1;
        VARIABLE col_index : INTEGER RANGE 0 TO 640 := 1;
        VARIABLE addr_index : INTEGER RANGE 0 TO 59999;
    BEGIN
        IF (Vsync ='0') THEN
            pixel_cntr := 0;
            row_index := 1;
            addr_index := 0;
            col_index := 1;
        ELSIF (pixel_clk'EVENT AND pixel_clk = '1') THEN
            IF (dena = '1') THEN
                IF (row_index <= rows and col_index <= cols) THEN                    
                    fifo_rd <= '1';
                    addr_index := addr_index + 1;
                    registered_pixel <= pixel_in;
                ELSE
                    fifo_rd <= '0';
                    registered_pixel <= "0000";
                END IF;
                
                IF ((pixel_cntr MOD 640) = 0) THEN
                    row_index := row_index + 1;
                    addr_index := addr_index + 1;
                    col_index := 1;
                END IF;
                col_index := col_index + 1;
                pixel_cntr := pixel_cntr + 1;
            END IF;
            address <= addr_index;
            flag <= NOT flag;
        END IF;
        IF (pixel_cntr < 300) THEN
            --address <= pixel_cntr;
        END IF;
    END PROCESS;
    
    PROCESS (dena, flag, registered_pixel)
    BEGIN
        IF (dena = '1') THEN
            R <= registered_pixel;
            G <= registered_pixel;
            B <= registered_pixel;
        ELSE
            R <= (OTHERS => '0');
            G <= (OTHERS => '0');
            B <= (OTHERS => '0');
        END IF;
    END PROCESS;
      -- This section is a simple image generator to test controls generation
--    PROCESS(Hsync, Vsync, Vactive, dena, red_switch, green_switch, blue_switch)
--        VARIABLE line_counter : INTEGER RANGE 0 TO Vc;
--    BEGIN
--        IF (Vsync = '0') THEN
--            line_counter := 0;
--        ELSIF (Hsync'EVENT AND Hsync = '1') THEN
--            IF (Vactive = '1') THEN
--                line_counter := line_counter + 1;
--            END IF;
--        END IF;
        
--        IF (dena = '1') THEN
--            IF (line_counter = 1) THEN
--                R <= (OTHERS => '0');
--                G <= (OTHERS => '1');
--                B <= (OTHERS => '0');
--            ELSIF (line_counter > 1 AND line_counter <= 6) THEN
--                R <= (OTHERS => '0');
--                G <= (OTHERS => '0');
--                B <= (OTHERS => '1');
--            ELSIF (line_counter > 6 AND line_counter <= 12) THEN
--                R <= (OTHERS => '1');
--                G <= (OTHERS => '0');
--                B <= (OTHERS => '0');
--            ELSE
--                R <= (OTHERS => red_switch);
--                G <= (OTHERS => green_switch);
--                B <= (OTHERS => blue_switch);
--            END IF;
--        ELSE
--            R <= (OTHERS => '0');
--            G <= (OTHERS => '0');
--            B <= (OTHERS => '0');
--        END IF;
--    END PROCESS;
END vga;