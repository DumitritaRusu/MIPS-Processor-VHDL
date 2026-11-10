library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port (
        Instr     : in  STD_LOGIC_VECTOR(5 downto 0);  -- opcode
        RegDst    : out STD_LOGIC;
        ExtOp     : out STD_LOGIC;
        ALUSrc    : out STD_LOGIC;
        Branch    : out STD_LOGIC;
        Jump      : out STD_LOGIC;
        ALUOp     : out STD_LOGIC_VECTOR(2 downto 0);
        MemWrite  : out STD_LOGIC;
        MemtoReg  : out STD_LOGIC;
        RegWrite  : out STD_LOGIC
    );
end UC;

architecture Behavioral of UC is
begin

    process(Instr)
    begin

        
        RegDst   <= '0';
        ExtOp    <= '0';
        ALUSrc   <= '0';
        Branch   <= '0';
        Jump     <= '0';
        ALUOp    <= "000";
        MemWrite <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';

        case Instr is

            when "000000" => -- R type: add, sub, sll, srl, and, or, xor, sllv
                RegDst   <= '1';
                ALUSrc   <= '0';
                Branch   <= '0';
                Jump     <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                RegWrite <= '1';
                ALUOp    <= "111"; -- tip R, decizia se ia dupa function

            when "001000" => -- ADDI
                RegDst   <= '0';
                ExtOp    <= '1';
                ALUSrc   <= '1';
                Branch   <= '0';
                Jump     <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                RegWrite <= '1';
                ALUOp    <= "000"; -- ADD

            when "100011" => -- LW
                RegDst   <= '0';
                ExtOp    <= '1';
                ALUSrc   <= '1';
                Branch   <= '0';
                Jump     <= '0';
                MemWrite <= '0';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp    <= "000"; -- ADD pentru calcul adresa

            when "101011" => -- SW
                RegDst   <= '0'; -- nu conteaza
                ExtOp    <= '1';
                ALUSrc   <= '1';
                Branch   <= '0';
                Jump     <= '0';
                MemWrite <= '1';
                MemtoReg <= '0'; -- nu conteaza
                RegWrite <= '0';
                ALUOp    <= "000"; -- ADD pentru calcul adresa

            when "000100" => -- BEQ
                RegDst   <= '0'; -- nu conteaza
                ExtOp    <= '1';
                ALUSrc   <= '0';
                Branch   <= '1';
                Jump     <= '0';
                MemWrite <= '0';
                MemtoReg <= '0'; -- nu conteaza
                RegWrite <= '0';
                ALUOp    <= "001"; -- SUB pentru comparatie

            when "001100" => -- ANDI
                RegDst   <= '0';
                ExtOp    <= '0'; -- zero extend
                ALUSrc   <= '1';
                Branch   <= '0';
                Jump     <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                RegWrite <= '1';
                ALUOp    <= "010"; -- AND

            when "001101" => -- ORI
                RegDst   <= '0';
                ExtOp    <= '0'; -- zero extend
                ALUSrc   <= '1';
                Branch   <= '0';
                Jump     <= '0';
                MemWrite <= '0';
                MemtoReg <= '0';
                RegWrite <= '1';
                ALUOp    <= "011"; -- OR

            when "000010" => -- J
                RegDst   <= '0'; 
                ExtOp    <= '0'; 
                ALUSrc   <= '0'; 
                Branch   <= '0';
                Jump     <= '1';
                MemWrite <= '0';
                MemtoReg <= '0'; 
                RegWrite <= '0';
                ALUOp    <= "000"; 

            when others =>
                null;

        end case;
    end process;

end Behavioral;