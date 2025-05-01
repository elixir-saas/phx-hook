module.exports = function () {
  return {
    mounted() {
      this.handleClick = this.handleClick.bind(this);
      this.handleContextMenu = this.handleContextMenu.bind(this);

      window.addEventListener("click", this.handleClick);
      window.addEventListener("contextmenu", this.handleContextMenu);
    },

    destroy() {
      window.removeEventListener("click", this.handleClick);
      window.removeEventListener("contextmenu", this.handleContextMenu);
    },

    handleClick(event) {
      if (!this.el.contains(event.target)) {
        let hideJS = this.el.getAttribute("phx-remove");

        if (hideJS) {
          liveSocket.execJS(this.el, hideJS);
        } else {
          this.el.style.display = "none";
        }
      }
    },

    handleContextMenu(event) {
      if (event.target.contains(this.el)) {
        event.preventDefault();

        Object.assign(this.el.style, {
          display: "block",
          position: "absolute",
          top: `${event.pageY}px`,
          left: `${event.pageX}px`,
        });
      } else {
        this.el.style.display = "none";
      }
    },
  };
}
