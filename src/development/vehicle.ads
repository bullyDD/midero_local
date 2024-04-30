with Motor;                   use Motor;
with Remote_Control;          use Remote_Control;
with System_Configuration;

package Vehicle is
   pragma Elaborate_Body;

   type Motor_Acc is access all Basic_Motor;
   type Motor_Array is array (Positive range <>) of Motor_Acc;

   Basic_Motor_1, Basic_Motor_2, Basic_Motor_3, Basic_Motor_4 : aliased Basic_Motor;
   
   M1 : Motor_Acc := Basic_Motor_1'Access;
   M2 : Motor_Acc := Basic_Motor_2'Access;
   M3 : Motor_Acc := Basic_Motor_3'Access;
   M4 : Motor_Acc := Basic_Motor_4'Access;
   
   Engines : Motor_Array (1 .. 4) := (M1, M2, M3, M4);
   
   procedure Initialize;

   function Speed return Float with Inline, Volatile_Function;
   -- in cm/sec

   function Odometer return Float with Inline, Volatile_Function;
   -- in centimeters

   function To_Propulsion_Motor_Direction (Direction : Remote_Control.Travel_Directions)
      return Motor.Directions
      with Inline,
         Pre => Direction /= Remote_Control.Neither;
   --  Map the input travel direction to a motor rotation direction. The result
   --  reflects the drive mechanism's physical construction with the propulsion
   --  motor.

   Wheel_Diameter : constant := 6.5;   
   -- in cm

   Gear_Ratio     : constant := 24.0 / 40.0;

private

   task Engine_Monitor with
      Storage_Size => 1 * 1024,
      Priority     => System_Configuration.Engine_Monitor_Priority;
end Vehicle;