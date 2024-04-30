with Hardware_Config;

with Ada.Unchecked_Conversion;

package body Motor is
   
   use Hardware_Config;

   procedure Configure_Polarity_Control (This : GPIO_Point);


   --------------
   -- Throttle --
   --------------

   function Throttle (This : Basic_Motor) return Power_Level is
   begin
      return This.Power_Plant.Current_Duty_Cycle;
   end Throttle;

   ------------
   -- Engage --
   ------------

   procedure Engage
     (This      : in out Basic_Motor;
      Direction : Directions;
      Power     : Power_Level)
   is
   begin
      case Direction is
         when Forward  =>
            Set (This.H_Bridge1);
            Clear (This.H_Bridge2);
         when Backward =>
            Clear (This.H_Bridge1);
            Set (This.H_Bridge2);
      end case;
      This.Power_Plant.Set_Duty_Cycle (Power);
   end Engage;

   ----------
   -- Stop --
   ----------

   procedure Stop (This : in out Basic_Motor) is
   begin
      Set (This.H_Bridge1);
      Set (This.H_Bridge2);
      This.Power_Plant.Set_Duty_Cycle (100);  -- full power to lock position
   end Stop;

   -----------
   -- Coast --
   -----------

   procedure Coast (This : in out Basic_Motor) is
   begin
      This.Power_Plant.Set_Duty_Cycle (0);  -- do not lock position
   end Coast;

   ------------------------
   -- Rotation_Direction --
   ------------------------

   function Rotation_Direction (This : Basic_Motor) return Directions is
   begin
      case Current_Direction (This.Encoder) is
         when Up   => return Forward;
         when Down => return Backward;
      end case;
   end Rotation_Direction;

   -------------------------
   -- Reset_Encoder_Count --
   -------------------------

   procedure Reset_Encoder_Count (This : in out Basic_Motor) is
   begin
      Reset_Count (This.Encoder);
   end Reset_Encoder_Count;

   -------------------
   -- Encoder_Count --
   -------------------

   function Encoder_Count (This : Basic_Motor) return Motor_Encoder_Counts is
      function As_Motor_Encoder_Count is new 
         Ada.Unchecked_Conversion (Source  => BT.UInt32, Target => Motor_Encoder_Counts);
   begin
      return As_Motor_Encoder_Count (Current_Count (This.Encoder));
   end Encoder_Count;

   ----------------
   -- Turn_Motor --
   ----------------
   --  procedure Turn_Motor (M1, M2, M3, M4 : in out Basic_Motor; Speed : Power_Level);

   --  procedure Turn_Motor (M1, M2, M3, M4 : in out Basic_Motor; Speed : Power_Level) is
   --     pragma Unreferenced (M2, M3, M4);
   --  begin
   --     case Current_Status is
   --        when Braking =>
   --           --M1.Set_Motor (OFF, 100);
   --           --  M2.Set_Motor (OFF);
   --           --  M3.Set_Motor (OFF);
   --           --  M4.Set_Motor (OFF);
   --           null;
   --        when Running =>
   --           if not Set (M1.H_Bridge1) 
   --              --  and not Set (M2.H_Bridge1)
   --              --  and not Set (M3.H_Bridge1)
   --              --  and not Set (M4.H_Bridge1)
   --           then
   --              --M1.Set_Motor (ON, Speed);
   --              --  M2.Set_Motor (ON);
   --              --  M3.Set_Motor (ON);
   --              --  M4.Set_Motor (ON);
   --              null;
   --           else   
   --              null;
   --           end if;
   --     end case;
   --  end Turn_Motor;

   ----------------------
   -- Set_Motor_Status --
   ----------------------

   procedure Set_Motor_Status (Status : Motor_Status) is
   begin
      Current_Status := Status;
   end Set_Motor_Status;



   ---------------
   -- Set_Motor --
   ---------------

   --  procedure Set_Motor (This : in out Basic_Motor; State : Motor_State; Speed : Power_Level) is
   --  begin
   --     case State is
   --        when ON  => Engage (This, Forward, Speed);
   --        when OFF => Stop   (This);
   --     end case;
   --  end Set_Motor;
   
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
