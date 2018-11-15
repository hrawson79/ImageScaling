-- Top module for testing uart transmitter
-- Author: Hunter R

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY uart_transmitter_top IS
PORT(
    clk     : IN   STD_LOGIC;
    sw      : IN   STD_LOGIC_VECTOR(15 DOWNTO 0);
    btnC    : IN   STD_LOGIC;
    RsTx    : OUT  STD_LOGIC;
    led     : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0));
END uart_transmitter_top;

ARCHITECTURE uart_transmitter_top OF uart_transmitter_top IS
---------------------- Include all of the components ----------------------
-- serial_out_ctrl
--COMPONENT serial_out_ctrl IS
--GENERIC (size : INTEGER := 4);
--PORT(
--    clk              : IN   STD_LOGIC;
--    tx_trigger       : IN   STD_LOGIC;
--    tx_busy          : IN   STD_LOGIC;
--    din              : IN   STD_LOGIC_VECTOR(7 DOWNTO 0);
--    address          : OUT  INTEGER RANGE 0 TO 3 := 0;
--    load_byte        : OUT  STD_LOGIC;
--    dout             : OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
--    state            : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0));
--END COMPONENT;

--COMPONENT UART_TX_CTRL is
--        Port ( SEND : in  STD_LOGIC;
--               DATA : in  STD_LOGIC_VECTOR (7 downto 0);
--               CLK : in  STD_LOGIC;
--               READY : out  STD_LOGIC;
--               UART_TX : out  STD_LOGIC);
--END COMPONENT;

COMPONENT transmitter IS
GENERIC(size : INTEGER := 4);
PORT(
    clk             : IN    STD_LOGIC;
    begin_tx        : IN    STD_LOGIC;
    data_in         : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
    address         : OUT   INTEGER RANGE 0 TO size-1;
    state_t         : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
    tx              : OUT   STD_LOGIC);
END COMPONENT;

---------------------- Include all of the signals ----------------------
SIGNAL s_tx_busy   : STD_LOGIC;
SIGNAL s_address   : INTEGER RANGE 0 TO 3 := 0;
SIGNAL s_load_byte : STD_LOGIC;
SIGNAL s_dout      : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL s_din       : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL s_rdy       : STD_LOGIC;
-- For testing
TYPE t_mem IS ARRAY(3 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL mem : t_mem := (OTHERS => (OTHERS => '0'));
BEGIN
    -- basic test
    --led <= sw;
    mem(0) <= "00000001";
    mem(1) <= "00000010";
    mem(2) <= "00000011";
    mem(3) <= "00000100";    
    s_din <= mem(s_address);
    
    u1: COMPONENT transmitter GENERIC MAP(size => 4)
                              PORT MAP(clk, btnC, s_din, s_address, led(15 DOWNTO 12), RsTx);
    
--    s_tx_busy <= NOT s_rdy;
--    u_serial_out_ctrl : COMPONENT serial_out_ctrl GENERIC MAP(size => 4)
--                                                    PORT MAP(clk, btnC, s_tx_busy, s_din, s_address, s_load_byte, s_dout, led(15 DOWNTO 12));
--    u1: COMPONENT UART_TX_CTRL PORT MAP(s_load_byte, s_dout, clk, s_rdy, RsTx);
END uart_transmitter_top;

