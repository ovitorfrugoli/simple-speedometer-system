/*******************************************************************************
* FILENAME :        simpleSpeedometerSystem.pwn
*
* DESCRIPTION :
*       Filterscript main archive.
*
* NOTES :
*       -
*
*
*/


/*
 * I N C L U D E S
 ******************************************************************************
 */
#include <a_samp>
#include <GetVehicleColor>


/*
 * D E F I N I T I O N S
 ******************************************************************************
 */

/**
* Macros Utilizados
*/
forward VerifyVehicleHealth(playerid, vehicleid);
forward IsPlayerInZone(playerid);

static stock stringFormat[256];

#define PlayerTextDrawSetStringFormat(%0,%1,%2,%3) \
	format(stringFormat, sizeof(stringFormat), %2, %3) && \
	PlayerTextDrawSetString(%0, PlayerText:%1, stringFormat)

const

	/**
	* Cores Utilizadas
	*/
	COLOR_RED		= 0xE84F33AA,
	COLOR_GREEN		= 0x9ACD32AA,
	COLOR_ORANGE    = 0xFF8B53FF,

	/**
	* Limite máximo do nome da área.
	*/
	MAX_ZONE_NAME   = 25


;

/*
 * E N U M E R A T O R S
 ******************************************************************************
 */

/**
* Enumerador da textdraw do velocímetro.
*/
enum E_TEXT_PRIVATE_SPEEDO
{
	PlayerText:E_SPEEDO_SPEED,
	PlayerText:E_SPEEDO_VEH_TYPE,
	PlayerText:E_SPEEDO_VEH_HEALTH,
	PlayerText:E_SPEEDO_LOCATION
}

/**
* Enumerador das informações do veículo.
*/
enum E_VEHICLE_INFO
{
	E_VEHICLE_TIMER_HEALTH,
	E_VEHICLE_TIMER_ZONE,
	E_VEHICLE_MODELID,
	E_VEHICLE_COLOR_ONE,
	E_VEHICLE_COLOR_TWO,
	E_VEHICLE_HEALTH,
	E_VEHICLE_SPEED
}

/**
* Enumerador das zonas de San Andreas.
*/
enum E_SA_ZONES 
{
	E_ZONE_NAME[MAX_ZONE_NAME],
	Float:E_ZONE_AREA[6]
}

/*
 * V A R I A B L E S
 ******************************************************************************
 */

