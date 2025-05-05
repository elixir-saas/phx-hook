export default function (options = {}) {
  return {
    mounted() {
      const activeClass =
        this.el.dataset["activeClass"] || options.activeClass || "drop-active";

      this.el.addEventListener("dragover", () => {
        this.el.classList.add(activeClass);
      });

      this.el.addEventListener("dragleave", () => {
        this.el.classList.remove(activeClass);
      });

      this.el.addEventListener("drop", () => {
        this.el.classList.remove(activeClass);
      });
    },
  };
}
