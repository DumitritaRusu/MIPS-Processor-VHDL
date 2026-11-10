library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port (
        clk           : in  STD_LOGIC;
        rst           : in  STD_LOGIC;
        en            : in  STD_LOGIC;
        Jump          : in  STD_LOGIC;
        PCSrc         : in  STD_LOGIC;
        JumpAddress   : in  STD_LOGIC_VECTOR(31 downto 0);
        BranchAddress : in  STD_LOGIC_VECTOR(31 downto 0);
        Instruction   : out STD_LOGIC_VECTOR(31 downto 0);
        PCPlus4       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end IFetch;

architecture Behavioral of IFetch is

    signal PC       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal PC4      : STD_LOGIC_VECTOR(31 downto 0);
    signal NextPC   : STD_LOGIC_VECTOR(31 downto 0);
    signal MUX1_out : STD_LOGIC_VECTOR(31 downto 0);

    type rom_type is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);

signal ROM : rom_type := (

    B"100011_00000_00001_0000000000000100", -- X"8C010004", 00: lw   $1, 4($0)      ; citeste numarul din memorie
    B"001000_00000_00010_0000000000001000", -- X"20020008", 01: addi $2, $0, 8      ; adresa de start pentru biti
    B"001000_00000_00011_0000000000000000", -- X"20030000", 02: addi $3, $0, 0      ; contor biti de 1
    B"001000_00000_00100_0000000000000001", -- X"20040001", 03: addi $4, $0, 1      ; constanta 1
    B"001000_00000_00111_0000000000000100", -- X"20070004", 04: addi $7, $0, 4      ; pas adresa memorie

    B"001100_00001_00101_0000000000000001", -- X"30250001", 05: andi $5, $1, 1      ; extrage LSB
    B"101011_00010_00101_0000000000000000", -- X"AC450000", 06: sw   $5, 0($2)      ; scrie bitul in memorie
    B"100011_00010_00110_0000000000000000", -- X"8C460000", 07: lw   $6, 0($2)      ; citeste bitul scris
    B"000100_00110_00000_0000000000000001", -- X"10C00001", 08: beq  $6, $0, skip   ; daca bitul e 0, sare
    B"001000_00011_00011_0000000000000001", -- X"20630001", 09: addi $3, $3, 1      ; incrementeaza contorul

    B"000000_00000_00001_00001_00001_000010", -- X"00010842", 10: srl  $1, $1, 1    ; deplasare dreapta
    B"001000_00010_00010_0000000000000100",   -- X"20420004", 11: addi $2, $2, 4    ; trece la urmatoarea adresa
    B"000100_00001_00000_0000000000000001",   -- X"10200001", 12: beq  $1, $0, final ; verifica finalul
    B"000010_00000000000000000000000101",     -- X"08000005", 13: j    5             ; revine in bucla

    B"101011_00000_00011_0000000000000000",   -- X"AC030000", 14: sw   $3, 0($0)     ; scrie numarul de biti de 1
    B"000010_00000000000000000000001111",     -- X"0800000F", 15: j    15            ; bucla infinita de stop

    others => X"00000000"

);

begin

    PC4 <= PC + 4;
    PCPlus4 <= PC4;

    MUX1_out <= BranchAddress when PCSrc = '1' else PC4;

    NextPC <= JumpAddress when Jump = '1' else MUX1_out;

    process(clk, rst)
    begin
        if rst = '1' then
            PC <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                PC <= NextPC;
            end if;
        end if;
    end process;

    Instruction <= ROM(conv_integer(PC(6 downto 2)));

end Behavioral;