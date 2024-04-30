with Ada.Interrupts.Names;  

with STM32;
with STM32.ADC;
with STM32.DMA;
with STM32.Device;
with STM32.GPIO;
with STM32.Timers;
with STM32.USARTs;            

pragma Elaborate_All (STM32);

package Hardware_Config is

   use Ada.Interrupts.Names;
   use STM32;
   use STM32.ADC;
   use STM32.DMA;
   use STM32.Device;
   use STM32.GPIO;
   use STM32.Timers;
   use STM32.USARTs;

   --  The hardware on the STM32 board used by the fours motors (on the
   --  L298N-driver)
   Motor_PWM_Freq : constant := 490;

   --  Motor 1 : Motor Bottom Right
   --  Encoder motor
   Motor1_Encoder_Input1 : GPIO_Point renames PA15;
   Motor1_Encoder_Input2 : GPIO_Point renames PB3;
   Motor1_Encoder_Timer  : constant access Timer                  := Timer_2'Access;
   Motor1_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM2_1;
   Motor1_PWM_Engine     : GPIO_Point renames PB6;
   Motor1_PWM_Engine_TMR : constant access Timer                  := Timer_4'Access;
   Motor1_PWM_Channel    : constant Timer_Channel                 := Channel_1;
   Motor1_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM4_2;
   Motor1_Polarity1      : GPIO_Point renames PA10;
   Motor1_Polarity2      : GPIO_Point renames PB1;


   --  Motor 2 : Motor Bottom Left
   --  Encoder motor
   Motor2_Encoder_Input1 : GPIO_Point renames PA0;
   Motor2_Encoder_Input2 : GPIO_Point renames PA1;
   Motor2_Encoder_Timer  : constant access Timer                  := Timer_5'Access;
   Motor2_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM5_2;
   --  Engine PWM
   Motor2_PWM_Engine     : GPIO_Point renames PB4;
   Motor2_PWM_Engine_TMR : constant access Timer                  := Timer_3'Access;
   Motor2_PWM_Channel    : constant Timer_Channel                 := Channel_1;
   Motor2_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM3_2;
   Motor2_Polarity1      : GPIO_Point renames PA2;
   Motor2_Polarity2      : GPIO_Point renames PA3;


   --  Motor 3 : Motor Top Right
   --  Encoder
   --  Motor3_Encoder_Input1 : GPIO_Point renames PB6;
   --  Motor3_Encoder_Input2 : GPIO_Point renames PB7;
   --  Motor3_Encoder_Timer  : constant access Timer                  := Timer_4'Access;
   --  Motor3_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM4_2;
   --  --  Engine PWM
   --  Motor3_PWM_Engine     : GPIO_Point renames PA0;
   --  Motor3_PWM_Engine_TMR : constant access Timer                  := Timer_2'Access;
   --  Motor3_PWM_Channel    : constant Timer_Channel                 := Channel_1;
   --  Motor3_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM2_1;
   --  Motor3_Polarity1      : GPIO_Point renames PC3;
   --  Motor3_Polarity2      : GPIO_Point renames PC2;


   --  Motor 4 : Motor Top Left
   --  Encoder
   --  Motor4_Encoder_Input1 : GPIO_Point renames PB14;
   --  Motor4_Encoder_Input2 : GPIO_Point renames PB15;
   --  Motor4_Encoder_Timer  : constant access Timer                  := Timer_8'Access;
   --  Motor4_Encoder_AF     : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM8_3;
   --  --  Engine PWM
   --  Motor4_PWM_Engine     : GPIO_Point renames PD12;
   --  Motor4_PWM_Engine_TMR : constant access Timer                  := Timer_4'Access;
   --  Motor4_PWM_Channel    : constant Timer_Channel                 := Channel_1;
   --  Motor4_PWM_Output_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM4_2;
   --  Motor4_Polarity1      : GPIO_Point renames PC5;
   --  Motor4_Polarity2      : GPIO_Point renames PC4;

   ------------------------
   --  SharpIR sensors
   -------------------------

   --  Sonar 1 --

   --Selected_DMA_Unit      : DMA_Controller renames DMA_2;
   --Selected_Stream_Unit   : constant DMA_Stream_Selector        := Stream_0;
   --Selected_ADC_Unit      : Analog_To_Digital_Converter renames ADC_1;
   --Selected_Input_Channel : constant Analog_Input_Channel       := 13;
   --Input_Pin              : GPIO_Point renames PC3;

   -----------------
   -- *** ADC *** --

   Converter     : Analog_To_Digital_Converter renames ADC_1;
   Input_Channel : constant Analog_Input_Channel      := 13;
   Input_Pin     : constant GPIO_Point                := PC3;

   -----------------
   -- *** DMA *** --

   Controller    : DMA_Controller renames DMA_2;
   Stream        : constant DMA_Stream_Selector       := Stream_0;


   -----------------------
   -- *** Bluetooth *** --

   -- The hardware used by the remote control HC05 BLE module USART
   BLE_UART_CTS_Pin     : GPIO_Point renames PD3;
   BLE_UART_RTS_Pin     : GPIO_Point renames PD4;
   BLE_UART_RXI_Pin     : GPIO_Point renames PD5;  -- goes to TXI pin on HC05 BLE module
   BLE_UART_TXO_Pin     : GPIO_Point renames PD6;  -- goes to RXO pin on HC05 BLE module
   BLE_UART_STATE_Pin   : GPIO_Point renames PD1;

   BLE_UART_Transceiver     : constant access USART := USART_2'Access;
   BLE_UART_Transceiver_AF  : constant STM32.GPIO_Alternate_Function := GPIO_AF_USART2_7;
   BLE_UART_Transceiver_IRQ : constant Ada.Interrupts.Interrupt_ID   := USART2_Interrupt;

end Hardware_Config;
