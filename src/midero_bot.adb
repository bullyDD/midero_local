with Ada.Real_Time;

with Global_Initialization;
with System_Configuration;

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
with Engine_Control;       pragma Unreferenced (Engine_Control);
with Remote_Control;       pragma Unreferenced (Remote_Control);
with Vehicle;              pragma Unreferenced (Vehicle);

procedure Midero_Bot is
   pragma Priority (System_Configuration.Main_Priority);
   use Ada.Real_Time;

begin
   Vehicle.Initialize;
   Global_Initialization.Critical_Instant.Signal (Epoch => Clock);
   loop
      delay until Time_Last;
   end loop;
end Midero_Bot;
