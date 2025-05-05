export default function (options = {}) {
  const activeClass = options.activeClass || "drag-active";

  return {
    dragCounter: 0,

    mounted() {
      this.dropTarget =
        this.el.dataset["dragTarget"] === "window" ? window : this.el;

      this.handleDragEnter = this.handleDragEnter.bind(this);
      this.handleDragLeave = this.handleDragLeave.bind(this);
      this.handleDrop = this.handleDrop.bind(this);

      this.dropTarget.addEventListener("dragenter", this.handleDragEnter);
      this.dropTarget.addEventListener("dragleave", this.handleDragLeave);
      this.dropTarget.addEventListener("drop", this.handleDrop);
    },

    destroyed() {
      this.dropTarget.removeEventListener("dragenter", this.handleDragEnter);
      this.dropTarget.removeEventListener("dragleave", this.handleDragLeave);
      this.dropTarget.removeEventListener("drop", this.handleDrop);
    },

    handleDragEnter(event) {
      this.dragCounter++;

      if (Array.from(event.dataTransfer.types).includes("Files")) {
        this.el.classList.add(activeClass);
      }
    },

    handleDragLeave() {
      this.dragCounter--;

      if (this.dragCounter === 0) {
        this.el.classList.remove(activeClass);
      }
    },

    handleDrop() {
      this.dragCounter = 0;

      this.el.classList.remove(activeClass);
    },
  };
}
