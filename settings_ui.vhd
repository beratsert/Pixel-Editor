library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity settings_ui is
    port (
        in_clk : in std_logic;
        async_reset : in std_logic;
        enable : in std_logic;
        btn_l, btn_r, btn_u, btn_d, btn_s : in std_logic;
        sel_color : out std_logic_vector (7 downto 0);
        sel_item : out integer range 0 to 3;
        clr_cmd : out std_logic
    );
end settings_ui;

architecture arch_settings_ui of settings_ui is
    signal en_item : integer range 0 to 3 := 0;
    signal r_lvl : std_logic_vector (2 downto 0) := "000";
    signal g_lvl : std_logic_vector (2 downto 0) := "000";
    signal b_lvl : std_logic_vector (1 downto 0) := "00";
    signal clr_cmd_sig : std_logic := '0';
begin
    sel_color <= r_lvl & g_lvl & b_lvl;
    sel_item <= en_item;
    clr_cmd <= clr_cmd_sig;
    settings_proc : process (in_clk, async_reset) begin
        if (async_reset = '0') then
            en_item <= 0;
            r_lvl <= "000";
            g_lvl <= "000";
            b_lvl <= "00";
            clr_cmd_sig <= '0';
        elsif (rising_edge(in_clk)) then
            if clr_cmd_sig = '1' then
                clr_cmd_sig <= '0';
            end if;
            if (enable = '1') then
                if (btn_u = '1') then
                    if (en_item /= 0) then
                        en_item <= en_item - 1;
                    else
                        en_item <= 3;
                    end if;
                elsif (btn_d = '1') then
                    if (en_item /= 3) then
                        en_item <= en_item + 1;
                    else
                        en_item <= 0;
                    end if;
                elsif (btn_l = '1') then
                    if (en_item = 0) then
                        if (r_lvl /= "000") then
                            r_lvl <= r_lvl - "001";
                        end if;
                    elsif (en_item = 1) then
                        if (g_lvl /= "000") then
                            g_lvl <= g_lvl - "001";
                        end if;
                    elsif (en_item = 2) then
                        if (b_lvl /= "00") then
                            b_lvl <= b_lvl - "01";
                        end if;
                    end if;
                elsif (btn_r = '1') then
                    if (en_item = 0) then
                        if (r_lvl /= "111") then
                            r_lvl <= r_lvl + "001";
                        end if;
                    elsif (en_item = 1) then
                        if (g_lvl /= "111") then
                            g_lvl <= g_lvl + "001";
                        end if;
                    elsif (en_item = 2) then
                        if (b_lvl /= "11") then
                            b_lvl <= b_lvl + "01";
                        end if;
                    end if;
                elsif btn_s = '1' then
                    if en_item = 3 then
                        clr_cmd_sig <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;
end arch_settings_ui;