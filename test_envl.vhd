library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port (
        clk : in STD_LOGIC;
        btn : in STD_LOGIC_VECTOR(4 downto 0);
        sw  : in STD_LOGIC_VECTOR(15 downto 0);
        led : out STD_LOGIC_VECTOR(15 downto 0);
        an  : out STD_LOGIC_VECTOR(7 downto 0);
        cat : out STD_LOGIC_VECTOR(6 downto 0)
    );
end test_env;

architecture Behavioral of test_env is

    component MPG is
        Port (
            enable : out STD_LOGIC;
            btn    : in  STD_LOGIC;
            clk    : in  STD_LOGIC
        );
    end component;

    component SSD is
        Port (
            clk    : in  STD_LOGIC;
            digits : in  STD_LOGIC_VECTOR(31 downto 0);
            an     : out STD_LOGIC_VECTOR(7 downto 0);
            cat    : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    component IFetch is
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
    end component;

    component UC is
        Port (
            Instr    : in  STD_LOGIC_VECTOR(5 downto 0);
            RegDst   : out STD_LOGIC;
            ExtOp    : out STD_LOGIC;
            ALUSrc   : out STD_LOGIC;
            Branch   : out STD_LOGIC;
            Jump     : out STD_LOGIC;
            ALUOp    : out STD_LOGIC_VECTOR(2 downto 0);
            MemWrite : out STD_LOGIC;
            MemtoReg : out STD_LOGIC;
            RegWrite : out STD_LOGIC
        );
    end component;

    component ID is
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
    end component;

    component EX is
        Port (
            RD1           : in  STD_LOGIC_VECTOR(31 downto 0);
            RD2           : in  STD_LOGIC_VECTOR(31 downto 0);
            Ext_Imm       : in  STD_LOGIC_VECTOR(31 downto 0);
            func          : in  STD_LOGIC_VECTOR(5 downto 0);
            sa            : in  STD_LOGIC_VECTOR(4 downto 0);
            PCPlus4       : in  STD_LOGIC_VECTOR(31 downto 0);
            ALUSrc        : in  STD_LOGIC;
            ALUOp         : in  STD_LOGIC_VECTOR(2 downto 0);

            ALURes        : out STD_LOGIC_VECTOR(31 downto 0);
            BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
            Zero          : out STD_LOGIC
        );
    end component;

    component MEM is
        Port (
            CLK       : in  STD_LOGIC;
            EN        : in  STD_LOGIC;
            MemWrite  : in  STD_LOGIC;
            ALUResIn  : in  STD_LOGIC_VECTOR(31 downto 0);
            RD2       : in  STD_LOGIC_VECTOR(31 downto 0);
            MemData   : out STD_LOGIC_VECTOR(31 downto 0);
            ALUResOut : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    signal EN : STD_LOGIC;

    signal Instruction   : STD_LOGIC_VECTOR(31 downto 0);
    signal PC4           : STD_LOGIC_VECTOR(31 downto 0);
    signal JumpAddress   : STD_LOGIC_VECTOR(31 downto 0);
    signal BranchAddress : STD_LOGIC_VECTOR(31 downto 0);
    signal PCSrc         : STD_LOGIC;

    signal RD1     : STD_LOGIC_VECTOR(31 downto 0);
    signal RD2     : STD_LOGIC_VECTOR(31 downto 0);
    signal Ext_Imm : STD_LOGIC_VECTOR(31 downto 0);
    signal func    : STD_LOGIC_VECTOR(5 downto 0);
    signal sa      : STD_LOGIC_VECTOR(4 downto 0);
    signal WD      : STD_LOGIC_VECTOR(31 downto 0);

    signal Zero      : STD_LOGIC;
    signal ALURes    : STD_LOGIC_VECTOR(31 downto 0);
    signal MemData   : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResOut : STD_LOGIC_VECTOR(31 downto 0);

    signal RegDst   : STD_LOGIC;
    signal ExtOp    : STD_LOGIC;
    signal ALUSrc   : STD_LOGIC;
    signal Branch   : STD_LOGIC;
    signal Jump     : STD_LOGIC;
    signal ALUOp    : STD_LOGIC_VECTOR(2 downto 0);
    signal MemWrite : STD_LOGIC;
    signal MemtoReg : STD_LOGIC;
    signal RegWrite : STD_LOGIC;

    signal digits : STD_LOGIC_VECTOR(31 downto 0);

begin

    monopulse: MPG
        port map (
            enable => EN,
            btn    => btn(0),
            clk    => clk
        );

    InstructionFetch: IFetch
        port map (
            clk           => clk,
            rst           => btn(1),
            en            => EN,
            Jump          => Jump,
            PCSrc         => PCSrc,
            JumpAddress   => JumpAddress,
            BranchAddress => BranchAddress,
            Instruction   => Instruction,
            PCPlus4       => PC4
        );

    ControlUnit: UC
        port map (
            Instr    => Instruction(31 downto 26),
            RegDst   => RegDst,
            ExtOp    => ExtOp,
            ALUSrc   => ALUSrc,
            Branch   => Branch,
            Jump     => Jump,
            ALUOp    => ALUOp,
            MemWrite => MemWrite,
            MemtoReg => MemtoReg,
            RegWrite => RegWrite
        );

    InstructionDecode: ID
        port map (
            clk      => clk,
            en       => EN,
            RegWrite => RegWrite,
            RegDst   => RegDst,
            ExtOp    => ExtOp,
            Instr    => Instruction(25 downto 0),
            WD       => WD,
            RD1      => RD1,
            RD2      => RD2,
            Ext_Imm  => Ext_Imm,
            func     => func,
            sa       => sa
        );

    ExecuteUnit: EX
        port map (
            RD1           => RD1,
            RD2           => RD2,
            Ext_Imm       => Ext_Imm,
            func          => func,
            sa            => sa,
            PCPlus4       => PC4,
            ALUSrc        => ALUSrc,
            ALUOp         => ALUOp,
            ALURes        => ALURes,
            BranchAddress => BranchAddress,
            Zero          => Zero
        );

    MemoryUnit: MEM
        port map (
            CLK       => clk,
            EN        => EN,
            MemWrite  => MemWrite,
            ALUResIn  => ALURes,
            RD2       => RD2,
            MemData   => MemData,
            ALUResOut => ALUResOut
        );

    WD <= MemData when MemtoReg = '1' else ALUResOut;

    PCSrc <= Branch and Zero;

    JumpAddress <= PC4(31 downto 28) & Instruction(25 downto 0) & "00";

    process(sw, Instruction, PC4, RD1, RD2, Ext_Imm, ALURes, MemData, WD)
    begin
        case sw(7 downto 5) is
            when "000" =>
                digits <= Instruction;
            when "001" =>
                digits <= PC4;
            when "010" =>
                digits <= RD1;
            when "011" =>
                digits <= RD2;
            when "100" =>
                digits <= Ext_Imm;
            when "101" =>
                digits <= ALURes;
            when "110" =>
                digits <= MemData;
            when others =>
                digits <= WD;
        end case;
    end process;

    display: SSD
        port map (
            clk    => clk,
            digits => digits,
            an     => an,
            cat    => cat
        );

    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    led(15 downto 11) <= (others => '0');

end Behavioral;