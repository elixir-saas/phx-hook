export default function (options = {}) {
  const copyEvent = options.copyEvent || "phx:copy";

  return {
    mounted() {
      this.handleCopy = this.handleCopy.bind(this);

      this.el.addEventListener(copyEvent, this.handleCopy);
    },

    handleCopy(event) {
      event.stopPropagation();

      let format = this.el.dataset["copyFormat"] || "plain";

      if (!(format === "plain" || format === "html")) {
        throw new Error(
          `data-copy-format must be "plain" or "html", received: "${format}"`,
        );
      }

      let dataPlain;
      let dataHTML;

      if (this.el.dataset["copyValue"] !== undefined) {
        dataPlain = dataHTML = this.el.dataset["copyValue"];
      } else {
        let copyEl;
        let copyContents = this.el.dataset["copyContents"];

        if (copyContents === "") {
          copyEl = this.el;
        } else if (copyContents !== undefined) {
          copyEl = this.el.querySelector(copyContents);
        }

        if (copyEl) {
          dataPlain = copyEl.innerText;
          dataHTML = copyEl.innerHTML;
        }
      }

      // If available, use the dispatcher element to communicate copy state
      let copierEl = event.detail.dispatcher || this.el;

      if (format === "plain" && dataPlain) {
        navigator.clipboard.writeText(dataPlain).then(() => {
          copierEl.dataset["copied"] = "copied";
        });
      } else if (format === "html" && dataPlain && dataHTML) {
        let clipboardItem = new ClipboardItem({
          "text/plain": new Blob([dataPlain], { type: "text/plain" }),
          "text/html": new Blob([dataHTML], { type: "text/html" }),
        });

        navigator.clipboard.write([clipboardItem]).then(() => {
          copierEl.dataset["copied"] = "copied";
        });
      }
    },
  };
}
