library ieee;
use ieee.std_logic_1164.all;
use work.data_types.all;

entity main is
    port (
        clk : in std_logic;
        reset : in std_logic;
        ui_switch : in std_logic;
        btn_l, btn_r, btn_u, btn_d, btn_s : in std_logic;
        vsync : out std_logic;
        hsync : out std_logic;
        red : out std_logic_vector (2 downto 0);
        green : out std_logic_vector (2 downto 0);
        blue : out std_logic_vector (1 downto 0)
    );
end main;

architecture arch of main is

    component button_control
        port (
            in_clk : in std_logic;
            async_reset : in std_logic;
            in_sig : in std_logic;
            out_sig : out std_logic
        );
    end component;

    component settings_ui
        port (
            in_clk : in std_logic;
            async_reset : in std_logic;
            enable : in std_logic;
            btn_l, btn_r, btn_u, btn_d, btn_s : in std_logic;
            sel_color : out std_logic_vector (7 downto 0);
            sel_item : out integer range 0 to 3;
            clr_cmd : out std_logic
        );
    end component;

    component image_control
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
    end component;
    
    component img_ram
        port (
            clk : in std_logic;
            wbit : in std_logic;
            win : in std_logic_vector (7 downto 0);
            wx : in integer range 0 to img_w - 1;
            wy : in integer range 0 to img_h - 1;
            rx : in integer range 0 to img_w - 1;
            ry : in integer range 0 to img_h - 1;
            rout : out std_logic_vector (7 downto 0)
        );
    end component;

    component freq_div
        port (
            reset : in std_logic;
            sys_clk : in std_logic;
            vga_clk : out std_logic
        );
    end component;

    component hsync_gen
        port (
            vga_clk : in std_logic;
            async_reset : in std_logic;
            hsync : out std_logic;
            line_en : out std_logic;
            draw : out std_logic
        );
    end component;

    component vsync_gen
        port (
            vga_clk : in std_logic;
            async_reset : in std_logic;
            vsync : out std_logic;
            frame_en : out std_logic;
            draw : out std_logic
        );
    end component;

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
            active_item : in integer range 0 to 2;
            rx : out integer range 0 to img_w - 1;
            ry : out integer range 0 to img_h - 1;
            color : out std_logic_vector (7 downto 0)
        );
    end component;

    component img_clear
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
    end component;

    -- Signal declarations
    signal btnsig_l : std_logic;
    signal btnsig_r : std_logic;
    signal btnsig_u : std_logic;
    signal btnsig_d : std_logic;
    signal btnsig_s : std_logic;
    
    signal sel_color : std_logic_vector (7 downto 0);
    signal sel_item : integer range 0 to 2;
    signal sel_pix_x : integer range 0 to img_w - 1;
    signal sel_pix_y : integer range 0 to img_h - 1;
    signal out_color : std_logic_vector (7 downto 0);

    signal vga_clk : std_logic;
    signal line_en : std_logic;
    signal frame_en : std_logic;
    signal vsync_sig : std_logic;
    signal hsync_sig : std_logic;

    signal vcount : integer range 0 to screen_h - 1;
    signal hcount : integer range 0 to screen_w - 1;

    signal img_ctrl_en : std_logic;
    signal settings_en : std_logic;
    signal pix_count_en : std_logic;
    signal img_ctrl_wbit : std_logic;
    signal img_ctrl_wx : integer range 0 to img_w - 1;
    signal img_ctrl_wy : integer range 0 to img_h - 1;
    signal img_ctrl_wdata : std_logic_vector (7 downto 0);
    signal draw_v, draw_h, draw : std_logic;
    
    signal wbit : std_logic;
    signal win : std_logic_vector (7 downto 0);
    signal wx : integer range 0 to img_w - 1;
    signal wy : integer range 0 to img_h - 1;
    signal rx : integer range 0 to img_w - 1;
    signal ry : integer range 0 to img_h - 1;
    signal rout : std_logic_vector (7 downto 0);
    
    signal clr_cmd : std_logic;
    signal clr_active : std_logic;
    signal clr_wx : integer range 0 to img_w - 1;
    signal clr_wy : integer range 0 to img_h - 1;
    signal clr_wbit : std_logic;
    signal clr_wdata : std_logic_vector (7 downto 0);

begin

    btn1 : button_control port map (clk, reset, btn_l, btnsig_l);
    btn2 : button_control port map (clk, reset, btn_r, btnsig_r);
    btn3 : button_control port map (clk, reset, btn_u, btnsig_u);
    btn4 : button_control port map (clk, reset, btn_d, btnsig_d);
    btn5 : button_control port map (clk, reset, btn_s, btnsig_s);
    
    settings_en <= ui_switch and (not clr_active);
    settings_ui1 : settings_ui port map (clk, reset, settings_en,
        btnsig_l, btnsig_r, btnsig_u, btnsig_d, btnsig_s, sel_color, sel_item, clr_cmd);
    
    img_ctrl_en <= (not ui_switch) and (not clr_active);
    img_ctrl1 : image_control port map (clk, reset, img_ctrl_en, sel_color,
        btnsig_l, btnsig_r, btnsig_u, btnsig_d, btnsig_s, sel_pix_x, sel_pix_y,
        img_ctrl_wbit, img_ctrl_wx, img_ctrl_wy, img_ctrl_wdata);
    
    wbit <= clr_wbit when clr_active = '1' else img_ctrl_wbit;
    wx <= clr_wx when clr_active = '1' else img_ctrl_wx;
    wy <= clr_wy when clr_active = '1' else img_ctrl_wy;
    win <= clr_wdata when clr_active = '1' else img_ctrl_wdata;
    img_ram1 : img_ram port map (clk, wbit, win, wx, wy, rx, ry, rout);

    img_clear1 : img_clear port map (clk, reset, clr_cmd, clr_active,
        clr_wbit, clr_wx, clr_wy, clr_wdata);
    
    freqdiv1 : freq_div port map (reset, clk, vga_clk);
    
    hsync_gen1 : hsync_gen port map (vga_clk, reset, hsync_sig, line_en, draw_h);
    vsync_gen1 : vsync_gen port map (vga_clk, reset, vsync_sig, frame_en, draw_v);
    
    pix_count_en <= line_en and frame_en;
    pixel_count1 : pixel_count port map (vga_clk, reset, pix_count_en, rout,
        sel_pix_x, sel_pix_y, sel_color, ui_switch, sel_item, rx, ry, out_color);
    
    draw <= draw_v and draw_h;
    red <= out_color (7 downto 5) when draw = '1' else "000";
    green <= out_color (4 downto 2) when draw = '1' else "000";
    blue <= out_color (1 downto 0) when draw = '1' else "00";
    hsync <= hsync_sig;
    vsync <= vsync_sig;

end arch;