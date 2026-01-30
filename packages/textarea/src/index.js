export default function (options = {}) {
  let defaultMaxHeight = options.defaultMaxHeight || Infinity;

  return {
    mounted() {
      if (!(this.el instanceof HTMLTextAreaElement)) {
        throw new Error(
          `@phx-hook/textarea may only be used with a <textarea> element`,
        );
      }

      this.handleInput = this.handleInput.bind(this);
      this.handleKeyDown = this.handleKeyDown.bind(this);

      this.el.addEventListener("input", this.handleInput);
      this.el.addEventListener("keydown", this.handleKeyDown);

      // Store initial height of element as the lower bound for resizing
      let rect = this.el.getBoundingClientRect();
      this.initHeight = rect.height;
    },

    updated() {
      // Recalculate height whenever element is updated
      this.handleInput();
    },

    handleInput() {
      // Apply max height constraint
      let maxHeight = parseInt(this.el.dataset["maxHeight"]);
      if (isNaN(maxHeight)) maxHeight = defaultMaxHeight;

      // Temporarily set height to "auto" to ensure accurate scrollHeight
      this.el.style.height = "auto";

      let height = this.el.scrollHeight;
      height = Math.min(height, maxHeight);
      height = Math.max(height, this.initHeight);

      this.el.style.height = `${height}px`;
    },

    handleKeyDown(event) {
      // Prevent form submission when shift key is held down
      if (event.key === "Enter" && !event.shiftKey) {
        let submitOnEnter = this.el.dataset["submitOnEnter"] !== undefined;

        // Allow form submission when meta key is held down
        if ((submitOnEnter || event.metaKey) && event.target.form) {
          event.preventDefault();

          // Submit form, allowing LiveView to handle the submission
          event.target.form.requestSubmit();

          // Execute custom JS command if specified
          let onSubmit = this.el.dataset["onSubmit"];
          if (onSubmit) liveSocket.execJS(this.el, onSubmit);
        }
      }
    },
  };
}
