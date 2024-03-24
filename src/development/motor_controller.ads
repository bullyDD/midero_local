with System;

with Motor;             use Motor;
with System_Configuration;

package Motor_Controller is
    pragma Elaborate_Body;

    M1 : Basic_Motor;
    M2 : Basic_Motor;
    M3 : Basic_Motor;
    M4 : Basic_Motor;
    
    procedure Initialize 
        with SPARK_Mode;

    function Speed return Float with Inline, Volatile_Function;
    -- in cm/sec

    function Odometer return Float with Inline, Volatile_Function;
    -- in centimeters

    Wheel_Diameter : constant := 6.5;   
    -- in cm

    Gear_Ratio     : constant := 21.0 / 47.0;

private
    task Engine_Monitor 
        with 
            Storage_Size => 1 * 1024,
            Priority => System_Configuration.Vehicle_Priority;

end Motor_Controller;