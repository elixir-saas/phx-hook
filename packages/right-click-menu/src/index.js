export default function () {
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
        // Custom container, check if event.target is within container
        let container = document.getElementById(containerID);

        if (!container) {
          throw `Missing RightClickMenu container element with ID "${containerID}"`;
        }

        show = container.contains(event.target);
      } else {
        // Infer container from parentElement, check if event.target is within container
        show = this.el.parentElement.contains(event.target);
      }

      if (show) {
        event.preventDefault();

        // Position first, so that bounding client rect height is accurate
        Object.assign(this.el.style, {
          display: "block",
          position: "absolute",
        });

        let clientY = event.clientY;
        let clientX = event.clientX;
        let rect = this.el.getBoundingClientRect();

        // Position to top of cursor if would otherwise render outside window
        let top = event.pageY;
        if (clientY + rect.height > window.innerHeight) top -= rect.height;

        // Position to left of cursor if would otherwise render outside window
        let left = event.pageX;
        if (clientX + rect.width > window.innerWidth) left -= rect.width;

        Object.assign(this.el.style, {
          top: `${top}px`,
          left: `${left}px`,
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
