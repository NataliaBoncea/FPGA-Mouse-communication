library IEEE;  
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.numeric_std.all;
  
entity ps2_rx is  
    port (  
        clk, reset: in std_logic;  
        ps2d, ps2c: in std_logic; -- k e y d a t a , k e y c l o c k  
        rx_en : in std_logic ;  
        rx_done_tick: out std_logic;  
        dout: out std_logic_vector (7 downto 0)  
    ) ;  
end ps2_rx; 
 
architecture arch of ps2_rx is  

 type statetype is (idle, dps, load);   --FSM cu 3 stari 
 signal state_reg , state_next : statetype;  
 signal filter_reg , filter_next : std_logic_vector (7 downto 0 ) ;  --filtru de 8 clock-uri (la fiecare clock de procesor sunt evaluati ultimii 8 biti de clock de la ps2c)
 signal f_ps2c_reg, f_ps2c_next : std_logic ;       --ps2 clock filtrat (daca toti ultimele 8 semnale de clock sunt 1 atunci 1, pt toti 0 -  0, altfel semnalul de dinainte; ajuta doar la perceperea momentului de fall_edge)
 signal n_reg , n_next : unsigned (3 downto 0) ;    --pentru numararea bitilor care se salveaza
 signal fall_edge : std_logic ;  
 signal b_reg , b_next : std_logic_vector (10 downto 0 ) ;  --pentru salvarea intermediara a bitilor  
 begin  
 --______________________________________________________________________________________-_-_--_-_--_ __  
 -- f i l t e r and f a l l i n g   e d g e   t i c k   g e n e r a t i o n   f o r ps2c  
 process ( clk , reset )  
 begin  
    if reset = '1' then  
        filter_reg <= ( others => '0' ) ;  
        f_ps2c_reg <= '0' ;  
    elsif ( clk'event and clk = '1' ) then  
        filter_reg <= filter_next ;  --registul filter primeste ce este in filter_next pe risign edge la clock-ului procesorului
        f_ps2c_reg <= f_ps2c_next ;  --registul f_ps2c primeste ce este in f_ps2c_next pe risign edge la clock-ului procesorului
    end if ;  
 end process ;  
 
 filter_next <= ps2c & filter_reg ( 7 downto 1);    --filter_next primeste ultimele 7 semnale ale ps2c concatenat cu semnalul ps2c curent  
 f_ps2c_next <= '1' when filter_reg = "11111111" else  --f_ps2c_next e 1 cand sunt transmise 8 semnale de 1 in linie, altfel e 0
                '0' when filter_reg = "00000000" else  
                f_ps2c_reg ;  
 fall_edge <= f_ps2c_reg and ( not f_ps2c_next ) ;  --fall_edge = 1 pe falling_edge pentru ps2c filtrat, in rest 0  
 --______-_______-_-_-_-_-_-_-__-_---_--_------_--_--- --------------  
 --45 -- f s m d t o e x t r a c t t h e 8 - b i t d a t a  
 --____ _-______-______-_-________________________-_-______-____-_-__-_--------------- ---------_-_------  
 ---_ r e g is t e r s  
 process ( clk , reset )  
 begin  
    if reset = '1' then  
        state_reg <= idle ;  --daca dam reset suntem in starea idle
        n_reg <= ( others => '0' ) ;  
        b_reg <= ( others => '0' ) ;  
    elsif ( clk'event and clk = '1' ) then  
        state_reg <= state_next ;  --altfel trecem in starea urmatoare (FSM)
        n_reg <= n_next ;  
        b_reg <= b_next ;  
    end if ;  
 end process ; 
  
 -- n e x t - s t a t e   l o g i c  
 process ( state_reg , n_reg,b_reg, fall_edge , rx_en , ps2d )  
 begin  
    rx_done_tick <= '0' ;  
    state_next <= state_reg ;   --state_next primeste state_reg cand se schimba ceva din lista de sensibilitate  
    n_next <= n_reg ;  
    b_next <= b_reg ;  
    case state_reg is  
        when idle =>  
            if fall_edge = '1' and rx_en = '1' then  --daca suntem in fall_edge si rx e enable, atunci luam date de la ps2d in b_next
                --s h i f t   i n   s t a r t   b i t  
                b_next <= ps2d & b_reg ( 10 downto 1);  --salvam bitul de start
                n_next <= "1001" ;  --pregatim cei 10 biti de date (8 data + 1 parity + 1 stop) sa fie salvati, cred
                state_next <= dps ; --trecem la starea urmatoare de salvare a datelor
            end if ;  
         when dps => -- 8 d a t a + 1 p a r i t y + 1 s t o p  
             if fall_edge = '1' then  
                 b_next <= ps2d & b_reg ( 10 downto 1 ) ;  --chiar daca noi i-am dat n=9, se fac 10 evaluari, astfel ca se salveaza 10 biti de date
                 if n_reg = 0 then          --daca am terminat de salvat date
                    state_next <= load ;    --trecem in starea urmatoare
                 else                       --altfel
                    n_next <= n_reg - 1;    --decrementam numarul de biti care mai trebuie primiti 
                 end if ;  
             end if ;  
     when load =>  
         -- 1 e x t r a   c l o c k   t o   c o m p l e t e   t h e   l a s t   s h i f t  
         state_next <= idle ;   --trecem inapoi la starea de asteptare 
         rx_done_tick <='1';    --anuntam ca am terminat de salvat un pachet de date  
     end case ;  
 end process ;  
 
 -- o u t p u t     --trimitem mai departe doar bitii de la 1 la 8 (adica fara start, stop si parity)
 dout <= b_reg ( 8 downto 1); -- d a t a b i t s
   
 end arch ;  