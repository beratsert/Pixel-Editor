library ieee;
use ieee.std_logic_1164.all;

entity freq_div is
    port (
        reset : in std_logic;
        sys_clk : in std_logic;
        vga_clk : out std_logic
    );
end freq_div;

architecture arch_freq_div of freq_div is
    signal count : integer range 0 to 1 := 0;
    signal vga_clk_buffer : std_logic := '0';
begin
    vga_clk <= vga_clk_buffer;
    freq_div_proc : process (sys_clk, reset) begin
        if (reset = '0') then
            count <= 0;
            vga_clk_buffer <= '0';
        elsif (rising_edge(sys_clk)) then
            if (count = 1) then
                vga_clk_buffer <= not vga_clk_buffer;
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
end arch_freq_div;