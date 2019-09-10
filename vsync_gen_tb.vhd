library ieee;
use ieee.std_logic_1164.all;
 
entity vsync_gen_tb is
end vsync_gen_tb;
 
architecture behavior of vsync_gen_tb is 
    component vsync_gen
    port (
        vga_clk : in std_logic;
        async_reset : in std_logic;
        vsync : out std_logic;
        frame_en : out std_logic;
        draw : out std_logic
    );
    end component;

   --inputs
    signal vga_clk : std_logic := '0';
    signal async_reset : std_logic := '0';
    --outputs
    signal vsync : std_logic;
    signal frame_en : std_logic;
    signal draw : std_logic;
    -- clock period definitions
    constant vga_clk_period : time := 40 ns;
begin
    -- instantiate the unit under test (uut)
    uut: vsync_gen port map (
        vga_clk => vga_clk,
        async_reset => async_reset,
        vsync => vsync,
        frame_en => frame_en,
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