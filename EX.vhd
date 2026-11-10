library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity EX is
    Port (
        RD1 : in STD_LOGIC_VECTOR(31 downto 0);
        RD2 : in STD_LOGIC_VECTOR(31 downto 0);
        Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
        func : in STD_LOGIC_VECTOR(5 downto 0);
        sa : in STD_LOGIC_VECTOR(4 downto 0);
        PCPlus4 : in STD_LOGIC_VECTOR(31 downto 0);
        ALUSrc : in STD_LOGIC;
        ALUOp : in STD_LOGIC_VECTOR(2 downto 0);

        ALURes : out STD_LOGIC_VECTOR(31 downto 0);
        BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
        Zero : out STD_LOGIC
    );
end EX;

architecture Behavioral of EX is

    signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
    signal B : STD_LOGIC_VECTOR(31 downto 0);
    signal C : STD_LOGIC_VECTOR(31 downto 0);

begin

   
    B <= Ext_Imm when ALUSrc = '1' else RD2;

   
    process(ALUOp, func)
    begin
        case ALUOp is

            when "111" =>
                -- instructiuni de tip R
                case func is

                    when "100000" =>
                        ALUCtrl <= "000"; -- add

                    when "100010" =>
                        ALUCtrl <= "001"; -- sub

                    when "100100" =>
                        ALUCtrl <= "010"; -- and

                    when "100101" =>
                        ALUCtrl <= "011"; -- or

                    when "100110" =>
                        ALUCtrl <= "100"; -- xor

                    when "000000" =>
                        ALUCtrl <= "101"; -- sll

                    when "000010" =>
                        ALUCtrl <= "110"; -- srl

                    when "000100" =>
                        ALUCtrl <= "111"; -- sllv

                    when others =>
                        ALUCtrl <= "000";

                end case;

            when others =>
                ALUCtrl <= ALUOp;

        end case;
    end process;

    process(RD1, B, ALUCtrl, sa)
    begin
        case ALUCtrl is

            when "000" =>
                -- ADD: addi, lw, sw, add
                C <= RD1 + B;

            when "001" =>
                -- SUB: beq, sub
                C <= RD1 - B;

            when "010" =>
                -- AND: andi, and
                C <= RD1 and B;

            when "011" =>
                -- OR: ori, or
                C <= RD1 or B;

            when "100" =>
                -- XOR
                C <= RD1 xor B;

            when "101" =>
                -- SLL: B << sa
                C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa));

            when "110" =>
                -- SRL: B >> sa logic
                C <= to_stdlogicvector(to_bitvector(B) srl conv_integer(sa));

            when "111" =>
                -- SLLV: B << RD1(4 downto 0)
                C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(RD1(4 downto 0)));

            when others =>
                C <= X"00000000";

        end case;
    end process;

    ALURes <= C;

    -- Zero pentru BEQ
    Zero <= '1' when C = X"00000000" else '0';

    -- BranchAddress = PCPlus4 + (Ext_Imm << 2)
    BranchAddress <= PCPlus4 + (Ext_Imm(29 downto 0) & "00");

end Behavioral;
