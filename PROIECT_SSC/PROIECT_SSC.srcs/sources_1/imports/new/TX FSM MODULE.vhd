library ieee;  
 use ieee.std_logic_1164.all;  
 use ieee.numeric_std.all;  
 entity ps2_tx is  
     port (  
         clk, reset: in std_logic;  
         din: in std_logic_vector (7 downto 0) ;  
         wr_ps2: std_logic; 
         ps2d, ps2c : inout std_logic ;  
         tx_idle: out std_logic;  
         tx_done_tick: out std_logic  
     ) ;  
 end ps2_tx;  
 
 architecture arch of ps2_tx is
   
 type statetype is (idle, rts, start, data, stop);  --FSM cu 5 stari  
 signal state_reg , state_next: statetype;  
 signal filter_reg , filter_next : std_logic_vector ( 7 downto 0 ) ;  
 signal f_ps2c_reg ,f_ps2c_next: std_logic;  
 signal b_reg , b_next : std_logic_vector (8 downto 0 ) ;  
 signal c_reg , c_next : unsigned (12 downto 0) ;  
 signal n_reg ,n_next : unsigned (3 downto 0) ;  
 signal par: std_logic;  
 signal tri_c , tri_d: std_logic ;  
 signal fall_edge : std_logic ;  
 signal ps2c_out , ps2d_out : std_logic;  
 begin --__ ______________________-_--____________________________________________-_--_-_--_--_- _ _ _ ~ ~ ~ ~ ~ _ ~ ~ ~  
 -- f i l t e r a n d f a l l i n g - e d g e t i c k g e n e r a t i o n f o r ps2c  
 --. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  
 process (clk , reset)  --acelasi lucru ca la rx
 begin  
     if reset= '1' then  
         filter_reg <= ( others => '0' ) ;  
         f_ps2c_reg <= '0' ;  
     elsif (clk'event and clk= '1' ) then  
         filter_reg <= filter_next;  
         f_ps2c_reg <= f_ps2c_next;  
     end if;  
 end process;  
 
 filter_next <= ps2c & filter_reg ( 7 downto 1);  
 f_ps2c_next <= '1' when filter_reg = "11111111" else  
                '0' when filter_reg = "00000000" else  
                f_ps2c_reg ;  
 fall_edge <= f_ps2c_reg and ( not f_ps2c_next ) ;  
 
 -- f s m d  
 -- registers  
 process ( clk , reset)  --trecere in starea urmatoare la clock-ul procesorului si resetare
 begin  
 if reset = '1' then  
      state_reg <= idle ;  
      c_reg <= ( others => '0' ) ;  
      n_reg <= ( others => '0' ) ;  
      b_reg <= ( others => '0' ) ;  
 elsif ( clk'event and clk = '1' ) then  
      state_reg <= state_next ;  
      c_reg <= c_next ;  
      n_reg <= n_next ;  
      b_reg <= b_next ;  
 end if ;  
 end process ;  
 
 -- odd   p a r i t y   b i t  
 par <= not ( din (7) xor din (6) xor din (5) xor din (4) xor  
                      din (3) xor din (2) xor din (1) xor din (0) ); --calculeaza bit-ul de paritate care ar trebui sa fie primit
 -- f s m d n e x t - s t a t e   l o g i c and data p a t h   l o g i c  
 process ( state_reg , n_reg , b_reg , c_reg , wr_ps2 ,  
                 din , par , fall_edge )  
 begin  
     state_next <= state_reg ;  --pregatim semnalele next cu cele salvate in registru
     c_next <= c_reg ;  
     n_next <= n_reg ;  
     b_next <= b_reg ;  
     tx_done_tick <= '0' ;      --setam flag-ul pentru tx_done_tick  
     ps2c_out <= '1';           --trimitem 1 pe clock catre ps2  
     ps2d_out <= '1' ;          --trimitem 1 pe data catre ps2 (presupun ca bitul de start)
     tri_c <= '0' ;  
     tri_d <= '0' ;  
     tx_idle <= '0' ;           --presupun ca tx nu este in asteptare  
     case state_reg is  
      when idle =>  
          tx_idle <= '1' ;      --tx este in starea idle(asteptare)  
          if wr_ps2 = '1' then  --daca trebuie sa scriem       
              b_next <= par & din ;     --trimitem datele de intrare si bitul de paritate  
              c_next <= ( others => '1' ) ; -- 2 ^ 1 3 - 1  
              state_next <= rts ;  --trecem in starea urmatoare
          end if ;  
      when rts => -- r e q u e s t   t o   s e n d  
          ps2c_out <= '0' ;     --pe ps2 clock punem 0  
          tri_c <= '1';  
          c_next <= c_reg - 1;  --fortam linia de clocl aprox 100?s 
          if(c_reg = 0 ) then  
              state_next <= start ;  
          end if ;  
      when start => -- a s s e r t   s t a r t    b i t  
          ps2d_out <= '0' ;     --trimitem bit-ul de start   
          tri_d <= '1' ;  
          if fall_edge = '1' then  
              n_next <= "1000" ;  
              state_next <= data ;  
          end if ;  
      when data => -- 8 data + 1 par i t y  
          ps2d_out <= b_reg (0) ;  
          tri_d <= '1' ;  
          if fall_edge = '1' then  
              b_next <= '0' & b_reg ( 8 downto 1);  --pune 8 biti de date de  si bitul de paritate 0
              if n_reg = 0 then  
                    state_next <= stop ;  
              else  
                    n_next <= n_reg - 1;  
              end if ;  
          end if ;  
      when stop => -- assume f l o a t i n g   h i g h    f o r    ps2d  
          if fall_edge = '1' then  
              state_next <= idle ;  
              tx_done_tick <='1';  
          end if ;  
     end case ;  
 end process ;  
 
 --tri_state_buffers  
 ps2c <= ps2c_out when tri_c = '1' else 'Z' ;  --trimitem clock pe ps2 daca tri_c este 1, altfel high impedance(no driver)
 ps2d <= ps2d_out when tri_d = '1' else 'Z' ;  --trimitem date pe ps2 daca tri_d este 1, altfel high impedance(no driver)  
 --  
 end arch ;