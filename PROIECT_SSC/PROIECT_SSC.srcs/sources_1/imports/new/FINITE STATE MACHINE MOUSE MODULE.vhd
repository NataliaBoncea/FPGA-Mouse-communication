library ieee;  
 use ieee.std_logic_1164.all;  
 use ieee.numeric_std.all;  
 entity mouse is  
 port (  
 clk, reset: in std_logic;  
 ps2d, ps2c : inout std_logic ;  
 xm, ym: out std_logic_vector ( 8 downto 0 ) ;  
 btnm: out std_logic_vector (2 downto 0 ) ;  
 m_done_tick : out std_logic  
 ) ;  
 end mouse;  
  architecture arch of mouse is  
 constant STRM: std_logic_vector ( 7 downto 0 ) := "11110100" ;  
 -- stream command F4  
 type state_type is (init1, init2, init3,  
 pack1 , pack2, pack3, done) ;  
 signal state_reg , state_next : state_type;  
 signal rx_data: std_logic_vector ( 7 downto 0 ) ;  
 signal rx_done_tick , tx_done_tick: std_logic;  
 signal wr_ps2 : std_logic;  
 signal x_reg , y_reg : std_logic_vector ( 8 downto 0) ;  
 signal x_next , y_next : std_logic_vector (8 downto 0 ) ;  
 signal x_overflow_next , y_overflow_next : std_logic; 
 signal x_overflow_reg , y_overflow_reg : std_logic; 
 signal btn_reg , btn_next : std_logic_vector ( 2 downto 0 ) ;  
 begin  
 -- in s t a n t i a t i o n  
 ps2_rxtx_unit : entity work.ps2_rxtx (arch)  
 port map(clk=>clk , reset=>reset , wr_ps2=>wr_ps2,  
         din=>STRM , dout=>rx_data ,  
         ps2d=>ps2d, ps2c=>ps2c,  
         rx_done_tick=>rx_done_tick,  
         tx_done_tick=>tx_done_tick);  
 --s t a t e and d a t a r e g is t e r s  
 process (clk, reset)  
 begin  
            if reset = '1' then  
                state_reg <= init1;  
                x_reg <= ( others =>'0' ) ;  
                y_reg <= ( others => '0' ) ;  
                btn_reg <= ( others => '0' ) ; 
                x_overflow_reg <= '0'; 
                y_overflow_reg <= '0'; 
            elsif (clk'event and clk='1') then  
                state_reg <= state_next ;  
                x_reg <= x_next;  
                y_reg <= y_next;  
                btn_reg <= btn_next ;
                x_overflow_reg <= x_overflow_next; 
                y_overflow_reg <= y_overflow_next;  
            end if ;  
 end process ;  
 -- n e x t - s t a t e   l o g i c  
 process (state_reg ,rx_done_tick, tx_done_tick,  
 x_reg ,y_reg, btn_reg, rx_data)  
 begin  
     wr_ps2 <= '0' ;  
     m_done_tick <= '0' ;  
     x_next <= x_reg;  
     y_next <= y_reg;  
     btn_next <= btn_reg ;  
     state_next <= state_reg;  
     case state_reg is  
         when init1 =>  
         wr_ps2 <= '1';  
         state_next <= init2 ;  
     when init2 => -- w a i t   f o r   s e n d   t o   c o m p l e t e  
         if tx_done_tick = '1' then  
             state_next <= init3 ;  
         end if ;  
     when init3 => -- w a i t   f o r   a c k n o w l e d g e   p a c k e t  
         if rx_done_tick = '1' then  
             state_next <= pack1 ;  
         end if ;  
     when pack1 => -- w a i t   f o r   1 s t   d a t a   p a c k e t  
         if rx_done_tick = '1' then  
             state_next <= pack2 ;
             y_overflow_next <= rx_data ( 7 ) ;  
             x_overflow_next <= rx_data ( 6 ) ;  
             y_next ( 8 ) <= rx_data ( 5 ) ;  
             x_next (8) <= rx_data ( 4 ) ;  
             btn_next <= rx_data ( 2 downto 0 ) ;  
         end if ;  
     when pack2 => -- w a i t f o r 2 n d d a t a p a c k e t  
     if rx_done_tick = '1' then  
     state_next <= pack3 ;  
     x_next ( 7 downto 0) <= rx_data ;  
     end if ;  
     when pack3 => -- w a i t f o r 3 r d d a t a p a c k e t  
     if rx_done_tick = '1' then  
     state_next <= done ;  
     y_next ( 7 downto 0 ) <= rx_data ;  
     end if ;  
     when done =>  
     m_done_tick <= '1' ;  
     state_next <= pack1 ;  
     end case ;  
 end process ;  
 xm <= x_reg ;  
 ym <= y_reg ;  
 btnm <= btn_reg ;  
 end arch ;