library ieee;
use ieee.std_logic_1164.all;
use work.data_types.all;

entity image_control is
    port (
        in_clk : in std_logic;
        async_reset : in std_logic;
        enable : in std_logic;
        sel_color : in std_logic_vector (7 downto 0);
        btn_l, btn_r, btn_u, btn_d, btn_s : in std_logic;
        sel_pixel_x_out : out integer range 0 to img_w - 1;
        sel_pixel_y_out : out integer range 0 to img_h - 1;
        wbit_out : out std_logic;
        wx_out : out integer range 0 to img_w - 1;
        wy_out : out integer range 0 to img_h - 1;
        wcolor_out : out std_logic_vector (7 downto 0)
    );
end image_control;

architecture arch_image_control of image_control is
    signal img_data : IMGTYPE;
    signal sel_pixel_x : integer range 0 to img_w - 1;
    signal sel_pixel_y : integer range 0 to img_h - 1;
    signal wbit : std_logic;
    signal wpix_x : integer range 0 to img_w - 1;
    signal wpix_y : integer range 0 to img_h - 1;
    signal wcolor : std_logic_vector(7 downto 0);
begin
    sel_pixel_x_out <= sel_pixel_x;
    sel_pixel_y_out <= sel_pixel_y;
    wbit_out <= wbit;
    wx_out <= wpix_x;
    wy_out <= wpix_y;
    wcolor_out <= wcolor;
    img_proc : process (in_clk, async_reset) begin
        if (async_reset = '0') then
            wbit <= '0';
            wpix_x <= 0;
            wpix_y <= 0;
            wcolor <= "00000000";
            sel_pixel_x <= 0;
            sel_pixel_y <= 0;
        elsif (rising_edge(in_clk)) then
            if (enable = '1') then
                if (wbit = '1') then
                    wbit <= '0';
                end if;
                if (btn_l = '1') then
                    if (sel_pixel_x /= 0) then
                        sel_pixel_x <= sel_pixel_x - 1;
                    end if;
                elsif (btn_r = '1') then
                    if (sel_pixel_x /= img_w - 1) then
                        sel_pixel_x <= sel_pixel_x + 1;
                    end if;
                elsif (btn_u = '1') then
                    if (sel_pixel_y /= 0) then
                        sel_pixel_y <= sel_pixel_y - 1;
                    end if;
                elsif (btn_d = '1') then
                    if (sel_pixel_y /= img_h - 1) then
                        sel_pixel_y <= sel_pixel_y + 1;
                    end if;
                elsif (btn_s = '1') then
                    wbit <= '1';
                    wpix_x <= sel_pixel_x;
                    wpix_y <= sel_pixel_y;
                    wcolor <= sel_color;
                end if;
            end if;
        end if;
    end process;
end arch_image_control;