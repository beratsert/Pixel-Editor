library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.data_types.all;

entity img_clear is
    port (
        clk : in std_logic;
        async_reset : in std_logic;
        clr_cmd : in std_logic;
        clr_active : out std_logic;
        wbit : out std_logic;
        wx : out integer range 0 to img_w - 1;
        wy : out integer range 0 to img_h - 1;
        wdata : out std_logic_vector (7 downto 0)
    );
end img_clear;

architecture arch_img_clear of img_clear is
    signal clr_active_sig : std_logic := '1';
    signal cx : integer range 0 to img_w - 1;
    signal cy : integer range 0 to img_h - 1;
begin
    clr_active <= clr_active_sig;
    wbit <= '1';
    wx <= cx;
    wy <= cy;
    wdata <= "00000000";
    clear_proc: process (clk, async_reset) begin
        if async_reset = '0' then
            cx <= 0;
            cy <= 0;
            clr_active_sig <= '1';
        elsif rising_edge(clk) then
            if clr_active_sig = '1' then
                if cx /= img_w - 1 then
                    cx <= cx + 1;
                else
                    cx <= 0;
                    if cy /= img_h - 1 then
                        cy <= cy + 1;
                    else
                        cy <= 0;
                        clr_active_sig <= '0';
                    end if;
                end if;
            elsif clr_cmd = '1' then
                clr_active_sig <= '1';
            end if;
        end if;
    end process;
end arch_img_clear;