/**
* Matriz com nome e coordenadas das zonas de San Andreas.
*/
static const sanAndreasZones[][E_SA_ZONES] = 
{
	{"The Big Ear",	                {-410.00,1403.30,-3.00,-137.90,1681.20,200.00}},
	{"Aldea Malvada",               {-1372.10,2498.50,0.00,-1277.50,2615.30,200.00}},
	{"Angel Pine",                  {-2324.90,-2584.20,-6.10,-1964.20,-2212.10,200.00}},
	{"Arco del Oeste",              {-901.10,2221.80,0.00,-592.00,2571.90,200.00}},
	{"Avispa Country Club",         {-2646.40,-355.40,0.00,-2270.00,-222.50,200.00}},
	{"Avispa Country Club",         {-2831.80,-430.20,-6.10,-2646.40,-222.50,200.00}},
	{"Avispa Country Club",         {-2361.50,-417.10,0.00,-2270.00,-355.40,200.00}},
	{"Avispa Country Club",         {-2667.80,-302.10,-28.80,-2646.40,-262.30,71.10}},
	{"Avispa Country Club",         {-2470.00,-355.40,0.00,-2270.00,-318.40,46.10}},
	{"Avispa Country Club",         {-2550.00,-355.40,0.00,-2470.00,-318.40,39.70}},
	{"Back o Beyond",               {-1166.90,-2641.10,0.00,-321.70,-1856.00,200.00}},
	{"Battery Point",               {-2741.00,1268.40,-4.50,-2533.00,1490.40,200.00}},
	{"Bayside",                     {-2741.00,2175.10,0.00,-2353.10,2722.70,200.00}},
	{"Bayside Marina",              {-2353.10,2275.70,0.00,-2153.10,2475.70,200.00}},
	{"Beacon Hill",                 {-399.60,-1075.50,-1.40,-319.00,-977.50,198.50}},
	{"Blackfield",                  {964.30,1203.20,-89.00,1197.30,1403.20,110.90}},
	{"Blackfield",                  {964.30,1403.20,-89.00,1197.30,1726.20,110.90}},
	{"Blackfield Chapel",           {1375.60,596.30,-89.00,1558.00,823.20,110.90}},
	{"Blackfield Chapel",           {1325.60,596.30,-89.00,1375.60,795.00,110.90}},
	{"Blackfield",     				{1197.30,1044.60,-89.00,1277.00,1163.30,110.90}},
	{"Blackfield",   				{1166.50,795.00,-89.00,1375.60,1044.60,110.90}},
	{"Blackfield",     				{1277.00,1044.60,-89.00,1315.30,1087.60,110.90}},
	{"Blackfield",     				{1375.60,823.20,-89.00,1457.30,919.40,110.90}},
	{"Blueberry",                   {104.50,-220.10,2.30,349.60,152.20,200.00}},
	{"Blueberry",                   {19.60,-404.10,3.80,349.60,-220.10,200.00}},
	{"Blueberry Acres",             {-319.60,-220.10,0.00,104.50,293.30,200.00}},
	{"Caligula's Palace",           {2087.30,1543.20,-89.00,2437.30,1703.20,110.90}},
	{"Caligula's Palace",           {2137.40,1703.20,-89.00,2437.30,1783.20,110.90}},
	{"Calton Heights",              {-2274.10,744.10,-6.10,-1982.30,1358.90,200.00}},
	{"Chinatown",                   {-2274.10,578.30,-7.60,-2078.60,744.10,200.00}},
	{"City Hall",                   {-2867.80,277.40,-9.10,-2593.40,458.40,200.00}},
	{"Castelo",           			{2087.30,943.20,-89.00,2623.10,1203.20,110.90}},
	{"Commerce",                    {1323.90,-1842.20,-89.00,1701.90,-1722.20,110.90}},
	{"Commerce",                    {1323.90,-1722.20,-89.00,1440.90,-1577.50,110.90}},
	{"Commerce",                    {1370.80,-1577.50,-89.00,1463.90,-1384.90,110.90}},
	{"Commerce",                    {1463.90,-1577.50,-89.00,1667.90,-1430.80,110.90}},
	{"Commerce",                    {1583.50,-1722.20,-89.00,1758.90,-1577.50,110.90}},
	{"Commerce",                    {1667.90,-1577.50,-89.00,1812.60,-1430.80,110.90}},
	{"Conference Center",           {1046.10,-1804.20,-89.00,1323.90,-1722.20,110.90}},
	{"Conference Center",           {1073.20,-1842.20,-89.00,1323.90,-1804.20,110.90}},
	{"Cranberry Station",           {-2007.80,56.30,0.00,-1922.00,224.70,100.00}},
	{"Creek",                       {2749.90,1937.20,-89.00,2921.60,2669.70,110.90}},
	{"Dillimore",                   {580.70,-674.80,-9.50,861.00,-404.70,200.00}},
	{"Doherty",                     {-2270.00,-324.10,-0.00,-1794.90,-222.50,200.00}},
	{"Doherty",                     {-2173.00,-222.50,-0.00,-1794.90,265.20,200.00}},
	{"San Fierro",                  {-1982.30,744.10,-6.10,-1871.70,1274.20,200.00}},
	{"San Fierro",                  {-1871.70,1176.40,-4.50,-1620.30,1274.20,200.00}},
	{"San Fierro",                  {-1700.00,744.20,-6.10,-1580.00,1176.50,200.00}},
	{"San Fierro",                  {-1580.00,744.20,-6.10,-1499.80,1025.90,200.00}},
	{"San Fierro",                  {-2078.60,578.30,-7.60,-1499.80,744.20,200.00}},
	{"San Fierro",                  {-1993.20,265.20,-9.10,-1794.90,578.30,200.00}},
	{"Downtown Los Santos",         {1463.90,-1430.80,-89.00,1724.70,-1290.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1430.80,-89.00,1812.60,-1250.90,110.90}},
	{"Downtown Los Santos",         {1463.90,-1290.80,-89.00,1724.70,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1384.90,-89.00,1463.90,-1170.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1250.90,-89.00,1812.60,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1170.80,-89.00,1463.90,-1130.80,110.90}},
	{"Downtown Los Santos",         {1378.30,-1130.80,-89.00,1463.90,-1026.30,110.90}},
	{"Downtown Los Santos",         {1391.00,-1026.30,-89.00,1463.90,-926.90,110.90}},
	{"Downtown Los Santos",         {1507.50,-1385.20,110.90,1582.50,-1325.30,335.90}},
	{"East Beach",                  {2632.80,-1852.80,-89.00,2959.30,-1668.10,110.90}},
	{"East Beach",                  {2632.80,-1668.10,-89.00,2747.70,-1393.40,110.90}},
	{"East Beach",                  {2747.70,-1668.10,-89.00,2959.30,-1498.60,110.90}},
	{"East Beach",                  {2747.70,-1498.60,-89.00,2959.30,-1120.00,110.90}},
	{"East Los Santos",             {2421.00,-1628.50,-89.00,2632.80,-1454.30,110.90}},
	{"East Los Santos",             {2222.50,-1628.50,-89.00,2421.00,-1494.00,110.90}},
	{"East Los Santos",             {2266.20,-1494.00,-89.00,2381.60,-1372.00,110.90}},
	{"East Los Santos",             {2381.60,-1494.00,-89.00,2421.00,-1454.30,110.90}},
	{"East Los Santos",             {2281.40,-1372.00,-89.00,2381.60,-1135.00,110.90}},
	{"East Los Santos",             {2381.60,-1454.30,-89.00,2462.10,-1135.00,110.90}},
	{"East Los Santos",             {2462.10,-1454.30,-89.00,2581.70,-1135.00,110.90}},
	{"Easter Basin",                {-1794.90,249.90,-9.10,-1242.90,578.30,200.00}},
	{"Easter Basin",                {-1794.90,-50.00,-0.00,-1499.80,249.90,200.00}},
	{"San Fierro Airport",          {-1499.80,-50.00,-0.00,-1242.90,249.90,200.00}},
	{"San Fierro Airport",          {-1794.90,-730.10,-3.00,-1213.90,-50.00,200.00}},
	{"San Fierro Airport",          {-1213.90,-730.10,0.00,-1132.80,-50.00,200.00}},
	{"San Fierro Airport",          {-1242.90,-50.00,0.00,-1213.90,578.30,200.00}},
	{"San Fierro Airport",          {-1213.90,-50.00,-4.50,-947.90,578.30,200.00}},
	{"San Fierro Airport",          {-1315.40,-405.30,15.40,-1264.40,-209.50,25.40}},
	{"San Fierro Airport",          {-1354.30,-287.30,15.40,-1315.40,-209.50,25.40}},
	{"San Fierro Airport",          {-1490.30,-209.50,15.40,-1264.40,-148.30,25.40}},
	{"Easter Bay Chemicals",        {-1132.80,-768.00,0.00,-956.40,-578.10,200.00}},
	{"Easter Bay Chemicals",        {-1132.80,-787.30,0.00,-956.40,-768.00,200.00}},
	{"El Castillo del Diablo",      {-464.50,2217.60,0.00,-208.50,2580.30,200.00}},
	{"El Castillo del Diablo",      {-208.50,2123.00,-7.60,114.00,2337.10,200.00}},
	{"El Castillo del Diablo",      {-208.50,2337.10,0.00,8.40,2487.10,200.00}},
	{"El Corona",                   {1812.60,-2179.20,-89.00,1970.60,-1852.80,110.90}},
	{"El Corona",                   {1692.60,-2179.20,-89.00,1812.60,-1842.20,110.90}},
	{"El Quebrados",                {-1645.20,2498.50,0.00,-1372.10,2777.80,200.00}},
	{"Esplanade East",              {-1620.30,1176.50,-4.50,-1580.00,1274.20,200.00}},
	{"Esplanade East",              {-1580.00,1025.90,-6.10,-1499.80,1274.20,200.00}},
	{"Esplanade East",              {-1499.80,578.30,-79.60,-1339.80,1274.20,20.30}},
	{"Esplanade North",             {-2533.00,1358.90,-4.50,-1996.60,1501.20,200.00}},
	{"Esplanade North",             {-1996.60,1358.90,-4.50,-1524.20,1592.50,200.00}},
	{"Esplanade North",             {-1982.30,1274.20,-4.50,-1524.20,1358.90,200.00}},
	{"Fallen Tree",                 {-792.20,-698.50,-5.30,-452.40,-380.00,200.00}},
	{"Fallow Bridge",               {434.30,366.50,0.00,603.00,555.60,200.00}},
	{"Fern Ridge",                  {508.10,-139.20,0.00,1306.60,119.50,200.00}},
	{"Financial",                   {-1871.70,744.10,-6.10,-1701.30,1176.40,300.00}},
	{"Fisher's Lagoon",             {1916.90,-233.30,-100.00,2131.70,13.80,200.00}},
	{"Flint ",          			{-187.70,-1596.70,-89.00,17.00,-1276.60,110.90}},
	{"Flint Range",                 {-594.10,-1648.50,0.00,-187.70,-1276.60,200.00}},
	{"Fort Carson",                 {-376.20,826.30,-3.00,123.70,1220.40,200.00}},
	{"Foster Valley",               {-2270.00,-430.20,-0.00,-2178.60,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-599.80,-0.00,-1794.90,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-1115.50,0.00,-1794.90,-599.80,200.00}},
	{"Foster Valley",               {-2178.60,-1250.90,0.00,-1794.90,-1115.50,200.00}},
	{"Frederick Bridge",            {2759.20,296.50,0.00,2774.20,594.70,200.00}},
	{"Gant Bridge",                 {-2741.40,1659.60,-6.10,-2616.40,2175.10,200.00}},
	{"Gant Bridge",                 {-2741.00,1490.40,-6.10,-2616.40,1659.60,200.00}},
	{"Ganton",                      {2222.50,-1852.80,-89.00,2632.80,-1722.30,110.90}},
	{"Ganton",                      {2222.50,-1722.30,-89.00,2632.80,-1628.50,110.90}},
	{"Garcia",                      {-2411.20,-222.50,-0.00,-2173.00,265.20,200.00}},
	{"Garcia",                      {-2395.10,-222.50,-5.30,-2354.00,-204.70,200.00}},
	{"Garver Bridge",               {-1339.80,828.10,-89.00,-1213.90,1057.00,110.90}},
	{"Garver Bridge",               {-1213.90,950.00,-89.00,-1087.90,1178.90,110.90}},
	{"Garver Bridge",               {-1499.80,696.40,-179.60,-1339.80,925.30,20.30}},
	{"Parque Gleen",                {1812.60,-1449.60,-89.00,1996.90,-1350.70,110.90}},
	{"Parque Gleen",                {1812.60,-1100.80,-89.00,1994.30,-973.30,110.90}},
	{"Parque Gleen",                {1812.60,-1350.70,-89.00,2056.80,-1100.80,110.90}},
	{"Green Palms",                 {176.50,1305.40,-3.00,338.60,1520.70,200.00}},
	{"Greenglass College",          {964.30,1044.60,-89.00,1197.30,1203.20,110.90}},
	{"Greenglass College",          {964.30,930.80,-89.00,1166.50,1044.60,110.90}},
	{"Hampton Barns",               {603.00,264.30,0.00,761.90,366.50,200.00}},
	{"Hankypanky Point",            {2576.90,62.10,0.00,2759.20,385.50,200.00}},
	{"Harry Gold Parkway",          {1777.30,863.20,-89.00,1817.30,2342.80,110.90}},
	{"Hashbury",                    {-2593.40,-222.50,-0.00,-2411.20,54.70,200.00}},
	{"Hilltop Farm",                {967.30,-450.30,-3.00,1176.70,-217.90,200.00}},
	{"Hunter Quarry",               {337.20,710.80,-115.20,860.50,1031.70,203.70}},
	{"Idlewood",                    {1812.60,-1852.80,-89.00,1971.60,-1742.30,110.90}},
	{"Idlewood",                    {1812.60,-1742.30,-89.00,1951.60,-1602.30,110.90}},
	{"Idlewood",                    {1951.60,-1742.30,-89.00,2124.60,-1602.30,110.90}},
	{"Idlewood",                    {1812.60,-1602.30,-89.00,2124.60,-1449.60,110.90}},
	{"Idlewood",                    {2124.60,-1742.30,-89.00,2222.50,-1494.00,110.90}},
	{"Idlewood",                    {1971.60,-1852.80,-89.00,2222.50,-1742.30,110.90}},
	{"Jefferson",                   {1996.90,-1449.60,-89.00,2056.80,-1350.70,110.90}},
	{"Jefferson",                   {2124.60,-1494.00,-89.00,2266.20,-1449.60,110.90}},
	{"Jefferson",                   {2056.80,-1372.00,-89.00,2281.40,-1210.70,110.90}},
	{"Jefferson",                   {2056.80,-1210.70,-89.00,2185.30,-1126.30,110.90}},
	{"Jefferson",                   {2185.30,-1210.70,-89.00,2281.40,-1154.50,110.90}},
	{"Jefferson",                   {2056.80,-1449.60,-89.00,2266.20,-1372.00,110.90}},
	{"Julius Thruway East",         {2623.10,943.20,-89.00,2749.90,1055.90,110.90}},
	{"Julius Thruway East",         {2685.10,1055.90,-89.00,2749.90,2626.50,110.90}},
	{"Julius Thruway East",         {2536.40,2442.50,-89.00,2685.10,2542.50,110.90}},
	{"Julius Thruway East",         {2625.10,2202.70,-89.00,2685.10,2442.50,110.90}},
	{"Julius Thruway North",        {2498.20,2542.50,-89.00,2685.10,2626.50,110.90}},
	{"Julius Thruway North",        {2237.40,2542.50,-89.00,2498.20,2663.10,110.90}},
	{"Julius Thruway North",        {2121.40,2508.20,-89.00,2237.40,2663.10,110.90}},
	{"Julius Thruway North",        {1938.80,2508.20,-89.00,2121.40,2624.20,110.90}},
	{"Julius Thruway North",        {1534.50,2433.20,-89.00,1848.40,2583.20,110.90}},
	{"Julius Thruway North",        {1848.40,2478.40,-89.00,1938.80,2553.40,110.90}},
	{"Julius Thruway North",        {1704.50,2342.80,-89.00,1848.40,2433.20,110.90}},
	{"Julius Thruway North",        {1377.30,2433.20,-89.00,1534.50,2507.20,110.90}},
	{"Julius Thruway South",        {1457.30,823.20,-89.00,2377.30,863.20,110.90}},
	{"Julius Thruway South",        {2377.30,788.80,-89.00,2537.30,897.90,110.90}},
	{"Julius Thruway West",         {1197.30,1163.30,-89.00,1236.60,2243.20,110.90}},
	{"Julius Thruway West",         {1236.60,2142.80,-89.00,1297.40,2243.20,110.90}},
	{"Juniper Hill",                {-2533.00,578.30,-7.60,-2274.10,968.30,200.00}},
	{"Juniper Hollow",              {-2533.00,968.30,-6.10,-2274.10,1358.90,200.00}},
	{"KACC. Military Fuels",     {2498.20,2626.50,-89.00,2749.90,2861.50,110.90}},
	{"Kincaid Bridge",              {-1339.80,599.20,-89.00,-1213.90,828.10,110.90}},
	{"Kincaid Bridge",              {-1213.90,721.10,-89.00,-1087.90,950.00,110.90}},
	{"Kincaid Bridge",              {-1087.90,855.30,-89.00,-961.90,986.20,110.90}},
	{"San Fierro",                  {-2329.30,458.40,-7.60,-1993.20,578.30,200.00}},
	{"San Fierro",                  {-2411.20,265.20,-9.10,-1993.20,373.50,200.00}},
	{"San Fierro",                  {-2253.50,373.50,-9.10,-1993.20,458.40,200.00}},
	{"LVA Freight Depot",           {1457.30,863.20,-89.00,1777.40,1143.20,110.90}},
	{"LVA Freight Depot",           {1375.60,919.40,-89.00,1457.30,1203.20,110.90}},
	{"LVA Freight Depot",           {1277.00,1087.60,-89.00,1375.60,1203.20,110.90}},
	{"LVA Freight Depot",           {1315.30,1044.60,-89.00,1375.60,1087.60,110.90}},
	{"LVA Freight Depot",           {1236.60,1163.40,-89.00,1277.00,1203.20,110.90}},
	{"Las Barrancas",               {-926.10,1398.70,-3.00,-719.20,1634.60,200.00}},
	{"Las Brujas",                  {-365.10,2123.00,-3.00,-208.50,2217.60,200.00}},
	{"Las Colinas",                 {1994.30,-1100.80,-89.00,2056.80,-920.80,110.90}},
	{"Las Colinas",                 {2056.80,-1126.30,-89.00,2126.80,-920.80,110.90}},
	{"Las Colinas",                 {2185.30,-1154.50,-89.00,2281.40,-934.40,110.90}},
	{"Las Colinas",                 {2126.80,-1126.30,-89.00,2185.30,-934.40,110.90}},
	{"Las Colinas",                 {2747.70,-1120.00,-89.00,2959.30,-945.00,110.90}},
	{"Las Colinas",                 {2632.70,-1135.00,-89.00,2747.70,-945.00,110.90}},
	{"Las Colinas",                 {2281.40,-1135.00,-89.00,2632.70,-945.00,110.90}},
	{"Las Payasadas",               {-354.30,2580.30,2.00,-133.60,2816.80,200.00}},
	{"Las Venturas Airport",        {1236.60,1203.20,-89.00,1457.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1203.20,-89.00,1777.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1143.20,-89.00,1777.40,1203.20,110.90}},
	{"Las Venturas Airport",        {1515.80,1586.40,-12.50,1729.90,1714.50,87.50}},
	{"Last Dime Motel",             {1823.00,596.30,-89.00,1997.20,823.20,110.90}},
	{"Leafy Hollow",                {-1166.90,-1856.00,0.00,-815.60,-1602.00,200.00}},
	{"Liberty City",                {-1000.00,400.00,1300.00,-700.00,600.00,1400.00}},
	{"Lil' Probe Inn",              {-90.20,1286.80,-3.00,153.80,1554.10,200.00}},
	{"Linden Side",                 {2749.90,943.20,-89.00,2923.30,1198.90,110.90}},
	{"Linden Station",              {2749.90,1198.90,-89.00,2923.30,1548.90,110.90}},
	{"Linden Station",              {2811.20,1229.50,-39.50,2861.20,1407.50,60.40}},
	{"Little Mexico",               {1701.90,-1842.20,-89.00,1812.60,-1722.20,110.90}},
	{"Little Mexico",               {1758.90,-1722.20,-89.00,1812.60,-1577.50,110.90}},
	{"Los Flores",                  {2581.70,-1454.30,-89.00,2632.80,-1393.40,110.90}},
	{"Los Flores",                  {2581.70,-1393.40,-89.00,2747.70,-1135.00,110.90}},
	{"Los Santos Airport",    		{1249.60,-2394.30,-89.00,1852.00,-2179.20,110.90}},
	{"Los Santos Airport",  		{1852.00,-2394.30,-89.00,2089.00,-2179.20,110.90}},
	{"Los Santos Airport",    		{1382.70,-2730.80,-89.00,2201.80,-2394.30,110.90}},
	{"Los Santos Airport",    		{1974.60,-2394.30,-39.00,2089.00,-2256.50,60.90}},
	{"Los Santos Airport",    		{1400.90,-2669.20,-39.00,2189.80,-2597.20,60.90}},
	{"Los Santos Airport",    		{2051.60,-2597.20,-39.00,2152.40,-2394.30,60.90}},
	{"Marina",                      {647.70,-1804.20,-89.00,851.40,-1577.50,110.90}},
	{"Marina",                      {647.70,-1577.50,-89.00,807.90,-1416.20,110.90}},
	{"Marina",                      {807.90,-1577.50,-89.00,926.90,-1416.20,110.90}},
	{"Market",                      {787.40,-1416.20,-89.00,1072.60,-1310.20,110.90}},
	{"Market",                      {952.60,-1310.20,-89.00,1072.60,-1130.80,110.90}},
	{"Market",                      {1072.60,-1416.20,-89.00,1370.80,-1130.80,110.90}},
	{"Market",                      {926.90,-1577.50,-89.00,1370.80,-1416.20,110.90}},
	{"Market Station",              {787.40,-1410.90,-34.10,866.00,-1310.20,65.80}},
	{"Martin Bridge",               {-222.10,293.30,0.00,-122.10,476.40,200.00}},
	{"Commerce",             		{-2994.40,-811.20,0.00,-2178.60,-430.20,200.00}},
	{"Montgomery",                  {1119.50,119.50,-3.00,1451.40,493.30,200.00}},
	{"Montgomery",                  {1451.40,347.40,-6.10,1582.40,420.80,200.00}},
	{"Montgomery",     				{1546.60,208.10,0.00,1745.80,347.40,200.00}},
	{"Montgomery",     				{1582.40,347.40,0.00,1664.60,401.70,200.00}},
	{"Mulholland",                  {1414.00,-768.00,-89.00,1667.60,-452.40,110.90}},
	{"Mulholland",                  {1281.10,-452.40,-89.00,1641.10,-290.90,110.90}},
	{"Mulholland",                  {1269.10,-768.00,-89.00,1414.00,-452.40,110.90}},
	{"Mulholland",                  {1357.00,-926.90,-89.00,1463.90,-768.00,110.90}},
	{"Mulholland",                  {1318.10,-910.10,-89.00,1357.00,-768.00,110.90}},
	{"Mulholland",                  {1169.10,-910.10,-89.00,1318.10,-768.00,110.90}},
	{"Mulholland",                  {768.60,-954.60,-89.00,952.60,-860.60,110.90}},
	{"Richman",                     {321.30,-768.00,-89.00,700.70,-674.80,110.90}},
	{"Robada",         				{-1119.00,1178.90,-89.00,-862.00,1351.40,110.90}},
	{"Roca Escalante",              {2237.40,2202.70,-89.00,2536.40,2542.50,110.90}},
	{"Roca Escalante",              {2536.40,2202.70,-89.00,2625.10,2442.50,110.90}},
	{"Rockshore East",              {2537.30,676.50,-89.00,2902.30,943.20,110.90}},
	{"Rockshore West",              {1997.20,596.30,-89.00,2377.30,823.20,110.90}},
	{"Rockshore West",              {2377.30,596.30,-89.00,2537.30,788.80,110.90}},
	{"Rodeo",                       {72.60,-1684.60,-89.00,225.10,-1544.10,110.90}},
	{"Rodeo",                       {72.60,-1544.10,-89.00,225.10,-1404.90,110.90}},
	{"Rodeo",                       {225.10,-1684.60,-89.00,312.80,-1501.90,110.90}},
	{"Rodeo",                       {225.10,-1501.90,-89.00,334.50,-1369.60,110.90}},
	{"Rodeo",                       {334.50,-1501.90,-89.00,422.60,-1406.00,110.90}},
	{"Rodeo",                       {312.80,-1684.60,-89.00,422.60,-1501.90,110.90}},
	{"Rodeo",                       {422.60,-1684.60,-89.00,558.00,-1570.20,110.90}},
	{"Rodeo",                       {558.00,-1684.60,-89.00,647.50,-1384.90,110.90}},
	{"Rodeo",                       {466.20,-1570.20,-89.00,558.00,-1385.00,110.90}},
	{"Rodeo",                       {422.60,-1570.20,-89.00,466.20,-1406.00,110.90}},
	{"Rodeo",                       {466.20,-1385.00,-89.00,647.50,-1235.00,110.90}},
	{"Rodeo",                       {334.50,-1406.00,-89.00,466.20,-1292.00,110.90}},
	{"Royal Casino",                {2087.30,1383.20,-89.00,2437.30,1543.20,110.90}},
	{"San Andreas Sound",           {2450.30,385.50,-100.00,2759.20,562.30,200.00}},
	{"San Fierro",                  {-2741.00,458.40,-7.60,-2533.00,793.40,200.00}},
	{"Santa Maria Beach",           {342.60,-2173.20,-89.00,647.70,-1684.60,110.90}},
	{"Santa Maria Beach",           {72.60,-2173.20,-89.00,342.60,-1684.60,110.90}},
	{"Shady Cabin",                 {-1632.80,-2263.40,-3.00,-1601.30,-2231.70,200.00}},
	{"Shady Creeks",                {-1820.60,-2643.60,-8.00,-1226.70,-1771.60,200.00}},
	{"Shady Creeks",                {-2030.10,-2174.80,-6.10,-1820.60,-1771.60,200.00}},
	{"Sobell Rail Yards",           {2749.90,1548.90,-89.00,2923.30,1937.20,110.90}},
	{"Spinybed",                    {2121.40,2663.10,-89.00,2498.20,2861.50,110.90}},
	{"Starfish Casino",             {2437.30,1783.20,-89.00,2685.10,2012.10,110.90}},
	{"Starfish Casino",             {2437.30,1858.10,-39.00,2495.00,1970.80,60.90}},
	{"Starfish Casino",             {2162.30,1883.20,-89.00,2437.30,2012.10,110.90}},
	{"Temple",                      {1252.30,-1130.80,-89.00,1378.30,-1026.30,110.90}},
	{"Temple",                      {1252.30,-1026.30,-89.00,1391.00,-926.90,110.90}},
	{"Temple",                      {1252.30,-926.90,-89.00,1357.00,-910.10,110.90}},
	{"Temple",                      {952.60,-1130.80,-89.00,1096.40,-937.10,110.90}},
	{"Temple",                      {1096.40,-1130.80,-89.00,1252.30,-1026.30,110.90}},
	{"Temple",                      {1096.40,-1026.30,-89.00,1252.30,-910.10,110.90}},
	{"The Camel's Toe",             {2087.30,1203.20,-89.00,2640.40,1383.20,110.90}},
	{"The Clown's Pocket",          {2162.30,1783.20,-89.00,2437.30,1883.20,110.90}},
	{"The Emerald Isle",            {2011.90,2202.70,-89.00,2237.40,2508.20,110.90}},
	{"The Farm",                    {-1209.60,-1317.10,114.90,-908.10,-787.30,251.90}},
	{"Four Dragons Casino",         {1817.30,863.20,-89.00,2027.30,1083.20,110.90}},
	{"The High Roller",             {1817.30,1283.20,-89.00,2027.30,1469.20,110.90}},
	{"The Mako Span",               {1664.60,401.70,0.00,1785.10,567.20,200.00}},
	{"The Panopticon",              {-947.90,-304.30,-1.10,-319.60,327.00,200.00}},
	{"The Pink Swan",               {1817.30,1083.20,-89.00,2027.30,1283.20,110.90}},
	{"The Sherman Dam",             {-968.70,1929.40,-3.00,-481.10,2155.20,200.00}},
	{"The Strip",                   {2027.40,863.20,-89.00,2087.30,1703.20,110.90}},
	{"The Strip",                   {2106.70,1863.20,-89.00,2162.30,2202.70,110.90}},
	{"The Strip",                   {2027.40,1783.20,-89.00,2162.30,1863.20,110.90}},
	{"The Strip",                   {2027.40,1703.20,-89.00,2137.40,1783.20,110.90}},
	{"The Visage",                  {1817.30,1863.20,-89.00,2106.70,2011.80,110.90}},
	{"The Visage",                  {1817.30,1703.20,-89.00,2027.40,1863.20,110.90}},
	{"Unity Station",               {1692.60,-1971.80,-20.40,1812.60,-1932.80,79.50}},
	{"Valle Ocultado",              {-936.60,2611.40,2.00,-715.90,2847.90,200.00}},
	{"Verdant Bluffs",              {930.20,-2488.40,-89.00,1249.60,-2006.70,110.90}},
	{"Verdant Bluffs",              {1073.20,-2006.70,-89.00,1249.60,-1842.20,110.90}},
	{"Verdant Bluffs",              {1249.60,-2179.20,-89.00,1692.60,-1842.20,110.90}},
	{"Verdant Meadows",             {37.00,2337.10,-3.00,435.90,2677.90,200.00}},
	{"Verona Beach",                {647.70,-2173.20,-89.00,930.20,-1804.20,110.90}},
	{"Verona Beach",                {930.20,-2006.70,-89.00,1073.20,-1804.20,110.90}},
	{"Verona Beach",                {851.40,-1804.20,-89.00,1046.10,-1577.50,110.90}},
	{"Verona Beach",                {1161.50,-1722.20,-89.00,1323.90,-1577.50,110.90}},
	{"Verona Beach",                {1046.10,-1722.20,-89.00,1161.50,-1577.50,110.90}},
	{"Vinewood",                    {787.40,-1310.20,-89.00,952.60,-1130.80,110.90}},
	{"Vinewood",                    {787.40,-1130.80,-89.00,952.60,-954.60,110.90}},
	{"Vinewood",                    {647.50,-1227.20,-89.00,787.40,-1118.20,110.90}},
	{"Vinewood",                    {647.70,-1416.20,-89.00,787.40,-1227.20,110.90}},
	{"Whitewood Estates",           {883.30,1726.20,-89.00,1098.30,2507.20,110.90}},
	{"Whitewood Estates",           {1098.30,1726.20,-89.00,1197.30,2243.20,110.90}},
	{"Willowfield",                 {1970.60,-2179.20,-89.00,2089.00,-1852.80,110.90}},
	{"Willowfield",                 {2089.00,-2235.80,-89.00,2201.80,-1989.90,110.90}},
	{"Willowfield",                 {2089.00,-1989.90,-89.00,2324.00,-1852.80,110.90}},
	{"Willowfield",                 {2201.80,-2095.00,-89.00,2324.00,-1989.90,110.90}},
	{"Willowfield",                 {2541.70,-1941.40,-89.00,2703.50,-1852.80,110.90}},
	{"Willowfield",                 {2324.00,-2059.20,-89.00,2541.70,-1852.80,110.90}},
	{"Willowfield",                 {2541.70,-2059.20,-89.00,2703.50,-1941.40,110.90}},
	{"Yellow Bell Station",         {1377.40,2600.40,-21.90,1492.40,2687.30,78.00}},
	// Citys Zones
	{"Los Santos",                  {44.60,-2892.90,-242.90,2997.00,-768.00,900.00}},
	{"Las Venturas",                {869.40,596.30,-242.90,2997.00,2993.80,900.00}},
	{"Bone County",                 {-480.50,596.30,-242.90,869.40,2993.80,900.00}},
	{"Tierra Robada",               {-2997.40,1659.60,-242.90,-480.50,2993.80,900.00}},
	{"Tierra Robada",               {-1213.90,596.30,-242.90,-480.50,1659.60,900.00}},
	{"San Fierro",                  {-2997.40,-1115.50,-242.90,-1213.90,1659.60,900.00}},
	{"Red County",                  {-1213.90,-768.00,-242.90,2997.00,596.30,900.00}},
	{"Flint County",                {-1213.90,-2892.90,-242.90,44.60,-768.00,900.00}},
	{"Whetstone",                   {-2997.40,-2892.90,-242.90,-1213.90,-1115.50,900.00}}
};

