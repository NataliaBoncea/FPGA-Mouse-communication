----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.11.2023 21:20:03
-- Design Name: 
-- Module Name: VGA Synchronization Circuit - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_UNSIGNED.all;
use ieee.std_logic_ARITH.all;
use ieee.numeric_std.all;

entity vga_sync is
    Port(
        clk: IN STD_LOGIC;
        hsync: OUT STD_LOGIC;
        vsync: OUT STD_LOGIC;
        xm: IN STD_LOGIC_VECTOR (8 downto 0 ) ;  
        ym: IN STD_LOGIC_VECTOR (8 downto 0 ) ; 
        r: OUT STD_LOGIC_VECTOR(3 downto 0);
        g: OUT STD_LOGIC_VECTOR(3 downto 0);
        b: OUT STD_LOGIC_VECTOR(3 downto 0);
        s: IN STD_LOGIC_VECTOR(2 downto 0)
        );
end vga_sync;


architecture arch of vga_sync is
-----1280x1024 @ 60 Hz pixel clock 108 MHz
signal RGB: STD_LOGIC_VECTOR(2 downto 0);
signal CURS_X : INTEGER range 0 to 1688:=1048;
signal CURS_Y : INTEGER range 0 to 1688:=554;
signal DRAW : STD_LOGIC := '0';
signal HPOS : INTEGER range 0 to 1688:=0;
signal VPOS : INTEGER range 0 to 1066:=0;

begin

cursor_draw_gen : entity WORK.cursor port map (
    clk => clk,
    x_cur => hpos, 
    y_cur => vpos,
    x_pos => curs_x,
    y_pos => curs_y,
    RGB_in => s,
    RGB_out => rgb,
    draw => draw);
    
process(clk)
begin
    if(clk'event and clk='1')then
        if(draw = '1') then
            r <= (others => rgb(0));
            g <= (others => rgb(1));
            b <= (others => rgb(2));
        else
            r <= (others => s(0));
            g <= (others => s(1));
            b <= (others => s(2));
        end if;
        if(hpos<1688)then
            hpos<=hpos+1;
        else
            hpos<=0;
            if(vpos<1066)then
                vpos<=vpos+1;
            else
                vpos<=0;  
--				IF(KEYS(0)='1')THEN
--			        curs_x<=curs_x+5;
--				END IF;
--                IF(KEYS(1)='1')THEN
--					curs_x<=curs_x-5;
--				END IF;
--				IF(KEYS(2)='1')THEN
--					curs_y<=curs_y-5;
--				END IF;
--				IF(KEYS(3)='1')THEN
--					curs_y<=curs_y+5;
--				END IF; 
				if(xm(8)='0' and xm > "0000011")then
				    curs_x <= curs_x+conv_integer(xm(7 downto 0));
				elsif (xm(8)='1' and not(xm(7 downto 0)-1) > "0000011")then
				    curs_x <= curs_x-conv_integer(not(xm(7 downto 0)-1));
				end if;
				if(ym(8)='0' and ym > "0000011")then
				    curs_y <= curs_y-conv_integer(ym(7 downto 0));
				elsif (ym(8)='1' and not(ym(7 downto 0)-1) > "0000011")then
				    curs_y <= curs_y+conv_integer(not(ym(7 downto 0)-1));
				end if;    
            end if;
        end if;
        if((hpos>0 and hpos<408) or (vpos>0 and vpos<42))then
            r<=(others=>'0');
            g<=(others=>'0');
            b<=(others=>'0');
        end if;
        if(hpos>48 and hpos<160)then----hsync
            hsync<='0';
        else
            hsync<='1';
        end if;
        if(vpos>0 and vpos<4)then----------vsync
            vsync<='0';
        else
            vsync<='1';
        end if;
    end if;
end process;

end arch;
