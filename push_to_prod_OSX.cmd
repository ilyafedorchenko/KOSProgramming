rm "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\boot\*.ks" /Q
rm "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\execute_on_ship\*.ks" /Q
rm "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\KOSProgramming\recieved_from_ship\*.*" /Q

cp "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\recieved_from_ship\*.*" "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\KOSProgramming\recieved_from_ship\"  /Y
cp "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\KOSProgramming\execute_on_ship\*.ks" "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\execute_on_ship\" /Y
cp "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\KOSProgramming\boot\*.ks" "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\boot\" /Y

rm "D:\Program files\Steam\steamapps\common\Kerbal Space Program\Ships\Script\recieved_from_ship\*.*" /Q