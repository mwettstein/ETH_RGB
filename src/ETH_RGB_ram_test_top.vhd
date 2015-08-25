library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ETH_RGB_RAM_test_top is
	port(
		inclk0     : in  std_ulogic;
		areset     : in  std_ulogic;
		wr_data    : in  std_logic_vector(15 downto 0);
		rd_address : in  std_logic_vector(9 downto 0);
		wr_address : in  std_logic_vector(9 downto 0);
		wr_enable  : in  std_logic;
		pll_locked : out std_logic;
		rd_clk     : out std_logic;
		wr_clk     : out std_logic;
		rd_data    : out std_logic_vector(15 downto 0)
	);
end entity ETH_RGB_RAM_test_top;

architecture structural of ETH_RGB_RAM_test_top is
	component my_altpll
		port(areset : IN  STD_LOGIC := '0';
			 inclk0 : IN  STD_LOGIC := '0';
			 c0     : OUT STD_LOGIC;
			 c1     : OUT STD_LOGIC;
			 locked : OUT STD_LOGIC);
	end component my_altpll;

	component ram_dual
		port(data      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rdaddress : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
			 rdclock   : IN  STD_LOGIC;
			 wraddress : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
			 wrclock   : IN  STD_LOGIC := '1';
			 wren      : IN  STD_LOGIC := '0';
			 q         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	end component ram_dual;

	SIGNAL raddr : natural range 0 to 1023;
	SIGNAL waddr : natural range 0 to 1023;

	SIGNAL s_rclk : std_logic;
	signal s_wclk : std_logic;

begin
	pll_inst : my_altpll
		port map(areset => areset,
			     inclk0 => inclk0,
			     c0     => s_rclk,
			     c1     => s_wclk,
			     locked => pll_locked);

	ram_inst : ram_dual
		port map(
			data      => wr_data,
			rdaddress => rd_address,
			rdclock   => s_rclk,
			wraddress => wr_address,
			wrclock   => s_wclk,
			wren      => wr_enable,
			q         => rd_data
		);

	raddr <= to_integer(unsigned(rd_address));
	waddr <= to_integer(unsigned(wr_address));

	rd_clk <= s_rclk;
	wr_clk <= s_wclk;

end architecture structural;