static 


	/**
	* Variável de salvamento dos dados do veículo do jogador.
	*/
	playerInfo[MAX_PLAYERS][E_VEHICLE_INFO],

	/**
	* Verifica se o jogador está vendo o velocímetro.
	*/
	bool:playerViewingSpeedometer[MAX_PLAYERS],

	/**
	* Variáveis das textdraws.
	*/
	Text:textGlobalSpeedometer[4],
	PlayerText:textPrivateSpeedometer[MAX_PLAYERS][E_TEXT_PRIVATE_SPEEDO]

;

/*
 * N A T I V E 
 * C A L L B A C K S
 ******************************************************************************
 */

/**
 * Inicia o Filterscript.
 * 
 * @param                 Não possui parâmetros.
 * @return                1 caso verdadeiro.
 */
public OnFilterScriptInit()
{
	PrintSystemLoaded("simpleSpeedometerSystem");

	CreateGlobalTDSpeedometer();

	return 1;
}

/**
 * Ativada ao usuário conectar no servidor.
 * 
 * @param playerid       ID do jogador.
 * @return               1 caso verdadeiro.
 */
public OnPlayerConnect(playerid)
{
	CreatePrivateTDSpeedometer(playerid);

	return 1;
}

/**
 * Ativada se o estado do jogador é alterado.
 * 
 * @param playerid       ID do jogador.
 * @param newstate       Novo estado.
 * @param oldstate       Antigo estado.
 * @return               1 caso verdadeiro.
 */
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	switch(newstate)
	{
		case PLAYER_STATE_DRIVER, PLAYER_STATE_PASSENGER:
		{
			if(!IsPlayerViewingSpeedometer(playerid))
			{
				ShowPlayerSpeedometer(playerid);
				return 1;			
			}
		}
	}

	switch(oldstate)
	{
		case PLAYER_STATE_DRIVER, PLAYER_STATE_PASSENGER:
		{
			if(IsPlayerViewingSpeedometer(playerid))
				HidePlayerSpeedometer(playerid);
		}
	}
	return 1;
}

