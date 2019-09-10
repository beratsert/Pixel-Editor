library ieee;
use ieee.std_logic_1164.all;

entity hsync_gen is
    port (
        vga_clk : in std_logic;
        async_reset : in std_logic;
        hsync : out std_logic;
        line_en : out std_logic;
        draw: out std_logic
    );
end hsync_gen;

architecture arch_hsync_gen of hsync_gen is
    constant tpw : integer := 96;
    constant tbp : integer := 48;
    constant tfp : integer := 16;
    constant tdisp : integer := 640;
    signal count : integer range 0 to tdisp - 1 := 0;
    signal state : std_logic_vector (3 downto 0) := "1000";
    signal hsync_buf : std_logic;
    signal line_en_buf : std_logic;
    signal draw_buf : std_logic;
begin
    hsync <= hsync_buf;
    line_en <= line_en_buf;
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
            hsync_buf <= '0';
        else
            hsync_buf <= '1';
        end if;
        if (state(1) = '1') then
            draw_buf <= '1';
        else
            draw_buf <= '0';
        end if;
        if (state(1) = '1') then
            line_en_buf <= '1';
        else
            line_en_buf <= '0';
        end if;
    end process;
end arch_hsync_gen;