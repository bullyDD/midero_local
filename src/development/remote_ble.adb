with Ada.Real_Time;         use Ada.Real_Time;

with Hardware_Config;       use Hardware_Config;
with Global_Initialization;

with Lcd_Out;               use Lcd_Out;
with Software_Serial;       use Software_Serial;

package body Remote_BLE is

    Period : constant Time_Span := 
                Milliseconds (System_Configuration.Remote_Period);
    HC05  : HC05_BLE;

    protected Critical_BLE is
        procedure Read;
        procedure Write (Data : out Character);
    private
        Incoming : Character;
    end Critical_BLE;

    ------------------
    -- Critical_BLE --
    ------------------

    protected body Critical_BLE is

        ----------
        -- Read --
        ----------

        procedure Read is
            Data : Character;
        begin
            HC05.Get (Data);
            Incoming := Data;
        end Read;

        -----------
        -- Write --
        -----------

        procedure Write (Data : out Character) is
        begin
            Data := Incoming;
        end Write;

    end Critical_BLE;

    -----------------
    -- Task : Pump --
    -----------------

    task body Pump is
        Next_Release    : Time;
        Message         : String (1 .. 8);
    begin
        Global_Initialization.Critical_Instant.Wait (Next_Release);

        loop
            Clear_Screen;
            Critical_BLE.Read;
            Critical_BLE.Write (Message (1));
            Put_Line ("Data received " & Message (1)'Image);

            Next_Release := Next_Release + Period;
            delay until Next_Release;
        end loop;

    end Pump;

    ----------------
    -- Initialize --
    ----------------

    procedure Initialize  is
        BLE_Baud_Rates : constant := 9600;
    begin
        HC05.Initialize (Transceiver   => BLE_UART_Transceiver,
                        Transceiver_AF => BLE_UART_Transceiver_AF,
                        Tx_Pin         => BLE_UART_TXO_Pin,
                        Rx_Pin         => BLE_UART_RXI_Pin,
                        CTS_Pin        => BLE_UART_CTS_Pin,
                        RTS_Pin        => BLE_UART_RTS_Pin);
        HC05.Configure (Baud_Rate => BLE_Baud_Rates);

        HC05.Set_CTS (False);       -- Essential
    end Initialize;

begin
    Initialize;
end Remote_BLE;