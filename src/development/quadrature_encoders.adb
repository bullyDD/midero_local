with System;
with STM32.Device;
with STM32_SVD;

package body Quadrature_Encoders is

   use System;
   use STM32.Device;
   use STM32_SVD;

   -------------------
   -- Current_Count --
   -------------------
   
   function Current_Count (This : Rotary_Encoder) return UInt32 is
   begin
      return Current_Counter (This.all);
   end Current_Count;
   
   -----------------
   -- Reset_Count --
   -----------------
   
   procedure Reset_Count (This : in out Rotary_Encoder) is
   begin
      Set_Counter (This.all, UInt16'(0));
   end Reset_Count;
   
   -----------------------
   -- Current_Direction --
   -----------------------
   function Current_Direction (This : Rotary_Encoder) return Counting_Direction
   is
   begin
      case Current_Counter_Mode (This.all) is
         when Up => return Up;
         when Down => return Down;
         when others => raise Program_Error;
      end case;
   end Current_Direction;

   ------------------------
   -- Initialize_Encoder --
   ------------------------
   
   procedure Initialize_Encoder 
     (This : in out Rotary_Encoder;
      Encoder_TI1   : GPIO_Point;
      Encoder_TI2   : GPIO_Point;
      Encoder_Timer : not null access Timer;
      Encoder_AF    : GPIO_Alternate_Function) 
   is
      Configuration : GPIO_Port_Configuration;
      Debounce_Filter : constant Timer_Input_Capture_Filter := 6;
      Period : constant UInt32 := (if Has_32bit_Counter (Encoder_Timer.all)
                                 then UInt32'Last else UInt32 (UInt16'Last));
   begin
      This := Rotary_Encoder (Encoder_Timer);
      
      --  Enable all TImers
      Enable_Clock (Encoder_TI1);
      Enable_Clock (Encoder_TI2);
      Enable_Clock (Encoder_Timer.all);
      
      --  Set Port configuration mode
      Configuration :=
        (Mode           => Mode_AF,
         Resistors      => Pull_Up,
         AF             => Encoder_AF,
         AF_Output_Type => Push_Pull,
         AF_Speed       => Speed_100MHz);
      
      --  Attach Port configuration to each Timer
      Encoder_TI1.Configure_IO (Configuration);
      Encoder_TI2.Configure_IO (Configuration);
      
      --  Lock configuration 
      Encoder_TI1.Lock;
      Encoder_TI2.Lock;
      
      --  Configure Encoder TImer
      Configure (Encoder_Timer.all, 0, Period, Div1, Up);
      
      --  Configure Encoder interface
      Configure_Encoder_Interface (This         => Encoder_Timer.all,
                                   Mode         => Encoder_Mode_TI1_TI2,
                                   IC1_Polarity => Rising,
                                   IC2_Polarity => Rising);
      
      --  Configure TImer channel
      Configure_Channel_Input (This      => Encoder_Timer.all,
                               Channel   => Channel_1,
                               Polarity  => Rising,
                               Selection => Direct_TI,
                               Prescaler => Div1,
                               Filter    => Debounce_Filter);
      
      Configure_Channel_Input (This      => Encoder_Timer.all,
                               Channel   => Channel_2,
                               Polarity  => Rising,
                               Selection => Direct_TI,
                               Prescaler => Div1,
                               Filter    => Debounce_Filter);
      
      Set_Autoreload (This    => Encoder_Timer.all, Value   => Period);
      Enable_Channel (This    => Encoder_Timer.all, Channel => Channel_1);
      Enable_Channel (This    => Encoder_Timer.all, Channel => Channel_2);
      
      --  Initialize TImer counter
      if Has_32bit_Counter (Encoder_Timer.all) then
         Set_Counter (Encoder_Timer.all, UInt32'(0));
      else
         Set_Counter (Encoder_Timer.all, UInt16'(0));
      end if;

      Enable (Encoder_Timer.all);

   end Initialize_Encoder;
   
   --------------------
   -- Bidirectional  --
   --------------------
   
   function Bidirectionnal (This : Timer) return Boolean is
     (This'Address = TIM1_Base or
        This'Address = TIM2_Base or
          This'Address = TIM3_Base or
            This'Address = TIM4_Base or
              This'Address = TIM5_Base or
                This'Address = TIM8_Base);
   

end Quadrature_Encoders;
