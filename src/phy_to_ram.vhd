LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;

ENTITY phy_to_ram IS
	PORT(
		-- MII interface 100MBit/s
		clk25	  : IN  STD_ULOGIC;
		rx_dv     : IN  STD_LOGIC;
		rx_data   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		
		-- to dual-port RAM interface
		data      : OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		wraddress : OUT  STD_LOGIC_VECTOR(16 DOWNTO 0);
		wren      : OUT  STD_LOGIC
	);
END phy_to_ram;

ARCHITECTURE rtl OF phy_to_ram IS

	constant exp_ethertype  : std_logic_vector(15 downto 0) := x"8e88";
	
	type stateType is (idle, dstMac, srcMac, EthTypeA, EthTypeB, EthTypeC,
	                   EthTypeD, extractLineNbr, pixelData, abort);					   
	signal state 			: stateType := idle;
	signal cnt              : integer range 0 to 12 := 0;
	signal line_nbr         : integer range 0 to 200 := 0;
	signal pixel_nbr        : integer range 0 to 400 := 0;
	signal data_int         : std_logic_vector(15 downto 0) := (others => '0');
	signal wraddr_int       : integer range 0 to 80000 := 0;
	signal wren_int         : std_logic := '0';

BEGIN

machwastolles : process(clk25)
begin
	if rising_edge(clk25) then
		if rx_dv = '0' then
			state 			<= idle;
			cnt             <= 0;
			line_nbr		<= 0;
			pixel_nbr		<= 0;
			data_int		<= (others => '0');
			wraddr_int		<= 0;
			wren_int		<= '0';
		else
			case state is
				-- Wait for the start of frame delimiter, ignore it
				-- sfd is 1101 in big endian format
				when idle =>
					if rx_data = x"D" then
						state <= dstMac;
					end if;

				-- read out destination MAC address (has to be
				-- broadcast, otherwise abort reading data
				when dstMac =>
					if rx_data = "1111" then
						cnt		<= cnt + 1;
						state   <= dstMac;
						if cnt = 11 then
							state <= srcMac;
							cnt <= 0;
						end if;
					else
						state <= abort;		-- wrong destination MAC address
					end if;

				-- read out source MAC address (but don't store or verify
				-- because we accept from everywhere)
				when srcMac =>
					cnt		<= cnt + 1;
					state   <= srcMac;
					if cnt = 11 then
						state <= EthTypeA;
						cnt <= 0;
					end if;
					
				-- read out Ethertype low byte low nibble and verify
				-- if Ethertype matches our protocol
				when EthTypeA =>
					if rx_data = exp_ethertype(3 downto 0) then
						state <= EthTypeB;
					else
						state <= abort;						
					end if;					
					
				-- read out Ethertype low byte high nibble and verify
				-- if Ethertype matches our protocol
				when EthTypeB =>
					if rx_data = exp_ethertype(7 downto 4) then
						state <= EthTypeC;
					else
						state <= abort;						
					end if;	
					
				-- read out Ethertype high byte low nibble and verify
				-- if Ethertype matches our protocol
				when EthTypeC =>
					if rx_data = exp_ethertype(11 downto 8) then
						state <= EthTypeD;
					else
						state <= abort;						
					end if;						
					
				-- read out Ethertype high byte high nibble and verify
				-- if Ethertype matches our protocol
				when EthTypeD =>
					if rx_data = exp_ethertype(15 downto 12) then
						state <= extractLineNbr;
						cnt   <= 0;
						line_nbr <= 0;
					else
						state <= abort;						
					end if;						
					
				-- extract line number from frame (max. 2 bytes)
				when extractLineNbr =>
					cnt <= cnt + 1;
					line_nbr <= line_nbr + (2**(4*cnt)) * to_integer(unsigned(rx_data));
					if cnt = 3 then
						state <= pixelData;
						cnt <= 0;
						pixel_nbr <= 0;
					else
						state <= extractLineNbr;
					end if;
				
				-- store pixeldata in RAM
				when pixelData =>
					cnt <= cnt + 1;
					
					wraddr_int <= 400 * line_nbr + pixel_nbr;
					
					if cnt = 0 then
						data_int <= data_int(15 downto 4) & rx_data;
						wren_int <= '0';
					end if;
					
					if cnt = 1 then
						data_int <= data_int(15 downto 8) & rx_data & data_int(3 downto 0);
						wren_int <= '0';
					end if;
					
					if cnt = 2 then
						data_int <= data_int(15 downto 12) & rx_data & data_int(7 downto 0);
						wren_int <= '0';
					end if;
						
					if cnt = 3 then
						data_int <= rx_data & data_int(11 downto 0);
						wren_int <= '1';
						cnt <= 0;
						pixel_nbr <= pixel_nbr + 1;
						if pixel_nbr = 79999 then
							state <= abort;
						end if;
					end if;
						
				-- if frame is not for us, or it is finished or something went wrong
				-- wait until frame is finished
				when abort =>
					state <= abort;
										
			end case;
		end if; -- rx_dv
	end if; -- clk
end process machwastolles;

data		<= data_int;
wraddress 	<= std_logic_vector(to_unsigned(wraddr_int, 17));
wren 		<= wren_int;

END rtl;