import { dependencies, sh } from "lib/utils";

// if (!dependencies("brightnessctl")) App.quit();
if (!dependencies("ddcutil")) App.quit();

// const get = (args: string) => Number(Utils.exec(`brightnessctl ${args}`));
// const screen = await bash`ls -w1 /sys/class/backlight | head -1`;
// const kbd = await bash`ls -w1 /sys/class/leds | head -1`;
const ddcGet = async () =>
  (await Utils.execAsync(`ddcutil getvcp 10 --brief`)).split(" ");

class Brightness extends Service {
  static {
    Service.register(
      this,
      {},
      {
        screen: ["float", "rw"],
        kbd: ["int", "rw"],
      }
    );
  }

  // #kbdMax = get(`--device ${kbd} max`);
  // #kbd = get(`--device ${kbd} get`);

  #screen: number;
  #screenMax: number;

  // get kbd() {
  //   return this.#kbd;
  // }
  get screen() {
    return this.#screen;
  }

  // set kbd(value: number) {
  //   if (value < 0 ?? value > this.#kbdMax) return;

  //   sh(`brightnessctl -d ${kbd} s ${value} -q`).then(() => {
  //     this.#kbd = value;
  //     this.changed("kbd");
  //   });
  // }

  set screen(percent: number) {
    if (percent < 0) percent = 0;
    if (percent > 1) percent = 1;

    sh(`ddcutil setvcp 10 ${Math.round(percent * this.#screenMax)}`).then(
      () => {
        this.#screen = percent;
        this.changed("screen");
      }
    );

    // sh(`brightnessctl set ${Math.floor(percent * 100)}% -q`).then(() => {
    //   this.#screen = percent;
    //   this.changed("screen");
    // });
  }

  changeRelative(percent: number, direction: "+" | "-") {
    if (percent < 0) percent = 0;
    if (percent > 100) percent = 100;

    const currentPercentage = this.#screen;
    if (direction === "+") this.#screen += percent / 100;
    else this.#screen -= percent / 100;
    this.changed("screen");

    sh(
      `ddcutil setvcp 10 ${direction} ${Math.round((percent / 100) * this.#screenMax)}`
    ).catch(() => {
      this.#screen = currentPercentage;
      this.changed("screen");
    });
  }

  constructor() {
    super();

    // this.#screenMax = get("max");
    // this.#screen = get("get") / get("max") ?? 1;

    ddcGet().then((values) => {
      this.#screenMax = Number(values[4]);
      this.#screen = Number(values[3]) / Number(values[4]) ?? 1;
    });

    // const screenPath = `/sys/class/backlight/${screen}/brightness`;
    // const kbdPath = `/sys/class/leds/${kbd}/brightness`;

    // Utils.monitorFile(screenPath, async (f) => {
    //   const v = await Utils.readFileAsync(f);
    //   this.#screen = Number(v) / this.#screenMax;
    //   this.changed("screen");
    // });

    // Utils.monitorFile(kbdPath, async (f) => {
    //   const v = await Utils.readFileAsync(f);
    //   this.#kbd = Number(v) / this.#kbdMax;
    //   this.changed("kbd");
    // });
  }
}

const brightness = new Brightness();

Object.assign(globalThis, { brightness });
export default brightness;