/**
 * Ativada a cada 30 segundos..
 * 
 * @param playerid       ID do jogador.
 * @return               1 caso verdadeiro.
 */
public OnPlayerUpdate(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		playerInfo[playerid][E_VEHICLE_SPEED] = GetPlayerSpeed(playerid);
		UpdateVehicleSpeed(playerid);
	}

		
	return 1;
}

/**
 * Ativada ao usuário entrar em um veículo.
 * 
 * @param playerid       ID do jogador.
 * @param vehicleid      ID do veículo
 * @param ispassanger    Verifica se o jogador é passageiro.
 * @return               1 caso verdadeiro.
 */
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	new colorOne,
		colorTwo,
		Float:vehHealth
	;

	GetVehicleColor(vehicleid, colorOne, colorTwo);
	GetVehicleHealth(vehicleid, vehHealth);

	playerInfo[playerid][E_VEHICLE_MODELID] = GetVehicleModel(vehicleid);
	playerInfo[playerid][E_VEHICLE_COLOR_ONE] = colorOne;
	playerInfo[playerid][E_VEHICLE_COLOR_TWO] = colorTwo;
	playerInfo[playerid][E_VEHICLE_HEALTH] = floatround(vehHealth)/10;

	return 1;
}

/*
 * M Y
 * C A L L B A C K S
 ******************************************************************************
 */

