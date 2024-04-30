package body Serial_IO.Interrupt_Driven is

    ---------
    -- Put --
    ---------

    overriding
    procedure Put (This : in out Serial_Port; Data : Character) is
    begin
        This.Controller.Put (Data);
    end Put;

    ---------
    -- Get --
    ---------

    overriding
    procedure Get (This : in out Serial_Port; Data : out Character) is
    begin
        Enable_Interrupts (This.Transceiver.all, Received_Data_Not_Empty);
        This.Controller.Get (Data);
    end Get;

    ----------------
    -- IO_Manager --
    ----------------

    protected body IO_Manager is

        -------------------------
        -- Handle_Transmission --
        -------------------------        

        procedure Handle_Transmission is
        begin
            Serial_IO.Put (Serial_IO.Device (Port.all), Outgoing);   -- Upcasting 
            Disable_Interrupts (Port.Transceiver.all, Source => Transmission_Complete);
        end Handle_Transmission;

        ----------------------
        -- Handle_Reception --
        ----------------------

        procedure Handle_Reception is
        begin
            Serial_IO.Get (Serial_IO.Device (Port.all), Incoming);      
            -- Conversion vers le type parent pour faire appel au sous programme Get associé au type type Device.
            loop
                exit when not Status (Port.Transceiver.all, Read_Data_Register_Not_Empty);
            end loop;

            Disable_Interrupts (Port.Transceiver.all, Source => Received_Data_Not_Empty);
        end Handle_Reception;


        -----------------
        -- IRQ_Handler --
        -----------------

        procedure IRQ_Handler is 
        begin
            -- Check for data arrival
            if Status (Port.Transceiver.all, Read_Data_Register_Not_Empty) and
                Interrupt_Enabled (Port.Transceiver.all, Received_Data_Not_Empty)
            then
                Handle_Reception;
                Clear_Status (Port.Transceiver.all, Read_Data_Register_Not_Empty);
                Incoming_Data_Available := True;
            end if;

            -- Check for transmission ready
            if Status (Port.Transceiver.all, Transmission_Complete_Indicated) and
                Interrupt_Enabled (Port.Transceiver.all, Transmission_Complete)
            then
                Handle_Transmission;
                Clear_Status (Port.Transceiver.all, Transmission_Complete_Indicated);
                Transmission_Pending := False;
            end if;
        end IRQ_Handler;

        ---------
        -- Put --
        ---------

        entry Put (Data: Character) when not Transmission_Pending is
        begin
            Transmission_Pending := True;
            Outgoing := Data;
            Enable_Interrupts (Port.Transceiver.all, Transmission_Complete);
        end Put;

        ---------
        -- Get --
        ---------

        entry Get (Data : out Character) when Incoming_Data_Available is
        begin
            Data := Incoming;
            Incoming_Data_Available := False;
        end Get;
    end IO_Manager;

end Serial_IO.Interrupt_Driven;