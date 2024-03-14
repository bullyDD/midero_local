-------------------------------------------------------------------------
-- This package provides driver for Bounty Hunter Metal Detector.
-- Note that, on the STM32F4xxx series, only DMA2 can attach to on ADC.

-- For our first, we are going to use ADC to converter sensor's data and
-- ask to cpu to poll continuously. 
-- As excpected we might stress our CPU.
--
-- The second approch is to use DMA to get sensor's data directly after 
-- conversion

with STM32.ADC;
with STM32.Device;
with STM32.GPIO;

package Metal_Detector is
   pragma Elaborate_Body;

   use STM32.ADC;
   use STM32.Device;
   use STM32.GPIO;
   -----------------------
   -- Package interface --
   
   type Target_Indicator is range 0 .. 1024;
   --  Presence of a iron object generate a voltage between 0 and 5V.
   --  We are going to mapped these values and we used them in our program
   
   type Metal_Sensor is private;
   
   -----------------------------
   -- Metal_Sensor facilities --
   
   procedure Initialize (This : in out Metal_Sensor);
   procedure Enable     (This : in out Metal_Sensor);
   procedure Disable    (This : in out Metal_Sensor); 
   function  Enabled    (This : Metal_Sensor) return Boolean;
   procedure Get_Raw_Reading
     (This       : in out Metal_Sensor;
      Reading    : out Natural;
      Successful : out Boolean);
   
   procedure Do_Reading_On_ADC
     (This          : in out Metal_Sensor;
      Reading       : out Integer;
      IO_Successful : out Boolean);
   --function Get_Signal_Internsity return Target_Indicator;
   
private
   
   Sensor_ADC_Resolution : constant ADC_Resolution := ADC_Resolution_8_Bits;

   Max_For_Resolution : constant Integer :=
     (case Sensor_ADC_Resolution is
         when ADC_Resolution_12_Bits => 4095,
         when ADC_Resolution_10_Bits => 1023,
         when ADC_Resolution_8_Bits  => 255,
         when ADC_Resolution_6_Bits  => 63);
   
   type Metal_Sensor is record
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point;
      High          : Natural := Max_For_Resolution;
      Low           : Natural := 0;
   end record;
   
   function Regular_Conversion (Channel : Analog_Input_Channel)
                                return Regular_Channel_Conversions 
   is
     (1 => (Channel, Sample_Time => Sample_144_Cycles));
   

end Metal_Detector;
