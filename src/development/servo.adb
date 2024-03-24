with HAL;

with STM32.Device;                     

package body Servo is
   
   use HAL;
   use STM32.Device;
   
   --  Config declaration for one servo
   --  Base servo
   Base_Pin   : GPIO_Point renames PA6;
   Ch1        : constant Timer_Channel := Channel_1;
   Base_Timer : Timer renames Timer_3;
   AF         : constant STM32.GPIO_Alternate_Function := GPIO_AF_TIM3_2;
   
   procedure Initialize 
     (This              : in out MG996R_Servo;
      Channel           : Timer_Channel;
      PWM_Engine        : GPIO_Point;
      PWM_Output_Timer  : not null access Timer;
      PWM_Output_AF     : STM32.GPIO_Alternate_Function;
      PWM_Frequency     : PWM_Frequency_T);
   procedure Initialize_PWM_Engine (This : in out MG996R_Servo);
   ------------
   -- Rotate --
   ------------
   procedure Rotate (This : out MG996R_Servo; Degree : STM32.PWM.Percentage) is
   begin
      This.PWM_Output_Engine.Set_Duty_Cycle (Value => Degree);
   end Rotate;
   --------------------
   -- Initialize_Arm --
   --------------------
   procedure Initialize_Arm (S1 : out MG996R_Servo; S2 : out MG996R_Servo;
                             S3 : out MG996R_Servo; S4 : out MG996R_Servo) is
      pragma Unreferenced (S2, S3, S4);
   begin
      --  Initialize Base servo
      Initialize (This             => S1,
                  Channel          => Ch1,
                  PWM_Engine       => Base_Pin,
                  PWM_Output_Timer => Base_Timer'Access,
                  PWM_Output_AF    => AF,
                  PWM_Frequency    => 50);
   end Initialize_Arm;
   -------------
   -- Enabled --
   -------------
   function Enabled (This : MG996R_Servo) return Boolean is
   begin
      return Output_Enabled (This.PWM_Output_Engine);
   end Enabled;
   ---------------
   -- Set_Timer --
   ---------------
   procedure Set_Timer (This      : in out MG996R_Servo; 
                        Generator : not null access Timer) is
   begin
      This.PWM_Output_Timer := Generator;
   end Set_Timer;
   ------------
   -- Attach --
   ------------
   procedure Attach (This : in out MG996R_Servo;
                     Pin  : GPIO_Point;
                     Channel : Timer_Channel) is
   begin
      This.Channel := Channel;
      This.PWM_Engine := Pin;
   end Attach;
   ------------
   -- Set_AF --
   ------------
   procedure Set_AF (This : in out MG996R_Servo; 
                     Func : STM32.GPIO_Alternate_Function)
   is
   begin
      This.PWM_Output_AF := Func;
   end Set_AF;
   -----------------------
   -- Set_PWM_Frequency --
   -----------------------
   procedure Set_PWM_Frequency (This : in out MG996R_Servo; 
                                Frequency : PWM_Frequency_T)
   is
   begin
      This.PWM_Frequency := Frequency;
   end Set_PWM_Frequency;
   ----------------
   -- Initialize --
   ----------------
   procedure Initialize 
     (This              : in out MG996R_Servo;
      Channel           : Timer_Channel;
      PWM_Engine        : GPIO_Point;
      PWM_Output_Timer  : not null access Timer;
      PWM_Output_AF     : STM32.GPIO_Alternate_Function;
      PWM_Frequency     : PWM_Frequency_T) is
   begin
      Set_Timer (This, PWM_Output_Timer);
      Attach (This, PWM_Engine, Channel);
      Set_AF (This, PWM_Output_AF);
      Set_PWM_Frequency (This, PWM_Frequency);
      Initialize_PWM_Engine (This);
      This.PWM_Engine.Lock;        --  Lock current config until next reset
   end Initialize;
   ---------------------------
   -- Initialize_PWM_Engine --
   ---------------------------
   procedure Initialize_PWM_Engine (This : in out MG996R_Servo) is
   begin
      Configure_PWM_Timer (Generator => This.PWM_Output_Timer,
                           Frequency => UInt32 (This.PWM_Frequency));
      Attach_PWM_Channel (This      => This.PWM_Output_Engine,
                          Generator => This.PWM_Output_Timer,
                          Channel   => This.Channel,
                          Point     => This.PWM_Engine,
                          PWM_AF    => This.PWM_Output_AF);
      This.PWM_Output_Engine.Enable_Output;
   end Initialize_PWM_Engine;
end Servo;
