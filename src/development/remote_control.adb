--  This package body implements the remote control package spec using
--  Bluetooth LE (BLE) Module (HC-05)
--

with Ada.Real_Time;                     use Ada.Real_Time;

with STM32.Board;                       use STM32.Board;    
with STM32.Device;                      use STM32.Device;
with STM32.GPIO;                        use STM32.GPIO;

with Hardware_Config;                   use Hardware_Config;
--with HC05_BLE_USART;                    use HC05_BLE_USART;
with Lcd_Out;                           use Lcd_Out;
--with Serial_IO.Interrupt_Driven;        use Serial_IO.Interrupt_Driven;

with Global_Initialization; 

package body Remote_Control is

    --#region declaration variables
    Period   : constant Time_Span := Milliseconds (System_Configuration.Remote_Period);
    --BLE_Port : aliased Serial_Port (BLE_UART_Transceiver_IRQ);
    --HC05     : Ble_Transceiver (BLE_Port'Access);
    --Led_Pin  : GPIO_Point renames PC0;
    
    Current_Vector : Travel_Vector := (5, Forward, Emergency_Braking => False) with
                                        Atomic, Async_Readers, Async_Writers;

    Temp_Vector : Travel_Vector;
    --#endregion

    --#region specification sous programmes

    procedure Initialize;
    --  Procedure élaborée par la tache principale.
    --  Elle permet d'initialise le module @BLE_Port, @Led_Pin et configure @HC05
    --  Les valeurs des composantes des objets proviennent du paquetage Hardware_Config.

    procedure Receive (Requested_Vector : out Travel_Vector);
    --  Get the requested control values from the input device

    --  procedure Receive (Buffer : out String; Data_Available : out Boolean);
    --  Cette procedure permet de récupérer des données dans un buffer d'un caractère. 
    --  Mettre à jour le paramètre effectif de confirmation du début de traitement 
    --  de l'information par la sous tache Pump

    -- procedure Panic;
    -- Simple procédure pour faire clignoter toutes les 100 millisecondes 
    -- les leds builtin du STM32F429 tant qu'aucun client n'est connecté.

    -- procedure Initialize_Led (This   : in out GPIO_Point);
    -- Procédure pour initialiser et configurer la led qui sert de test.

    -- procedure Toggle_Led (This   : in out GPIO_Point);
    -- Enfin cette procedure permet de faire clignoter la led jaune qui
    -- sert de test.

    --#endregion

    --#region task
    task body Pump is
        Next_Release        : Time;
        --Buffer              : String (1 .. 2);
        --Data_Is_Available   : Boolean;
    begin
        
        Global_Initialization.Critical_Instant.Wait (Next_Release);
        loop
            -- Clear_Screen;
            --Put_Line ("Msg : " & Buffer (Buffer'First)'Image);
            -- En attente d'un appareil pour démarrer la reception de données
            
            --  Receive (Buffer, Data_Is_Available);
            --  if Data_Is_Available then
            --      Put_Line ("Msg : " & Buffer (Buffer'First)'Image);
            --  else
            --      Put_Line ("Data not available");
            --  end if;
            Receive (Temp_Vector);
            Current_Vector := Temp_Vector;

            --Put_Line ("Power= " & Temp_Vector.Power'Image);

            Next_Release := Next_Release + Period;
            delay until Next_Release;
        end loop;

    end Pump;
    --endregion

    --#region implementation sous programmes


    ----------------------
    -- Requested_Vector --
    ----------------------

    function Requested_Vector return Travel_Vector is
    begin
        return Current_Vector;
    end Requested_Vector;

    -------------
    -- Receive --
    -------------

    procedure Receive (Requested_Vector : out Travel_Vector)
    is
        --Buffer   : String (1 .. 2);
        Power    : Integer;
    begin
        --HC05.Get (Buffer);
        Power := 4;
        Requested_Vector.Power := Power;
        Requested_Vector.Direction := Neither;
        Requested_Vector.Emergency_Braking := False;
    end Receive;

    -------------
    -- Receive --
    -------------

    --  procedure Receive (Buffer : out String; Data_Available : out Boolean) is
    --      Temp : String (1 .. 2);
    --  begin
    --      HC05.Get (Buffer (Buffer'First));
    --      if Buffer (Buffer'First) /= ASCII.NUL then 
    --          Data_Available := True;
    --      else
    --          Data_Available := False;
    --      end if;
    --  end Receive;

    -----------
    -- Panic --
    -----------

    --  procedure Panic is
    --      Panic_Period : constant Time_Span := Milliseconds (100);
    --  begin
    --      -- Allume toutes les leds pendant 100 millisecondes
    --      loop
    --          All_LEDs_On;
    --          delay until Clock + Panic_Period;

    --          -- Eteint toutes les leds pendant 100 millisecondes
    --          All_LEDs_Off;
    --          delay until Clock + Panic_Period;
    --      end loop;
    --  end Panic;

    --------------------
    -- Initialize_Led --
    ---------------------

    --  procedure Initialize_Led (This : in out GPIO_Point) is
    --      Pin_Mode : GPIO_Port_Configuration (Mode_Out);
    --  begin
    --      Pin_Mode.Resistors      := Floating;
    --      Pin_Mode.Output_Type    := Push_Pull;
    --      Pin_Mode.Speed          := Speed_100MHz;

    --      Enable_Clock (This);
    --      Configure_IO (This, Pin_Mode);

    --  end Initialize_Led;

    ----------------
    -- Toggle_Led --
    ----------------

    --  procedure Toggle_Led (This : in out GPIO_Point) is
    --  begin
    --      STM32.Board.Toggle (This => This);
    --  end Toggle_Led;


    ----------------
    -- Initialize --
    ----------------

    procedure Initialize is
        BLE_Friend_Baudrate : constant := 9600;
    begin

        -- Initialize UART Port
        --  BLE_Port.Initialize
        --    (Transceiver    => BLE_UART_Transceiver,
        --     Transceiver_AF => BLE_UART_Transceiver_AF,
        --     Tx_Pin         => BLE_UART_TXO_Pin,
        --     Rx_Pin         => BLE_UART_RXI_Pin, 
        --     CTS_Pin        => BLE_UART_CTS_Pin, 
        --     RTS_Pin        => BLE_UART_RTS_Pin); 

        --  BLE_Port.Configure (Baud_Rate => BLE_Friend_Baudrate);
        --  BLE_Port.Set_CTS (False);

        --  -- Configure Module HC05
        --  HC05.Configure (BLE_UART_STATE_Pin);

        --  -- Initialise la led
        --  Initialize_Led (Led_Pin);
        null;
    end Initialize;

    --#endregion
begin
    Initialize;
end Remote_Control;