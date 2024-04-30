with System_Configuration;

package Remote_BLE is

    pragma Elaborate_Body;
    procedure Initialize;
    
    task Pump
        with 
            Priority => System_Configuration.Remote_Priority;

end Remote_BLE;