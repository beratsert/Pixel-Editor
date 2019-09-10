library ieee;
use ieee.std_logic_1164.all;
  
entity main2_tb is
end main2_tb;
 
architecture behavior of main2_tb is 
    component main
    port (
        clk : in std_logic;
        reset : in std_logic;
        ui_switch : in std_logic;
        btn_l : in std_logic;
        btn_r : in std_logic;
        btn_u : in std_logic;
        btn_d : in std_logic;
        btn_s : in std_logic;
        vsync : out std_logic;
        hsync : out std_logic;
        red : out std_logic_vector(2 downto 0);
        green : out std_logic_vector(2 downto 0);
        blue : out std_logic_vector(1 downto 0)
    );
    end component;

    --inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal ui_switch : std_logic := '0';
    signal btn_l : std_logic := '0';
    signal btn_r : std_logic := '0';
    signal btn_u : std_logic := '0';
    signal btn_d : std_logic := '0';
    signal btn_s : std_logic := '0';

    --outputs
    signal vsync : std_logic;
    signal hsync : std_logic;
    signal red : std_logic_vector(2 downto 0);
    signal green : std_logic_vector(2 downto 0);
    signal blue : std_logic_vector(1 downto 0);

    -- clock period definitions
    constant clk_period : time := 10 ns;
 
begin
 
	-- instantiate the unit under test (uut)
    uut: main port map (
        clk => clk,
        reset => reset,
        ui_switch => ui_switch,
        btn_l => btn_l,
        btn_r => btn_r,
        btn_u => btn_u,
        btn_d => btn_d,
        btn_s => btn_s,
        vsync => vsync,
        hsync => hsync,
        red => red,
        green => green,
        blue => blue
    );

    -- clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- stimulus process
    stim_proc: process
    begin
        reset <= '0';
        ui_switch <= '0';
        btn_l <= '0';
        btn_r <= '0';
        btn_u <= '0';
        btn_d <= '0';
        btn_s <= '0';
        wait for 100 ns;
        wait for clk_period*10;
        reset <= '1';
        wait;
    end process;
end;