/**
 * Verifica a vida de um veículo.
 * 
 * @param playerid       ID do jogador.
 * @param vehicleid      ID do veículo
 * @return               1 caso verdadeiro.
 */
public VerifyVehicleHealth(playerid, vehicleid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new Float:vehHealth,
			vehicleID = GetPlayerVehicleID(playerid)
		;

		GetVehicleHealth(vehicleID, vehHealth);

		playerInfo[playerid][E_VEHICLE_HEALTH] = floatround(vehHealth)/10;
		UpdateVehicleHealth(playerid);					
	}

	return 1;
}

/**
 * Verifica a localização do jogador.
 * 
 * @param playerid       ID do jogador.
 * @return               1 caso verdadeiro.
 */
public IsPlayerInZone(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new zone[MAX_ZONE_NAME];
	
		GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
	
		PlayerTextDrawSetStringFormat(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION], "%s", zone);
	
		PlayerTextDrawShow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION]);
	}
	return 1;
}

/*
 * F U N C T I O N S
 ******************************************************************************
 */

/**
 * Cria a textdraw global.
 * 
 * @param                não possui parâmetros.
 * @return               não retorna valores.
 */
static CreateGlobalTDSpeedometer()
{
	textGlobalSpeedometer[0] = TextDrawCreate(539.601928, 368.057769, "box");
	TextDrawLetterSize(textGlobalSpeedometer[0], 0.000000, 7.799994);
	TextDrawTextSize(textGlobalSpeedometer[0], 632.000000, 0.000000);
	TextDrawAlignment(textGlobalSpeedometer[0], 1);
	TextDrawColor(textGlobalSpeedometer[0], -1);
	TextDrawUseBox(textGlobalSpeedometer[0], 1);
	TextDrawBoxColor(textGlobalSpeedometer[0], -1077952513);
	TextDrawSetShadow(textGlobalSpeedometer[0], 0);
	TextDrawSetOutline(textGlobalSpeedometer[0], 0);
	TextDrawBackgroundColor(textGlobalSpeedometer[0], 255);
	TextDrawFont(textGlobalSpeedometer[0], 1);
	TextDrawSetProportional(textGlobalSpeedometer[0], 1);

	textGlobalSpeedometer[1] = TextDrawCreate(543.333374, 418.562896, "box");
	TextDrawLetterSize(textGlobalSpeedometer[1], 0.000000, 1.688667);
	TextDrawTextSize(textGlobalSpeedometer[1], 628.381347, 0.000000);
	TextDrawAlignment(textGlobalSpeedometer[1], 1);
	TextDrawColor(textGlobalSpeedometer[1], -1);
	TextDrawUseBox(textGlobalSpeedometer[1], 1);
	TextDrawBoxColor(textGlobalSpeedometer[1], 1718026239);
	TextDrawSetShadow(textGlobalSpeedometer[1], 0);
	TextDrawSetOutline(textGlobalSpeedometer[1], 0);
	TextDrawBackgroundColor(textGlobalSpeedometer[1], 255);
	TextDrawFont(textGlobalSpeedometer[1], 1);
	TextDrawSetProportional(textGlobalSpeedometer[1], 1);

	textGlobalSpeedometer[2] = TextDrawCreate(543.333374, 397.676422, "box");
	TextDrawLetterSize(textGlobalSpeedometer[2], 0.000000, 1.688667);
	TextDrawTextSize(textGlobalSpeedometer[2], 628.000000, 0.000000);
	TextDrawAlignment(textGlobalSpeedometer[2], 1);
	TextDrawColor(textGlobalSpeedometer[2], -1);
	TextDrawUseBox(textGlobalSpeedometer[2], 1);
	TextDrawBoxColor(textGlobalSpeedometer[2], 1718026239);
	TextDrawSetShadow(textGlobalSpeedometer[2], 0);
	TextDrawSetOutline(textGlobalSpeedometer[2], 0);
	TextDrawBackgroundColor(textGlobalSpeedometer[2], 255);
	TextDrawFont(textGlobalSpeedometer[2], 1);
	TextDrawSetProportional(textGlobalSpeedometer[2], 1);

	textGlobalSpeedometer[3] = TextDrawCreate(543.233398, 376.675140, "box_velo");
	TextDrawLetterSize(textGlobalSpeedometer[3], 0.000000, 1.688667);
	TextDrawTextSize(textGlobalSpeedometer[3], 628.099975, 0.000000);
	TextDrawAlignment(textGlobalSpeedometer[3], 1);
	TextDrawColor(textGlobalSpeedometer[3], -1);
	TextDrawUseBox(textGlobalSpeedometer[3], 1);
	TextDrawBoxColor(textGlobalSpeedometer[3], 1718026239);
	TextDrawSetShadow(textGlobalSpeedometer[3], 0);
	TextDrawSetOutline(textGlobalSpeedometer[3], 0);
	TextDrawBackgroundColor(textGlobalSpeedometer[3], 255);
	TextDrawFont(textGlobalSpeedometer[3], 1);
	TextDrawSetProportional(textGlobalSpeedometer[3], 1);
}

