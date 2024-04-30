with Ada.Real_Time;           use Ada.Real_Time;

with STM32;
with STM32.Device;
with STM32.GPIO;
with STM32.PWM;
with STM32.Timers;
with HAL;

with Quadrature_Encoders;

package Motor is

   pragma Elaborate_Body;
   
   use STM32;
   use STM32.Device;
   use STM32.GPIO;
   use STM32.Timers;
   use STM32.PWM;
   use Quadrature_Encoders;

   package BT renames HAL;

   type Motor_State is (ON, OFF);
   type Basic_Motor is tagged limited private;
   ---------------------
   -- Motor Utilities --
   --------------------- 

   subtype Power_Level is Integer range 0 .. 100;
   function Throttle (This : Basic_Motor) return Power_Level;

   type Directions is (Forward, Backward);
   function Rotation_Direction (This : Basic_Motor) return Directions;

   type Motor_Encoder_Counts is range -(2 ** 31) .. +(2 ** 31 - 1);
   Encoder_Count_Per_Revolution : constant := 720;
   -- 1/2 degree per revolution

   procedure Engage
   (This        : in out Basic_Motor;
      Direction : Directions;
      Power     : Power_Level) with 
      Post => Throttle (This) = Power;

   procedure Stop (This : in out Basic_Motor) with
      Post => Throttle (This) = 100;
   --  Full stop immediately and actively lock motor position.
   
   procedure Coast (This : in out Basic_Motor) with
     Post => Throttle (This) = 0;
   --  Gradual stop without locking motor position.

   procedure Reset_Encoder_Count (This : in out Basic_Motor) 
      with Post => Encoder_Count (This) = 0;
   function  Encoder_Count       (This : Basic_Motor) return Motor_Encoder_Counts;
     

   procedure Initialize
      (This                : in out Basic_Motor;
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
      Polarity2            : GPIO_Point) with
      Pre  => Has_32bit_Counter (Encoder_Timer.all) and
               Bidirectionnal (Encoder_Timer.all),
      Post => Encoder_Count (This) = 0 and Throttle (This) = 0;

   type Motor_Status is (Running, Braking);
   procedure Set_Motor_Status (Status : Motor_Status);

private

   Current_Status : Motor_Status := Braking;       -- By default, any motor is running.

   type Basic_Motor is tagged limited 
      record
         Encoder           : Rotary_Encoder;
         Power_Plant       : PWM_Modulator;
         Power_Channel     : Timer_Channel;
         H_Bridge1         : GPIO_Point;
         H_Bridge2         : GPIO_Point;
   end record;

end Motor;
