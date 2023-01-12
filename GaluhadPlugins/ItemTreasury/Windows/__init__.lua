
import (PLUGINDIR..".Windows.Item");
import (PLUGINDIR..".Windows.MainWin");
import (PLUGINDIR..".Windows.Scanner");

function DrawWindows()
	CreateDesktopIcon(_IMAGES.BACKGROUNDS.ICON);
	DrawItem();
	DrawMainWin();
	DrawScanWin();
end
