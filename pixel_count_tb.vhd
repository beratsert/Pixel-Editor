library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; 
use work.data_types.all;
 
entity pixel_count_tb is
end pixel_count_tb;
 
architecture behavior of pixel_count_tb is 
 
    -- component declaration for the unit under test (uut)
    component pixel_count
        port (
            pclk : in std_logic;
            async_reset : in std_logic;
            enable : in std_logic;
            rin : in std_logic_vector (7 downto 0);
            brush_x : in integer range 0 to img_w - 1;
            brush_y : in integer range 0 to img_h - 1;
            brush_color : in std_logic_vector (7 downto 0);
            ui_active : in std_logic;
            active_item : in integer range 0 to 3;
            rx : out integer range 0 to img_w - 1;
            ry : out integer range 0 to img_h - 1;
            color : out std_logic_vector (7 downto 0)
        );
    end component;

    -- inputs
    signal pclk : std_logic := '0';
    signal async_reset : std_logic := '0';
    signal enable : std_logic := '0';
    signal rin : std_logic_vector (7 downto 0) := "00000000";
    signal brush_x : integer range 0 to img_w - 1 := 0;
    signal brush_y : integer range 0 to img_h - 1 := 0;
    signal brush_color : std_logic_vector (7 downto 0) := "00000000";
    signal ui_active : std_logic := '0';
    signal active_item : integer range 0 to 3 := 0;
    -- outputs
    signal rx : integer range 0 to img_w - 1;
    signal ry : integer range 0 to img_h - 1;
    signal color : std_logic_vector (7 downto 0);

    -- clock period definitions
    constant pclk_period : time := 10 ns; 

begin

    -- instantiate the unit under test (uut)
    uut: pixel_count port map (
        pclk => pclk,
        async_reset => async_reset,
        enable => enable,
        rin => rin,
        brush_x => brush_x,
        brush_y => brush_y,
        brush_color => brush_color,
        ui_active => ui_active,
        active_item => active_item,
        rx => rx,
        ry => ry,
        color => color
    );

    -- clock process definitions
    pclk_process :process
    begin
        pclk <= '0';
        wait for pclk_period/2;
        pclk <= '1';
        wait for pclk_period/2;
    end process;

    input_proc : process (rx, ry)
    begin
        if rx >= 1 and rx < 3 and ry >= 1 and ry < 3 then
            rin <= "00000001";
        else
            rin <= "00000000";
        end if;
    end process;

    -- stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        wait for 100 ns;
        wait for pclk_period*10;
        async_reset <= '1';
        enable <= '1';
        brush_x <= 1;
        brush_y <= 5;
        wait;
    end process;
end;