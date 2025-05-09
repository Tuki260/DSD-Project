LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        car2_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        serve : IN STD_LOGIC; -- initiates serve
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        hit_cnt : inout STD_LOGIC_VECTOR(15 DOWNTO 0);
        hit_cnt2 : inout STD_LOGIC_VECTOR(15 DOWNTO 0)
        
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    signal hit_check: std_logic := '0';
    signal hit_check2: std_logic := '0';
    CONSTANT bsize : INTEGER := 16; -- ball size in pixels
    CONSTANT wheelsize: INTEGER := 10;
    signal bat_w : INTEGER := 20; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 35; -- bat height in pixels
    signal car2_w : INTEGER := 20;
    CONSTANT car2_h : INTEGER := 35;
    -- distance ball moves each frame
    signal lfsr : std_logic_vector(10 DOWNTO 0) := (others => '1');
    signal lfsr2 : std_logic_vector(10 DOWNTO 0) := (others => '1');
    signal counter : STD_LOGIC_VECTOR (35 DOWNTO 0);
    signal randomx : STD_LOGIC_VECTOR (10 DOWNTO 0);
    signal ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0);
    signal ball2_speed : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL ball_on : STD_LOGIC;
    SIGNAL wheel_on: STD_LOGIC := '0';
    SIGNAL car2wheel_on: STD_LOGIC := '0';
    SIGNAL ball2_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    signal car2_on : STD_LOGIC;
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 11);
    SIGNAL ball2_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(650, 11);
    SIGNAL ball2_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
    signal wheel1_x, wheel1_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    signal wheel2_x, wheel2_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    signal wheel3_x, wheel3_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    signal wheel4_x, wheel4_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    signal car2wheel1_x, car2wheel1_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    signal car2wheel2_x, car2wheel2_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    signal car2wheel3_x, car2wheel3_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    signal car2wheel4_x, car2wheel4_y : STD_LOGIC_VECTOR(10 DOWNTO 0);
    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(550, 11);
    CONSTANT car2_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(550, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion, ball_y_motion, ball2_x_motion, ball2_y_motion  : STD_LOGIC_VECTOR(10 DOWNTO 0);
    
    Signal wall_right_on : Std_logic := '0';
    Signal wall_left_on : Std_logic := '0';
    signal wall_fill : std_logic := '0';
    signal wall_bottom : std_logic := '0';    
BEGIN

red   <= ball_on AND NOT wall_left_on AND NOT wall_right_on AND NOT wall_fill AND ball2_on AND car2_on;
green <= bat_on or wheel_on or car2wheel_on;
blue  <= NOT ball2_on AND NOT ball_on AND NOT bat_on AND NOT car2_on AND NOT wall_left_on AND NOT wall_right_on AND NOT wall_fill;
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball_x THEN -- vx = |ball_x - pixel_col|
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;
        IF pixel_row <= ball_y THEN -- vy = |ball_y - pixel_row|
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball_on <= game_on;
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;
    
    balldraw2 : PROCESS (ball2_x, ball2_y, pixel_row, pixel_col) IS
        VARIABLE v2x, v2y : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball2_x THEN -- vx = |ball_x - pixel_col|
            v2x := ball2_x - pixel_col;
        ELSE
            v2x := pixel_col - ball2_x;
        END IF;
        IF pixel_row <= ball2_y THEN -- vy = |ball_y - pixel_row|
            v2y := ball2_y - pixel_row;
        ELSE
            v2y := pixel_row - ball2_y;
        END IF;
        IF ((v2x * v2x) + (v2y * v2y)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball2_on <= game_on;
        ELSE
            ball2_on <= '0';
        END IF;
    END PROCESS;
    -- process to draw a wall
    walldraw : process(pixel_col)
    Begin
        If pixel_col = 350 THEN
            wall_left_on <= '1';
        else
            wall_left_on <= '0';
        end if;
        
        if pixel_col = 450 then
            wall_right_on <= '1';
        else
            wall_right_on <= '0';
        end if;
        
        if pixel_col >= 351 AND pixel_col <= 449 then
            wall_fill <= '1';
        else
            wall_fill <= '0';
        end if;
        
        if pixel_row >= 590 AND pixel_row <= 600 then
            wall_bottom <= '1';
        else
            wall_bottom <= '0';
        end if;
    end process;                    
        
    
    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
   BEGIN
       IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
            pixel_row >= bat_y - bat_h AND
            pixel_row <= bat_y + bat_h THEN
              bat_on <= '1';
        end if;
        IF bat_on <= '1' THEN
                wheel1_x <= bat_x + 14; 
                wheel1_y <= bat_y + 25; 
                wheel2_x <= bat_x - 14;
                wheel2_y <= bat_y - 25;
                wheel3_x <= bat_x + 14; 
                wheel3_y <= bat_y - 25; 
                wheel4_x <= bat_x - 14;
                wheel4_y <= bat_y + 25;
        END IF;
    END PROCESS;
    
     wheeldraw : PROCESS( pixel_col, pixel_row, wheel1_x, wheel1_y, wheel2_x, wheel2_y, wheel3_x, wheel3_y, wheel4_x, wheel4_y) IS
    VARIABLE vx, vy : STD_LOGIC_VECTOR(10 DOWNTO 0);
    VARIABLE hit  : BOOLEAN := FALSE;
BEGIN
    hit := FALSE;

    -- Wheel 1
    IF pixel_col <= wheel1_x THEN
        vx := wheel1_x - pixel_col;
    ELSE
        vx := pixel_col - wheel1_x;
    END IF;
    IF pixel_row <= wheel1_y THEN
        vy := wheel1_y - pixel_row;
    ELSE
        vy := pixel_row - wheel1_y;
    END IF;
    IF ((vx * vx) + (vy * vy)) < (wheelsize * wheelsize) THEN
        hit := TRUE;
    END IF;

    -- Wheel 2
    IF pixel_col <= wheel2_x THEN
        vx := wheel2_x - pixel_col;
    ELSE
        vx := pixel_col - wheel2_x;
    END IF;
    IF pixel_row <= wheel2_y THEN
        vy := wheel2_y - pixel_row;
    ELSE
        vy := pixel_row - wheel2_y;
    END IF;
    IF ((vx * vx) + (vy * vy)) < (wheelsize * wheelsize) THEN
        hit := TRUE;
    END IF;

    -- Wheel 3
    IF pixel_col <= wheel3_x THEN
        vx := wheel3_x - pixel_col;
    ELSE
        vx := pixel_col - wheel3_x;
    END IF;
    IF pixel_row <= wheel3_y THEN
        vy := wheel3_y - pixel_row;
    ELSE
        vy := pixel_row - wheel3_y;
    END IF;
    IF ((vx * vx) + (vy * vy)) < (wheelsize * wheelsize) THEN
        hit := TRUE;
    END IF;

    -- Wheel 4
    IF pixel_col <= wheel4_x THEN
        vx := wheel4_x - pixel_col;
    ELSE
        vx := pixel_col - wheel4_x;
    END IF;
    IF pixel_row <= wheel4_y THEN
        vy := wheel4_y - pixel_row;
    ELSE
        vy := pixel_row - wheel4_y;
    END IF;
    IF ((vx * vx) + (vy * vy)) < (wheelsize * wheelsize) THEN
        hit := TRUE;
    END IF;

    IF hit THEN
        wheel_on <= '1';
    ELSE
        wheel_on <= '0';
    END IF;
END PROCESS;
    
 car2wheeldraw : PROCESS( pixel_col, pixel_row, car2wheel1_x, car2wheel1_y, car2wheel2_x, car2wheel2_y, car2wheel3_x, car2wheel3_y, car2wheel4_x, car2wheel4_y) IS
    VARIABLE vx, vy : STD_LOGIC_VECTOR(10 DOWNTO 0);
    VARIABLE hit  : BOOLEAN := FALSE;
BEGIN
    hit := FALSE;

    -- Wheel 1
    IF pixel_col <= car2wheel1_x THEN
        vx := car2wheel1_x - pixel_col;
    ELSE
        vx := pixel_col - car2wheel1_x;
    END IF;
    IF pixel_row <= car2wheel1_y THEN
        vy := car2wheel1_y - pixel_row;
    ELSE
        vy := pixel_row - car2wheel1_y;
    END IF;
    IF ((vx * vx) + (vy * vy)) < (wheelsize * wheelsize) THEN
        hit := TRUE;
    END IF;

    -- Wheel 2
    IF pixel_col <= car2wheel2_x THEN
        vx := car2wheel2_x - pixel_col;
    ELSE
        vx := pixel_col - car2wheel2_x;
    END IF;
    IF pixel_row <= car2wheel2_y THEN
        vy := car2wheel2_y - pixel_row;
    ELSE
        vy := pixel_row - car2wheel2_y;
    END IF;
    IF ((vx * vx) + (vy * vy)) < (wheelsize * wheelsize) THEN
        hit := TRUE;
    END IF;

    -- Wheel 3
    IF pixel_col <= car2wheel3_x THEN
        vx := car2wheel3_x - pixel_col;
    ELSE
        vx := pixel_col - car2wheel3_x;
    END IF;
    IF pixel_row <= car2wheel3_y THEN
        vy := car2wheel3_y - pixel_row;
    ELSE
        vy := pixel_row - car2wheel3_y;
    END IF;
    IF ((vx * vx) + (vy * vy)) < (wheelsize * wheelsize) THEN
        hit := TRUE;
    END IF;

    -- Wheel 4
    IF pixel_col <= car2wheel4_x THEN
        vx := car2wheel4_x - pixel_col;
    ELSE
        vx := pixel_col - car2wheel4_x;
    END IF;
    IF pixel_row <= wheel4_y THEN
        vy := car2wheel4_y - pixel_row;
    ELSE
        vy := pixel_row - car2wheel4_y;
    END IF;
    IF ((vx * vx) + (vy * vy)) < (wheelsize * wheelsize) THEN
        hit := TRUE;
    END IF;

    IF hit THEN
        car2wheel_on <= '1';
    ELSE
        car2wheel_on <= '0';
    END IF;
END PROCESS;

    car2draw : PROCESS (car2_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= car2_x - car2_w) OR (car2_x <= car2_w)) AND
         pixel_col <= car2_x + car2_w AND
             pixel_row >= car2_y - car2_h AND
             pixel_row <= car2_y + car2_h THEN
                car2_on <= '1';
        end if;
        If car2_on <= '1' then
                car2wheel1_x <= car2_x + 14; 
                car2wheel1_y <= car2_y + 25; 
                car2wheel2_x <= car2_x - 14;
                car2wheel2_y <= car2_y - 25;
                car2wheel3_x <= car2_x + 14; 
                car2wheel3_y <= car2_y - 25; 
                car2wheel4_x <= car2_x - 14;
                car2wheel4_y <= car2_y + 25;
        END IF;
    END PROCESS;
    
    
    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp2 : STD_LOGIC_VECTOR (11 DOWNTO 0);
        variable rnd_int : integer;
        variable rnd_int2 : integer;
        
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        lfsr <= lfsr(9 DOWNTO 0) & (lfsr(10) xor lfsr(8));
        lfsr2 <= lfsr2(9 DOWNTO 0) & (lfsr2(10) xor lfsr2(8));
        rnd_int := conv_integer(unsigned(lfsr(8 DOWNTO 0))) mod 301;
        rnd_int2 := conv_integer(unsigned(lfsr2(8 DOWNTO 0))) mod 326;
        IF serve = '1' AND game_on = '0' THEN -- test for new serve 
            counter <= (OTHERS =>'0');
        else
            counter <= counter + 1;
        end if;
        IF serve = '1' AND game_on = '0' THEN -- test for new serve          
            game_on <= '1';
            hit_cnt <= "0000000000000000";
            hit_cnt2 <= "0000000000000000";
            hit_check <= '0';
            ball_speed <= CONV_STD_LOGIC_VECTOR(6, 11); 
            ball_x_motion <= CONV_STD_LOGIC_VECTOR(6, 11);
            ball_y_motion <= (CONV_STD_LOGIC_VECTOR(6, 11)) + 1; -- set vspeed to (- ball_speed) pixels 
                 
        ELSIF ball_y <= bsize THEN -- bounce off top wall
            ball_y_motion <= ball_speed;
            hit_check <= '0'; -- set vspeed to (+ ball_speed) pixels
        ELSIF ball_y + bsize >= 600 then -- if ball meets bottom wall
            --ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            if hit_check = '0' then
            hit_check   <= '1';
            ball_y_motion<= ball_speed;
            end if;
            if (unsigned(ball_y) > conv_unsigned(bsize,11)) then
            hit_check <= '0';
            ball_speed <= conv_std_logic_vector(6 + conv_integer(unsigned(hit_cnt)), 11);
            end if;
            --game_on <= '1'; -- and make ball disappea
            
        END IF;
        -- allow for bounce off car
        IF (ball_x + bsize/2) >= (bat_x - bat_w) AND
         (ball_x - bsize/2) <= (bat_x + bat_w) AND
             (ball_y + bsize/2) >= (bat_y - bat_h) AND
             (ball_y - bsize/2) <= (bat_y + bat_h) THEN
                --ball_y_motion <= (NOT ball_speed) + 1;
                --bat_w <= bat_w - 1; -- set vspeed to (- ball_speed) pixels
                if unsigned(hit_cnt) > conv_unsigned(5, 16) then
                hit_cnt <= conv_std_logic_vector((unsigned(hit_cnt) - 2), 16);
                ball_y <= CONV_STD_LOGIC_VECTOR(10, 11);
                else
                hit_cnt <= (others=>'0');
                ball_y <= CONV_STD_LOGIC_VECTOR(10, 11);
                end if;
               --game_on <= '0';
        END IF;
        -- Ball 2 motion 
        IF serve = '1' AND game_on = '0' THEN -- test for new serve          
            game_on <= '1';
            hit_cnt <= "0000000000000000";
            ball2_speed <= CONV_STD_LOGIC_VECTOR(6, 11); 
            ball2_x_motion <= CONV_STD_LOGIC_VECTOR(6, 11);
            ball2_y_motion <= (CONV_STD_LOGIC_VECTOR(6, 11)) + 1; -- set vspeed to (- ball_speed) pixels          
        ELSIF ball2_y <= bsize THEN -- bounce off top wall
            ball2_y_motion <= ball2_speed;
            --hit_check <= '0'; -- set vspeed to (+ ball_speed) pixels
        ELSIF ball2_y + bsize >= 600 then -- if ball meets bottom wall
            --ball2_y_motion <= (NOT ball2_speed) + 1; -- set vspeed to (- ball_speed) pixels
            if hit_check2 = '0' then
            hit_check2   <= '1';
            ball2_y_motion<= ball2_speed;
            end if;
            if (unsigned(ball2_y) > conv_unsigned(10,11)) then
            hit_check2 <= '0';
            ball2_speed <= conv_std_logic_vector(6 + conv_integer(unsigned(hit_cnt2)), 11);
            end if;
            --game_on <= '1';
        END IF;
        -- allow for bounce off bat
        IF (ball2_x + bsize/2) >= (car2_x - car2_w) AND
         (ball2_x - bsize/2) <= (car2_x + car2_w) AND
             (ball2_y + bsize/2) >= (car2_y - car2_h) AND
             (ball2_y - bsize/2) <= (car2_y + car2_h) THEN
                if unsigned(hit_cnt2) > conv_unsigned(5, 16) then
                hit_cnt2 <= conv_std_logic_vector((unsigned(hit_cnt2) - 2), 16);
                ball2_y <= CONV_STD_LOGIC_VECTOR(10, 11);
                else
                hit_cnt2 <= (others=>'0');
                ball2_y <= CONV_STD_LOGIC_VECTOR(10, 11);
                end if;
               --game_on <= '0';
        END IF;     
 
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(10, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSIF conv_integer(temp(10 DOWNTO 0)) + bsize >= 600 THEN
        ball_x <= std_logic_vector(conv_unsigned((rnd_int), 11));
        ball_y <= CONV_STD_LOGIC_VECTOR(10, 11);
        hit_cnt <= hit_cnt + 1;
        if hit_cnt = 69 then
        game_on <= '0';
        end if;
        if hit_cnt < 25 then
        ball_speed <= conv_std_logic_vector(6 + conv_integer(unsigned(hit_cnt)), 11);
        end if;
        ball_y_motion <= ball_speed;
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;
        --ball 2
        temp2 := ('0' & ball2_y) + (ball2_y_motion(10) & ball2_y_motion);
        IF game_on = '0' THEN
            ball2_y <= CONV_STD_LOGIC_VECTOR(10, 11);
        ELSIF temp2(11) = '1' THEN
            ball2_y <= (OTHERS => '0');
        ELSIF conv_integer(temp2(10 DOWNTO 0)) + bsize >= 600 THEN
        ball2_x <= std_logic_vector(conv_unsigned(rnd_int2 + 450, 11));
        ball2_y <= CONV_STD_LOGIC_VECTOR(10, 11);
        hit_cnt2 <= hit_cnt2 + 1;
        if hit_cnt2 = 69 then
        game_on <= '0';
        end if;
        if hit_cnt2 < 25 then
        ball2_speed <= conv_std_logic_vector(6 + conv_integer(unsigned(hit_cnt2)), 11);
        end if;
        ball2_y_motion <= ball2_speed;
        ELSE ball2_y <= temp2(10 DOWNTO 0); -- 9 downto 0
        END IF;
         
    END PROCESS;
END Behavioral;
