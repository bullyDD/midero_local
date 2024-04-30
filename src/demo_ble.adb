with Ada.Real_Time;                     use Ada.Real_Time;
with Remote_BLE;                        pragma Unreferenced (Remote_BLE);        
with Lcd_Out;                           use Lcd_Out;


with Global_Initialization;             
with System_Configuration;


procedure Demo_Ble is
    pragma Priority (System_Configuration.Main_Priority);
begin
    Remote_BLE.Initialize;
    Global_Initialization.Critical_Instant.Signal (Clock);
    
    loop
        Clear_Screen;
        Put_Line ("Inside Main");
        delay until Time_Last;
    end loop;
end Demo_Ble;