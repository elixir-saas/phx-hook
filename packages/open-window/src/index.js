export default function (options = {}) {
  let defaults = options.defaults || {};
  let openEvent = options.openEvent || "phx:open";

  return {
    mounted() {
      this.handleOpen = this.handleOpen.bind(this);

      this.el.addEventListener(openEvent, this.handleOpen);
    },

    handleOpen() {
      let windowUrl = this.el.dataset["windowUrl"];
      let windowName = this.el.dataset["windowName"];
      let windowDimensions = this.el.dataset["windowDimensions"];

      window.open(windowUrl, windowName, objectToWindowOptions({
        ...defaults,
        ...decodeWindowDimensions(windowDimensions),
      }));
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
