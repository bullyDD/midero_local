----------------------------------------------------------------------------
--  This package provides an interface to a quadrature motor encoder (so
--  stricly speaking it is a decoder). It uses the specific capabilities of
--  selected ST Micro timers to perform this function, thereby relieving the
--  MCU of having to do so (eg via interrupts)

with STM32.GPIO;   
with STM32.Timers; 
with STM32;        

with HAL;  
package Quadrature_Encoders is
   
  pragma Elaborate_Body;
  
  use STM32.GPIO;
  use STM32.Timers;
  use STM32;
  use HAL;
   
  type Rotary_Encoder is limited private;
  function Current_Count (This : Rotary_Encoder) return UInt32
    with Inline;
   
  procedure Reset_Count (This : in out Rotary_Encoder) 
    with 
      Post => Current_Count (This) = 0;
  
  type Counting_Direction is (Up, Down);
  function Current_Direction (This : Rotary_Encoder) return Counting_Direction
    with Inline;
  
  procedure Initialize_Encoder 
    (This         : in out Rotary_Encoder;
    Encoder_TI1   : GPIO_Point;
    Encoder_TI2   : GPIO_Point;
    Encoder_Timer : not null access Timer;
    Encoder_AF    : GPIO_Alternate_Function)
      with
        Pre   => Has_32bit_Counter (Encoder_Timer.all) and
                  Bidirectionnal (Encoder_Timer.all),
        Post  => Current_Count (This) = 0 and 
                  Current_Direction (This) = Up;
  --  Note that the encoder always uses channels 1 and 2 on the specified
  --  timer for Encoder_TI1 and Encoder_TI2, the two timer input discretes.
  
  function Bidirectionnal (This : Timer) return Boolean;
  --  The selected timer must be able to count both up and down, so not all
  --  are candidates. Only Timers 1..5 and 8 are bidirectional, per the F429
  --  Datasheet, Table 6, pg 33.
  
private
  
  type Rotary_Encoder is access all Timer
    with 
      Storage_Size => 0;

end Quadrature_Encoders;
