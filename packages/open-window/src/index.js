export default function (options = {}) {
  let defaults = options.defaults || {};
  let openEvent = options.openEvent || "phx:open";
  let closeEvent = options.openEvent || "phx:close";
  let onCloseInterval = options.onCloseInterval || 500;

  return {
    mounted() {
      this.windows = {};
      this.intervals = [];

      this.handleOpen = this.handleOpen.bind(this);
      this.handleClose = this.handleClose.bind(this);

      this.el.addEventListener(openEvent, this.handleOpen);
      this.el.addEventListener(closeEvent, this.handleClose);
    },

    destroyed() {
      for (let i = 0; i < this.intervals.length; i++) {
        clearInterval(this.intervals[i]);
      }
    },

    handleOpen() {
      let windowUrl = this.el.dataset["windowUrl"];
      let windowName = this.el.dataset["windowName"];
      let windowDimensions = this.el.dataset["windowDimensions"];

      let popup = window.open(
        windowUrl,
        windowName,
        objectToWindowOptions({
          ...defaults,
          ...decodeWindowDimensions(windowDimensions),
        }),
      );

      // Store the popup value to later close it
      this.windows[windowName] = popup;

      // Set up interval to detect when window is closed
      let onWindowClose = this.el.dataset["onWindowClose"];
      if (onWindowClose) {
        let interval = setInterval(() => {
          if (popup.closed) {
            clearInterval(interval);
            liveSocket.execJS(this.el, onWindowClose);
          }
        }, onCloseInterval);

        this.intervals.push(interval);
      }
    },

    handleClose(event) {
      let popup = this.windows[event.detail.name];
      if (popup && !popup.closed) popup.close();
    },
  };
}

function decodeWindowDimensions(dimensions) {
  let options = {};
  if (!dimensions) return options;

  let split = dimensions.split(":");

  if (split.length >= 2) {
    options.width = parseInt(split[0]);
    options.height = parseInt(split[1]);
  }

  if (
    (split.length === 1 && split[0] === "center") ||
    (split.length === 3 && split[2] === "center")
  ) {
    let top = window.top;
    options.left = top.outerWidth / 2 + top.screenX - options.width / 2;
    options.top = top.outerHeight / 2 + top.screenY - options.height / 2;
  }

  if (split.length === 4) {
    options.left = parseInt(split[2]);
    options.top = parseInt(split[3]);
  }

  return options;
}

function objectToWindowOptions(options) {
  let windowOptions = [];
  for (var option in options) {
    if (options[option]) {
      windowOptions.push(option + "=" + options[option]);
    }
  }
  return windowOptions.join(",");
}
