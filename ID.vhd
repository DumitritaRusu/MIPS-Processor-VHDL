library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ID is
    Port (
        clk      : in  STD_LOGIC;
        en       : in  STD_LOGIC;
        RegWrite : in  STD_LOGIC;
        RegDst   : in  STD_LOGIC;
        ExtOp    : in  STD_LOGIC;
        Instr    : in  STD_LOGIC_VECTOR(25 downto 0);
        WD       : in  STD_LOGIC_VECTOR(31 downto 0);

        RD1      : out STD_LOGIC_VECTOR(31 downto 0);
        RD2      : out STD_LOGIC_VECTOR(31 downto 0);
        Ext_Imm  : out STD_LOGIC_VECTOR(31 downto 0);
        func     : out STD_LOGIC_VECTOR(5 downto 0);
        sa       : out STD_LOGIC_VECTOR(4 downto 0)
    );
end ID;

architecture Behavioral of ID is

    type reg_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal RF : reg_array := (others => X"00000000");

    signal WriteAddr : STD_LOGIC_VECTOR(4 downto 0);

begin


    WriteAddr <= Instr(15 downto 11) when RegDst = '1' else Instr(20 downto 16);

    
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and RegWrite = '1' then
                RF(conv_integer(WriteAddr)) <= WD;
            end if;
        end if;
    end process;

 
    RD1 <= RF(conv_integer(Instr(25 downto 21)));
    RD2 <= RF(conv_integer(Instr(20 downto 16)));

    
    Ext_Imm(15 downto 0)  <= Instr(15 downto 0);
    Ext_Imm(31 downto 16) <= (others => Instr(15)) when ExtOp = '1' else
                             (others => '0');

   
    func <= Instr(5 downto 0);
    sa   <= Instr(10 downto 6);

end Behavioral;