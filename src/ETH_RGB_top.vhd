library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ETH_RGB_top is
	port(
		
		clk50         : in  std_ulogic;
		eth_rx_dv     : in  std_logic;
		eth_rx_data   : in  std_logic_vector(3 downto 0);
		
		
		clk25         : out std_ulogic
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
		port(clk25      : in  std_ulogic;
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
	
	signal s_clk40 : std_logic;
	signal s_clk25 : std_logic;
	signal s_pll_locked : STD_LOGIC;
	signal s_wr_data : std_logic_vector(15 downto 0);
	signal s_rd_address : std_logic_vector(16 downto 0);
	signal s_wr_address : std_logic_vector(16 downto 0);
	signal s_wr_enable : std_logic;
	signal s_rd_enable : STD_LOGIC;
	signal s_rd_data : std_logic_vector(15 downto 0);
	
	begin
	pll_inst : my_altpll
		port map(areset => '0',
			     inclk0 => clk50,
			     c0     => s_clk25,
			     c1     => s_clk40,
			     locked => s_pll_locked);
			     
	ram_inst: component ram_top
		port map(
			clk25      => s_clk25,
			clk40      => s_clk40,
			areset     => '0',
			wr_data    => s_wr_data,
			rd_address => s_rd_address,
			wr_address => s_wr_address,
			wr_enable  => s_wr_enable,
			rd_enable  => s_rd_enable,
			pll_locked => s_pll_locked,
			rd_data    => s_rd_data
		);

	phy_to_ram_inst: component phy_to_ram
		port map(
			clk25		=> s_clk25,
			rx_dv		=> eth_rx_dv,
			rx_data		=> eth_rx_data,
			data		=> s_wr_data,
			wr_address	=> s_wr_address,
			wren		=> s_wr_enable,
		);		
		
	end architecture structural;
