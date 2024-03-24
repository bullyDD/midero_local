--  Task periods and priorities

with System;    use System;

package System_Configuration is

   --  These constants are the priorities of the tasks in the system, defined
   --  here for ease of setting with the big picture in view.

   Main_Priority           : constant Priority := Priority'First; -- lowest
   --Scanner_Priority        : constant Priority := Main_Priority + 1;
   Vehicle_Priority        : constant Priority := Main_Priority + 1;
   Sonar_Priority          : constant Priority := Vehicle_Priority + 1;
   --RF_Priority             : constant Priority := Sonar_Priority + 1;
   Scheduler_Priority      : constant Priority := Sonar_Priority + 1;

   Highest_Priority : Priority renames Scheduler_Priority;

   Highest_Period          : constant := 450;
   Scanner_Period          : constant := Highest_Period - 50;    -- millisecond
   Engine_Monitor_Period   : constant := 150;                     -- For testing purpose
   Vehicle_Period          : constant := Scanner_Period - 50;
   Sonar_Period            : constant := Vehicle_Period - 50;
   RF_Period               : constant := Sonar_Period   - 50;

end System_Configuration;
