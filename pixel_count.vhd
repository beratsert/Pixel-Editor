library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity pixel_count is
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
end pixel_count;

architecture arch_pixel_count of pixel_count is

    constant canvas_xi : integer := 174;
    constant canvas_xf : integer := 462;
    constant canvas_yi : integer := 48;
    constant canvas_yf : integer := 432;
    constant canvas_w : integer := canvas_xf - canvas_xi;
    constant canvas_h : integer := canvas_yf - canvas_yi;
    constant canvas_pw : integer := 9;
    constant canvas_ph : integer := 12;

    constant colorbar_xi : integer := 44;
    constant colorbar_xf : integer := 132;
    constant colorbar_yi : integer := 80;
    constant colorbar_yf : integer := 120;

    constant slider_w : integer := 84;
    constant slider_t : integer := 4;
    constant slider_xi : integer := 46;
    constant slider_xf : integer := 130;
    
    constant r_slider_yi : integer := 140;
    constant r_slider_yf : integer := 144;
    constant r_slider_seg_w : integer := 12;
    constant r_slider_seg_n : integer := 7;
    constant g_slider_yi : integer := 156;
    constant g_slider_yf : integer := 160;
    constant g_slider_seg_w : integer := 12;
    constant g_slider_seg_n : integer := 7;
    constant b_slider_yi : integer := 172;
    constant b_slider_yf : integer := 176;
    constant b_slider_seg_w : integer := 28;
    constant b_slider_seg_n : integer := 3;
    
    constant slider_tip_hw : integer := 2;
    constant slider_tip_hh : integer := 6;
    
    constant r_tip_stride : integer := 12;
    constant r_tip_yi : integer := 142 - slider_tip_hh;
    constant r_tip_yf : integer := 142 + slider_tip_hh;

    constant g_tip_stride : integer := 12;
    constant g_tip_yi : integer := 158 - slider_tip_hh;
    constant g_tip_yf : integer := 158 + slider_tip_hh;

    constant b_tip_stride : integer := 28;
    constant b_tip_yi : integer := 174 - slider_tip_hh;
    constant b_tip_yf : integer := 174 + slider_tip_hh;

    constant clr_btn_xi : integer := 44;
    constant clr_btn_xf : integer := 132;
    constant clr_btn_yi : integer := 240;
    constant clr_btn_yf : integer := 280;

    signal hcount_sig : integer range 0 to screen_w - 1 := 0;
    signal vcount_sig : integer range 0 to screen_h - 1 := 0;

    signal canvas_begin : std_logic := '0';
    signal canvas_en : std_logic := '0';
    signal canvas_px : integer range 0 to img_w - 1 := 0;
    signal canvas_py : integer range 0 to img_h - 1 := 0;
    signal canvas_pix_x : integer range 0 to canvas_pw - 1 := 0;
    signal canvas_pix_y : integer range 0 to canvas_ph - 1 := 0;

    signal colorbar_begin : std_logic := '0';
    signal colorbar_en : std_logic := '0';

    signal r_slider_begin : std_logic := '0';
    signal r_slider_en : std_logic := '0';
    signal r_slider_seg_cnt : integer range 0 to r_slider_seg_w - 1 := 0;
    signal r_slider_seg : std_logic_vector (2 downto 0) := "000";

    signal g_slider_begin : std_logic := '0';
    signal g_slider_en : std_logic := '0';
    signal g_slider_seg_cnt : integer range 0 to g_slider_seg_w - 1 := 0;
    signal g_slider_seg : std_logic_vector (2 downto 0) := "000";

    signal b_slider_begin : std_logic := '0';
    signal b_slider_en : std_logic := '0';
    signal b_slider_seg_cnt : integer range 0 to b_slider_seg_w - 1 := 0;
    signal b_slider_seg : std_logic_vector (1 downto 0) := "00";
    
    signal clr_btn_begin : std_logic := '0';
    signal clr_btn_en : std_logic := '0';
    signal clr_btn_x : integer range 0 to clr_bmp_w - 1 := 0;
    signal clr_btn_y : integer range 0 to clr_bmp_h - 1 := 0;

