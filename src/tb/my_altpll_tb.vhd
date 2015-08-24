library ieee;
use ieee.std_logic_1164.all;

entity my_altpll_tb is
end entity my_altpll_tb;

architecture structural of my_altpll_tb is

	CONSTANT C_CLK_PERIOD:	time := 20 ns;
	
	signal areset_sig : STD_LOGIC;
	signal inclk0_sig : STD_LOGIC;
	signal c0_sig     : STD_LOGIC;
	signal c1_sig     : STD_LOGIC;
	signal locked_sig : STD_LOGIC;

	component my_altpll
		port(areset : IN  STD_LOGIC := '0';
			 inclk0 : IN  STD_LOGIC := '0';
			 c0     : OUT STD_LOGIC;
			 c1     : OUT STD_LOGIC;
			 locked : OUT STD_LOGIC);
	end component my_altpll;

begin

    clk_proc: process
    begin
        inclk0_sig <= '0';
        wait for C_CLK_PERIOD/2;
        inclk0_sig <= '1';
        wait for C_CLK_PERIOD/2;
    end process;
    
    reset_n_proc: process
    begin
        areset_sig <= '1';
        wait for 100 ns;
        areset_sig <= '0';
        wait;
    end process;
    
	my_altpll_inst : my_altpll PORT MAP(
			areset => areset_sig,
			inclk0 => inclk0_sig,
			c0     => c0_sig,
			c1     => c1_sig,
			locked => locked_sig
		);

end architecture structural;
