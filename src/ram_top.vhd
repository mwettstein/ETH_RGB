library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_top is
	port(
		clk25     : in  std_ulogic;
		clk40     : in  std_ulogic;
		areset     : in  std_ulogic;
		wr_data    : in  std_logic_vector(15 downto 0);
		rd_address : in  std_logic_vector(16 downto 0);
		wr_address : in  std_logic_vector(16 downto 0);
		wr_enable  : in  std_logic;
		rd_enable  : IN STD_LOGIC;
		pll_locked : out std_logic;
		rd_data    : out std_logic_vector(15 downto 0)
	);
end entity ram_top;

architecture structural of ram_top is

	component ram_dual
		port(data      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rdaddress : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
			 rdclock   : IN  STD_LOGIC;
			 rden      : IN  STD_LOGIC := '1';
			 wraddress : IN  STD_LOGIC_VECTOR(14 DOWNTO 0);
			 wrclock   : IN  STD_LOGIC := '1';
			 wren      : IN  STD_LOGIC := '0';
			 q         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	end component ram_dual;

	component ram_dual_small
		port(data      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rdaddress : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);
			 rdclock   : IN  STD_LOGIC;
			 rden      : IN  STD_LOGIC := '1';
			 wraddress : IN  STD_LOGIC_VECTOR(13 DOWNTO 0);
			 wrclock   : IN  STD_LOGIC := '1';
			 wren      : IN  STD_LOGIC := '0';
			 q         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	end component ram_dual_small;
	

	SIGNAL s_rclk : std_logic;
	signal s_wclk : std_logic;
	signal s_rd_cs : std_logic_vector(1 downto 0);
	signal s_wr_cs : std_logic_vector(1 downto 0);
	
	signal rd_enable0 : STD_LOGIC;
	signal rd_enable1 : std_logic;
	signal rd_enable2 : std_logic;
	signal wr_enable0 : std_logic;
	signal wr_enable1 : std_logic;
	signal wr_enable2 : std_logic;
	signal s_rd_address : std_logic_vector(14 downto 0);
	signal s_wr_address : std_logic_vector(14 downto 0);
	signal s_rd_data0 : std_logic_vector(15 downto 0);
	signal s_rd_data1 : std_logic_vector(15 downto 0);
	signal s_rd_data2 : std_logic_vector(15 downto 0);

begin
	
	ram_inst0: ram_dual
		port map(
			data      => wr_data,
			rdaddress => s_rd_address,
			rdclock   => s_rclk,
			rden      => rd_enable0,
			wraddress => s_wr_address,
			wrclock   => s_wclk,
			wren      => wr_enable0,
			q         => s_rd_data0
		);
	
		ram_inst1: ram_dual
		port map(
			data      => wr_data,
			rdaddress => s_rd_address,
			rdclock   => s_rclk,
			rden      => rd_enable1,
			wraddress => s_wr_address,
			wrclock   => s_wclk,
			wren      => wr_enable1,
			q         => s_rd_data1
		);
	
		ram_inst2: ram_dual_small
			port map(
				data      => wr_data,
				rdaddress => s_rd_address(13 downto 0),
				rdclock   => s_rclk,
				rden      => rd_enable2,
				wraddress => s_wr_address(13 downto 0),
				wrclock   => s_wclk,
				wren      => wr_enable2,
				q         => s_rd_data2
			);

	process(s_rd_cs, rd_enable)
	begin
		case s_rd_cs is
			when "00" => 	rd_enable0 <= rd_enable;
							rd_enable1 <= '0';
							rd_enable2 <= '0';
			when "01" => 	rd_enable0 <= '0';
							rd_enable1 <= rd_enable;
							rd_enable2 <= '0';
			when "10" => 	rd_enable0 <= '0';
							rd_enable1 <= '0';
							rd_enable2 <= rd_enable;
			when others => 	rd_enable0 <= '0';
							rd_enable1 <= '0';
							rd_enable2 <= '0';
		end case;
	end process;
	
		process(s_rd_cs, s_rd_data0,s_rd_data1,s_rd_data2)
	begin
		case s_rd_cs is
			when "00" => 	rd_data <= s_rd_data0;
			when "01" => 	rd_data <= s_rd_data1;
			when "10" => 	rd_data <= s_rd_data2;
			when others => 	rd_data <= (others => '0');
							
		end case;
	end process;
		process(s_wr_cs, wr_enable)
	begin
		case s_wr_cs is
			when "00" => 	wr_enable0 <= wr_enable;
							wr_enable1 <= '0';
							wr_enable2 <= '0';
			when "01" => 	wr_enable0 <= '0';
							wr_enable1 <= wr_enable;
							wr_enable2 <= '0';
			when "10" => 	wr_enable0 <= '0';
							wr_enable1 <= '0';
							wr_enable2 <= wr_enable;
			when others => 	wr_enable0 <= '0';
							wr_enable1 <= '0';
							wr_enable2 <= '0';
		end case;
	end process;
	

	
	s_rd_cs <= rd_address(16 downto 15);
	s_wr_cs <= wr_address(16 downto 15);
	s_rd_address <= rd_address(14 downto 0);
	s_wr_address <= wr_address(14 downto 0);
	
	s_rclk <= clk40;
	s_wclk <= clk25;

end architecture structural;
