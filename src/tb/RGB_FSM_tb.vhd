library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb_fsm_tb is
end entity rgb_fsm_tb;

architecture structural of rgb_fsm_tb is
	CONSTANT C_CLK_PERIOD : time := 20 ns;

	component rgb_fsm
		port(clk_40     : in  std_ulogic;
			 reset_n    : in  std_ulogic;
			 rd_address : out std_logic_vector(16 downto 0);
			 rd_enable  : out STD_LOGIC;
			 rd_data    : in  std_logic_vector(15 downto 0);
			 v_sync     : out std_logic;
			 h_sync     : out std_logic;
			 data_en    : out std_logic;
			 red_out    : out std_logic_vector(4 downto 0);
			 green_out  : out std_logic_vector(5 downto 0);
			 blue_out   : out std_logic_vector(4 downto 0));
	end component rgb_fsm;

	component ram_top
		port(clk25      : in  std_ulogic;
			 clk40      : in  std_ulogic;
			 wr_data    : in  std_logic_vector(15 downto 0);
			 rd_address : in  std_logic_vector(16 downto 0);
			 wr_address : in  std_logic_vector(16 downto 0);
			 wr_enable  : in  std_logic;
			 rd_enable  : IN  STD_LOGIC;
			 rd_data    : out std_logic_vector(15 downto 0));
	end component ram_top;

	signal s_clk40      : STD_LOGIC;
	signal s_reset_n    : std_logic;
	signal s_rd_address : std_logic_vector(16 downto 0);
	signal s_rd_enable  : STD_LOGIC;
	signal s_rd_data    : std_logic_vector(15 downto 0);
	signal s_wr_data : std_logic_vector(15 downto 0);
	signal s_wr_address : std_logic_vector(16 downto 0);
	signal s_wr_enable : std_logic;

begin
	clk_proc : process
	begin
		s_clk40 <= '0';
		wait for C_CLK_PERIOD / 2;
		s_clk40 <= '1';
		wait for C_CLK_PERIOD / 2;
	end process;

	reset_n_proc : process
	begin
		s_reset_n <= '0';
		wait for 100 ns;
		s_reset_n <= '1';
		wait;
	end process;

	wr : PROCESS
	BEGIN
		s_wr_enable     <= '0';
		s_wr_data       <= (OTHERS => '0');
		s_wr_address    <= (OTHERS => '0');
		WAIT for 120 ns;
		FOR i IN 0 TO 20 LOOP
			s_wr_enable  <= '1';
			WAIT for 20 ns;
			s_wr_address <= std_logic_vector(to_unsigned(i, 17));
			s_wr_data    <= std_logic_vector(to_unsigned(i+1, 16));
			WAIT UNTIL rising_edge(s_clk40);
		END LOOP;
		s_wr_enable  <= '0';
		s_wr_address <= std_logic_vector(to_unsigned(0, 17));
		s_wr_data    <= std_logic_vector(to_unsigned(0, 16));
		WAIT;
	END PROCESS;
	

	rgb_fsm_inst : component rgb_fsm
		port map(
			clk_40     => s_clk40,
			reset_n    => s_reset_n,
			rd_address => s_rd_address,
			rd_enable  => s_rd_enable,
			rd_data    => s_rd_data,
			v_sync     => open,
			h_sync     => open,
			data_en    => open,
			red_out    => open,
			green_out  => open,
			blue_out   => open
		);
	ram_inst : component ram_top
		port map(
			clk25      => s_clk40,
			clk40      => s_clk40,
			wr_data    => s_wr_data,
			rd_address => s_rd_address,
			wr_address => s_wr_address,
			wr_enable  => s_wr_enable,
			rd_enable  => s_rd_enable,
			rd_data    => s_rd_data
		);

end architecture structural;
