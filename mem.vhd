library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    Port (
        CLK       : in  STD_LOGIC;
        EN        : in  STD_LOGIC;
        MemWrite  : in  STD_LOGIC;

        ALUResIn  : in  STD_LOGIC_VECTOR(31 downto 0);
        RD2       : in  STD_LOGIC_VECTOR(31 downto 0);

        MemData   : out STD_LOGIC_VECTOR(31 downto 0);
        ALUResOut : out STD_LOGIC_VECTOR(31 downto 0)
    );
end MEM;

architecture Behavioral of MEM is

    type mem_type is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);

   signal MEM : mem_type := (
    0 => X"00000000", -- aici se va scrie numarul de biti de 1
    1 => X"0000000D", -- numarul de la adresa 4 (13 = 1101)
    others => X"00000000"
);

    signal Address : STD_LOGIC_VECTOR(5 downto 0);

begin
    Address <= ALUResIn(7 downto 2);

    process(CLK)
    begin
        if rising_edge(CLK) then
            if EN = '1' and MemWrite = '1' then
                MEM(conv_integer(Address)) <= RD2;
            end if;
        end if;
    end process;

   
    MemData <= MEM(conv_integer(Address));

   
    ALUResOut <= ALUResIn;

end Behavioral;