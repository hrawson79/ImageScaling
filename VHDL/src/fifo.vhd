-- Generic fifo buffer for storing outgoing data
-- Author: Hunter R

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY fifo IS
GENERIC(
	WIDTH : INTEGER := 8;  -- should be the width of a row of pixels for output image
	DEPTH :	INTEGER := 4); -- should be large enough to prevent stalling
PORT(
	wr_clk		: IN	STD_LOGIC;
	rd_clk      : IN    STD_LOGIC;
	rd_en 		: IN	STD_LOGIC;
	wr_data 	: IN	STD_LOGIC_VECTOR((WIDTH-1) DOWNTO 0);
	wr_en		: IN	STD_LOGIC;
	fifo_full 	: OUT	STD_LOGIC;
	fifo_empty 	: OUT	STD_LOGIC;
	rd_data 	: OUT	STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0));
END fifo;

ARCHITECTURE fifo OF fifo IS
	TYPE ram_type IS ARRAY(0 TO DEPTH-1) OF STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
	SIGNAL buff : ram_type := (OTHERS => (OTHERS => '0'));
	SIGNAL s_full : STD_LOGIC := '0';
	SIGNAL s_empty : STD_LOGIC := '1';
	SIGNAL s_rd_index : INTEGER RANGE 0 TO (WIDTH-1) := 0;
	SIGNAL s_wr_index : INTEGER RANGE 0 TO (WIDTH-1) := 0;
	SIGNAL s_cntr : INTEGER RANGE 0 TO (DEPTH-1);
	SIGNAL s2_cntr : INTEGER RANGE 0 TO (DEPTH -1);
BEGIN
    -- Write side
	PROCESS(wr_clk)
	BEGIN
		IF (wr_clk'EVENT AND wr_clk = '1') THEN
			IF (wr_en = '1') THEN	-- Write only
				s_cntr <= s_cntr + 1;
			END IF;
			
			IF (wr_en = '1' AND s_full = '1') THEN
				buff(s_wr_index) <= wr_data;
				s_wr_index <= 0;
			ELSE
				s_wr_index <= s_wr_index + 1;
			END IF;	
		END IF;
	END PROCESS;
	
	-- Read side
	PROCESS(rd_clk)
	BEGIN
	   IF (rd_clk'EVENT AND rd_clk = '1') THEN
            IF (rd_en = '1') THEN
                s2_cntr <= s2_cntr - 1;
            END IF;
            
            IF (rd_en = '1' AND s_rd_index = DEPTH-1) THEN
                            
            ELSE
                s_rd_index <= s_rd_index + 1;
            END IF;
      END IF;
	END PROCESS;
	
	rd_data <= buff(s_rd_index);
	
	-- Flags
	s_empty <= '1' WHEN (s_cntr-s2_cntr) = 0 ELSE '0';
	s_full <= '1' WHEN (s_cntr-s2_cntr) = DEPTH-1 ELSE '0';
	
	fifo_empty <= s_empty;
	fifo_full <= s_full;
	
END fifo;