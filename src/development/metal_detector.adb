with Ada.Real_Time;


with Hardware_Config;
with Math_Utilities;

package body Metal_Detector is

   use Ada.Real_Time;
   
   use Hardware_Config;
   use Math_Utilities;
   
   function Mapped is new Map (T => Integer);
   -- Mapps a given value from the given range to the given domain. Used to scale
   -- a raw input value in the range low .. High to the percentage value 
   -- 0 .. 100
   
   Period : constant Time_Span := Milliseconds (150);
   Sensor : Metal_Sensor;
   
   procedure Set_Up_ADC_General_Settings;
   --  Does ADC general setup for al ADC units.
   procedure Assign_ADC
     (This          : in out Metal_Sensor;
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point);
   
   ----------------------
   -- Protected Object --
   ----------------------
   
   protected Critical_Detection is
      procedure Set_Internal_Signal_Intensity (Reading : Target_Indicator);
      function  Get_Internal_Signal_Intensity return Target_Indicator;
   private
      Internal_Signal_Intensity : Target_Indicator := 0;
   end Critical_Detection;
   
   protected body Critical_Detection is
      -----------------------------------
      -- Set_Internal_Signal_Intensity --
      -----------------------------------
      procedure Set_Internal_Signal_Intensity (Reading : Target_Indicator) is
      begin
         Internal_Signal_Intensity := Reading;
      end Set_Internal_Signal_Intensity;
      -----------------------------------
      -- Get_Internal_Signal_Intensity --
      -----------------------------------
      function Get_Internal_Signal_Intensity return Target_Indicator is
        (Internal_Signal_Intensity);
   end Critical_Detection;  
   -----------------------
   -- Simple_Controller --
   -----------------------
   task Simple_Controller;
   task body Simple_Controller is
      Reading      : Integer;
      Successful   : Boolean;
      Next_Time    : Time := Clock + Period;
   begin
      loop
         --Clear_Screen;
         delay until Next_Time; 
         Do_Reading_On_ADC (This          => Sensor,
                            Reading       => Reading,
                            IO_Successful => Successful);
         if not Successful then
            Critical_Detection.Set_Internal_Signal_Intensity (Reading => 0);
         else
            Critical_Detection.Set_Internal_Signal_Intensity 
              (Target_Indicator (Reading));
         end if;
         --Put_Line ("Target = " & 
         --            Critical_Detection.Get_Internal_Signal_Intensity'Image);
         Next_Time := Next_Time + Period;
      end loop;
   end Simple_Controller;
   ------------
   -- Enable --
   ------------
   procedure Enable (This : in out Metal_Sensor) is
   begin
      STM32.ADC.Enable (This.Converter.all);
   end Enable;
   -------------
   -- Disable --
   -------------
   procedure Disable (This : in out Metal_Sensor) is
   begin
      STM32.ADC.Disable (This.Converter.all);
   end Disable;
   -------------
   -- Enabled --
   -------------
   function Enabled (This : Metal_Sensor) return Boolean is
     (STM32.ADC.Enabled (This.Converter.all));
   ----------------
   -- Assign_ADC --
   ----------------
   procedure Assign_ADC
     (This          : in out Metal_Sensor;
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point)
   is
   begin
      This.Converter     := Converter;
      This.Input_Channel := Input_Channel;
      This.Input_Pin     := Input_Pin;
   end Assign_ADC;
   ---------------------------------
   -- Set_Up_ADC_General_Settings --
   ---------------------------------
   procedure Set_Up_ADC_General_Settings is
   begin
      Reset_All_ADC_Units;
      Configure_Common_Properties
        (Mode           => Independent,
         Prescalar      => PCLK2_Div_2,
         DMA_Mode       => Disabled,  -- this is multi-dma mode
         Sampling_Delay => Sampling_Delay_5_Cycles);
   end Set_Up_ADC_General_Settings;
   ----------------
   -- Initialize --
   ----------------
   procedure Initialize (This : in out Metal_Sensor) is
   begin
      Set_Up_ADC_General_Settings;
      Assign_ADC (This          => This,
                  Converter     => Selected_ADC_Unit'Access,
                  Input_Channel => Selected_Input_Channel,
                  Input_Pin     => Input_Pin);
      
      Enable_Clock (This.Input_Pin);
      This.Input_Pin.Configure_IO ((Mode_Analog, Resistors => Floating));

      Enable_Clock (This.Converter.all);
      Configure_Unit (This.Converter.all,
                      Resolution => Sensor_ADC_Resolution,
                      Alignment => Right_Aligned);
      
      Configure_Regular_Conversions
        (This        => This.Converter.all,
         Continuous  => False,
         Trigger     => Software_Triggered,
         Enable_EOC  => True,
         Conversions => Regular_Conversion (This.Input_Channel));
      Enable (This);
   end Initialize;
   ---------------------
   -- Get_Raw_Reading --
   ---------------------
   procedure Get_Raw_Reading
     (This       : in out Metal_Sensor;
      Reading    : out Natural;
      Successful : out Boolean)
   is
   begin
      Start_Conversion (This.Converter.all);
      Poll_For_Status (This.Converter.all, Regular_Channel_Conversion_Complete,
                       Successful);
      if not Successful then
         Reading := 0;
      else
         Reading := Integer (Conversion_Value (This.Converter.all));
      end if;
   end Get_Raw_Reading;

   -----------------------
   -- Do_Reading_On_ADC --
   -----------------------
   procedure Do_Reading_On_ADC
     (This          : in out Metal_Sensor;
      Reading       : out Integer;
      IO_Successful : out Boolean)
   is
      Direct_Reading : Natural;
      ADC_Successful : Boolean;
   begin

      Get_Raw_Reading (This, Direct_Reading, ADC_Successful);
      --  Call ADC to get readings from Sharp metal sensor
      Reading := Integer (Direct_Reading);
      IO_Successful := True;
      
      --  if not ADC_Successful then
      --     Reading := 0;
      --     IO_Successful := False;
      --  else
      --     Reading := Integer (Direct_Reading);
      --      -- We map ADC readings
      --     IO_Successful := True;
      --  end if;
   end Do_Reading_On_ADC;
begin
   Initialize (This => Sensor);
end Metal_Detector;
