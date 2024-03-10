----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.12.2023 10:13:55
-- Design Name: 
-- Module Name: cursor - Behavioral
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

entity cursor is
    Port ( clk : IN STD_LOGIC;
           x_cur, y_cur : IN INTEGER;
           x_pos, y_pos : IN INTEGER;
           RGB_in : IN STD_LOGIC_VECTOR(2 downto 0);
           RGB_out : OUT STD_LOGIC_VECTOR(2 downto 0);
           draw : OUT STD_LOGIC
    );
end cursor;

architecture Behavioral of cursor is

type displayrom is array(0 to 255) of std_logic_vector(1 downto 0);
signal mouserom: displayrom := (
"00","00","11","11","11","11","11","11","11","11","11","11","11","11","11","11",
"00","01","00","11","11","11","11","11","11","11","11","11","11","11","11","11",
"00","01","01","00","11","11","11","11","11","11","11","11","11","11","11","11",
"00","01","01","01","00","11","11","11","11","11","11","11","11","11","11","11",
"00","01","01","01","01","00","11","11","11","11","11","11","11","11","11","11",
"00","01","01","01","01","01","00","11","11","11","11","11","11","11","11","11",
"00","01","01","01","01","01","01","00","11","11","11","11","11","11","11","11",
"00","01","01","01","01","01","01","01","00","11","11","11","11","11","11","11",
"00","01","01","01","01","01","00","00","00","00","11","11","11","11","11","11",
"00","01","01","01","01","01","00","11","11","11","11","11","11","11","11","11",
"00","01","00","00","01","01","00","11","11","11","11","11","11","11","11","11",
"00","00","11","11","00","01","01","00","11","11","11","11","11","11","11","11",
"00","11","11","11","00","01","01","00","11","11","11","11","11","11","11","11",
"11","11","11","11","11","00","01","01","00","11","11","11","11","11","11","11",
"11","11","11","11","11","00","01","01","00","11","11","11","11","11","11","11",
"11","11","11","11","11","11","00","00","11","11","11","11","11","11","11","11"
);

constant OFFSET: INTEGER := 16;   -- 16
signal rom_pos: INTEGER range 0 to 255 := 0;   -- 16
signal en: STD_LOGIC;

begin
en <= '1' when (x_cur>=x_pos and x_cur<(x_pos+OFFSET)
                  and y_cur>=y_pos and y_cur<(y_pos+OFFSET))
       else '0';

draw <= en;

rom_pos <= (y_cur - y_pos) * 16 + (x_cur - x_pos) 
                  when (x_cur>=x_pos and x_cur<(x_pos+OFFSET)
                  and y_cur>=y_pos and y_cur<(y_pos+OFFSET))
           else 0;

process(en, rom_pos)
   begin
      if en = '1' then
        case mouserom(rom_pos) is
            when "01" => rgb_out <= "111"; 
            when "00" => rgb_out <= "000";
            when "11" => rgb_out <= rgb_in;   
            when others => rgb_out <= rgb_in; 
         end case;
      else
        rgb_out <= rgb_in;
      end if;
end process;

end Behavioral;
