import "lib/session";
import "style/style";

import init from "lib/init";
import { forMonitors } from "lib/utils";
import options from "options";
import Bar from "widget/bar/Bar";
import ScreenCorners from "widget/bar/ScreenCorners";
import { setupDateMenu } from "widget/datemenu/DateMenu";
import Launcher from "widget/launcher/Launcher";
import NotificationPopups from "widget/notifications/NotificationPopups";
import OSD from "widget/osd/OSD";
import Overview from "widget/overview/Overview";
import PowerMenu from "widget/powermenu/PowerMenu";
import Verification from "widget/powermenu/Verification";
import { setupQuickSettings } from "widget/quicksettings/QuickSettings";
import SettingsDialog from "widget/settings/SettingsDialog";

App.config({
  onConfigParsed: () => {
    setupQuickSettings();
    setupDateMenu();
    init();
  },
  closeWindowDelay: {
    launcher: options.transition.value,
    overview: options.transition.value,
    quicksettings: options.transition.value,
    datemenu: options.transition.value,
  },
  windows: () => [
    ...forMonitors(Bar),
    ...forMonitors(NotificationPopups),
    ...forMonitors(ScreenCorners),
    ...forMonitors(OSD),
    Launcher(),
    Overview(),
    PowerMenu(),
    SettingsDialog(),
    Verification(),
  ],
});
