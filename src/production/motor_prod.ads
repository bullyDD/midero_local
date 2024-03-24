with STM32;
with STM32.Device;
with STM32.GPIO;
with STM32.PWM;
with STM32.Timers;
with HAL;

package Motor_Prod is
   
   -----------------------
   -- Package interface --
   -----------------------
   
   use STM32.Device;
   use STM32.GPIO;
   use STM32.Timers;
   use STM32.PWM;
   
   package BT renames HAL;

   type Direction       is (Forward, Backward);
   type Motor_State     is (ON, OFF);
   type Current_State_T is (Running, Braking);
   
   subtype Power_Level is Integer range 0 .. 100;
   
   type Basic_Motor is tagged limited private;
   ----------------------
   -- Motor Facilities --
   ----------------------
   procedure Initialize_Motors  (M1, M2, M3, M4 : in out Basic_Motor);
   procedure Turn_Motor         (M1, M2, M3, M4 : in out Basic_Motor);
   procedure Set_Internal_State (State : Current_State_T);

private
   type Basic_Motor is tagged limited 
      record
         Power_Plant       : PWM_Modulator;
         Power_Channel     : Timer_Channel;
         H_Bridge1         : GPIO_Point;
         H_Bridge2         : GPIO_Point;
   end record;
end Motor_Prod;
