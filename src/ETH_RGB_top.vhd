library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ETH_RGB_top is
	port(
		MAX10_CLK1_50	: in  std_ulogic;
		NET_RX_CLK		: in  std_ulogic;
		NET_RX_DV		: in  std_logic;
		NET_RXD			: in  std_logic_vector(3 downto 0);
		NET_RESET_n		: out std_logic;
		NET_TX_EN		: out std_logic;
		NET_TXD			: out std_logic_vector(3 downto 0);
		NET_PCF_EN		: out std_logic;
		GPIO1_D		: out std_logic_vector(21 downto 0);
		debug 			: out std_logic
		
	);
end entity ETH_RGB_top;

architecture structural of ETH_RGB_top is

	component my_altpll
		port(areset : IN  STD_LOGIC := '0';
			 inclk0 : IN  STD_LOGIC := '0';
			 c0     : OUT STD_LOGIC;
			 c1     : OUT STD_LOGIC;
			 locked : OUT STD_LOGIC);
	end component my_altpll;
	
	component ram_top
		port(clk25     : in  std_ulogic;
			 clk40      : in  std_ulogic;
			 areset     : in  std_ulogic;
			 wr_data    : in  std_logic_vector(15 downto 0);
			 rd_address : in  std_logic_vector(16 downto 0);
			 wr_address : in  std_logic_vector(16 downto 0);
			 wr_enable  : in  std_logic;
			 rd_enable  : IN  STD_LOGIC;
			 pll_locked : out std_logic;
			 rd_data    : out std_logic_vector(15 downto 0));
	end component ram_top;
	
	component phy_to_ram
		port(	clk25	  		: IN   STD_ULOGIC;
				rx_dv    	: IN   STD_LOGIC;
				rx_data   	: IN   STD_LOGIC_VECTOR(3 DOWNTO 0);
				data      	: OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
				wraddress	: OUT  STD_LOGIC_VECTOR(16 DOWNTO 0);
				wren      	: OUT  STD_LOGIC);
	end component phy_to_ram;
	
	component rgb_fsm
		port( clk_40		: in  std_ulogic;
				reset_n		: in  std_ulogic;
				v_sync      : out std_logic;
				h_sync      : out std_logic;
				data_en     : out std_logic;
				red_out     : out std_logic_vector(4 downto 0);
				green_out   : out std_logic_vector(5 downto 0);
				blue_out    : out std_logic_vector(4 downto 0));
	end component rgb_fsm;
		
	signal s_clk25 		: std_logic;
	signal s_clk40 		: std_logic;
	signal s_pll_locked 	: STD_LOGIC;
	signal s_wr_data 		: std_logic_vector(15 downto 0);
	signal s_rd_address 	: std_logic_vector(16 downto 0) := (others => '0');
	signal s_wr_address 	: std_logic_vector(16 downto 0);
	signal s_wr_enable 	: std_logic;
	signal s_rd_enable 	: STD_LOGIC;
	signal s_rd_data 		: std_logic_vector(15 downto 0);	
	signal s_gpios			: std_logic_vector(21 downto 0) := (others => '0');
	
	begin

	pll_inst : my_altpll
		port map(areset => '0',
			     inclk0 => MAX10_CLK1_50,
			     c0     => s_clk40,		-- currently not used
			     c1     => s_clk25,
			     locked => s_pll_locked);
			     
	ram_inst: component ram_top
		port map(
			clk25      => NET_RX_CLK,
			clk40      => s_clk40,
			areset     => '0',
			wr_data    => s_wr_data,
			rd_address => s_rd_address,
			wr_address => s_wr_address,
			wr_enable  => s_wr_enable,
			rd_enable  => '1', --s_rd_enable,
			pll_locked => s_pll_locked,
			rd_data    => s_rd_data
		);

	phy_to_ram_inst: component phy_to_ram
		port map(
			clk25			=> NET_RX_CLK,
			rx_dv			=> NET_RX_DV,
			rx_data		=> NET_RXD,
			data			=> s_wr_data,
			wraddress	=> s_wr_address,
			wren			=> s_wr_enable
		);		

	rgb_fsm_inst: component rgb_fsm
		port map(
			clk_40		=> s_clk40,
			reset_n		=> '1',
			v_sync      => s_gpios(0),
			h_sync      => s_gpios(2),
			data_en     => s_gpios(4),
			red_out     => s_gpios(9 downto 5),
			green_out   => s_gpios(15 downto 10),
			blue_out    => s_gpios(20 downto 16)
		);

		NET_RESET_n 		<= '1';
		NET_TX_EN			<= '0';
		NET_TXD				<= (others => '0');
		NET_PCF_EN			<= '0';
		
		s_gpios(1)		<= '0';
		s_gpios(3)		<= '0';
		s_gpios(21)		<= s_clk40;		
		GPIO1_D    		<= s_gpios;
		
		debug				<= s_gpios(21);
		
		
	end architecture structural;
