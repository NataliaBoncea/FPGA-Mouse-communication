----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.11.2023 23:15:47
-- Design Name: 
-- Module Name: vga_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_tb is
--  Port ( );
end vga_tb;

architecture Behavioral of vga_tb is

CONSTANT CLK_PERIOD: time := 10 ns;
signal clk: std_logic;
signal sw: std_logic_vector(2 downto 0) := "001";
signal xm: STD_LOGIC_VECTOR (11 downto 0 ) := (others => '0');  
signal ym: STD_LOGIC_VECTOR (11 downto 0 ) := (others => '0');
signal hsync: std_logic;
signal vsync: std_logic;
signal red: std_logic_vector(3 downto 0);
signal green: std_logic_vector(3 downto 0);
signal blue: std_logic_vector(3 downto 0);

begin
vga_circuit: entity WORK.rgb_vga port map(
    clk => clk,
    reset => '0',
    sw => sw,
    hsync => hsync,
    vsync => vsync,
    xm => xm,
    ym => ym,
    red => red,
    green => green,
    blue => blue);

process
begin
    clk <= '1';
    wait for CLK_PERIOD/2;
    clk <= '0';
    wait for CLK_PERIOD/2;
end process;

end Behavioral;
