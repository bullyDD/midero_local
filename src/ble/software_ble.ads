with STM32.GPIO;                use STM32.GPIO;

generic
    pragma Optimize (Space);

    type Transport_Media (<>) is limited private;
    --  This is the means of communicating between the BLE device and the MCU.

    with procedure Read (This  : in out Transport_Media;
                        Value  : out Character) is <>;
    with procedure Write (This : in out Transport_Media;
                         Value : Character) is <>;
package Software_Ble with SPARK_Mode => ON is

    type Ble_Transceiver (Port : not null access Transport_Media) is tagged limited private;
    procedure Configure  (This : in out Ble_Transceiver; State_Pin : in out GPIO_Point)
        with 
            Post => not Is_Connected (This); 

    procedure Put (This : in out Ble_Transceiver; Data : Character)
        with 
            Pre => Data /= ASCII.NUL and This.Is_Connected;

    procedure Put (This : in out Ble_Transceiver; Data : String)
        with
            Pre => Data (Data'First) /= ASCII.NUL and This.Is_Connected;
            
    procedure Get (This : in out Ble_Transceiver; Data : out Character);
        --with 
            --Pre  => This.Is_Connected,
            --Post => Data /= ASCII.NUL;

    procedure Get (This : in out Ble_Transceiver; Data : out String; Last : out Natural);
    function  Is_Connected (This : Ble_Transceiver) return Boolean with Inline;

private

    type Ble_Transceiver (Port : not null access Transport_Media) is tagged limited record
        State_Pin       : GPIO_Point;
        Is_Connected    : Boolean;
    end record with Pack;

end Software_Ble;
