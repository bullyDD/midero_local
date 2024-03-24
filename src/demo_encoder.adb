-- Unitary test DC Motor
with Ada.Real_Time;                 use Ada.Real_Time;
with STM32.Board;                   use STM32.Board;

with STM32.Device;                  
with Lcd_Out;                       use Lcd_Out;
with Motor;                         use Motor;
with Quadrature_Encoders;           use Quadrature_Encoders;



procedure Demo_Encoder is

    Throttle_Setting : Motor.Power_Level := 0;
    Encoder_Sampling_Interval : constant Time_Span := Seconds (1);

    Period : constant Time_Span := Milliseconds (150);
    Next_Time : Time := Clock + Period;

    M1, M2, M3, M4: Basic_Motor;

    --  These subtypes represent categories of rotation rates. The ranges are
    --  dependent on both the battery level and the motor.
    subtype Stopped is Motor_Encoder_Counts range 0 .. 0;
    subtype Slow is Motor_Encoder_Counts range Stopped'Last + 1 .. 600;
    subtype Cruising is Motor_Encoder_Counts range Slow'Last + 1 .. 1400;

    procedure Await_Button_Toggle;
    -- function  Encoder_Delta (This : Basic_Motor; Sample_Interval: Time_Span) return
    --    Motor_Encoder_Counts;
    
    procedure Panic with No_Return;
    --  Flash the LEDs to indicate disaster, forever.

    procedure All_Stop;
    --  Powers down This motor and waits for rotations to cease by polling the
    --  motor's encoder.

    -----------
    -- Panic --
    -----------

    procedure Panic is
    begin
        loop
            --  When in danger, or in doubt, run in circles, scream and shout.
            All_LEDs_Off;
            delay until Clock + Milliseconds (250); -- arbitrary
            All_LEDs_On;
            delay until Clock + Milliseconds (250); -- arbitrary
        end loop;
    end Panic;


    -------------------
    -- Encoder_Delta --
    -------------------

    --  function Encoder_Delta (This : Basic_Motor; Sample_Interval : Time_Span)
    --    return Motor_Encoder_Counts
    --  is
    --      Start_Sample, End_Sample : Motor_Encoder_Counts;
    --  begin
    --      Start_Sample := This.Encoder_Count;
    --      delay until Clock + Sample_Interval;
    --      End_Sample := This.Encoder_Count;
    --      return abs (End_Sample - Start_Sample);  -- they can rotate backwards...
    --  end Encoder_Delta;


    --------------
    -- All_Stop --
    --------------

    procedure All_Stop is
        Stopping_Time : constant Time_Span := Milliseconds (50);  -- WAG
    begin
        M1.Stop;
        loop
            exit when Encoder_Delta (M1, Sample_Interval => Stopping_Time) = 0;
        end loop;
    end All_Stop;

    -------------------------
    -- Await_Button_Toggle --
    -------------------------

    procedure Await_Button_Toggle is
    begin
        loop
            exit when User_Button_Point.Set;
        end loop;

        loop
            exit when not User_Button_Point.Set;
        end loop;
    end Await_Button_Toggle;   

    NumberRotation : Motor_Encoder_Counts;

begin
    Initialize_Motors (M1, M2, M3, M4);
    STM32.Board.Configure_User_Button_GPIO;

    Initialize_LEDs;
    All_LEDs_Off;

    loop
        Lcd_Out.Clear_Screen;
        -- Await_Button_Toggle;
        if User_Button_Point.Set then
            Throttle_Setting := (if Throttle_Setting = 100 then 0 else Throttle_Setting + 10);

            if Throttle_Setting = 0 then
                All_Stop;
            else
                M1.Run;
            end if;
        end if;

        NumberRotation := Encoder_Count (M1);
        Lcd_Out.Put_Line ("Tours= " & NumberRotation'Image);
        delay 1.0;

        --  note that the following function call delays for the Sample_Interval
        case Encoder_Delta (M1, Sample_Interval => Encoder_Sampling_Interval) is
            when Stopped   => All_LEDs_Off;
            when Slow      => Green_LED.Set;
            when Cruising  => Red_LED.Set;
            when others    => Panic;
        end case;
    end loop;

end Demo_Encoder;