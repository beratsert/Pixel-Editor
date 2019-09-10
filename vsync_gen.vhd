library ieee;
use ieee.std_logic_1164.all;

entity vsync_gen is
    port (
        vga_clk : in std_logic;
        async_reset : in std_logic;
        vsync : out std_logic;
        frame_en : out std_logic;
        draw : out std_logic
    );
end vsync_gen;

architecture arch_vsync_gen of vsync_gen is
    constant tpw : integer := 1600;
    constant tbp : integer := 23200;
    constant tfp : integer := 8000;
    constant tdisp : integer := 384000;
    signal count : integer range 0 to tdisp - 1 := 0;
    signal state : std_logic_vector (3 downto 0) := "1000";
    signal vsync_buf : std_logic;
    signal frame_en_buf : std_logic;
    signal draw_buf : std_logic;
begin
    vsync <= vsync_buf;
    frame_en <= frame_en_buf;
    draw <= draw_buf;
    count_proc : process (vga_clk, async_reset) begin
        if (async_reset = '0') then
            count <= 0;
            state <= "1000";
        elsif (rising_edge(vga_clk)) then
            if (state(3) = '1') then
                if (count = (tpw - 1)) then
                    state <= "0100";
                    count <= 0;
                else
                    state <= "1000";
                    count <= count + 1;
                end if;
            elsif (state(2) = '1') then
                if (count = (tbp - 1)) then
                    state <= "0010";
                    count <= 0;
                else
                    state <= "0100";
                    count <= count + 1;
                end if;
            elsif (state(1) = '1') then
                if (count = (tdisp - 1)) then
                    state <= "0001";
                    count <= 0;
                else
                    state <= "0010";
                    count <= count + 1;
                end if;
            elsif (state(0) = '1') then
                if (count = (tfp - 1)) then
                    state <= "1000";
                    count <= 0;
                else
                    state <= "0001";
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;
    out_proc : process (state, count) begin
        if (state(3) = '1') then
            vsync_buf <= '0';
        else
            vsync_buf <= '1';
        end if;
        if (state(1) = '1') then
            frame_en_buf <= '1';
        else
            frame_en_buf <= '0';
        end if;
        if (state(1) = '1') then
            draw_buf <= '1';
        else
            draw_buf <= '0';
        end if;
    end process;
end arch_vsync_gen;