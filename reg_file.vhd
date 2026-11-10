----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.03.2026 19:02:37
-- Design Name: 
-- Module Name: reg_file - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_file is
           Port (
        clk   : in STD_LOGIC;
        regWr : in STD_LOGIC;
        ra1   : in STD_LOGIC_VECTOR(4 downto 0);
        ra2   : in STD_LOGIC_VECTOR(4 downto 0);
        wa    : in STD_LOGIC_VECTOR(4 downto 0);
        wd    : in STD_LOGIC_VECTOR(31 downto 0);
        rd1   : out STD_LOGIC_VECTOR(31 downto 0);
        rd2   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end reg_file;

architecture Behavioral of reg_file is
    type t_reg is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal mem : t_reg := (
        0  => x"00000001",
        1  => x"00000002",
        2  => x"00000003",
        3  => x"00000004",
        4  => x"00000005",
        others => x"00000000"
    );
begin
  process(clk)
    begin
        if rising_edge(clk) then
            if regWr = '1' then
                mem(conv_integer(wa)) <= wd;
            end if;
        end if;
    end process;
  rd1 <= mem(conv_integer(ra1));
  rd2 <= mem(conv_integer(ra2));

end Behavioral;
