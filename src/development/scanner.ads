-------------------------------------------------------------------------
--  Interface
--
--  S1, S2, S3, S4 represent Four joint (base, shoulder, elbow and wrist)
--  of robotic arm.
--
--  Theta1, Theta2, Theta3 and Theta4 represent rotation angles for the
--  corresponding joints.
--  Their respective rotation's intervals are :
--
--  Theta1 £ [0, 180°]
--  Theta2 £ [0, 90°]
--  Theta3 £ [0, 90°]
--  Theta4 £ [0, 90°]
-- 
------------------------------------------------------------------------

with Servo;

package Scanner is

   use Servo;
   S1, S2, S3, S4 : MG996R_Servo;
   
   procedure Deploy with
     Pre => 
       Enabled (S1) and 
       Enabled (S2) and 
       Enabled (S3) and 
       Enabled (S4);
   
   procedure Dispose with
     Post => 
       not Enabled (S1) and 
       not Enabled (S2) and 
       not Enabled (S3) and 
       not Enabled (S4);
   
   procedure Sweep;

end Scanner;
