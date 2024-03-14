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

   type Direction       is (Forward, Backward);
   type Motor_State     is (ON, OFF);
   type Motor_Encoder_Counts is range -(2 ** 31) .. +(2 ** 31 - 1);

   subtype Power_Level  is Integer range 0 .. 100;
   
   ---------------------
   -- Motor Utilities --
   ---------------------

   type Basic_Motor is tagged limited private;
   procedure Initialize_Motors  (M1, M2, M3, M4 : in out Basic_Motor);
   procedure Turn_Motor         (M1, M2, M3, M4 : in out Basic_Motor);
   procedure Stop               (This : out Basic_Motor);
   procedure Run                (This : in out Basic_Motor; Power : Power_Level);
   function  Encoder_Count      (This : Basic_Motor) return Motor_Encoder_Counts;
   function  Encoder_Delta (This : Basic_Motor; Sample_Interval: Time_Span) return
        Motor_Encoder_Counts;

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
