library ieee;
use ieee.std_logic_1164.all;

entity rgb_fsm_tb is
end entity rgb_fsm_tb;

architecture structural of rgb_fsm_tb is
	CONSTANT C_CLK_PERIOD : time := 20 ns;

	component rgb_fsm
		port(clk_40        : in  std_ulogic;
			 reset_n       : in  std_ulogic;
			 v_sync        : out std_logic;
			 h_sync        : out std_logic;
			 data_en       : out std_logic;
			 red_out       : out std_logic_vector(4 downto 0);
			 green_out     : out std_logic_vector(5 downto 0);
			 blue_out      : out std_logic_vector(4 downto 0));
	end component rgb_fsm;

	signal s_clk40   : STD_LOGIC;
	signal s_reset_n : std_logic;

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

	rgb_fsm_inst : component rgb_fsm
		port map(
			clk_40        => s_clk40,
			reset_n       => s_reset_n,
			v_sync        => open,
			h_sync        => open,
			data_en       => open,
			red_out       => open,
			green_out     => open,
			blue_out      => open
		);

end architecture structural;
