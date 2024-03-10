----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.12.2023 08:17:53
-- Design Name: 
-- Module Name: mouse_to_vga - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mouse_to_vga is
    Port ( clk, reset: in std_logic;  
           ps2d, ps2c : inout std_logic; 
           hsync, vsync: out std_logic;
           red: out std_logic_vector(3 downto 0);
           green: out std_logic_vector(3 downto 0);
           blue: out std_logic_vector(3 downto 0)
    );
end mouse_to_vga;

architecture Behavioral of mouse_to_vga is
 
 signal xm: std_logic_vector (8 downto 0 ) ;  
 signal ym: std_logic_vector (8 downto 0 ) ; 
 signal m_done_tick: std_logic;  
 signal btnm: std_logic_vector (2 downto 0) := (others => '0'); 
 signal x_reg , x_next : std_logic_vector (8 downto 0 ) := ( others => '0' ) ;
 signal y_reg , y_next : std_logic_vector (8 downto 0 ) := ( others => '0' ); 
 
 signal sw: std_logic_vector(2 downto 0) := (others => '0');
 signal en: std_logic;
 
 type RAM is array (0 to 7) of STD_LOGIC_VECTOR(2 downto 0);
 signal color : RAM := (
    "000",
    "001",
    "010",
    "011",
    "100",
    "101",
    "110",
    "111");
    
begin
  
mouse_gen : entity work.mouse(arch) port map(
    clk => clk, 
    reset => reset,  
    ps2d => ps2d, 
    ps2c => ps2c,  
    xm => xm, 
    ym => ym, 
    btnm => btnm,
    m_done_tick => m_done_tick);  
     
vga_gen : entity work.rgb_vga port map(
    clk => clk, 
    reset => reset,
    sw => sw,
    hsync => hsync, 
    vsync => vsync,
    xm => x_reg,
    ym => y_reg,
    red => red,
    green => green,
    blue => blue);
    
counter_en : entity work.counter_enable port map (
    Clock => clk,
    RESET => reset,
    enable => en);
    
process (clk, btnm, reset)
begin
    if reset = '1' then
        sw <= (others => '0'); 
    elsif clk = '1' and clk'event and en = '1' then
        if btnm(0) = '1' then 
            if sw >= 7 then
                sw <= "000";
            else
                sw <= sw + 1;
            end if;
        end if;
    end if;
end process;

x_reg <= x_reg when m_done_tick= '0' else  
    xm;
y_reg <= y_reg when m_done_tick= '0' else  
    ym;

end Behavioral;
