with Ada.Real_Time;           use Ada.Real_Time;

with STM32;
with STM32.Device;
with STM32.GPIO;
with STM32.PWM;
with STM32.Timers;
with HAL;

with Quadrature_Encoders;

package Motor is
   
   use STM32;
   use STM32.Device;
   use STM32.GPIO;
   use STM32.Timers;
   use STM32.PWM;
   use Quadrature_Encoders;
   
   package BT renames HAL;

   subtype Power_Level  is Integer range 0 .. 100;

   type Direction       is (Forward, Backward);
   type Motor_State     is (ON, OFF);
   type Motor_Encoder_Counts is range -(2 ** 31) .. +(2 ** 31 - 1);

   Encoder_Count_Per_Revolution : constant := 720;
   -- 1/2 degree per revolution

   ---------------------
   -- Motor Utilities --
   ---------------------

   type Basic_Motor is tagged limited private;
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
      
   procedure Initialize_Motors  (M1, M2, M3, M4 : in out Basic_Motor);
   procedure Turn_Motor         (M1, M2, M3, M4 : in out Basic_Motor);
   procedure Stop               (This : out Basic_Motor);                           -- Testing Purpose
   procedure Run                (This : in out Basic_Motor);                        -- Testing purpose

   procedure Reset_Encoder_Count (This : in out Basic_Motor) 
      with Post => Encoder_Count (This) = 0;
   function  Encoder_Count      (This : Basic_Motor) return Motor_Encoder_Counts;
   function  Encoder_Delta      (This : Basic_Motor; Sample_Interval: Time_Span) return Motor_Encoder_Counts;
   

   type Current_State_T is (Running, Braking);
   procedure Set_Internal_State(State : Current_State_T);

private
   type Basic_Motor is tagged limited 
      record
         Encoder           : Rotary_Encoder;
         Power_Plant       : PWM_Modulator;
         Power_Channel     : Timer_Channel;
         H_Bridge1         : GPIO_Point;
         H_Bridge2         : GPIO_Point;
   end record;
end Motor;
