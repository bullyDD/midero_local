with Hardware_Config;

with Ada.Unchecked_Conversion;

package body Motor is
   
   use Hardware_Config;
   
   Internal_Power : constant Power_Level := 50;
   Internal_State : Current_State_T      := Running;
   
   procedure Engage     (This : out Basic_Motor);
   --procedure Stop       (This : out Basic_Motor);
   procedure Set_Motor  (This : out Basic_Motor; State : Motor_State);

   procedure Initialize
     (This                 : in out Basic_Motor;
      --  motor encoder
      Encoder_Input1       : GPIO_Point;
      Encoder_Input2       : GPIO_Point;
      Encoder_Timer        : not null access Timer;
      Encoder_AF           : GPIO_Alternate_Function;
      --  motor power control
      PWM_Timer            : not null access Timer;
      PWM_Output_Frequency : BT.UInt32; -- in Hertz
      PWM_AF               : GPIO_Alternate_Function;
      PWM_Output           : GPIO_Point;
      PWM_Output_Channel   : Timer_Channel;
      --  discrete outputs to H-Bridge that control direction and stopping
      Polarity1            : GPIO_Point;
      Polarity2            : GPIO_Point);

   procedure Initialize 
     (This                 : out Basic_Motor;
      PWM_Timer            : not null access Timer;
      PWM_Output_Frequency : BT.UInt32; -- in Hertz
      PWM_AF               : STM32.GPIO_Alternate_Function;
      PWM_Output           : GPIO_Point;
      PWM_Output_Channel   : Timer_Channel;
      --  discrete outputs to H-Bridge that control direction and stopping
      Polarity1            : GPIO_Point;
      Polarity2            : GPIO_Point);

   procedure Configure_Polarity_Control (This : GPIO_Point);
   
   -------------------
   -- Encoder_Delta --
   -------------------
   function Encoder_Delta (This : Basic_Motor; Sample_Interval : Time_Span)
      return Motor_Encoder_Counts
   is
      Start_Sample, End_Sample : Motor_Encoder_Counts;
   begin
      Start_Sample := This.Encoder_Count;
      delay until Clock + Sample_Interval;
      End_Sample := This.Encoder_Count;
      return abs (End_Sample - Start_Sample);  -- they can rotate backwards...
   end Encoder_Delta;

   ---------
   -- Run --
   ---------
   procedure Run (This : in out Basic_Motor; Power : Power_Level) is
   begin
      Toggle (This.H_Bridge1);
      Clear  (This.H_Bridge2);
      This.Power_Plant.Set_Duty_Cycle (Value => Integer (Power));
   end Run;

   -------------------
   -- Encoder_Count --
   -------------------
   function Encoder_Count (This : Basic_Motor) return Motor_Encoder_Counts is
      function As_Motor_Encoder_Count is new Ada.Unchecked_Conversion (Source  => BT.UInt32, Target => Motor_Encoder_Counts);
   begin
      return As_Motor_Encoder_Count (Current_Count (This.Encoder));
   end Encoder_Count;

   ----------------
   -- Turn_Motor --
   ----------------
   procedure Turn_Motor (M1, M2, M3, M4 : in out Basic_Motor) is
      pragma Unreferenced (M2, M3, M4);
   begin
      case Internal_State is
         when Braking =>
            M1.Set_Motor (OFF);
            --  M2.Set_Motor (OFF);
            --  M3.Set_Motor (OFF);
            --  M4.Set_Motor (OFF);
         when Running =>
            if not Set (M1.H_Bridge1)
               --  and not Set (M2.H_Bridge1) 
               --  and not Set (M3.H_Bridge1)
               --  and not Set (M4.H_Bridge1)
            then
               M1.Set_Motor (ON);
               --  M2.Set_Motor (ON);
               --  M3.Set_Motor (ON);
               --  M4.Set_Motor (ON);
            else   
               null;
            end if;
      end case;
   end Turn_Motor;

   ------------------------
   -- Set_Internal_State --
   ------------------------
   procedure Set_Internal_State(State : Current_State_T) is
   begin
      Internal_State := State;
   end Set_Internal_State;

   ----------
   -- Stop --
   ----------
   procedure Stop (This : out Basic_Motor) is
   begin
      Clear (This.H_Bridge1);
      Clear (This.H_Bridge2);
      This.Power_Plant.Set_Duty_Cycle (100); --  Full power to Lock position 
   end Stop;

   ------------
   -- Engage --
   ------------
   procedure Engage (This : out Basic_Motor) is
   begin
      Toggle (This.H_Bridge1);
      Clear  (This.H_Bridge2);
      This.Power_Plant.Set_Duty_Cycle (Value => Integer (Internal_Power));
   end Engage;

   ---------------
   -- Set_Motor --
   ---------------
   procedure Set_Motor (This : out Basic_Motor; State : Motor_State) is
   begin
      case State is
         when ON  => Engage (This);
         when OFF => Stop   (This);
      end case;
   end Set_Motor;

   -----------------------
   -- Initialize_Motors --
   -----------------------
   procedure Initialize_Motors (M1, M2, M3, M4 : in out Basic_Motor) is
      pragma Unreferenced (M2, M3, M4);
   begin
      Initialize (This => M1,
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
      --  Motor Bottom Right
      --  Initialize (This => M1,
      --              PWM_Timer            => Motor1_PWM_Engine_TMR,
      --              PWM_Output_Frequency => Motor_PWM_Freq,
      --              PWM_AF               => Motor1_PWM_Output_AF,
      --              PWM_Output           => Motor1_PWM_Engine,
      --              PWM_Output_Channel   => Motor1_PWM_Channel,
      --              Polarity1            => Motor1_Polarity1,
      --              Polarity2            => Motor1_Polarity2);
      --  --  Motor Bottom Left  
      --  Initialize (This => M2,
      --              PWM_Timer            => Motor2_PWM_Engine_TMR,
      --              PWM_Output_Frequency => Motor_PWM_Freq,
      --              PWM_AF               => Motor2_PWM_Output_AF,
      --              PWM_Output           => Motor2_PWM_Engine,
      --              PWM_Output_Channel   => Motor2_PWM_Channel,
      --              Polarity1            => Motor2_Polarity1,
      --              Polarity2            => Motor2_Polarity2);
      --  --  Motor Top Left
      --  Initialize (This => M3,
      --              PWM_Timer            => Motor3_PWM_Engine_TMR,
      --              PWM_Output_Frequency => Motor_PWM_Freq,
      --              PWM_AF               => Motor3_PWM_Output_AF,
      --              PWM_Output           => Motor3_PWM_Engine,
      --              PWM_Output_Channel   => Motor3_PWM_Channel,
      --              Polarity1            => Motor3_Polarity1,
      --              Polarity2            => Motor3_Polarity2);
      --  --  Motor Top Right
      --  Initialize (This => M4,
      --              PWM_Timer            => Motor4_PWM_Engine_TMR,
      --              PWM_Output_Frequency => Motor_PWM_Freq,
      --              PWM_AF               => Motor4_PWM_Output_AF,
      --              PWM_Output           => Motor4_PWM_Engine,
      --              PWM_Output_Channel   => Motor4_PWM_Channel,
      --              Polarity1            => Motor4_Polarity1,
      --              Polarity2            => Motor4_Polarity2);
   end Initialize_Motors;
   
   ----------------
   -- Initialize --
   ----------------
   procedure Initialize
     (This                 : in out Basic_Motor;
      --  motor encoder I/O
      Encoder_Input1       : GPIO_Point;
      Encoder_Input2       : GPIO_Point;
      Encoder_Timer        : not null access Timer;
      Encoder_AF           : GPIO_Alternate_Function;
      --  motor power control
      PWM_Timer            : not null access Timer;
      PWM_Output_Frequency : BT.UInt32; -- in Hertz
      PWM_AF               : GPIO_Alternate_Function;
      PWM_Output           : GPIO_Point;
      PWM_Output_Channel   : Timer_Channel;
      --  discrete outputs to L298N Shield that control motor direction
      Polarity1            : GPIO_Point;
      Polarity2            : GPIO_Point)
   is
   begin
      --  First set up the PWM for the motors' power control.
      --  We do this configuration here because we are not sharing the timer
      --  across other PWM generation clients
      Configure_PWM_Timer (PWM_Timer, PWM_Output_Frequency);

      This.Power_Plant.Attach_PWM_Channel
        (PWM_Timer,
         PWM_Output_Channel,
         PWM_Output,
         PWM_AF);

      This.Power_Plant.Enable_Output;

      This.Power_Channel := PWM_Output_Channel;

      --  Now set up the motor encoders

      Initialize_Encoder
        (This.Encoder,
         Encoder_Input1,
         Encoder_Input2,
         Encoder_Timer,
         Encoder_AF);

      Reset_Count (This.Encoder);

      --  Finally, configure the output points for controlling the H-Bridge
      --  circuits that control the rotation direction as well as stopping
      --  the rotation entirely (via procedure Stop)

      This.H_Bridge1 := Polarity1;
      This.H_Bridge2 := Polarity2;

      Enable_Clock (This.H_Bridge1);
      Enable_Clock (This.H_Bridge2);

      Configure_Polarity_Control (This.H_Bridge1);
      Configure_Polarity_Control (This.H_Bridge2);
   end Initialize;

   ----------------
   -- Initialize --
   ----------------
   procedure Initialize 
     (This                 : out Basic_Motor;
      PWM_Timer            : not null access Timer;
      PWM_Output_Frequency : BT.UInt32; -- in Hertz
      PWM_AF               : STM32.GPIO_Alternate_Function;
      PWM_Output           : GPIO_Point;
      PWM_Output_Channel   : Timer_Channel;
      --  discrete outputs to H-Bridge that control direction and stopping
      Polarity1            : GPIO_Point;
      Polarity2            : GPIO_Point) is
   begin

      Configure_PWM_Timer (PWM_Timer, PWM_Output_Frequency);

      This.Power_Plant.Attach_PWM_Channel (PWM_Timer,  PWM_Output_Channel,
                                           PWM_Output, PWM_AF);
      This.Power_Plant.Enable_Output;
      This.Power_Channel := PWM_Output_Channel;

      This.H_Bridge1 := Polarity1;
      This.H_Bridge2 := Polarity2;

      Enable_Clock (Point => This.H_Bridge1);
      Enable_Clock (Point => This.H_Bridge2);

      Configure_Polarity_Control (This.H_Bridge1);
      Configure_Polarity_Control (This.H_Bridge2);
   end Initialize;

   --------------------------------
   -- Configure_Polarity_Control --
   --------------------------------
   procedure Configure_Polarity_Control (This : GPIO_Point) is
      Config : GPIO_Port_Configuration;
   begin
      Config := (Mode           => Mode_Out,
                 Output_Type    => Push_Pull,
                 Resistors      => Floating,
                 Speed          => Speed_100MHz);
      This.Configure_IO (Config => Config);
      This.Lock;      -- Lock the current configuration of Pin until reset.
   end Configure_Polarity_Control;

end Motor;
