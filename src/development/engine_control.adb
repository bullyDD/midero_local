with Ada.Real_Time;          use Ada.Real_Time;
with STM32.Board;            use STM32.Board;


with Global_Initialization;
with Motor;                 use Motor;
with Remote_Control;         use Remote_Control;
with Vehicle;                use Vehicle;

package body Engine_Control with
    SPARK_Mode --=>   Off -- for now... --

is
    Period : constant Time_Span := Milliseconds (System_Configuration.Engine_Control_Period);
    Vector : Remote_Control.Travel_Vector with Atomic, Async_Readers, Async_Writers;
    --  we must declare this here, and access it as shown in the task body, for SPARK

    procedure Apply (Direction : Remote_Control.Travel_Directions;
                    Power      : Remote_Control.Percentage);

    type Controller_States is (Running, Braked, Awaiting_Reversal);

    ----------------
    -- Controller --
    ----------------

    task body Controller is
        Current_State       : Controller_States := Running;
        Next_Release        : Time;
        Requested_Direction : Remote_Control.Travel_Directions;
        Requested_Braking   : Boolean;
        Requested_Power     : Remote_Control.Percentage;
        Collision_Imminent  : Boolean;
        Current_Speed       : Float;
    begin
        Global_Initialization.Critical_Instant.Wait (Epoch => Next_Release);

        --  In the following loop, the call to get the requested vector does not
        --  block awaiting some change of input. The vectors are received as a
        --  continuous stream of values, often not changing from their previous
        --  values, rather than as a set of discrete commanded changes sent only
        --  when a new vector is commanded by the user.

        loop        
            Vector              := Remote_Control.Requested_Vector;
            Requested_Direction := Vector.Direction;
            Requested_Braking   := Vector.Emergency_Braking;
            Requested_Power     := Vector.Power;
            Current_Speed       := Vehicle.Speed;

            -- Apply (Requested_Direction, Requested_Power);

            --  case Current_State is
            --      when Running =>
            --          --Apply (Requested_Direction, Requested_Power);
            --          null;
            --      when Braked =>
            --          if not Requested_Braking then
            --              Current_State := Running;
            --          end if;
            --      when Awaiting_Reversal =>
            --          if Requested_Direction = Backward then
            --              Current_State := Running;
            --          end if;
            --  end case;

            Next_Release := Next_Release + Period;
            delay until Next_Release;
        end loop;
    end Controller;

    --#region Sub programs implementation

    -----------
    -- Apply --
    -----------

    procedure Apply
        (Direction : Remote_Control.Travel_Directions;
        Power      : Remote_Control.Percentage)
    is
    begin
        if Direction /= Neither then
            Engines(1).all.Engage (Vehicle.To_Propulsion_Motor_Direction (Direction), Power);
        else
            Engines(1).all.Coast;
        end if;
    end Apply;

    --#endregion
end Engine_Control;