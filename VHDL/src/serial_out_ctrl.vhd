-- Control flow of data to uart
-- expecting data to be stored in memory
-- Author: Hunter R

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY serial_out_ctrl IS
GENERIC (size : INTEGER := 4);  --size should specify total number of memory addresses to be read
PORT(
    clk              : IN   STD_LOGIC;
    tx_trigger       : IN   STD_LOGIC;
    tx_busy          : IN   STD_LOGIC;
    din              : IN   STD_LOGIC_VECTOR(7 DOWNTO 0);
    address          : OUT  INTEGER RANGE 0 TO size-1;
    load_byte        : OUT  STD_LOGIC;
    dout             : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
    state            : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0));
END serial_out_ctrl;

ARCHITECTURE serial_out_ctrl OF serial_out_ctrl IS
    TYPE serial_out_type IS (idle, read_byte, wait_set, send_byte, wait_for_load, wait_for_tx_comp);
    SIGNAL serial_out_fsm : serial_out_type := idle;
    SIGNAL prev_tx_trigger : STD_LOGIC := '0';
BEGIN
    PROCESS(clk)
        VARIABLE bytes_sent : INTEGER RANGE 0 TO size := 0;
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN
            prev_tx_trigger <= tx_trigger;
            CASE serial_out_fsm IS
                WHEN idle =>
                    state <= "0001";
                    IF (prev_tx_trigger = '0' AND tx_trigger = '1') THEN
                        bytes_sent := 0;
                        serial_out_fsm <= read_byte;
                    END IF;
                WHEN read_byte =>
                    state <= "0010";
                    address <= bytes_sent;
                    serial_out_fsm <= wait_set;
                WHEN wait_set =>
                    state <= "0011";
                    serial_out_fsm <= send_byte;
                WHEN send_byte =>
                    state <= "0100";
                    dout <= din;
                    load_byte <= '1';
                    bytes_sent := bytes_sent + 1;
                    serial_out_fsm <= wait_for_load;
                WHEN wait_for_load =>
                    state <= "0101";
                    serial_out_fsm <= wait_for_tx_comp;
                WHEN wait_for_tx_comp =>
                    state <= "0110";
                    load_byte <= '0';
                    IF (tx_busy = '0' AND bytes_sent < 4) THEN
                        serial_out_fsm <= read_byte;
                    ELSIF (tx_busy = '0' AND bytes_sent >= 4) THEN
                        serial_out_fsm <= idle;
                    ELSE
                        serial_out_fsm <= wait_for_tx_comp;
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
END serial_out_ctrl;