/**
 * Criam as textdraws privadas.
 * 
 * @param playerid       ID do jogador.
 * @return               não retorna valores.
 */
static CreatePrivateTDSpeedometer(playerid)
{
	textPrivateSpeedometer[playerid][E_SPEEDO_SPEED] = CreatePlayerTextDraw(playerid, 606.733520, 375.637054, "169 KM/h");
	PlayerTextDrawLetterSize(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED], 0.313333, 1.765925);
	PlayerTextDrawAlignment(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED], 3);
	PlayerTextDrawColor(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED], -1);
	PlayerTextDrawSetShadow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED], 0);
	PlayerTextDrawSetOutline(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED], 0);
	PlayerTextDrawBackgroundColor(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED], 255);
	PlayerTextDrawFont(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED], 1);
	PlayerTextDrawSetProportional(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED], 1);

	textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE] = CreatePlayerTextDraw(playerid, 536.333862, 317.634185, "");
	PlayerTextDrawLetterSize(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 90.000000, 90.000000);
	PlayerTextDrawAlignment(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 1);
	PlayerTextDrawColor(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], -1);
	PlayerTextDrawSetShadow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 0);
	PlayerTextDrawSetOutline(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 0);
	PlayerTextDrawBackgroundColor(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 0);
	PlayerTextDrawFont(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 5);
	PlayerTextDrawSetProportional(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 0);
	PlayerTextDrawSetPreviewModel(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 411);
	PlayerTextDrawSetPreviewRot(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 0.000000, 0.000000, 57.000000, 1.000000);
	PlayerTextDrawSetPreviewVehCol(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], 1, 1);

	textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION] = CreatePlayerTextDraw(playerid, 586.000061, 416.459289, "Las Venturas Airport");
	PlayerTextDrawLetterSize(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION], 0.259999, 1.844740);
	PlayerTextDrawAlignment(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION], 2);
	PlayerTextDrawColor(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION], -1);
	PlayerTextDrawSetShadow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION], 0);
	PlayerTextDrawSetOutline(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION], 0);
	PlayerTextDrawBackgroundColor(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION], 255);
	PlayerTextDrawFont(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION], 1);
	PlayerTextDrawSetProportional(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION], 1);
	
	textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH] = CreatePlayerTextDraw(playerid, 617.035217, 397.705841, "Lataria: 100%");
	PlayerTextDrawLetterSize(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH], 0.274333, 1.429924);
	PlayerTextDrawAlignment(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH], 3);
	PlayerTextDrawColor(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH], -1);
	PlayerTextDrawSetShadow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH], 0);
	PlayerTextDrawSetOutline(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH], 0);
	PlayerTextDrawBackgroundColor(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH], 255);
	PlayerTextDrawFont(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH], 1);
	PlayerTextDrawSetProportional(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH], 1);
}

