library ieee;
use ieee.std_logic_1164.all;

entity dummy_top is

end entity dummy_top;

architecture struct of dummy_top is
	component altera_top
		port(inclk0     : in  std_ulogic;
			 areset     : in  std_ulogic;
			 wr_data    : in  std_logic_vector(15 downto 0);
			 rd_address : in  std_logic_vector(9 downto 0);
			 wr_address : in  std_logic_vector(9 downto 0);
			 wr_enable  : in  std_logic;
			 pll_locked : out std_logic;
			 rd_clk     : out std_logic;
			 wr_clk     : out std_logic;
			 rd_data    : out std_logic_vector(15 downto 0));
	end component altera_top;
	signal inclk0 : std_ulogic;
	signal areset : std_ulogic;
	signal wr_data : std_logic_vector(15 downto 0);
	signal rd_address : std_logic_vector(9 downto 0);
	signal wr_address : std_logic_vector(9 downto 0);
	signal pll_locked : std_logic;
	signal wr_enable : std_logic;
	signal rd_clk : std_logic;
	signal rd_data : std_logic_vector(15 downto 0);
	signal wr_clk : std_logic;
begin
	altera_top_inst: component altera_top
		port map(inclk0     => inclk0,
			     areset     => areset,
			     wr_data    => wr_data,
			     rd_address => rd_address,
			     wr_address => wr_address,
			     wr_enable  => wr_enable,
			     pll_locked => pll_locked,
			     rd_clk     => rd_clk,
			     wr_clk     => wr_clk,
			     rd_data    => rd_data);
end architecture struct;
