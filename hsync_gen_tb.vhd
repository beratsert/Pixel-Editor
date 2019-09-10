library ieee;
use ieee.std_logic_1164.all;
 
entity hsync_gen_tb is
end hsync_gen_tb;
 
architecture behavior of hsync_gen_tb is 
    component hsync_gen
    port (
        vga_clk : in std_logic;
        async_reset : in std_logic;
        hsync : out std_logic;
        line_en : out std_logic;
        draw : out std_logic
    );
    end component;

   --inputs
    signal vga_clk : std_logic := '0';
    signal async_reset : std_logic := '0';
    --outputs
    signal hsync : std_logic;
    signal line_en : std_logic;
    signal draw : std_logic;
    -- clock period definitions
    constant vga_clk_period : time := 40 ns;
begin
    -- instantiate the unit under test (uut)
    uut: hsync_gen port map (
        vga_clk => vga_clk,
        async_reset => async_reset,
        hsync => hsync,
        line_en => line_en,
        draw => draw
    );
    vga_clk_process :process
    begin
        vga_clk <= '0';
        wait for vga_clk_period/2;
        vga_clk <= '1';
        wait for vga_clk_period/2;
    end process;

    -- stimulus process
    stim_proc: process
    begin
        --vga_clk <= '0';
        --async_reset <= '0';
        -- hold reset state for 100 ns.
        wait for 100 ns;	
        wait for vga_clk_period*10;
        -- insert stimulus here
        async_reset <= '1';
        wait;
    end process;
end;