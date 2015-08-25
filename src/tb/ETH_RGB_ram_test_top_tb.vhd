library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.ram_test_tb_pkg.all;
use ieee.math_real.all;

entity altera_tb is
end entity altera_tb;

architecture structural of altera_tb is
	component ETH_RGB_RAM_test_top
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
	end component ETH_RGB_RAM_test_top;

	signal rd_port : t_rd_port;
	signal wr_port : t_wr_port;

	--obsolete(?)
	signal inclk0           : std_ulogic;
	signal areset           : std_ulogic;
	signal pll_locked       : std_logic;
	signal wr_address       : std_logic_vector(9 downto 0);
	signal wr_data          : std_logic_vector(15 downto 0);
	signal p_write_finished : std_logic := '0';
	signal rd_address       : std_logic_vector(9 downto 0);
	signal rd_data          : std_logic_vector(15 downto 0);
	signal random           : integer;
	signal read_done        : std_logic := '0';
begin
	

	altera_top_inst : component ETH_RGB_RAM_test_top
		port map(inclk0     => inclk0,
			     areset     => areset,
			     wr_data    => wr_port.data,
			     rd_address => rd_port.addr,
			     wr_address => wr_port.addr,
			     wr_enable  => wr_port.enable,
			     pll_locked => pll_locked,
			     rd_clk     => rd_port.clock,
			     wr_clk     => wr_port.clock,
			     rd_data    => rd_port.data
		);

	p_clock : process
	begin
		WHILE read_done /= '1' LOOP
			inclk0 <= '0';
			wait for C_CLK_PERIOD / 2;
			inclk0 <= '1';
			wait for C_CLK_PERIOD / 2;
		END LOOP;
		--	if now >= C_END_OF_SIM then
		assert false report "End of simulation" severity note;
		wait;
	--	end if;
	end process;

	areset_proc : process
	begin
		areset <= '1';
		wait for 100 ns;
		areset <= '0';
		wait;
	end process;

	p_write : process
		file read_file : text open read_mode is "f_write.txt";
		VARIABLE read_line  : line;
		Variable write_addr : natural;
		VARIABLE write_data : std_logic_vector(15 downto 0);

	begin
		wr_port.clock  <= 'Z';
		wr_port.enable <= '0';
		wr_port.data   <= (OTHERS => '0');
		wr_port.addr   <= (OTHERS => '0');
		WAIT UNTIL pll_locked = '1';
		wait until rising_edge(wr_port.clock);
		for i in 0 to 7 loop
			readline(read_file, read_line);
			read(read_line, write_addr);
			hread(read_line, write_data);
			wr_address <= std_logic_vector(to_unsigned(write_addr, 10));
			wr_data    <= write_data;
			wr_mem(wr_address, wr_data, wr_port);
		end loop;
		wr_port.enable <= '0';
		file_close(read_file);
		p_write_finished <= '1';
		assert false report "Process p_write finished" severity note;
		wait;
	end process p_write;

	p_read : process
		file check_file : text open read_mode is "f_read.txt";
		file result_file : text open write_mode is "f_result.txt";
		variable write_line : line;
		VARIABLE check_line : line;
		Variable read_addr  : natural;
		VARIABLE read_data  : std_logic_vector(15 downto 0);
	begin
		rd_port.clock <= 'Z';
		rd_address    <= (others => '0');
		rd_data       <= (others => '0');
		rd_port.data  <= (others => 'Z');
		WAIT UNTIL p_write_finished = '1';
		wait for 2 * C_CLK_PERIOD;
		for i in 0 to 7 loop
			readline(check_file, check_line);
			read(check_line, read_addr);
			hread(check_line, read_data);

			rd_address <= std_logic_vector(to_unsigned(read_addr, 10));
			rd_data    <= read_data;
			rd_mem(rd_address, rd_data, rd_port, write_line);

			writeline(result_file, write_line);
		end loop;
		file_close(check_file);
		file_close(result_file);
		read_done <= '1';
		assert false report "Process p_read finished" severity note;
		wait;
	end process p_read;

	rand_gen : process
		variable seed1, seed2 : positive; -- Seed values for random generator
		variable rand         : real;   -- Random real-number value in range 0 to 1.0
		variable stim         : real;   -- Stimulus (real-number)
	begin
		uniform(seed1, seed2, rand);
		random <= integer(rand);
		wait;
	end process rand_gen;

end architecture structural;

