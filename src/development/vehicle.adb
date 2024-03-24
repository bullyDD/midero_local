with Ada.Real_Time;

with Motor_Prod;
with Sonar_Prod;

with Global_Initialization;
with System_Configuration;

package body Vehicle is
   
   use Ada.Real_Time;
   use Motor_Prod;
   use Sonar_Prod;

   M1, M2, M3, M4 : Basic_Motor;
   Limit          : constant Centimeters := 30;
   
   Period         : constant Time_Span := 
     Milliseconds (System_Configuration.Vehicle_Period);
   
   task Controller 
     with
       Priority => System_Configuration.Vehicle_Priority;
   ----------------
   -- Controller --
   ----------------
   task body Controller is
      Next_Time : Time;
   begin
      Global_Initialization.Critical_Instant.Wait (Epoch => Next_Time);
      Next_Time := Next_Time + Period;
      loop
         delay until Next_Time;
         
         if Sonar_Prod.Get_Distance < Limit then
            Motor_Prod.Set_Internal_State (Braking);
         else
            Motor_Prod.Set_Internal_State (Running);
         end if;
         
         Motor_Prod.Turn_Motor (M1, M2, M3, M4);
         Next_Time := Next_Time + Period;
         
      end loop;
      
   end Controller;
   
     
   ---------------
   -- Initialize --
   ---------------
   procedure Initialize is
   begin
      Motor_Prod.Initialize_Motors (M1, M2, M3, M4);
   end Initialize;
   

end Vehicle;
