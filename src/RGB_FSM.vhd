library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb_fsm is
	port(
		clk_40     : in  std_ulogic;
		reset_n    : in  std_ulogic;
		--outputs to RAM
		rd_address : out std_logic_vector(16 downto 0);
		rd_enable  : out STD_LOGIC;
		rd_data    : in  std_logic_vector(15 downto 0);
		-- outputs to TFT
		v_sync     : out std_logic;
		h_sync     : out std_logic;
		data_en    : out std_logic;
		red_out    : out std_logic_vector(4 downto 0);
		green_out  : out std_logic_vector(5 downto 0);
		blue_out   : out std_logic_vector(4 downto 0)
	);

end entity rgb_fsm;
architecture behavioral of rgb_fsm is
	-----------------------------------------------------------------------------
	-- Type Definitions
	-----------------------------------------------------------------------------
	type state_type_h is (h_pulsewidth, h_backporch, h_validdata, h_frontporch, h_blank); --type of v control state machine.
	type state_type_v is (v_pulsewidth, v_backporch, v_validdata, v_frontporch, v_blank); --type of h control state machine.
	----------------------------------------------------------------------------
	-- Constants
	-----------------------------------------------------------------------------
	constant C_H_PULSEWIDTH : positive := 2; --[clock ticks]
	constant C_H_BACKPORCH  : positive := 45; --[clock ticks]
	constant C_H_VALIDDATA  : positive := 800; --[clock ticks]
	constant C_H_FRONTPORCH : positive := 17; --[clock ticks]
	constant C_H_BLANK      : positive := 1; --[clock ticks]

	constant C_V_PULSEWIDTH : positive := 2; --[lines]
	constant C_V_BACKPORCH  : positive := 22; --[lines]
	constant C_V_VALIDDATA  : positive := 480; --[lines]
	constant C_V_FRONTPORCH : positive := 22; --[lines]
	constant C_V_BLANK      : positive := 1; --[lines]

	constant C_TEST_RED   : std_logic_vector(4 downto 0) := "10000";
	constant C_TEST_GREEN : std_logic_vector(5 downto 0) := "100000";
	constant C_TEST_BLUE  : std_logic_vector(4 downto 0) := "10000";

	-----------------------------------------------------------------------------
	-- Components
	-----------------------------------------------------------------------------

	-----------------------------------------------------------------------------
	-- Signals
	-----------------------------------------------------------------------------
	signal s_h_sync : std_logic;
	signal s_v_sync : std_logic;

