export default function (options = {}) {
  let activeClass = options.activeClass || "moving";
  let resizeClass = options.resizeClass || "resizing";
  let resizeSize = options.resizeCornerSize || "8px";
  let resizeOffset = options.resizeCornerOffset || "-4px";

  let resizeCornersStyle = [
    { top: resizeOffset, left: resizeOffset, cursor: "nwse-resize" },
    { top: resizeOffset, right: resizeOffset, cursor: "nesw-resize" },
    { bottom: resizeOffset, left: resizeOffset, cursor: "nesw-resize" },
    { bottom: resizeOffset, right: resizeOffset, cursor: "nwse-resize" },
  ];

  return {
    mounted() {
      this.style = { position: "absolute" };

      this.handleMouseDown = this.handleMouseDown.bind(this);
      this.handleMouseUp = this.handleMouseUp.bind(this);
      this.handleMouseMove = this.handleMouseMove.bind(this);
      this.handleCornerMouseUp = this.handleCornerMouseUp.bind(this);
      this.handleCornerMouseMove = this.handleCornerMouseMove.bind(this);

      let moveHandleEl = this.el.dataset["moveHandle"]
        ? this.el.querySelector(this.el.dataset["moveHandle"])
        : this.el;

      moveHandleEl.addEventListener("mousedown", this.handleMouseDown);

      this.appendResizeCorners();

      Object.assign(this.el.style, this.style);
    },

    updated() {
      // Re-add corners removed by LiveView
      this.appendResizeCorners();

      // Re-apply saved styles
      Object.assign(this.el.style, this.style);
    },

    destroyed() {
      document.removeEventListener("mouseup", this.handleMouseUp);
      document.removeEventListener("mousemove", this.handleMouseMove);
      document.removeEventListener("mouseup", this.handleCornerMouseUp);
      document.removeEventListener("mousemove", this.handleCornerMouseMove);
    },

    appendResizeCorners() {
      if (this.el.dataset["resizable"] === undefined) {
        return;
      }

      resizeCornersStyle.forEach((style, index) => {
        let cornerEl = document.createElement("div");

        cornerEl.dataset["index"] = index;

        Object.assign(cornerEl.style, {
          ...style,
          position: "absolute",
          width: resizeSize,
          height: resizeSize,
          opacity: 0,
        });

        this.el.appendChild(cornerEl);

        cornerEl.addEventListener("mousedown", (event) => {
          this.handleCornerMouseDown(event, cornerEl);
        });
      });
    },

    pushPosition(eventName) {
      let rect = this.el.getBoundingClientRect();
      let zIndex = parseInt(this.el.style.zIndex);

      this.pushEvent(eventName, {
        top: this.el.offsetTop,
        left: this.el.offsetLeft,
        width: rect.width,
        height: rect.height,
        z: isNaN(zIndex) ? null : zIndex,
      });
    },

    updateZGroupIndex() {
      let zGroup = this.el.dataset["zGroup"];
      if (zGroup) {
        let zMax = 0;
        let groupEls = document.querySelectorAll(`[data-z-group="${zGroup}"]`);

        for (let i = 0; i < groupEls.length; i++) {
          let el = groupEls[i];
          let zIndex = parseInt(el.style.zIndex);
          if (!isNaN(zIndex)) zMax = Math.max(zIndex, zMax);
        }

        if (this.el.style.zIndex === `${zMax}`) return;

        Object.assign(this.style, { zIndex: `${zMax + 1}` });
        Object.assign(this.el.style, this.style);
      }
    },

    handleMouseDown(event) {
      event.preventDefault();

      this.initOffsetTop = this.el.offsetTop;
      this.initOffsetLeft = this.el.offsetLeft;
      this.clientInitY = event.clientY;
      this.clientInitX = event.clientX;

      this.el.classList.add(activeClass);
      this.updateZGroupIndex();

      document.addEventListener("mouseup", this.handleMouseUp);
      document.addEventListener("mousemove", this.handleMouseMove);
    },

    handleMouseUp() {
      this.el.classList.remove(activeClass);

      let moveEvent = this.el.dataset["moveEvent"];
      if (moveEvent) this.pushPosition(moveEvent);

      document.removeEventListener("mouseup", this.handleMouseUp);
      document.removeEventListener("mousemove", this.handleMouseMove);
    },

    handleMouseMove(event) {
      let deltaY = this.clientInitY - event.clientY;
      let deltaX = this.clientInitX - event.clientX;

      let updates = {
        top: `${this.initOffsetTop - deltaY}px`,
        left: `${this.initOffsetLeft - deltaX}px`,
      };

      Object.assign(this.style, updates);
      Object.assign(this.el.style, this.style);
    },

    handleCornerMouseDown(event, cornerEl) {
      event.preventDefault();
      event.stopPropagation();

      this.initRect = this.el.getBoundingClientRect();
      this.initOffsetTop = this.el.offsetTop;
      this.initOffsetLeft = this.el.offsetLeft;
      this.clientInitX = event.clientX;
      this.clientInitY = event.clientY;

      this.activeCorner = cornerEl;
      this.el.classList.add(resizeClass);
      this.updateZGroupIndex();

      document.addEventListener("mouseup", this.handleCornerMouseUp);
      document.addEventListener("mousemove", this.handleCornerMouseMove);
    },

    handleCornerMouseUp(event, cornerEl) {
      this.activeCorner = null;
      this.el.classList.remove(resizeClass);

      let resizeEvent = this.el.dataset["resizeEvent"];
      if (resizeEvent) this.pushPosition(resizeEvent);

      document.removeEventListener("mouseup", this.handleCornerMouseUp);
      document.removeEventListener("mousemove", this.handleCornerMouseMove);
    },

    handleCornerMouseMove(event) {
      if (!this.activeCorner) {
        throw new Error("Missing active corner element for resize");
      }

      let cornerIndex = this.activeCorner.dataset["index"];
      let deltaY = this.clientInitY - event.clientY;
      let deltaX = this.clientInitX - event.clientX;

      let w;
      let h;
      let left;
      let top;

      // Handle top-left corner
      if (cornerIndex === "0") {
        w = this.initRect.width + deltaX;
        h = this.initRect.bottom - this.initRect.top + deltaY;
        left = this.initOffsetLeft - deltaX;
        top = this.initOffsetTop - deltaY;
      }

      // Handle top-right corner
      if (cornerIndex === "1") {
        w = this.initRect.width - deltaX;
        h = this.initRect.bottom - this.initRect.top + deltaY;
        top = this.initOffsetTop - deltaY;
      }

      // Handle bottom-left corner
      if (cornerIndex === "2") {
        w = this.initRect.width + deltaX;
        h = this.initRect.height - deltaY;
        left = this.initOffsetLeft - deltaX;
      }

      // Handle bottom-right corner
      if (cornerIndex === "3") {
        w = this.initRect.width - deltaX;
        h = this.initRect.height - deltaY;
      }

      // Apply aspect ratio
      let resizeAspect = this.el.dataset["resizeAspect"];

      if (resizeAspect) {
        let [aspectW, aspectH] = resizeAspect.split(":");

        aspectW = parseInt(aspectW);
        aspectH = parseInt(aspectH);

        if (isNaN(aspectW)) {
          throw new Error(`Invalid aspect width: ${aspectW}`);
        }
        if (isNaN(aspectH)) {
          throw new Error(`Invalid aspect height: ${aspectH}`);
        }

        let ratio = aspectW / aspectH;

        if (w) {
          let offset = parseInt(this.el.dataset["resizeAspectOffset"]);
          if (isNaN(offset)) offset = 0;

          h = w / ratio + offset;

          if (cornerIndex === "0") {
            top = this.initOffsetTop - deltaX / ratio;
          }
          if (cornerIndex === "1") {
            top = this.initOffsetTop + deltaX / ratio;
          }
        } else {
          h = top = undefined;
        }
      }

      // Apply min width and height constraints
      let minWidth = parseInt(this.el.dataset["resizeMinWidth"]);
      let minHeight = parseInt(this.el.dataset["resizeMinHeight"]);

      if (!isNaN(minWidth) && w < minWidth) {
        w = minWidth;
        left = undefined;
      }

      if (!isNaN(minHeight) && h < minHeight) {
        h = minHeight;
        top = undefined;
      }

      // Apply max width and height constraints
      let maxWidth = parseInt(this.el.dataset["resizeMaxWidth"]);
      let maxHeight = parseInt(this.el.dataset["resizeMaxHeight"]);

      if (!isNaN(maxWidth) && w > maxWidth) {
        w = maxWidth;
        left = undefined;
      }

      if (!isNaN(maxHeight) && h > maxHeight) {
        h = maxHeight;
        top = undefined;
      }

      // Apply calculated style updates
      let updates = {
        width: `${w}px`,
        height: `${h}px`,
      };

      if (left) updates.left = `${left}px`;
      if (top) updates.top = `${top}px`;

      Object.assign(this.style, updates);
      Object.assign(this.el.style, this.style);
    },
  };
}
