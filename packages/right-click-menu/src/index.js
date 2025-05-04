module.exports = function () {
  return {
    opened: false,

    mounted() {
      this.handleClick = this.handleClick.bind(this);
      this.handleContextMenu = this.handleContextMenu.bind(this);

      window.addEventListener("click", this.handleClick);
      window.addEventListener("contextmenu", this.handleContextMenu);
    },

    destroyed() {
      window.removeEventListener("click", this.handleClick);
      window.removeEventListener("contextmenu", this.handleContextMenu);
    },

    handleClick(event) {
      if (this.opened && !this.el.contains(event.target)) {
        let hideJS = this.el.getAttribute("phx-remove");

        if (hideJS) {
          liveSocket.execJS(this.el, hideJS);
        } else {
          this.el.style.display = "none";
        }

        this.opened = false;
      }
    },

    handleContextMenu(event) {
      let show = false;
      let containerID = this.el.dataset["containerId"];

      if (containerID) {
        // Custom container, check if event.target is within container.
        let container = document.getElementById(containerID);
        if (!container) throw `Missing RightClickMenu container element with ID "${containerID}"`;
        show = container.contains(event.target)
      } else {
        // Infer container from event.target, check if has hook element as child.
        let container = event.target;
        show = new Array(...container.children).includes(this.el)
      }

      if (show) {
        event.preventDefault();

        Object.assign(this.el.style, {
          display: "block",
          position: "absolute",
          top: `${event.pageY}px`,
          left: `${event.pageX}px`,
        });

        let onShowJS = this.el.dataset["onShow"];

        if (onShowJS) {
          liveSocket.execJS(this.el, onShowJS);
        }
      } else {
        this.el.style.display = "none";
      }

      this.opened = show;
    },
  };
}
