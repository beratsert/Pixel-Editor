library ieee;
use ieee.std_logic_1164.ALL;
use work.data_types.all;

entity img_ram is
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
end img_ram;

architecture arch_img_ram of img_ram is
    signal ram : IMGTYPE;
begin
    write_proc : process (clk) begin
        if rising_edge(clk) then
            if wbit = '1' then
                ram (wx, wy) <= win;
            end if;
        end if;
    end process;
    rout <= ram (rx, ry);
end arch_img_ram;