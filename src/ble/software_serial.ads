with STM32;             use STM32;
with STM32.GPIO;        use STM32.GPIO;
with STM32.USARTs;      use STM32.USARTs;

with Serial_IO;


package Software_Serial is

    pragma Elaborate_Body;

    type HC05_BLE is new Serial_IO.Device with private;

    overriding
    procedure Initialize (This : in out HC05_BLE;
                        Transceiver    : not null access USART;
                        Transceiver_AF : GPIO_Alternate_Function;
                        Tx_Pin         : GPIO_Point;
                        Rx_Pin         : GPIO_Point;
                        CTS_Pin        : GPIO_Point;
                        RTS_Pin        : GPIO_Point);

    overriding
    procedure Configure (This : in out HC05_BLE; 
                        Baud_Rate : Baud_Rates;
                        Parity    : Parities     := No_Parity;
                        Data_Bits : Word_Lengths := Word_Length_8;
                        End_Bits  : Stop_Bits    := Stopbits_1;
                        Control   : Flow_Control := No_Flow_Control);
    
    overriding
    procedure Put (This : in out HC05_BLE; Data : Character);
    
    overriding
    procedure Get (This : in out HC05_BLE; Data : out Character);

private

    type HC05_BLE is new Serial_IO.Device with record
        State_Pin   : GPIO_Point;
        EN_Key_Pin  : GPIO_Point;
    end record;

end Software_Serial;