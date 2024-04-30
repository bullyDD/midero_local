with Ada.Real_Time;
with Ada.Numerics;                  use Ada.Numerics;

with Hardware_Config;               use Hardware_Config;
with Global_Initialization;
with Lcd_Out;                       use Lcd_Out;
with Recursive_Moving_Average_Filters_Discretes;

package body Vehicle is
   
   use Ada.Real_Time;
   
   
   Period : constant Time_Span := 
      Milliseconds (System_Configuration.Engine_Monitor_Period);

   Sample_Interval : constant Float  := Float (System_Configuration.Engine_Monitor_Period) / 1000.0;
   --  The time interval at which the task samples the encoder counts, which is
   --  also the period of the task itself.

   subtype Nonnegative_Float is Float range 0.0 .. Float'Last;

   Counts_Per_Revolution      : constant Nonnegative_Float := Float (Encoder_Count_Per_Revolution);
   Wheel_Circumference        : constant Nonnegative_Float := Pi * Wheel_Diameter * Gear_Ratio;
   Distance_Per_Encoder_Count : constant Nonnegative_Float := Wheel_Circumference / Counts_Per_Revolution;

   Current_Speed : Nonnegative_Float := 0.0 with Atomic, Async_Readers, Async_Writers;
   --  in cm/sec
   --  assigned by the Engine_Monitor task

   Total_Distance_Traveled : Nonnegative_Float := 0.0 with Atomic, Async_Readers, Async_Writers;
   --  in cm
   --  assigned by the Engine_Monitor task

   procedure Initialize_Motors (Engines : in out Motor_Array);
   --  Initializes the four motors. This must be done
   --  before any software commands or accesses to those motors.

   function Safely_Subtract (Left, Right : Motor_Encoder_Counts) return Motor_Encoder_Counts;
   --  Computes Left - Right without actually overflowing. The result is either
   --  the subtracted value, or, if the subtraction would overflow, the 'First
   --  or 'Last for type Motor_Encoder_Counts.

   -----------
   -- Speed --
   -----------

   function Speed return Float is
   begin
      return Current_Speed;
   end Speed;

   --------------
   -- Odometer --
   --------------

   function Odometer return Float is
   begin
      return Total_Distance_Traveled;
   end Odometer;


   -----------------------------------
   -- To_Propulsion_Motor_Direction --
   -----------------------------------

   function To_Propulsion_Motor_Direction (Direction : Remote_Control.Travel_Directions)
     return Motor.Directions
   is 
      (if Direction = Remote_Control.Forward then Motor.Forward else Motor.Backward);


   -------------------
   -- Encoder_Noise --
   -------------------

   package Encoder_Noise is new Recursive_Moving_Average_Filters_Discretes
     (Sample      => Motor_Encoder_Counts,
      Accumulator => Long_Long_Integer);

  --------------------
   -- Engine_Monitor --
   --------------------

   task body Engine_Monitor is
      Next_Release      : Time;
      Current_Count     : Motor_Encoder_Counts := 0;
      Previous_Count    : Motor_Encoder_Counts;
      Encoder_Delta     : Motor_Encoder_Counts;
      Interval_Distance : Nonnegative_Float;
      Current_Distance  : Nonnegative_Float;
      Noise_Filter      : Encoder_Noise.RMA_Filter (Window_Size => 5); -- arbitrary size
   begin
      Noise_Filter.Reset;
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);
      
      loop
         Clear_Screen;
         
         Previous_Count := Current_Count;
         Noise_Filter.Insert (Engines(1).all.Encoder_Count);
         Current_Count := Noise_Filter.Value;

         Encoder_Delta := Safely_Subtract (Current_Count, Previous_Count);

         Interval_Distance := abs (Float (Encoder_Delta) * Distance_Per_Encoder_Count);
         Current_Speed     := Interval_Distance / Sample_Interval;    -- package global variable

         Current_Distance := Total_Distance_Traveled;
         Current_Distance := Current_Distance + Interval_Distance;

         Total_Distance_Traveled := Current_Distance; -- package global variable
         Put_Line ("Dist = " & Total_Distance_Traveled'Image);

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
      
   end Engine_Monitor;

   ---------------------
   -- Safely_Subtract --
   ---------------------

   function Safely_Subtract (Left, Right : Motor_Encoder_Counts)
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

   -----------------------
   -- Initialize_Motors --
   -----------------------

   procedure Initialize_Motors (Engines : in out Motor_Array) is
   begin
      --  Motor Bottom Right
      Motor.Initialize (This => Engines(1).all,
      --  motor encoder I/O
      Encoder_Input1       => Motor1_Encoder_Input1,
      Encoder_Input2       => Motor1_Encoder_Input2,
      Encoder_Timer        => Motor1_Encoder_Timer,
      Encoder_AF           => Motor1_Encoder_AF,
      PWM_Timer            => Motor1_PWM_Engine_TMR,
      PWM_Output_Frequency => Motor_PWM_Freq,
      PWM_AF               => Motor1_PWM_Output_AF,
      PWM_Output           => Motor1_PWM_Engine,
      PWM_Output_Channel   => Motor1_PWM_Channel,
      Polarity1            => Motor1_Polarity1,
      Polarity2            => Motor1_Polarity2);

      --  Motor Bottom Left  

      --  Motor Top Left
   
      --  Motor Top Right

   end Initialize_Motors;
     
   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      Initialize_Motors (Engines);
   end Initialize;

end Vehicle;