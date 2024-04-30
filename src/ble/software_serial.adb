with STM32.Device;          use STM32.Device;

package body Software_Serial is

    procedure Pin_Mode (Pin : in out GPIO_Point; Mode : Pin_IO_Modes);


    --------------
    -- Pin_Mode --
    --------------

    procedure Pin_Mode (Pin : in out GPIO_Point; Mode : Pin_IO_Modes) is
        Config_Mode : GPIO_Port_Configuration (Mode);
    begin

        Enable_Clock (Pin);

        case Mode is
            when Mode_In =>
                Config_Mode.Resistors   := Pull_Down;
            when Mode_Out =>
                Config_Mode.Resistors   := Floating;
                Config_Mode.Output_Type := Push_Pull;
                Config_Mode.Speed       := Speed_100MHz;
            when others =>
                null;
        end case;   

        Configure_IO (Pin, Config_Mode);
    end Pin_Mode;

    ----------------
    -- Initialize --
    ----------------
    overriding
    procedure Initialize (This         : in out HC05_BLE;
                        Transceiver    : not null access USART;
                        Transceiver_AF : GPIO_Alternate_Function;
                        Tx_Pin         : GPIO_Point;
                        Rx_Pin         : GPIO_Point;
                        CTS_Pin        : GPIO_Point;
                        RTS_Pin        : GPIO_Point) is
    begin

        Serial_IO.Device (This).Initialize (
           Transceiver    => Transceiver,
           Transceiver_AF => Transceiver_AF,
           Tx_Pin         => Tx_Pin,
           Rx_Pin         => Rx_Pin,
           CTS_Pin        => CTS_Pin,
           RTS_Pin        => RTS_Pin);

        -- Configure_State
        --Pin_Mode (This.State_Pin, Mode_In);

        -- Configure_EN_KEY
        --Pin_Mode (This.EN_Key_Pin, Mode_In);

    end Initialize;

    ---------------
    -- Configure --
    ---------------
    overriding
    procedure Configure (This     : in out HC05_BLE; 
                        Baud_Rate : Baud_Rates;
                        Parity    : Parities     := No_Parity;
                        Data_Bits : Word_Lengths := Word_Length_8;
                        End_Bits  : Stop_Bits    := Stopbits_1;
                        Control   : Flow_Control := No_Flow_Control) is
    begin
        Serial_IO.Device (This).Configure
          (Baud_Rate, Parity, Data_Bits, End_Bits, Control);
    end Configure;
    
    ---------
    -- Put --
    ---------
    overriding
    procedure Put (This : in out HC05_BLE; Data : Character) is
    begin
        Serial_IO.Device (This).Put (Data);
    end Put;
    
    ---------
    -- Get --
    ---------
    overriding
    procedure Get (This : in out HC05_BLE; Data : out Character) is
    begin
        Serial_IO.Device (This).Get (Data);
    end Get;

end Software_Serial;