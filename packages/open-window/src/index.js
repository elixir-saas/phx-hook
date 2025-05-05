export default function ({ defaults } = { defaults: {} }) {
  return {
    windowUrl() {
      return this.el.getAttribute("data-window-url");
    },

    windowName() {
      return this.el.getAttribute("data-window-name");
    },

    windowDimensionsOptions() {
      let dimensions = this.el.getAttribute("data-window-dimensions");

      if (dimensions) {
        let options = {};
        let split = dimensions.split(":");

        if (split.length >= 2) {
          options.width = parseInt(split[0]);
          options.height = parseInt(split[1]);
        }

        if (
          (split.length === 1 && split[0] === "center") ||
          (split.length === 3 && split[2] === "center")
        ) {
          options.left =
            window.top.outerWidth / 2 + window.top.screenX - options.width / 2;
          options.top =
            window.top.outerHeight / 2 +
            window.top.screenY -
            options.height / 2;
        }

        if (split.length === 4) {
          options.left = parseInt(split[2]);
          options.top = parseInt(split[3]);
        }

        return options;
      } else {
        return {};
      }
    },

    eventName() {
      return this.el.getAttribute("data-event");
    },

    // @impl true
    mounted() {
      let options = {
        ...defaults,
        ...this.windowDimensionsOptions(),
      };

      this.el.addEventListener("click", () => {
        window.open(
          this.windowUrl(),
          this.windowName(),
          objectToWindowOptions(options),
        );

        if (this.eventName()) {
          this.pushEvent(this.eventName(), {});
        }
      });
    },
  };
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
