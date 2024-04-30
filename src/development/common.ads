pragma Ada_2012;
pragma Extensions_Allowed (On);

package Common is

   --  Portable type
   type Real is digits 3 range -(2.0**32) .. (2.0**31);
   type Int is range -(2**32) .. (2**32);

   --  Arm_T types
   type Part_Length is new Positive range 1 .. 300;

   --  Joint types
   type DOF is range 1 .. 3;
   type Base_Index is range 1 .. 101;
   type Shoulder_Index is range 1 .. 66;
   type Elbow_Index is range 1 .. 31;

   type Degree_T is mod 2010;
   subtype Base_Degree_T is Degree_T;
   subtype Shoulder_Degree_T is Degree_T;
   subtype Elbow_Degree_T is Degree_T;

   type Degree_Array is array (DOF) of Degree_T;
   type Base_Deg_Array is array (Base_Index) of Base_Degree_T;
   type Shoulder_Deg_Array is array (Shoulder_Index) of Shoulder_Degree_T;
   type Elbow_Deg_Array is array (Elbow_Index) of Elbow_Degree_T;

   type PWM_Frequency is range 10 .. 2_000_000;

   Base_Pos   : Base_Deg_Array :=
     [2000, 1990, 1980, 1970, 1960, 1950, 1940, 1930, 1920, 1910, 1900,
      1890, 1880, 1870, 1860, 1850, 1840, 1830, 1820, 1810, 1800, 1790,
      1780, 1770, 1760, 1750, 1740, 1730, 1720, 1710, 1700, 1690, 1680,
      1670, 1660, 1650, 1640, 1630, 1620, 1610, 1600, 1590, 1580, 1570,
      1560, 1550, 1540, 1530, 1520, 1510, 1500, 1490, 1480, 1470, 1460,
      1450, 1440, 1430, 1420, 1410, 1400, 1390, 1380, 1370, 1360, 1350,
      1340, 1330, 1320, 1310, 1300, 1290, 1280, 1270, 1260, 1250, 1240,
      1230, 1220, 1210, 1200, 1190, 1180, 1170, 1160, 1150, 1140, 1130,
      1120, 1110, 1100, 1090, 1080, 1070, 1060, 1050, 1040, 1030, 1020,
      1010, 1000];

   Shoulder_Pos    : Shoulder_Deg_Array :=
     [400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 510, 520,
      530, 540, 550, 560, 570, 580, 590, 600, 610, 620, 630, 640, 650,
      660, 670, 680, 690, 700, 710, 720, 730, 740, 750, 760, 770, 780,
      790, 800, 810, 820, 830, 840, 850, 860, 870, 880, 890, 900, 910,
      920, 930, 940, 950, 960, 970, 980, 990, 1000, 1010, 1020, 1030,
      1040, 1050];

   --  Elbow_Pos    : Elbow_Deg_Array :=
   --    [400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 510, 520,
   --     530, 540, 550, 560, 570, 580, 590, 600, 610, 620, 630, 640, 650,
   --     660, 670, 680, 690, 700, 710, 720, 730, 740, 750, 760, 770, 780,
   --     790, 800, 810, 820, 830, 840, 850, 860, 870, 880, 890, 900, 910,
   --     920, 930, 940, 950, 960, 970, 980, 990, 1000];
   Elbow_Pos    : Elbow_Deg_Array :=
     [400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500, 510, 520,
      530, 540, 550, 560, 570, 580, 590, 600, 610, 620, 630, 640, 650,
      660, 670, 680, 690, 700];

end Common;
