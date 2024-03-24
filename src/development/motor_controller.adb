with Ada.Real_Time;             use Ada.Real_Time;
with Ada.Numerics;              use Ada.Numerics;

with Global_Initialization;
with Hardware_Config;
with Recursive_Moving_Average_Filters_Discretes;

with Lcd_Out;                   use Lcd_Out;

package body Motor_Controller is
    Period          : constant Time_Span    := Milliseconds (System_Configuration.Engine_Monitor_Period);
    Sample_Interval : constant Float        := Float (System_Configuration.Engine_Monitor_Period) / 1000.0;
    --  The time interval at which the task samples the encoder counts, which is
    --  also the period of the task itself.

    subtype Nonnegative_Float is Float range 0.0 .. Float'Last;

    Count_Per_Revolution        : constant Nonnegative_Float := Float (Encoder_Count_Per_Revolution);
    Wheel_Circumference         : constant Nonnegative_Float := Pi * Wheel_Diameter * Gear_Ratio;
    Distance_Per_Encoder_Count  : constant Nonnegative_Float := Wheel_Circumference / Count_Per_Revolution;


    Current_Speed : Nonnegative_Float := 0.0 with Atomic, Async_Readers, Async_Writers;
    -- in cm/sec 
    -- assigned by Engine_Monitor task

    Total_Traveled_Distance     : Nonnegative_Float := 0.0 with Atomic, Async_Readers, Async_Writers;
    -- in cm
    -- assigned by Engine_Monitor task

    --procedure Initialize_Motors (This : in out Basic_Motor);

    function Safely_Subtract (Left, Right : Motor_Encoder_Counts) return Motor_Encoder_Counts;
    --  Computes Left - Right without actually overflowing. The result is either
    --  the subtracted value, or, if the subtraction would overflow, the 'First
    --  or 'Last for type Motor_Encoder_Counts.

    -----------
    -- Speed --
    -----------

    function Speed return Float is
        (Current_Speed);
    

    --------------
    -- Odometer --
    --------------

    function Odometer return Float is
        (Total_Traveled_Distance);
    
    -------------------
    -- Encoder_Noise --
    -------------------

    package Encoder_Noise is 
        new Recursive_Moving_Average_Filters_Discretes (Sample =>  Motor_Encoder_Counts, 
                                                        Accumulator => Long_Long_Integer);
    
    --------------------
    -- Engine_Monitor --
    --------------------

    Task body Engine_Monitor is
        Next_Release        : Time;
        Current_Count       : Motor_Encoder_Counts := 0;
        Previous_Count      : Motor_Encoder_Counts;
        Encoder_Delta       : Motor_Encoder_Counts;
        Interval_Distance   : Nonnegative_Float;
        Current_Distance    : Nonnegative_Float;
        Noise_Filter        : Encoder_Noise.RMA_Filter (Window_Size => 5);
    begin
        Noise_Filter.Reset;
        Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);

        loop
            Clear_Screen;

            Previous_Count := Current_Count;
            Noise_Filter.Insert (M1.Encoder_Count);
            Current_Count := Noise_Filter.Value;

            Encoder_Delta := Safely_Subtract (Current_Count, Previous_Count);

            Interval_Distance   := abs (Float (Encoder_Delta) * Distance_Per_Encoder_Count);
            Current_Speed       := Interval_Distance / Sample_Interval;    -- package global variable

            Current_Distance := Total_Traveled_Distance;
            Current_Distance := @ + Interval_Distance;

            Total_Traveled_Distance := Current_Distance;                    -- Package global variable
            Put_Line ("Dist= " & Total_Traveled_Distance'Image);
            Put_Line ("Speed= " & Current_Speed'Image);

            if Total_Traveled_Distance >= 1.0 then
                M1.Stop;                        -- After 1cm cut power off
            else
                M1.Run;
            end if;

            Next_Release := @ + Period;
            delay until Next_Release;

        end loop;
    end Engine_Monitor;


    ---------------------
    -- Safely_Subtract --
    ---------------------

    function Safely_Subtract
        (Left, Right : Motor_Encoder_Counts)
    return Motor_Encoder_Counts
    is
        Result : Motor_Encoder_Counts;
    begin
        if Right > 0 then
            if Left >= Motor_Encoder_Counts'First + Right then
                Result := Left - Right;
            else -- would overflow
                Result := Motor_Encoder_Counts'First;
            end if;
        else -- Right is negative or zero
            if Left <= Motor_Encoder_Counts'Last + Right then
                Result := Left - Right;
            else -- would overflow
                Result := Motor_Encoder_Counts'Last;
            end if;
        end if;

        return Result;
    end Safely_Subtract;


    ----------------------
    -- Initialize_Motor --
    ----------------------

    --  procedure Initialize_Motors (This : in out Basic_Motor) is
    --      use Hardware_Config;
    --  begin
    --      This.Initialize
    --        (Encoder_Input1       => Motor1_Encoder_Input1,
    --         Encoder_Input2       => Motor1_Encoder_Input2,
    --         Encoder_Timer        => Motor1_Encoder_Timer,
    --         Encoder_AF           => Motor1_Encoder_AF,
    --         PWM_Timer            => Motor1_PWM_Engine_TMR,
    --         PWM_Output_Frequency => Motor_PWM_Freq,
    --         PWM_AF               => Motor1_PWM_Output_AF,
    --         PWM_Output           => Motor1_PWM_Engine,
    --         PWM_Output_Channel   => Motor1_PWM_Channel,
    --         Polarity1            => Motor1_Polarity1,
    --         Polarity2            => Motor1_Polarity2);

    --  end Initialize_Motors;

    ----------------
    -- Initialize --
    ----------------

    procedure Initialize is
    begin
        Motor.Initialize_Motors (M1, M2, M3, M4);
    end Initialize;
begin
    null;
end Motor_Controller;