with Ada.Real_Time;

with Global_Initialization;
with Hardware_Config;
with System_Configuration;

package body Sonar_Prod is
   
   use Ada.Real_Time;
   use Hardware_Config;
   
   Sensor : SharpIR (GP2Y0A21YK0F);
   
   Period : constant Time_Span := 
     Milliseconds (System_Configuration.Sonar_Period);
   
   ---------------------------------
   -- Protected sensor facilities --
   ---------------------------------
   procedure Set_Up_ADC_General_Settings;
   --  Does ADC general setup for al ADC units.
   procedure Assign_ADC
     (This          : in out SharpIR;
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point);
   protected Critical_Distance is
      procedure Set_Internal_Dist (Reading : Centimeters);
      function  Get_Internal_Dist return Centimeters;
   private
      Internal_Distance : Centimeters;
   end Critical_Distance;
   
   -----------------------
   -- Critical_Distance --
   -----------------------
   protected body Critical_Distance is
      -----------------------
      -- Set_Internal_Dist --
      -----------------------
      procedure Set_Internal_Dist (Reading : Centimeters) is
      begin
         Internal_Distance := Reading;
      end Set_Internal_Dist;
      -----------------------
      -- Get_Internal_Dist --
      -----------------------
      function Get_Internal_Dist return Centimeters is
        (Internal_Distance);

   end Critical_Distance;
   -----------------------
   -- Task : Controller --
   -----------------------
   task Controller
     with 
       Priority => System_Configuration.Sonar_Priority;
   
   task body Controller is
      Reading      : Integer;
      Successful   : Boolean;
      Next_Time    : Time;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Time);
      Next_Time := Next_Time + Period;
      
      loop
         delay until Next_Time;
         
         Sensor.Do_Reading_On_ADC (Reading       => Reading,
                                   IO_Successful => Successful);
         if Successful then
            Critical_Distance.Set_Internal_Dist 
              (Reading => Centimeters (Reading));
         else
            Critical_Distance.Set_Internal_Dist (Reading => 0);
         end if;
         
         Next_Time := Next_Time + Period;
      end loop;
   end Controller;
   ------------------
   -- Get_Distance --
   ------------------
   function Get_Distance return Centimeters is
     (Critical_Distance.Get_Internal_Dist);
   ------------
   -- Enable --
   ------------
   procedure Enable (This : in out SharpIR) is
   begin
      STM32.ADC.Enable (This.Converter.all);
   end Enable;
   -------------
   -- Disable --
   -------------
   procedure Disable (This : in out SharpIR) is
   begin
      STM32.ADC.Disable (This.Converter.all);
   end Disable;
   -------------
   -- Enabled --
   -------------
   function Enabled (This : SharpIR) return Boolean is
      (STM32.ADC.Enabled (This.Converter.all));
   ----------------
   -- Assign_ADC --
   ----------------
   procedure Assign_ADC
     (This          : in out SharpIR;
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
   procedure Initialize (This : in out SharpIR) is
   begin
      Set_Up_ADC_General_Settings;
      This.Assign_ADC (Selected_ADC_Unit'Access,
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
      This.Enable;
   end Initialize;
   ---------------------
   -- Get_Raw_Reading --
   ---------------------
   procedure Get_Raw_Reading
     (This       : in out SharpIR;
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
     (This          : in out SharpIR;
      Reading       : out Integer;
      IO_Successful : out Boolean)
   is
      Direct_Reading : Natural;
      ADC_Successful : Boolean;
   begin

      This.Get_Raw_Reading (Direct_Reading, ADC_Successful);
      --  Call ADC to get readings from Sharp IR sensor

      if not ADC_Successful then
         Reading := 0;
         IO_Successful := False;
      end if;

      --  Because of polymorphism of This, we check the kind of sensor
      --  before computing This.Distance
      case This.Kind is
         when GP2Y0A41SK0F =>
            Reading :=
              (Natural (This.GP2Y0A41_Num) /
               (Direct_Reading - This.GP2Y0A41_Offset));
         when GP2Y0A21YK0F =>
            Reading :=
              (Natural (This.GP2Y0A21_Num) /
               (Direct_Reading - This.GP2Y0A21_Offset));
         when GP2Y0A02YK0F =>
            Reading :=
              (Natural (This.GP2Y0A02_Num) /
               (Direct_Reading - This.GP2Y0A02_Offset));
      end case;

      --  Once This.Distance is computed then we bound it.
      case This.Kind is
      
         when GP2Y0A41SK0F =>
            if Reading > GP2Y0A41SK0F_Nothing_Detected then
               Reading := GP2Y0A41SK0F_Nothing_Detected;
            elsif Reading < 4 then
               Reading := 3;
            end if;
      
         when GP2Y0A21YK0F =>
            if Reading > GP2Y0A21YK0F_Nothing_Detected then
               Reading := GP2Y0A21YK0F_Nothing_Detected;
            elsif Reading < 0 then
               Reading := 4;
            end if;
      
         when GP2Y0A02YK0F =>
            if Reading > GP2Y0A02YK0F_Nothing_Detected then
               Reading := GP2Y0A02YK0F_Nothing_Detected;
            elsif Reading < 20 then
               Reading := 19;
            end if;
      end case;
      IO_Successful := True;
   end Do_Reading_On_ADC;
begin
   Sensor.Initialize;
end Sonar_Prod;
