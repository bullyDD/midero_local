with Ada.Real_Time;         use Ada.Real_Time;

with Global_Initialization;
with Motor_Controller;      pragma Unreferenced (Motor_Controller);
with System_Configuration;

procedure Demo_Motor_Control 
    with Priority => System_Configuration.Main_Priority
is

begin
    Motor_Controller.Initialize;
    Global_Initialization.Critical_Instant.Signal (Epoch => Clock);
    loop
        delay until Time_Last;
    end loop;
end Demo_Motor_Control;

