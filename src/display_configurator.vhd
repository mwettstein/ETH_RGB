LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY display_configurator IS
	PORT(
		clk50	  : IN    STD_ULOGIC;
		sda_i2c   : INOUT STD_LOGIC;
		scl_i2c	  : INOUT STD_LOGIC
	);
END display_configurator;

ARCHITECTURE rtl OF display_configurator IS

	component i2c_master
		port(clk       : IN  	STD_LOGIC;                    --system clock 50MHz
			 reset_n   : IN  	STD_LOGIC;                    --active low reset
			 ena       : IN     STD_LOGIC;                    --latch in command
			 addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
			 rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
			 data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
			 busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
			 data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
			 ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
			 sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
			 scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
	end component i2c_master;
	
	constant C_WAIT_100MS: integer := 5_000_000;
	constant C_WAIT_300MS: integer := 15_000_000;
	constant C_I2C_ADDR:   std_logic_vector(6 downto 0) := "1100100";   -- 0x64
	
	type stateType is (idle, after100ms, after300ms, after301ms, waitforever);					   
	signal state 			: stateType := idle;
	signal cnt              : integer range 0 to 15_000_000 := 0;
	signal i2c_ena          : std_logic := '0';
	signal i2c_addr         : std_logic_vector(6 downto 0) := C_I2C_ADDR;
	signal i2c_rw           : std_logic := '0';
	signal i2c_data_wr      : std_logic_vector(7 downto 0) := (others => '0');
	signal i2c_busy         : std_logic := '0';
	signal busy_prev        : std_logic := '0';
	
	

BEGIN

	i2c_master_inst : i2c_master
		port map(clk		=> clk50,
				 reset_n 	=> '1',
				 ena       	=> i2c_ena,         --latch in command
				 addr       => i2c_addr,        --address of target slave
				 rw         => i2c_rw,          --'0' is write, '1' is read
				 data_wr    => i2c_data_wr,     --data to write to slave
				 busy      	=> i2c_busy,        --indicates transaction in progress
				 data_rd   	=> open,  			--data read from slave
				 ack_error 	=> open,			--flag if improper acknowledge from slave
				 sda       	=> sda_i2c,
				 scl       	=> scl_i2c);

machwastolles : process(clk50)
	variable busy_cnt       : integer range 0 to 10 := 0;
begin
	if rising_edge(clk50) then
		case state is

			when idle =>
				cnt <= cnt + 1;
				if cnt = C_WAIT_100MS then
					state			<= after100ms;
					cnt				<= 0;
				end if;

			when after100ms =>
			
			  busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
			  IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
				busy_cnt := busy_cnt + 1;                  --counts the times busy has gone from low to high during transaction
			  END IF;
			  CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
				WHEN 0 =>                                  --no command latched in yet
				  i2c_ena <= '1';                            --initiate the transaction
				  i2c_addr <= C_I2C_ADDR;                    --set the address of the slave
				  i2c_rw <= '0';                             --command 1 is a write
				  i2c_data_wr <= x"06";              		 --data to be written (address of LED0 register)
				WHEN 1 =>                                  --1st busy high: command 1 latched, okay to issue command 2
				  i2c_data_wr <= x"01";              		 --data to be written (LED0 register value)
				WHEN OTHERS =>                                  --2nd busy high: command 2 latched, ready to stop
				  i2c_ena <= '0';                            --deassert enable to stop transaction after command 4
				  IF(i2c_busy = '0') THEN                    --indicates data write is finished
					                     
					cnt <= cnt + 1;
					if cnt = C_WAIT_300MS then
						state			<= after300ms;					 --transaction complete, go to next state in design after 300ms
						busy_cnt := 0;  								 --reset busy_cnt for next transaction
						cnt				<= 0;
					end if;                   
				  END IF;
				--WHEN OTHERS => NULL;
			  END CASE;
			
			when after300ms =>
			  busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
			  IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
				busy_cnt := busy_cnt + 1;                  --counts the times busy has gone from low to high during transaction
			  END IF;
			  CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
				WHEN 0 =>                                  --no command latched in yet
				  i2c_ena <= '1';                            --initiate the transaction
				  i2c_addr <= C_I2C_ADDR;                    --set the address of the slave
				  i2c_rw <= '0';                             --command 1 is a write
				  i2c_data_wr <= x"06";              		 --data to be written (address of LED0 and LED1 register)
				WHEN 1 =>                                  --1st busy high: command 1 latched, okay to issue command 2
				  i2c_data_wr <= x"05";              		 --data to be written (LED0 and LED1 register value)
				WHEN 2 =>                                  --2nd busy high: command 2 latched, ready to stop
				  i2c_ena <= '0';                            --deassert enable to stop transaction after command 4
				  IF(i2c_busy = '0') THEN                    --indicates data write is finished
					busy_cnt := 0;                           --reset busy_cnt for next transaction
					state <= after301ms;                     --transaction complete, go to next state in design
				  END IF;
				WHEN OTHERS => NULL;
			  END CASE;			
			
			when after301ms =>
			  busy_prev <= i2c_busy;                       --capture the value of the previous i2c busy signal
			  IF(busy_prev = '0' AND i2c_busy = '1') THEN  --i2c busy just went high
				busy_cnt := busy_cnt + 1;                  --counts the times busy has gone from low to high during transaction
			  END IF;
			  CASE busy_cnt IS                             --busy_cnt keeps track of which command we are on
				WHEN 0 =>                                  --no command latched in yet
				  i2c_ena <= '1';                            --initiate the transaction
				  i2c_addr <= C_I2C_ADDR;                    --set the address of the slave
				  i2c_rw <= '0';                             --command 1 is a write
				  i2c_data_wr <= x"08";              		 --data to be written (address of LED8 register)
				WHEN 1 =>                                  --1st busy high: command 1 latched, okay to issue command 2
				  i2c_data_wr <= x"02";              		 --data to be written (LED8 register value)
				WHEN 2 =>                                  --2nd busy high: command 2 latched, ready to stop
				  i2c_ena <= '0';                            --deassert enable to stop transaction after command 4
				  IF(i2c_busy = '0') THEN                    --indicates data write is finished
					busy_cnt := 0;                           --reset busy_cnt for next transaction
					state <= waitforever;                    --transaction complete, go to next state in design
				  END IF;
				WHEN OTHERS => NULL;
			  END CASE;	
			  
			when waitforever =>
				state 				<= waitforever;
										
			end case;
	end if; -- clk
end process machwastolles;


END rtl;