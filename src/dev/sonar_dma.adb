with Ada.Real_Time;             use Ada.Real_Time;
with Ada.Text_IO;

with STM32.Device;              use STM32.Device;
with STM32.ADC;                 use STM32.ADC;
with STM32.DMA;                 use STM32.DMA;
with STM32.GPIO;                use STM32.GPIO;

with System_Configuration;
with Hardware_Config;           use Hardware_Config;

package body Sonar_DMA is

   Counts        : UInt16 with Volatile;
   Period        : constant Time_Span := 
     Milliseconds (System_Configuration.Sonar_Period);
   
   procedure Initialize_DMA;
   procedure Initialize_ADC;

   protected Critical_Distance is
      procedure Set (Reading : UInt16);
      function  Get return UInt16;
   private
      Internal_Dist : UInt16 := 0;
   end Critical_Distance;
   
   -----------------------
   -- Critical_Distance --
   -----------------------
   protected body Critical_Distance is
      ---------
      -- Set --
      ---------
      procedure Set (Reading : UInt16) is
      begin
         Internal_Dist := Reading;
      end Set;
      ---------
      -- Get --
      ---------
      function Get return UInt16 is
        (Internal_Dist);
   end Critical_Distance;
   
   ----------------
   -- Controller --
   ----------------
   task Controller_Task;
   task body Controller_Task is
      Next_Time : Time;
   begin
      Next_Time := @ + Period;
      loop
         --Clear_Screen;
         Critical_Distance.Set (Counts);
         --LCD_Std_Out.Put_Line ("Val= " & Get_Distance'Image);
         Next_Time := @ + Period;
         delay until Next_Time;
      end loop;
   end Controller_Task;
   --------------------
   -- Initialize_DMA --
   --------------------
   procedure Initialize_DMA  is
      Config : DMA_Stream_Configuration;
   begin
      Enable_Clock (Controller);
      Reset (This   => Controller,
             Stream => Stream);
      
      Config.Channel                      := Channel_0;
      Config.Direction                    := Peripheral_To_Memory;
      Config.Memory_Data_Format           := HalfWords;
      Config.Peripheral_Data_Format       := HalfWords;
      Config.Increment_Peripheral_Address := False;
      Config.Increment_Memory_Address     := False;
      Config.Operation_Mode               := Circular_Mode;
      Config.Priority                     := Priority_Very_High;
      Config.FIFO_Enabled                 := False;
      Config.Memory_Burst_Size            := Memory_Burst_Single;
      Config.Peripheral_Burst_Size        := Peripheral_Burst_Single;
      
      Configure        (Controller, Stream, Config);
      Clear_All_Status (Controller, Stream);
      
   end Initialize_DMA;
   
   --------------------
   -- Initialize_ADC --
   --------------------
   procedure Initialize_ADC  is
      All_Regular_Conversions : constant Regular_Channel_Conversions :=
        [1 => (Channel => Input_Channel, Sample_Time => Sample_480_Cycles)];
      
      ----------------------------
      -- Configure_Analog_Input --
      ----------------------------
      procedure Configure_Analog_Input is
      begin
         Enable_Clock (Hardware_Config.Input_Pin);
         Configure_IO (Input_Pin, 
                       (Mode => Mode_Analog, Resistors => Floating));
      end Configure_Analog_Input;
   begin
      Configure_Analog_Input;
      Enable_Clock (Converter);
      Reset_All_ADC_Units;
      
      Configure_Common_Properties (Mode           => Independent,
                                   Prescalar      => PCLK2_Div_2,
                                   DMA_Mode       => Disabled,
                                   Sampling_Delay => Sampling_Delay_5_Cycles);
      
      Configure_Unit (This       => Converter,
                      Resolution => ADC_Resolution_10_Bits,
                      Alignment  => Right_Aligned);
      
      Configure_Regular_Conversions (This        => Converter,
                                     Continuous  => True,
                                     Trigger     => Software_Triggered,
                                     Enable_EOC  => False,
                                     Conversions => All_Regular_Conversions);
      
      Enable_DMA (Converter);
      Enable_DMA_After_Last_Transfer (Converter);
      
   end Initialize_ADC;
   
   ------------------
   -- Get_Distance --
   ------------------
   function Get_Distance return UInt16 is
      Measure : UInt16;
   begin
      Measure := UInt16 (4800) / (Critical_Distance.Get - 20);
      
      if Measure > 79 then
         Measure := 79;
      elsif Measure = 0 then
         Measure := 4;
      end if;      
      return Measure;
   end Get_Distance;
   
   ----------------
   -- Initialize --
   -----------------
   procedure Initialize is
   begin
       --  1) Initialize_DMA
      Initialize_DMA;
      
      --  2) Initialize ADC
      Initialize_ADC;
      
      --  3) Enable converter
      Enable (Converter);
      
      Start_Transfer (This        => Controller,
                      Stream      => Stream,
                      Source      => Data_Register_Address (Converter),
                      Destination => Counts'Address,
                      Data_Count  => 1);
      Start_Conversion (Converter);
   end Initialize;
   
begin
  Initialize;
   
end Sonar_DMA;
