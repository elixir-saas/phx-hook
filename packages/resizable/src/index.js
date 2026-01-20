export default function (options = {}) {
  let activeClass = options.activeClass || "resizing";
  let willSnapClass = options.willSnapClass || "will-snap";
  let resizeSize = options.resizeHandleSize || "4px";
  let resizeOffset = options.resizeHandleOffset || "-2px";

  let resizeHandleStyle = {
    right: {
      right: resizeOffset,
      width: resizeSize,
      top: "0px",
      bottom: "0px",
    },
    left: { left: resizeOffset, width: resizeSize, top: "0px", bottom: "0px" },
    bottom: {
      bottom: resizeOffset,
      height: resizeSize,
      left: "0px",
      right: "0px",
    },
    top: { top: resizeOffset, height: resizeSize, left: "0px", right: "0px" },
  };

  let resizeHandleCursorStyle = {
    right: "ew-resize",
    left: "ew-resize",
    bottom: "ns-resize",
    top: "ns-resize",
  };

  return {
    mounted() {
      this.style = {};

      this.handleMouseDown = this.handleMouseDown.bind(this);
      this.handleMouseUp = this.handleMouseUp.bind(this);
      this.handleMouseMove = this.handleMouseMove.bind(this);

      // Element that will be resized
      let resizeTarget = this.el.dataset["resizeTarget"]
        ? this.el.querySelector(this.el.dataset["resizeTarget"])
        : this.el;

      if (!resizeTarget) {
        throw new Error(
          `Query selector for data-resize-target did not return an element`,
        );
      }

      this.resizeTarget = resizeTarget;

      // Direction for the placement of the resize handle element
      let resizeFrom = this.el.dataset["resizeFrom"] || "right";

      let isValidPosition =
        resizeFrom === "right" ||
        resizeFrom === "left" ||
        resizeFrom === "bottom" ||
        resizeFrom === "top";

      if (!isValidPosition) {
        throw new Error(
          `data-resize-from must be "right", "left", "bottom", or "top", received: "${resizeFrom}"`,
        );
      }

      this.resizeFrom = resizeFrom;

      // Append the resize handle element
      this.appendResizeHandle();
    },

    updated() {
      // Re-add handle removed by LiveView
      this.appendResizeHandle();

      // Re-apply saved styles
      this.setVarProperty(this.varPropertyValue);
      Object.assign(this.resizeTarget.style, this.style);
    },

    destroyed() {
      document.body.style["cursor"] = "auto";

      document.removeEventListener("mouseup", this.handleMouseUp);
      document.removeEventListener("mousemove", this.handleMouseMove);
    },

    appendResizeHandle() {
      let style = resizeHandleStyle[this.resizeFrom];
      let handleEl = document.createElement("div");

      Object.assign(handleEl.style, {
        ...style,
        position: "absolute",
        opacity: 0,
        cursor: resizeHandleCursorStyle[this.resizeFrom],
      });

      this.resizeTarget.appendChild(handleEl);
      handleEl.addEventListener("mousedown", this.handleMouseDown);

      this.handleEl = handleEl;
    },

    setVarProperty(value) {
      if (!value) return;
      let propertyName = this.el.dataset["resizeVar"];
      if (propertyName) this.el.style.setProperty(propertyName, `${value}px`);
    },

    pushPosition(eventName) {
      let rect = this.resizeTarget.getBoundingClientRect();

      if (this.resizeFrom === "right" || this.resizeFrom === "left") {
        this.pushEvent(eventName, { width: rect.width });
      }

      if (this.resizeFrom === "bottom" || this.resizeFrom === "top") {
        this.pushEvent(eventName, { height: rect.height });
      }
    },

    handleMouseDown(event) {
      event.preventDefault();

      let rect = this.resizeTarget.getBoundingClientRect();

      this.snapped = false;
      this.initWidth = rect.width;
      this.initHeight = rect.height;
      this.clientInitX = event.clientX;
      this.clientInitY = event.clientY;

      this.el.classList.add(activeClass);
      document.body.style["cursor"] = resizeHandleCursorStyle[this.resizeFrom];

      document.addEventListener("mouseup", this.handleMouseUp);
      document.addEventListener("mousemove", this.handleMouseMove);
    },

    handleMouseUp() {
      let onSnap = this.el.dataset["onSnap"];
      if (onSnap && this.el.classList.contains(willSnapClass)) {
        liveSocket.execJS(this.el, onSnap);
      }

      this.el.classList.remove(activeClass);
      this.el.classList.remove(willSnapClass);
      document.body.style["cursor"] = "auto";

      let resizeEvent = this.el.dataset["resizeEvent"];
      if (resizeEvent) this.pushPosition(resizeEvent);

      document.removeEventListener("mouseup", this.handleMouseUp);
      document.removeEventListener("mousemove", this.handleMouseMove);
    },

    handleMouseMove(event) {
      let deltaX = this.clientInitX - event.clientX;
      let deltaY = this.clientInitY - event.clientY;

      let w;
      let h;

      // Handle each possible resize direction
      if (this.resizeFrom === "right") w = this.initWidth - deltaX;
      if (this.resizeFrom === "left") w = this.initWidth + deltaX;
      if (this.resizeFrom === "bottom") h = this.initHeight - deltaY;
      if (this.resizeFrom === "top") h = this.initHeight + deltaY;

      // Apply min/max width and height constraints
      let min = parseInt(this.el.dataset["resizeMin"]);
      let max = parseInt(this.el.dataset["resizeMax"]);

      // Store unclamped values for snap threshold check
      let rawW = w;
      let rawH = h;

      if (w && !isNaN(min) && w < min) w = min;
      if (h && !isNaN(min) && h < min) h = min;
      if (w && !isNaN(max) && w > max) w = max;
      if (h && !isNaN(max) && h > max) h = max;

      // Apply snap behavior with a trigger and threshold
      let onSnap = this.el.dataset["onSnap"];
      let onSnapReverse = this.el.dataset["onSnapReverse"];

      if (onSnap) {
        let snapThreshold = this.el.dataset["snapThreshold"]
          ? parseInt(this.el.dataset["snapThreshold"])
          : 1;

        let snap = false;
        if (rawW && !isNaN(min)) snap = min - rawW > snapThreshold;
        if (rawH && !isNaN(min)) snap = min - rawH > snapThreshold;

        let snapTrigger = this.el.dataset["snapTrigger"] || "mouseup";

        if (snapTrigger === "mouseup") {
          if (snap) {
            this.el.classList.add(willSnapClass);
          } else {
            this.el.classList.remove(willSnapClass);
          }
        }

        if (snapTrigger === "mousemove") {
          if (snap) {
            if (!this.snapped) {
              this.snapped = true;
              liveSocket.execJS(this.el, onSnap);
            }
          } else {
            if (this.snapped && onSnapReverse) {
              this.snapped = false;
              liveSocket.execJS(this.el, onSnapReverse);
            }
          }
        }
      }

      if (this.el.dataset["resizeVar"]) {
        this.varPropertyValue = w || h;
        this.setVarProperty(this.varPropertyValue);
      } else {
        let updates = {};
        if (w) updates.width = `${w}px`;
        if (h) updates.height = `${h}px`;

        Object.assign(this.style, updates);
        Object.assign(this.resizeTarget.style, this.style);
      }
    },
  };
}
