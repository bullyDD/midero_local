with Ada.Real_Time;                 use Ada.Real_Time;
with Vehicle;                       pragma Unreferenced (Vehicle);

with System_Configuration;
with Global_Initialization;

procedure Demo_Motor is
    pragma Priority (System_Configuration.Main_Priority);
begin
    Vehicle.Initialize;

    --  Allow the tasks to start doing their post-initialization work, ie the
    --  epoch starts for their periodic loops with the value passed
    Global_Initialization.Critical_Instant.Signal (Clock);
    
    loop
        delay until Time_Last;
    end loop;
end Demo_Motor;