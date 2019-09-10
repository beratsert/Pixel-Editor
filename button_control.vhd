library ieee;
use ieee.std_logic_1164.all;

entity button_control is
    port (
        in_clk : in std_logic;
        async_reset : in std_logic;
        in_sig : in std_logic;
        out_sig : out std_logic
    );
end button_control;

architecture arch_button_control of button_control is
    constant wait_time : integer := 7000000;
    signal count : integer range 0 to wait_time - 1 := 0;
    signal out_buf : std_logic := '0';
begin
    out_sig <= out_buf;
    button_proc : process (in_clk, async_reset) begin
        if (async_reset = '0') then
            count <= 0;
            out_buf <= '0';
        elsif (rising_edge(in_clk)) then
            if (in_sig = '1') then
                if (count = wait_time-1) then
                    count <= 0;
                    out_buf <= '1';
                else
                    count <= count + 1;
                    out_buf <= '0';
                end if;
            else
                count <= 0;
                out_buf <= '0';
            end if;
        end if;
    end process;
end arch_button_control;