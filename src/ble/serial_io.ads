with STM32;                 use STM32;
with STM32.GPIO;            use STM32.GPIO;
with STM32.USARTs;          use STM32.USARTs;

package Serial_IO is
    
  type Device is tagged limited private;
  -- represent a Non-memory map device

  procedure Initialize
  (This            : in out Device;
    Transceiver    : not null access USART;
    Transceiver_AF : GPIO_Alternate_Function;
    Tx_Pin         : GPIO_Point;
    Rx_Pin         : GPIO_Point;
    CTS_Pin        : GPIO_Point;
    RTS_Pin        : GPIO_Point);

  procedure Configure
  (This       : in out Device;
    Baud_Rate : Baud_Rates;
    Parity    : Parities     := No_Parity;
    Data_Bits : Word_Lengths := Word_Length_8;
    End_Bits  : Stop_Bits    := Stopbits_1;
    Control   : Flow_Control := No_Flow_Control);

  procedure Set_CTS (This : in out Device; Value : Boolean) with Inline;
  procedure Set_RTS (This : in out Device; Value : Boolean) with Inline;

  procedure Put (This : in out Device; Data : Character) with Inline;
  procedure Get (This : in out Device; Data : out Character) with Inline;

private

    type Device is tagged limited record
        Transceiver : access USART;
        Tx_Pin      : GPIO_Point;
        Rx_Pin      : GPIO_Point;
        CTS_Pin     : GPIO_Point;
        RTS_Pin     : GPIO_Point;
    end record;

end Serial_IO;