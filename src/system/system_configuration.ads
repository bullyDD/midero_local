--  Task periods and priorities

with System;    use System;

package System_Configuration is

   --  These constants are the priorities of the tasks in the system, defined
   --  here for ease of setting with the big picture in view.

   Main_Priority           : constant Priority := Priority'First; -- lowest
   Engine_Monitor_Priority : constant Priority := Main_Priority + 1;
   Remote_Priority         : constant Priority := Engine_Monitor_Priority + 1;
   Engine_Control_Priority : constant Priority := Remote_Priority + 1;
   
   Highest_Priority : Priority renames Engine_Control_Priority;
   --  Whichever is highest. All the tasks call into the global initialization
   --  PO to await completion before doing anything interesting, so the PO
   --  requires the highest of those caller priorities

   Highest_Period          : constant := 250;
   Engine_Control_Period   : constant := Highest_Period - 50;               -- 200 milliseconds
   Engine_Monitor_Period   : constant := Engine_Control_Period - 50;
   Remote_Period           : constant := Engine_Monitor_Period - 50;
   Sonar_Period            : constant := Remote_Period - 50;
   
end System_Configuration;
