LIBRARY ieee;
LIBRARY ieee_proposed;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee_proposed.fixed_pkg.all;
--use ieee.fixed_pkg.all;

ENTITY bilinear_interpolation IS
    PORT(clk, rst   : IN    STD_LOGIC;
         a,b,c,d    : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
         x_h        : IN    INTEGER RANGE 0 TO 599;
         y_h        : IN    INTEGER RANGE 0 TO 399;
         scale      : IN    STD_LOGIC_VECTOR(5 DOWNTO 0);
         in_valid   : IN    STD_LOGIC;
         rows       : IN    INTEGER RANGE 0 TO 599;
         address    : OUT   INTEGER RANGE 0 TO 59999;
         we         : OUT   STD_LOGIC;
         x_p        : OUT   INTEGER RANGE 0 TO 299;
         y_p        : OUT   INTEGER RANGE 0 TO 199;
         pixel      : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0));
END bilinear_interpolation;

ARCHITECTURE bilinear_interpolation OF bilinear_interpolation IS

    SIGNAL s1_rdy, s2_rdy, s3_rdy, s4_rdy, s5_rdy, s6_rdy, s7_rdy : STD_LOGIC := '1';
    SIGNAL d1_valid, d2_valid, d3_valid, d4_valid, d5_valid, d6_valid, d7_valid : STD_LOGIC := '0';
    
    --S1 signals
    SIGNAL scale_fixed : UFIXED(1 DOWNTO -4); --fixed scale factor
    SIGNAL x_h_fixed : UFIXED(10 DOWNTO 0);
    SIGNAL y_h_fixed : UFIXED(10 DOWNTO 0);
    SIGNAL addr_s1 : INTEGER RANGE 0 TO 59999;
    
    --S2 signals
    SIGNAL x_fixed : UFIXED(12 DOWNTO -4); --fixed product of scale_fixed*x_h_fixed
    SIGNAL y_fixed : UFIXED(12 DOWNTO -4);
    SIGNAL addr_s2 : INTEGER RANGE 0 TO 59999;
    SIGNAL x_o : UFIXED(8 DOWNTO 0);
    SIGNAL y_o : UFIXED(9 DOWNTO 0);
    
    --S3 signals
    SIGNAL delta_x : UFIXED(0 DOWNTO -4);
    SIGNAL delta_y : UFIXED(0 DOWNTO -4);
    SIGNAL one_minus_delta_x : UFIXED(1 DOWNTO -4);
    SIGNAL one_minus_delta_y : UFIXED(1 DOWNTO -4);
    SIGNAL addr_s3 : INTEGER RANGE 0 TO 59999;
    
    --S4 signals
    SIGNAL a_fixed : UFIXED(7 DOWNTO 0);
    SIGNAL b_fixed : UFIXED(7 DOWNTO 0);
    SIGNAL c_fixed : UFIXED(7 DOWNTO 0);
    SIGNAL d_fixed : UFIXED(7 DOWNTO 0);
    SIGNAL a_new : UFIXED(9 DOWNTO -4);
    SIGNAL b_new : UFIXED(9 DOWNTO -4);
    SIGNAL c_new : UFIXED(9 DOWNTO -4);
    SIGNAL d_new : UFIXED(9 DOWNTO -4);
    SIGNAL a_hat : UFIXED(10 DOWNTO -4);
    SIGNAL b_hat : UFIXED(10 DOWNTO -4);
    SIGNAL delta_y_s4 : UFIXED(0 DOWNTO -4);
    SIGNAL one_minus_delta_y_s4 : UFIXED(1 DOWNTO -4);
    SIGNAL addr_s4 : INTEGER RANGE 0 TO 59999;
    
    --S5 signals
    SIGNAL a_prime : UFIXED(12 DOWNTO -8);
    SIGNAL b_prime : UFIXED(11 DOWNTO -8);
    SIGNAL pixel_s5 : UFIXED(13 DOWNTO -8);
    SIGNAL addr_s5 : INTEGER RANGE 0 TO 59999;
    
