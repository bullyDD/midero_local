with STM32.Device;              use STM32.Device;

package body Software_Ble is

    ---------------
    -- Configure --
    ---------------

    procedure Configure (This : in out Ble_Transceiver; State_Pin : in out GPIO_Point) is
        Pin_Mode : GPIO_Port_Configuration (Mode_In);
    begin
        This.State_Pin := State_Pin;
        Enable_Clock (This.State_Pin);
        
        Pin_Mode.Resistors := Pull_Down;
        Configure_IO (This.State_Pin, Pin_Mode);

        This.Is_Connected := (This.State_Pin.Set);
        -- Set l'état de la composante Is_Connected par une lecture de l'état de GPIO
        -- State du module HC05

    end Configure;

    ---------
    -- Put --
    ---------

    procedure Put (This : in out Ble_Transceiver; Data : Character) is
    begin
        Write (This.Port.all, Data);
    end Put;

    ---------
    -- Put --
    ---------

    procedure Put (This : in out Ble_Transceiver; Data : String) is
    begin
        for Next_Char of Data loop
            Write (This.Port.all, Next_Char);
        end loop; 
    end Put;

    ---------
    -- Get --
    ---------

    procedure Get (This : in out Ble_Transceiver; Data : out Character) is
    begin
        Read (This.Port.all, Data);
    end Get;

    ---------
    -- Get --
    ---------

    procedure Get (This : in out Ble_Transceiver; Data : out String; Last : out Natural) is
        Next_Received : Character;
    begin
        Last := Data'First - 1;
        for Index in Data'Range loop
            Read (This.Port.all, Next_Received);
            exit when Next_Received = ASCII.CR;
            Data (Index) := Next_Received;
            Last := Index;
        end loop;
    end Get;


    ------------------
    -- Is_Connected --
    ------------------

    function Is_Connected (This : Ble_Transceiver) return Boolean is
        (This.Is_Connected);
        
end Software_Ble;