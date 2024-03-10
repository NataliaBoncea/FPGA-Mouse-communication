----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.05.2022 17:58:01
-- Design Name: 
-- Module Name: DIVIZOR_DE_FRECVENTA - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter_enable is
    Port ( Clock : in STD_LOGIC;
           RESET : in STD_LOGIC;
           enable: out std_logic );
end counter_enable;

architecture Behavioral of counter_enable is

signal counter: STD_LOGIC_VECTOR (27 downto 0);

begin

process( reset,Clock)
begin
        if(reset='1') then
            counter <= (others => '0');
        elsif(rising_edge(Clock)) then
            if(counter>x"1F5E000") then
                counter <= (others => '0');
            else
                counter <= counter + 1;
            end if;
        end if;
end process;
enable <= '1' when counter=x"1F5E000" else '0';

end Behavioral;
