export default function (options = {}) {
  const cancelEvent = options.cancelEvent || "phx:cancel";

  return {
    mounted() {
      this.handleCancel = this.handleCancel.bind(this);
      this.handleBeforeUnload = this.handleBeforeUnload.bind(this);

      this.el.addEventListener(cancelEvent, this.handleCancel);
      window.addEventListener("beforeunload", this.handleBeforeUnload);
    },

    destroyed() {
      window.removeEventListener("beforeunload", this.handleBeforeUnload);
    },

    handleCancel() {
      const cancelJS = this.el.dataset["onCancel"];

      if (cancelJS && this.hasUnsavedChanges()) {
        const confirmMessage =
          this.el.dataset["confirmMessage"] ||
          "Are you sure? You may have unsaved changes.";

        if (window.confirm(confirmMessage)) {
          liveSocket.execJS(this.el, cancelJS);
        }
      } else {
        liveSocket.execJS(this.el, cancelJS);
      }
    },

    handleBeforeUnload(event) {
      if (this.hasUnsavedChanges()) {
        event.preventDefault();

        // Included for legacy support, e.g. Chrome/Edge < 119
        event.returnValue = true;
      }
    },

    hasUnsavedChanges() {
      return this.el.dataset["hasUnsavedChanges"] !== undefined;
    },
  };
}
