-- Top module of transmitter, combines serial_out_ctrl and uart
-- Author: Hunter R
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY transmitter IS
GENERIC(size : INTEGER := 4);
PORT(
    clk             : IN    STD_LOGIC;
    begin_tx        : IN    STD_LOGIC;
    data_in         : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
    address         : OUT   INTEGER RANGE 0 TO size-1;
    state_t         : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
    tx              : OUT   STD_LOGIC);
END transmitter;

ARCHITECTURE transmitter OF transmitter IS
---------------------- Include all of the components ----------------------
-- serial_out_ctrl
COMPONENT serial_out_ctrl IS
GENERIC (size : INTEGER := 4);
PORT(
    clk              : IN   STD_LOGIC;
    tx_trigger       : IN   STD_LOGIC;
    tx_busy          : IN   STD_LOGIC;
    din              : IN   STD_LOGIC_VECTOR(7 DOWNTO 0);
    address          : OUT  INTEGER RANGE 0 TO 3 := 0;
    load_byte        : OUT  STD_LOGIC;
    dout             : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
    state            : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0));
END COMPONENT;

COMPONENT UART_TX_CTRL is
        Port ( SEND : in  STD_LOGIC;
               DATA : in  STD_LOGIC_VECTOR (7 downto 0);
               CLK : in  STD_LOGIC;
               READY : out  STD_LOGIC;
               UART_TX : out  STD_LOGIC);
END COMPONENT;

---------------------- Include all of the signals ----------------------
SIGNAL s_tx_busy   : STD_LOGIC;
SIGNAL s_load_byte : STD_LOGIC;
SIGNAL s_dout      : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL s_rdy       : STD_LOGIC;
-- For testing
TYPE t_mem IS ARRAY(3 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL mem : t_mem := (OTHERS => (OTHERS => '0'));
BEGIN
    s_tx_busy <= NOT s_rdy;
    u_serial_out_ctrl : COMPONENT serial_out_ctrl GENERIC MAP(size => size)
                                                    PORT MAP(clk, begin_tx, s_tx_busy, data_in, address, s_load_byte, s_dout, state_t);
    u1: COMPONENT UART_TX_CTRL PORT MAP(s_load_byte, s_dout, clk, s_rdy, tx);
END transmitter;