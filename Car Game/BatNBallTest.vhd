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
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    CONSTANT wheelsize: INTEGER := 10;
    signal bat_w : INTEGER := 10; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 50; -- bat height in pixels
    signal car2_w : INTEGER := 10;
    CONSTANT car2_h : INTEGER := 50;
    -- distance ball moves each frame
    signal ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0);
    signal ball2_speed : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL ball_on : STD_LOGIC;
    SIGNAL ball2_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL wheel_on: STD_LOGIC;
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    signal car2_on : STD_LOGIC;
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
    SIGNAL ball2_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(650, 11);
    SIGNAL ball2_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
    SIGNAL wheel_x: STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL wheel_y: STD_LOGIC_VECTOR(10 DOWNTO 0);

    

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
red   <= ball_on AND NOT wall_left_on AND NOT wall_right_on AND NOT wall_fill AND ball2_on;
green <= bat_on or car2_on or wall_bottom or wheel_on; 
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
        IF pixel_col <= bat_x THEN -- vx = |ball_x - pixel_col|
            vx := bat_x - pixel_col;
        ELSE
            vx := pixel_col - bat_x;
        END IF;
        IF pixel_row <= bat_y THEN -- vy = |ball_y - pixel_row|
            vy := bat_y - pixel_row;
        ELSE
            vy := pixel_row - bat_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bat_w * bat_w) THEN -- test if radial distance < bsize
            bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;            
            IF bat_on <= '1' THEN
                wheel_x := vx + 5;
                wheel_y := vy + 8;
    END IF;
    END PROCESS;

           wheeldraw: PROCESS( wheel_x, wheel_y, pixel_row, pixel_col) is
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
   BEGIN
        IF pixel_col <= wheel_x THEN -- vx = |ball_x - pixel_col|
            vx := wheel_x - pixel_col;
        ELSE
            vx := pixel_col - wheel_x;
        END IF;
        IF pixel_row <= wheel_y THEN -- vy = |ball_y - pixel_row|
            vy := wheel_y - pixel_row;
        ELSE
            vy := pixel_row - wheel_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (wheelsize * wheelsize) THEN -- test if radial distance < bsize
            wheel_on <= '1';
        ELSE
            wheel_on <= '0';
        END IF;                   
    
    
    car2draw : PROCESS (car2_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= car2_x - car2_w) OR (car2_x <= car2_w)) AND
         pixel_col <= car2_x + car2_w AND
             pixel_row >= car2_y - car2_h AND
             pixel_row <= car2_y + car2_h THEN
                car2_on <= '1';
        ELSE
            car2_on <= '0';
        END IF;
    END PROCESS;
    
    
    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
        VARIABLE temp2 : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
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
        -- allow for bounce off left or right of screen
        IF ball_x + bsize >= 350 THEN -- bounce off right wall
            --ball_x_motion <= (NOT ball_speed) + 1;
            --hit_check <= '0'; -- set hspeed to (- ball_speed) pixels
        ELSIF ball_x <= bsize THEN -- bounce off left wall
            --ball_x_motion <= ball_speed;
            --hit_check <= '0'; -- set hspeed to (+ ball_speed) pixels
        END IF;
        -- allow for bounce off bat
        IF (ball_x + bsize/2) >= (bat_x - bat_w) AND
         (ball_x - bsize/2) <= (bat_x + bat_w) AND
             (ball_y + bsize/2) >= (bat_y - bat_h) AND
             (ball_y - bsize/2) <= (bat_y + bat_h) THEN
                --ball_y_motion <= (NOT ball_speed) + 1;
                --bat_w <= bat_w - 1; -- set vspeed to (- ball_speed) pixels
               game_on <= '0';
        END IF;
        -- Ball 2 motion 
        IF serve = '1' AND game_on = '0' THEN -- test for new serve          
            game_on <= '1';
            hit_cnt <= "0000000000000000";
            ball2_speed <= CONV_STD_LOGIC_VECTOR(6, 11); 
            ball2_x_motion <= CONV_STD_LOGIC_VECTOR(6, 11);
            ball2_y_motion <= (NOT CONV_STD_LOGIC_VECTOR(6, 11)) + 1; -- set vspeed to (- ball_speed) pixels          
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
        -- allow for bounce off left or right of screen
        IF ball2_x + bsize >= 800 THEN -- bounce off right wall
            ball2_x_motion <= (NOT ball2_speed) + 1;
            --hit_check <= '0'; -- set hspeed to (- ball_speed) pixels
        ELSIF ball2_x + bsize <= 4 THEN -- bounce off left wall
            ball2_x_motion <= ball2_speed;
            --hit_check <= '0'; -- set hspeed to (+ ball_speed) pixels
        END IF;
        -- allow for bounce off bat
        IF (ball2_x + bsize/2) >= (car2_x - car2_w) AND
         (ball2_x - bsize/2) <= (car2_x + car2_w) AND
             (ball2_y + bsize/2) >= (car2_y - car2_h) AND
             (ball2_y - bsize/2) <= (car2_y + car2_h) THEN
                --ball2_y_motion <= (NOT ball2_speed) + 1;
                --bat_w <= bat_w - 1; -- set vspeed to (- ball_speed) pixels
               game_on <= '0';
        END IF;     
        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to zero and ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(10, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSIF conv_integer(temp(10 DOWNTO 0)) + bsize >= 600 THEN
        ball_y <= CONV_STD_LOGIC_VECTOR(10, 11);
        hit_cnt <= hit_cnt + 1;
        ball_speed <= conv_std_logic_vector(6 + conv_integer(unsigned(hit_cnt)), 11);
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
        ball2_y <= CONV_STD_LOGIC_VECTOR(10, 11);
        hit_cnt2 <= hit_cnt2 + 1;
        ball2_speed <= conv_std_logic_vector(6 + conv_integer(unsigned(hit_cnt2)), 11);
        ball2_y_motion <= ball2_speed;
        ELSE ball2_y <= temp2(10 DOWNTO 0); -- 9 downto 0
        END IF;
         --compute next ball horizontal position
         --variable temp adds one more bit to calculation to fix unsigned underflow problems 
         --when ball_x is close to zero and ball_x_motion is negative
--        temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
--        IF temp(11) = '1' THEN
--            ball_x <= (OTHERS => '0');
--        ELSE ball_x <= temp(10 DOWNTO 0);
--        END IF;
--        -- ball 2
--        temp2 := ('0' & ball2_x) + (ball2_x_motion(10) & ball2_x_motion);
--        IF temp2(11) = '1' THEN
--            ball2_x <= (OTHERS => '0');
--        ELSE ball2_x <= temp2(10 DOWNTO 0);
--        END IF;
    END PROCESS;
END Behavioral;