/**
 * Exibe o velocímetro para um jogador.
 * 
 * @param playerid       ID do jogador.
 * @return               não retorna valores.
 */
static ShowPlayerSpeedometer(playerid)
{
	TextDrawShowForPlayer(playerid, textGlobalSpeedometer[0]);
	TextDrawShowForPlayer(playerid, textGlobalSpeedometer[1]);
	TextDrawShowForPlayer(playerid, textGlobalSpeedometer[2]);
	TextDrawShowForPlayer(playerid, textGlobalSpeedometer[3]);
	UpdatePlayerSpeedometer(playerid);
	
	playerInfo[playerid][E_VEHICLE_TIMER_HEALTH] = SetTimerEx("VerifyVehicleHealth", 200, true, "i", playerid);
	playerInfo[playerid][E_VEHICLE_TIMER_ZONE] = SetTimerEx("IsPlayerInZone", 1000, true, "i", playerid);

	playerViewingSpeedometer[playerid] = true;
}

/**
 * Esconde a textdraw do velocímetro.
 * 
 * @param playerid       ID do jogador.
 * @return               não retorna valores.
 */
static HidePlayerSpeedometer(playerid)
{
	TextDrawHideForPlayer(playerid, textGlobalSpeedometer[0]);
	TextDrawHideForPlayer(playerid, textGlobalSpeedometer[1]);
	TextDrawHideForPlayer(playerid, textGlobalSpeedometer[2]);
	TextDrawHideForPlayer(playerid, textGlobalSpeedometer[3]);

	PlayerTextDrawHide(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED]);		
	PlayerTextDrawHide(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE]);		
	PlayerTextDrawHide(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION]);		
	PlayerTextDrawHide(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH]);

	KillTimer(playerInfo[playerid][E_VEHICLE_TIMER_HEALTH]);
	KillTimer(playerInfo[playerid][E_VEHICLE_TIMER_ZONE]);

	playerViewingSpeedometer[playerid] = false;		
}

