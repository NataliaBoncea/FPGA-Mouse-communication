----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.11.2023 23:04:12
-- Design Name: 
-- Module Name: rgb_vga - Behavioral
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

entity rgb_vga is
    Port ( 
        clk, reset: in std_logic;
        sw: in std_logic_vector(2 downto 0);
        hsync, vsync: out std_logic;
        xm: IN STD_LOGIC_VECTOR (8 downto 0 ) ;  
        ym: IN STD_LOGIC_VECTOR (8 downto 0 ) ; 
        red: out std_logic_vector(3 downto 0);
        green: out std_logic_vector(3 downto 0);
        blue: out std_logic_vector(3 downto 0)
    );
end rgb_vga;

architecture Behavioral of rgb_vga is

 signal x_reg : std_logic_vector (8 downto 0 ) := ( others => '0' ) ;
 signal y_reg : std_logic_vector (8 downto 0 ) := ( others => '0' ); 
 signal VGACLK:STD_LOGIC;

component clk_wiz_0
port
 (-- Clock in ports
  -- Clock out ports
  clk_out1          : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  clk_in1           : in     std_logic
 );
end component;
 begin
 
 C: clk_wiz_0
   port map ( 
  -- Clock out ports  
   clk_out1 => VGACLK,
  -- Status and control signals                
   reset => reset,
   -- Clock in ports
   clk_in1 => clk
 );
 
 C1: entity work.vga_sync PORT MAP(
    CLK => VGACLK,
    HSYNC => hsync,
    VSYNC => vsync,
    xm => xm,
    ym => ym,
    R => red,
    G => green,
    B => blue,
    S => sw);

end Behavioral;