BEGIN
    -- combinational logic for stage ready signals
    s1_rdy <= '0' WHEN d1_valid = '1' AND s2_rdy = '0' ELSE
              '1';
    s2_rdy <= '0' WHEN d2_valid = '1' AND s3_rdy = '0' ELSE
              '1';
    s3_rdy <= '0' WHEN d3_valid = '1' AND s4_rdy = '0' ELSE
              '1';
    s4_rdy <= '0' WHEN d4_valid = '1' AND s5_rdy = '0' ELSE
              '1';
    s5_rdy <= '0' WHEN d5_valid = '1' AND s6_rdy = '0' ELSE
              '1';
    s6_rdy <= '0' WHEN d6_valid = '1' AND s7_rdy = '0' ELSE
              '1';
    s7_rdy <= '1';
    
    -- S1 - input
        PROCESS (clk) IS
        BEGIN
            IF (clk'EVENT AND clk = '1') THEN
                IF (rst = '1') THEN
                
                ELSE
                    IF (s1_rdy = '1') THEN
                        d1_valid <= in_valid;
                        IF (in_valid = '1') THEN
                            scale_fixed <= TO_UFIXED(scale, 1, -4);
                            x_h_fixed <= TO_UFIXED(x_h, 10, 0);
                            y_h_fixed <= TO_UFIXED(y_h, 10, 0);
                            addr_s1 <= x_h + (y_h * rows);
                        END IF;
                    END IF;
                END IF;
            END IF;
        END PROCESS;
        
        -- S2 - 
        PROCESS (clk) IS
        BEGIN
            IF (clk'EVENT AND clk = '1') THEN
                IF (rst = '1') THEN
                    
                ELSE
                    IF (s2_rdy = '1') THEN
                        d2_valid <= d1_valid;
                        IF (d1_valid = '1') THEN
                            x_fixed <= scale_fixed * x_h_fixed;
                            y_fixed <= scale_fixed * y_h_fixed;                            
                            addr_s2 <= addr_s1;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END PROCESS;
        
        x_o <= x_fixed(8 DOWNTO 0);
        x_p <= TO_INTEGER(x_o);
        y_o <= y_fixed(9 DOWNTO 0);
        y_p <= TO_INTEGER(y_o);
        
        -- S3 - 
        PROCESS (clk) IS
        BEGIN
            IF (clk'EVENT AND clk = '1') THEN
                IF (rst = '1') THEN
                
                ELSE
                    IF (s3_rdy = '1') THEN
                        d3_valid <= d2_valid;
                        IF (d2_valid = '1') THEN
                            delta_x <= '0' & x_fixed(-1 DOWNTO -4);
                            delta_y <= '0' & y_fixed(-1 DOWNTO -4);
                            addr_s3 <= addr_s2;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END PROCESS;
        
        -- ONE MINUS VARIABLES
        one_minus_delta_x <= 1 - delta_x;
        one_minus_delta_y <= 1 - delta_y;
        
        -- FIXED PIXELS
        a_fixed <= TO_UFIXED(a, 7, 0);
        b_fixed <= TO_UFIXED(b, 7, 0);
        c_fixed <= TO_UFIXED(c, 7, 0);
        d_fixed <= TO_UFIXED(d, 7, 0);
        
        -- S4 - 
        PROCESS (clk) IS
        BEGIN
            IF (clk'EVENT AND clk = '1') THEN
                IF (rst = '1') THEN
                
                ELSE
                    IF (s4_rdy = '1') THEN
                        d4_valid <= d3_valid;
                        IF (d3_valid = '1') THEN
                            a_new <= a_fixed * one_minus_delta_x;
                            b_new <= b_fixed * RESIZE(delta_x, 1, -4);
                            c_new <= c_fixed * one_minus_delta_x;
                            d_new <= d_fixed * RESIZE(delta_x, 1, -4);
                            delta_y_s4 <= delta_y;
                            one_minus_delta_y_s4 <= one_minus_delta_y;
                            addr_s4 <= addr_s3;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END PROCESS;
        
        -- ADD A_HAT AND B_HAT
        a_hat <= a_new + b_new;
        b_hat <= c_new + d_new;
        
        -- S5 - 
        PROCESS (clk) IS
        BEGIN
            IF (clk'EVENT AND clk = '1') THEN
                IF (rst = '1') THEN
                
                ELSE
                    IF (s5_rdy = '1') THEN
                        d5_valid <= d4_valid;
                        IF (d4_valid = '1') THEN
                            a_prime <= a_hat * one_minus_delta_y_s4;
                            b_prime <= b_hat * delta_y_s4;
                            addr_s5 <= addr_s4;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END PROCESS;
        
        pixel_s5 <= a_prime + b_prime;
        pixel <= TO_SLV(pixel_s5(7 DOWNTO 0));
        address <= addr_s5;
--        next_in <= s1_rdy;
        we <= d5_valid;
END bilinear_interpolation;