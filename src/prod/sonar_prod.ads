with STM32.Device; 
with STM32.ADC;            
with STM32.GPIO;           

package Sonar_Prod is
   -----------------------
   -- Package interface --
   -----------------------
   pragma Elaborate_Body;
   
   use STM32.Device;
   use STM32.ADC;
   use STM32.GPIO;
   
   type Centimeters is range 0 .. 255;
   type SharpIRSensor is (GP2Y0A41SK0F, GP2Y0A21YK0F, GP2Y0A02YK0F);
   --  The acquisition of data depends on the sensor type
   
   type SharpIR (Kind : SharpIRSensor) is tagged private;
   
   -----------------------------
   -- Basic sensor facilities --
   -----------------------------
   procedure Initialize (This : in out SharpIR);
   --  Initialize the input port/pin and the basics for the ADC itself, such
   --  as the resolution and alignment.
   procedure Enable  (This : in out SharpIR);
   procedure Disable (This : in out SharpIR); 
   function  Enabled (This :        SharpIR) return Boolean;
   procedure Get_Raw_Reading
     (This : in out SharpIR;
      Reading : out Natural;
      Successful : out Boolean);
   --  Polls for completion.if the conversion times out, Reading is zero 
   --  and Successful is False.
   
   GP2Y0A41SK0F_Nothing_Detected : constant Integer := 31;
   GP2Y0A21YK0F_Nothing_Detected : constant Integer := 79;
   GP2Y0A02YK0F_Nothing_Detected : constant Integer := 130;
   
   procedure Do_Reading_On_ADC
     (This          : in out SharpIR;
      Reading       : out Integer;
      IO_Successful : out Boolean);
   function Get_Distance return Centimeters;



private
   Sensor_ADC_Resolution : constant ADC_Resolution := ADC_Resolution_10_Bits;

   Max_For_Resolution : constant Integer :=
     (case Sensor_ADC_Resolution is
         when ADC_Resolution_12_Bits => 4095,
         when ADC_Resolution_10_Bits => 1023,
         when ADC_Resolution_8_Bits  => 255,
         when ADC_Resolution_6_Bits  => 63);
   
   type SharpIRNumerator is range 2076 .. 9462;
   
   type SharpIR (Kind : SharpIRSensor) is tagged record
      Converter     : access Analog_To_Digital_Converter;
      Input_Channel : Analog_Input_Channel;
      Input_Pin     : GPIO_Point;
      High          : Natural := Max_For_Resolution;
      Low           : Natural := 0;
      Distance      : Integer;
      case Kind is
         when GP2Y0A41SK0F =>
            GP2Y0A41_Num : SharpIRNumerator := 2076;
            GP2Y0A41_Offset : Natural := 11;
         when GP2Y0A21YK0F =>
            GP2Y0A21_Num : SharpIRNumerator := 4800;
            GP2Y0A21_Offset : Natural := 20;
         when GP2Y0A02YK0F =>
            GP2Y0A02_Num : SharpIRNumerator := 9462;
            GP2Y0A02_Offset : Natural := 17;
      end case;
   end record;
   
   function Regular_Conversion (Channel : Analog_Input_Channel)
                                return Regular_Channel_Conversions 
   is
     [1 => (Channel, Sample_Time => Sample_144_Cycles )];
   
end Sonar_Prod;