begin

	-----------------------------------------------------------------------------
	-- RGB State Machine
	-----------------------------------------------------------------------------
	clocked : process(clk_40, reset_n)
		variable current_state_v, next_state_v : state_type_v; --current and next state declaration for vertical control.
		variable current_state_h, next_state_h : state_type_h; --current and next state declaration for horizontal control.
		variable clk_count                     : integer range 0 to 865 := 0;
		variable line_count                    : integer range 0 to 527 := 0; --527
		variable line_count_real               : integer range 0 to 200 := 0;
		variable data_enable_h                 : std_logic              := '0';
		variable debug_count_clk               : integer                := 0;
		variable debug_count_line              : integer                := 0;

	begin
		IF reset_n = '0' then
			s_h_sync <= '0';
			s_v_sync <= '0';

			red_out   <= (others => '0');
			green_out <= (others => '0');
			blue_out  <= (others => '0');

			current_state_h := h_pulsewidth;
			current_state_v := v_pulsewidth;
			clk_count       := 0;
			line_count      := 0;
		elsif rising_edge(clk_40) then
			current_state_h := next_state_h;
			current_state_v := next_state_v;

			-- Horizontal control
			debug_count_clk := debug_count_clk + 1;
			clk_count       := clk_count + 1;
			case current_state_h is

				--PULSEWIDTH
				when h_pulsewidth =>
					s_h_sync      <= '0';
					data_enable_h := '0';
					if clk_count < C_H_PULSEWIDTH then
						next_state_h := h_pulsewidth;
					else
						next_state_h := h_backporch;
						clk_count    := 0;
					end if;

				--BACKPORCH
				when h_backporch =>
					s_h_sync      <= '1';
					data_enable_h := '0';
					if clk_count < C_H_BACKPORCH - 2 then
						next_state_h := h_backporch;
					elsif clk_count = C_H_BACKPORCH - 2 then
						rd_enable  <= '1';
						rd_address <= std_logic_vector(to_unsigned(line_count_real * 400 + 0, 17));
					elsif clk_count = C_H_BACKPORCH - 1 then
						rd_address <= std_logic_vector(to_unsigned(line_count_real * 400 + 1, 17));
						rd_enable  <= '1';
					else
						clk_count    := 0;
						next_state_h := h_validdata;
						rd_address   <= std_logic_vector(to_unsigned(line_count_real * 400 + 2, 17));
						rd_enable    <= '1';
					end if;

				--VALIDDATA
				when h_validdata =>
					s_h_sync      <= '1';
					data_enable_h := '1';
					if clk_count < C_H_VALIDDATA then
						next_state_h := h_validdata;
						rd_address   <= std_logic_vector(to_unsigned(line_count_real * 400 + clk_count + 3, 17));
						rd_enable    <= '1';
						red_out      <= rd_data(15 downto 11); --C_TEST_RED;
						green_out    <= rd_data(10 downto 5); --C_TEST_GREEN;
						blue_out     <= rd_data(4 downto 0); --C_TEST_BLUE;

					else
						clk_count    := 0;
						red_out      <= (others => '0');
						green_out    <= (others => '0');
						blue_out     <= (others => '0');
						next_state_h := h_frontporch;

						rd_enable <= '0';
					end if;

				--FRONTPORCH
				when h_frontporch =>
					s_h_sync      <= '1';
					data_enable_h := '0';
					if clk_count < C_H_FRONTPORCH then
						next_state_h := h_frontporch;
					else
						clk_count    := 0;
						next_state_h := h_blank;
					end if;

				--BLANK
				when h_blank =>
					s_h_sync      <= '1';
					data_enable_h := '0';
					if clk_count < C_H_BLANK then
						next_state_h := h_blank;
					else
						clk_count  := 0;
						line_count := line_count + 1;
						if line_count >= 200 then
							if line_count >= 400 then
								line_count_real := line_count mod 400;
							else
								line_count_real := line_count mod 200;
							end if;
						else 
							line_count_real := line_count;
						end if;

						debug_count_line := debug_count_line + 1;
						next_state_h     := h_pulsewidth;
					end if;
			end case;

			-- Vertical control
			case current_state_v is
				--PULSEWIDTH
				when v_pulsewidth =>
					s_v_sync <= '0';
					data_en  <= '0';
					if line_count < C_V_PULSEWIDTH then
						next_state_v := v_pulsewidth;
					else
						line_count   := 0;
						next_state_v := v_backporch;
					end if;

				--BACKPORCH
				when v_backporch =>
					s_v_sync <= '1';
					data_en  <= '0';
					if line_count < C_V_BACKPORCH then
						next_state_v := v_backporch;
					else
						line_count   := 0;
						next_state_v := v_validdata;
					end if;

				--VALIDDATA	
				when v_validdata =>
					s_v_sync <= '1';
					data_en  <= data_enable_h;
					if line_count < C_V_VALIDDATA then
						next_state_v := v_validdata;
					else
						line_count   := 0;
						next_state_v := v_frontporch;
					end if;

				--FRONTPORCH	
				when v_frontporch =>
					s_v_sync <= '1';
					data_en  <= '0';
					if line_count < C_V_FRONTPORCH then
						next_state_v := v_frontporch;
					else
						line_count   := 0;
						next_state_v := v_blank;
					end if;

				-- BLANK	
				when v_blank =>
					s_v_sync <= '1';
					data_en  <= '0';
					if line_count < C_V_BLANK then
						next_state_v := v_blank;
					else
						line_count   := 0;
						next_state_v := v_pulsewidth;
					end if;
			end case;

		end if;
	end process;

	h_sync <= s_h_sync;
	v_sync <= s_v_sync;

end architecture behavioral;

