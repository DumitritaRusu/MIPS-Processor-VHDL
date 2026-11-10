library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram_64x32 is
    Port (
        clk  : in  std_logic;
        we   : in  std_logic;
        addr : in  std_logic_vector(5 downto 0);
        di   : in  std_logic_vector(31 downto 0);
        do   : out std_logic_vector(31 downto 0)
    );
end ram_64x32;

architecture Behavioral of ram_64x32 is

    type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (
        0  => x"00000000",
        1  => x"00000001",
        2  => x"00000002",
        3  => x"00000003",
        4  => x"00000004",
        5  => x"00000005",
        6  => x"00000006",
        7  => x"00000007",
        8  => x"00000008",
        9  => x"00000009",
        10 => x"0000000A",
        11 => x"0000000B",
        12 => x"0000000C",
        13 => x"0000000D",
        14 => x"0000000E",
        15 => x"0000000F",
        others => x"00000000"
    );

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(addr))) <= di;
                do <= di;  -- write-first
            else
                do <= ram(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;

end Behavioral;