/**
 * Atualiza a textdraw do velocímetro.
 * 
 * @param playerid       ID do jogador.
 * @return               não retorna valores.
 */
static UpdatePlayerSpeedometer(playerid)
{
	PlayerTextDrawShow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED]);			
	PlayerTextDrawShow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_LOCATION]);		
	UpdateVehicleSpeedometer(playerid);
	UpdateVehicleHealth(playerid);
}

/**
 * Atualiza a textdraw do veículo.
 * 
 * @param playerid       ID do jogador.
 * @return               não retorna valores.
 */
static UpdateVehicleSpeedometer(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return;

	PlayerTextDrawSetPreviewModel(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], playerInfo[playerid][E_VEHICLE_MODELID]);
	PlayerTextDrawSetPreviewVehCol(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE], playerInfo[playerid][E_VEHICLE_COLOR_ONE], playerInfo[playerid][E_VEHICLE_COLOR_TWO]);

	PlayerTextDrawShow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_TYPE]);	
}

/**
 * Atualiza a textdraw de velocidade do veículo.
 * 
 * @param playerid       ID do jogador.
 * @return               não retorna valores.
 */
static UpdateVehicleSpeed(playerid)
{
	PlayerTextDrawSetStringFormat(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED], "%d KM/h", playerInfo[playerid][E_VEHICLE_SPEED]);

	PlayerTextDrawShow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_SPEED]);	
}

/**
 * Atualiza a textdraw de lataria do veículo.
 * 
 * @param playerid       ID do jogador.
 * @return               não retorna valores.
 */
static UpdateVehicleHealth(playerid)
{
	PlayerTextDrawSetStringFormat(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH], "Lataria: %d%%", playerInfo[playerid][E_VEHICLE_HEALTH]);

	PlayerTextDrawShow(playerid, textPrivateSpeedometer[playerid][E_SPEEDO_VEH_HEALTH]);
}

/**
 * Verifica se a textdraw está sendo exibida para o jogador.
 * 
 * @param playerid       ID do jogador.
 * @return               retorna se está exibindo ou não.
 */
static IsPlayerViewingSpeedometer(playerid)
	return playerViewingSpeedometer[playerid];

/*
 * C O M P L E M E N T S
 ******************************************************************************
 */

/**
 * Printa no Console o aviso do sistema carregado.
 * 
 * @param systemName[]       nome do sistema.
 * @return                   não retorna valores.
 */
static PrintSystemLoaded(systemName[])
{
	new splitter[100], size, i;

	size = ((strlen(systemName) < 13) ? (13) : (strlen(systemName)));

	for(i = 0; i < size; i++)
		splitter[i] = '-';

	format(splitter, sizeof(splitter), "%s------", splitter);

	printf("\n---------------%s", splitter);
	printf("      > %s loaded", systemName);
	print("      > Developed by Vithinn");
	printf("---------------%s\n", splitter);
}

/**
 * Verifica a localização do jogador.
 * 
 * @param playerid      ID do jogador.
 * @param zone          Zona.
 * @param zoneName      Nome da zona.
 * @return              retorna o nome da zona onde o jogador está localizado.
 */
stock GetPlayer2DZone(playerid, zone[], zoneName)
{
	new Float:posX,
		Float:posY,
		Float:posZ
	;
	
	GetPlayerPos(playerid, posX, posY, posZ);
	
	for(new i = 0; i != sizeof(sanAndreasZones); i++)
	{
		if(posX >= sanAndreasZones[i][E_ZONE_AREA][0] && posX <= sanAndreasZones[i][E_ZONE_AREA][3] && posY >= sanAndreasZones[i][E_ZONE_AREA][1] && posY <= sanAndreasZones[i][E_ZONE_AREA][4])
		{
			return format(zone, zoneName, sanAndreasZones[i][E_ZONE_NAME], 0);
		}
	}
	return 0;
}

/**
 * Verifica a velocidade do jogador.
 * 
 * @param playerid      ID do jogador.
 * @return              retorna a velocidade do jogador.
 */
stock GetPlayerSpeed(playerid)
{
	new Float:ST[4];

	if(IsPlayerInAnyVehicle(playerid))
		GetVehicleVelocity(GetPlayerVehicleID(playerid),ST[0],ST[1],ST[2]);

	else 
		GetPlayerVelocity(playerid,ST[0],ST[1],ST[2]);

	ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 179.28625;

	return floatround(ST[3]);
}