begin
    count_proc : process (pclk, async_reset) begin
        if (async_reset = '0') then
            hcount_sig <= 0;
            vcount_sig <= 0;

            canvas_begin <= '0';
            canvas_en <= '0';
            canvas_px <= 0;
            canvas_py <= 0;
            canvas_pix_x <= 0;
            canvas_pix_y <= 0;

            colorbar_begin <= '0';
            colorbar_en <= '0';

            r_slider_begin <= '0';
            r_slider_en <= '0';
            g_slider_begin <= '0';
            g_slider_en <= '0';
            b_slider_begin <= '0';
            b_slider_en <= '0';
            
            clr_btn_begin <= '0';
            clr_btn_en <= '0';
            clr_btn_x <= 0;
            clr_btn_y <= 0;
        elsif (rising_edge(pclk)) then
            if (enable = '1') then
                -- Screen coordinates update
                if (hcount_sig /= screen_w - 1) then
                    hcount_sig <= hcount_sig + 1;
                    vcount_sig <= vcount_sig;
                else
                    hcount_sig <= 0;
                    if (vcount_sig /= screen_h - 1) then
                        vcount_sig <= vcount_sig + 1;
                    else
                        vcount_sig <= 0;
                    end if;
                end if;
                -- Canvas drawing state update
                if (hcount_sig = canvas_xi - 1 and vcount_sig = canvas_yi) then
                    canvas_begin <= '1';
                    canvas_en <= '1';
                elsif (hcount_sig = canvas_xf - 1) then
                    if (vcount_sig = canvas_yf - 1) then
                        canvas_begin <= '0';
                    end if;
                    canvas_en <= '0';
                elsif (hcount_sig = canvas_xi - 1 and canvas_begin = '1') then
                    canvas_en <= '1';
                end if;
                -- Canvas pixel coordinate update
                if (canvas_en = '1') then
                    if (canvas_pix_x /= canvas_pw - 1) then
                        canvas_pix_x <= canvas_pix_x + 1;
                    else
                        canvas_pix_x <= 0;
                        -- Reached pixel end, update pixel value
                        if (canvas_px /= img_w - 1) then
                            canvas_px <= canvas_px + 1;
                        else
                            canvas_px <= 0;
                            if (canvas_pix_y /= canvas_ph - 1) then
                                canvas_pix_y <= canvas_pix_y + 1;
                            else
                                canvas_pix_y <= 0;
                                if (canvas_py /= img_h - 1) then
                                    canvas_py <= canvas_py + 1;
                                else
                                    canvas_py <= 0;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
                -- Colorbar state update
                if (hcount_sig = colorbar_xi - 1 and vcount_sig = colorbar_yi) then
                    colorbar_begin <= '1';
                    colorbar_en <= '1';
                elsif (hcount_sig = colorbar_xf - 1) then
                    if (vcount_sig = colorbar_yf - 1) then
                        colorbar_begin <= '0';
                    end if;
                    colorbar_en <= '0';
                elsif (hcount_sig = colorbar_xi - 1 and colorbar_begin = '1') then
                    colorbar_en <= '1';
                end if;
                -- R-slider updates
                if hcount_sig = slider_xi - 1 and vcount_sig = r_slider_yi then
                    r_slider_begin <= '1';
                    r_slider_en <= '1';
                elsif hcount_sig = slider_xf - 1 then
                    if vcount_sig = r_slider_yf - 1 then
                        r_slider_begin <= '0';
                    end if;
                    r_slider_en <= '0';
                elsif hcount_sig = slider_xi - 1 and r_slider_begin = '1' then
                    r_slider_en <= '1';
                end if;
                -- G-slider updates
                if hcount_sig = slider_xi - 1 and vcount_sig = g_slider_yi then
                    g_slider_begin <= '1';
                    g_slider_en <= '1';
                elsif hcount_sig = slider_xf - 1 then
                    if vcount_sig = g_slider_yf - 1 then
                        g_slider_begin <= '0';
                    end if;
                    g_slider_en <= '0';
                elsif hcount_sig = slider_xi - 1 and g_slider_begin = '1' then
                    g_slider_en <= '1';
                end if;
                -- B-slider updates
                if hcount_sig = slider_xi - 1 and vcount_sig = b_slider_yi then
                    b_slider_begin <= '1';
                    b_slider_en <= '1';
                elsif hcount_sig = slider_xf - 1 then
                    if vcount_sig = b_slider_yf - 1 then
                        b_slider_begin <= '0';
                    end if;
                    b_slider_en <= '0';
                elsif hcount_sig = slider_xi - 1 and b_slider_begin = '1' then
                    b_slider_en <= '1';
                end if;
                -- Clear button state updates
                if (hcount_sig = clr_btn_xi - 1 and vcount_sig = clr_btn_yi) then
                    clr_btn_begin <= '1';
                    clr_btn_en <= '1';
                elsif (hcount_sig = clr_btn_xf - 1) then
                    if (vcount_sig = clr_btn_yf - 1) then
                        clr_btn_begin <= '0';
                    end if;
                    clr_btn_en <= '0';
                elsif (hcount_sig = clr_btn_xi - 1 and clr_btn_begin = '1') then
                    clr_btn_en <= '1';
                end if;
                if clr_btn_en = '1' then
                    if clr_btn_x /= clr_bmp_w - 1 then
                        clr_btn_x <= clr_btn_x + 1;
                    else
                        clr_btn_x <= 0;
                        if clr_btn_y /= clr_bmp_h - 1 then
                            clr_btn_y <= clr_btn_y + 1;
                        else
                            clr_btn_y <= 0;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
    out_proc : process (hcount_sig, vcount_sig,
        canvas_en, canvas_px, canvas_py, canvas_pix_x, canvas_pix_y,
        rin, ui_active, r_slider_en, g_slider_en, b_slider_en,
        clr_btn_en, clr_btn_x, clr_btn_y,
        brush_color, brush_x, brush_y, colorbar_en, active_item)
        variable r_tip_xi : integer range 0 to slider_xf - slider_tip_hw;
        variable g_tip_xi : integer range 0 to slider_xf - slider_tip_hw;
        variable b_tip_xi : integer range 0 to slider_xf - slider_tip_hw;
        variable r_tip_xf : integer range 0 to slider_xf + slider_tip_hw;
        variable g_tip_xf : integer range 0 to slider_xf + slider_tip_hw;
        variable b_tip_xf : integer range 0 to slider_xf + slider_tip_hw;
    begin
        r_tip_xi := slider_xi - slider_tip_hw + r_tip_stride * to_integer(unsigned(brush_color (7 downto 5)));
        g_tip_xi := slider_xi - slider_tip_hw + g_tip_stride * to_integer(unsigned(brush_color (4 downto 2)));
        b_tip_xi := slider_xi - slider_tip_hw + b_tip_stride * to_integer(unsigned(brush_color (1 downto 0)));
        r_tip_xf := slider_xi + slider_tip_hw + r_tip_stride * to_integer(unsigned(brush_color (7 downto 5)));
        g_tip_xf := slider_xi + slider_tip_hw + g_tip_stride * to_integer(unsigned(brush_color (4 downto 2)));
        b_tip_xf := slider_xi + slider_tip_hw + b_tip_stride * to_integer(unsigned(brush_color (1 downto 0)));
        if canvas_en = '1' then
            if canvas_px = brush_x and canvas_py = brush_y then
                if canvas_pix_x = 0 or
                    canvas_pix_y = 0 or
                    canvas_pix_x = 1 or
                    canvas_pix_y = 1 or
                    canvas_pix_x = canvas_pw - 1 or
                    canvas_pix_y = canvas_ph - 1 or
                    canvas_pix_x = canvas_pw - 2 or
                    canvas_pix_y = canvas_ph - 2
                then
                    color <= "11111111";
                else
                    color <= rin;
                end if;
            else
                color <= rin;
            end if;
        elsif colorbar_en = '1' then
            if hcount_sig = colorbar_xi or hcount_sig = colorbar_xf - 1 or
                vcount_sig = colorbar_yi or vcount_sig = colorbar_yf - 1
            then
                color <= "11111111";
            else
                color <= brush_color;
            end if;
        elsif hcount_sig >= r_tip_xi and hcount_sig < r_tip_xf
            and vcount_sig >= r_tip_yi and vcount_sig < r_tip_yf
        then
            if ui_active = '1' and active_item = 0 then
                color <= "11000000";
            else
                color <= "10000000";
            end if;
        elsif hcount_sig >= g_tip_xi and hcount_sig < g_tip_xf
            and vcount_sig >= g_tip_yi and vcount_sig < g_tip_yf
        then
            if ui_active = '1' and active_item = 1 then
                color <= "00011000";
            else
                color <= "00010000";
            end if;
        elsif hcount_sig >= b_tip_xi and hcount_sig < b_tip_xf
            and vcount_sig >= b_tip_yi and vcount_sig < b_tip_yf
        then
            if ui_active = '1' and active_item = 2 then
                color <= "00000011";
            else
                color <= "00000010";
            end if;
        elsif r_slider_en = '1' then
            if ui_active = '1' and active_item = 0 then
                color <= "11000000";
            else
                color <= "10000000";
            end if;
        elsif g_slider_en = '1' then
            if ui_active = '1' and active_item = 1 then
                color <= "00011000";
            else
                color <= "00010000";
            end if;
        elsif b_slider_en = '1' then
            if ui_active = '1' and active_item = 2 then
                color <= "00000011";
            else
                color <= "00000010";
            end if;
        elsif clr_btn_en = '1' and clear_bitmap(clr_btn_y, clr_btn_x) = '1' then
            if ui_active = '1' and active_item = 3 then
                color <= "11110100";
            else
                color <= "11111111";
            end if;
        else
            color <= "01001001";
        end if;
    end process;
    rx <= canvas_px;
    ry <= canvas_py;
end arch_pixel_count;