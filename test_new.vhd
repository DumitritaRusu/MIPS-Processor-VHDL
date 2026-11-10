library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_new is
    Port (
        clk : in STD_LOGIC;
        btn : in STD_LOGIC_VECTOR (4 downto 0);
        sw  : in STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0);
        an  : out STD_LOGIC_VECTOR (7 downto 0);
        cat : out STD_LOGIC_VECTOR (6 downto 0)
    );
end test_new;

architecture Behavioral of test_new is

    component MPG
        Port (
            btn : in STD_LOGIC;
            clk : in STD_LOGIC;
            en  : out STD_LOGIC
        );
    end component;

    component SSD
        Port (
            clk    : in STD_LOGIC;
            digits : in STD_LOGIC_VECTOR(31 downto 0);
            an     : out STD_LOGIC_VECTOR(7 downto 0);
            cat    : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    signal en    : STD_LOGIC;
    signal pc    : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal instr : STD_LOGIC_VECTOR(31 downto 0);

    type rom_type is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);

    -- Scopul programului:
    -- Se afiseaza pe SSD continutul ROM-ului de instructiuni, cate o instructiune
    -- la fiecare apasare a butonului BTN0. Programul MIPS stocat in ROM:
    -- 1) citeste un numar din mem[4];
    -- 2) extrage bitii de la LSB la MSB;
    -- 3) scrie fiecare bit in memorie incepand de la adresa 8;
    -- 4) dupa fiecare SW face un LW de verificare de la aceeasi adresa;
    -- 5) numara bitii de 1;
    -- 6) la final scrie in mem[0] numarul total de biti de 1.
    --
    -- Registre folosite in program:
    -- $1 = numarul curent
    -- $2 = adresa unde se scrie bitul
    -- $3 = contor biti de 1
    -- $4 = constanta 1
    -- $5 = bit extras
    -- $6 = valoare citita inapoi din memorie
    -- $7 = constanta 4

    signal ROM : rom_type := (
        B"100011_00000_00001_0000000000000100", -- X"8C010004", 00: lw   $1, 4($0)        ; citeste numarul din mem[4]
        B"001000_00000_00010_0000000000001000", -- X"20020008", 01: addi $2, $0, 8        ; adresa de start pentru biti = 8
        B"001000_00000_00011_0000000000000000", -- X"20030000", 02: addi $3, $0, 0        ; contor biti de 1 = 0
        B"001000_00000_00100_0000000000000001", -- X"20040001", 03: addi $4, $0, 1        ; constanta 1
        B"001000_00000_00111_0000000000000100", -- X"20070004", 04: addi $7, $0, 4        ; pas adresa = 4

        B"001100_00001_00101_0000000000000001", -- X"30250001", 05: andi $5, $1, 1        ; loop: extrage LSB din numar
        B"101011_00010_00101_0000000000000000", -- X"AC450000", 06: sw   $5, 0($2)        ; scrie bitul in mem[adresa curenta]
        B"100011_00010_00110_0000000000000000", -- X"8C460000", 07: lw   $6, 0($2)        ; citeste din aceeasi adresa pentru verificare
        B"000100_00110_00000_0000000000000001", -- X"10C00001", 08: beq  $6, $0, skip     ; daca bitul citit e 0, sari peste incrementare
        B"001000_00011_00011_0000000000000001", -- X"20630001", 09: addi $3, $3, 1        ; contor = contor + 1

        B"000000_00000_00001_00001_00001_000010", -- X"00010842", 10: srl  $1, $1, 1        ; skip: deplaseaza numarul la dreapta
        B"001000_00010_00010_0000000000000100", -- X"20420004", 11: addi $2, $2, 4        ; trece la urmatoarea locatie
        B"000100_00001_00000_0000000000000001", -- X"10200001", 12: beq  $1, $0, final    ; daca numarul a devenit 0, termină
        B"000010_00000000000000000000000101", -- X"08000005", 13: j    5                 ; revine la loop (instructiunea 05)

        B"101011_00000_00011_0000000000000000", -- X"AC030000", 14: sw   $3, 0($0)        ; final: scrie in mem[0] numarul de biti de 1

        others => X"00000000"
    );

begin

    mpg_inst: MPG
    port map (
        btn => btn(0),
        clk => clk,
        en  => en
    );

    -- Counter pentru PC pe 5 biti
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                pc <= pc + 1;
            end if;
        end if;
    end process;

    -- Citire asincrona din ROM
    instr <= ROM(conv_integer(pc));

    ssd_inst: SSD
    port map (
        clk    => clk,
        digits => instr,
        an     => an,
        cat    => cat
    );

    led <= (others => '0');

end Behavioral;