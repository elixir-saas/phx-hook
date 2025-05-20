export default function () {
  return {
    mounted() {
      this.handleKeyDown = this.handleKeyDown.bind(this);
      this.handleMouseMove = this.handleMouseMove.bind(this);

      this.el.addEventListener("keydown", this.handleKeyDown);
      this.el.addEventListener("mousemove", this.handleMouseMove);
    },

    itemsList() {
      let selector = this.el.dataset["itemsSelector"];
      let itemEls = selector
        ? this.el.querySelectorAll(selector)
        : this.el.children;

      return [...itemEls];
    },

    focusCurrent() {
      let selector = this.el.dataset["focusSelector"];
      let focusEl = selector
        ? this.current.querySelector(selector)
        : this.current;

      if (focusEl) focusEl.focus();
    },

    handleKeyDown(event) {
      if (event.key === "ArrowDown" || event.key === "ArrowRight") {
        event.preventDefault();

        let items = this.itemsList();
        let index = -1;

        if (this.current && this.current.contains(document.activeElement)) {
          index = items.indexOf(this.current);
        }

        let homeSelector = this.el.dataset["homeSelector"];
        if (homeSelector && index === items.length - 1) {
          this.current = null;
          this.el.querySelector(homeSelector).focus();
        } else {
          this.current = items[Math.min(index + 1, items.length - 1)];
          this.focusCurrent();
        }

        return;
      }

      if (event.key === "ArrowUp" || event.key === "ArrowLeft") {
        event.preventDefault();

        let items = this.itemsList();
        let index = items.length;

        if (this.current && this.current.contains(document.activeElement)) {
          index = items.indexOf(this.current);
        }

        let homeSelector = this.el.dataset["homeSelector"];
        if (homeSelector && index === 0) {
          this.current = null;
          this.el.querySelector(homeSelector).focus();
        } else {
          this.current = items[Math.max(index - 1, 0)];
          this.focusCurrent();
        }

        return;
      }

      // Trigger click on an element when a specific "jump" key is used
      let jumpEl = this.el.querySelector(`[data-jump-key="${event.key}"]`);

      if (jumpEl) {
        event.preventDefault();
        jumpEl.click();
      }
    },

    handleMouseMove(event) {
      if (this.current && this.current.contains(event.target)) {
        return;
      }

      let items = this.itemsList();
      let item = items.find((item) => item.contains(event.target));

      if (item) {
        this.current = item;
        this.focusCurrent();
      }
    },
  };
}
