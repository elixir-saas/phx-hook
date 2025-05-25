export default function (options = {}) {
  let activeClass = options.activeClass || "cropping";
  let minSize = options.minSize || 50;
  let threshold = options.threshold || 10;

  return {
    mounted() {
      this.moving = false;

      // Bind event handlers
      this.handleInputChange = this.handleInputChange.bind(this);
      this.handleMouseDown = this.handleMouseDown.bind(this);
      this.handleMouseMove = this.handleMouseMove.bind(this);
      this.handleDocumentMouseMove = this.handleDocumentMouseMove.bind(this);
      this.handleDocumentMouseUp = this.handleDocumentMouseUp.bind(this);

      // Set up container element
      let containerId = this.el.dataset["cropContainerId"];
      this.containerEl = containerId
        ? document.getElementById(containerId)
        : this.el;

      if (!this.containerEl) {
        throw new Error(
          `@phx-hook/crop-image: Cound not find element #${containerId}`,
        );
      }

      if (this.containerEl.getAttribute("phx-update") !== "ignore") {
        console.warn(
          `@phx-hook/crop-image: Add phx-update="ignore" to your crop container element to prevent DOM overwriting`,
        );
      }

      // Set up canvas element
      this.appendCanvas();
      this.canvasEl.addEventListener("mousemove", this.handleMouseMove);
      this.canvasEl.addEventListener("mousedown", this.handleMouseDown);

      // Attempt to load image from data-crop-image-src attribute
      this.initImageSrc();

      // Listen for files to show in canvas if configured
      let fileInputId = this.el.dataset["cropFileInputId"];
      if (fileInputId) {
        let fileInputEl = document.getElementById(fileInputId);

        if (!fileInputEl || fileInputEl.type !== "file") {
          throw new Error(
            `@phx-hook/crop-image: Element #${fileInputId} is missing or is not a "file"-type input`,
          );
        }

        fileInputEl.addEventListener("change", this.handleInputChange);
      }
    },

    updated() {
      this.initImageSrc();

      if (this.active) {
        this.el.classList.add(activeClass);
        this.updateInputs();
      }
    },

    destroyed() {
      document.removeEventListener("mousemove", this.handleDocumentMouseMove);
      document.removeEventListener("mouseup", this.handleDocumentMouseUp);
    },

    appendCanvas() {
      let canvasEl = document.createElement("canvas");
      Object.assign(canvasEl.style, { width: "100%", height: "100%" });

      this.containerEl.appendChild(canvasEl);
      this.canvasEl = canvasEl;
    },

    initImageSrc() {
      // Initialize canvas from image src if configured
      let imageSrc = this.el.dataset["cropImageSrc"];
      if (imageSrc && imageSrc !== this.imageSrc) {
        this.imageSrc = imageSrc;
        this.initCanvasForImage(imageSrc);
      }
    },

    initCanvasForImage(src) {
      let image = new Image();

      image.addEventListener("load", () => {
        let size = Math.max(image.width, image.height);
        this.canvasEl.setAttribute("width", size);
        this.canvasEl.setAttribute("height", size);
        this.ctx = this.canvasEl.getContext("2d");

        // Avoid reading canvas dimensions before they are calculated
        requestAnimationFrame(() => {
          // Calculate pixel ratio between canvas and canvasEl
          let { width: pixelWidth } = this.canvasEl.getBoundingClientRect();
          let pr = size / pixelWidth;

          let yOffset = Math.max(0, image.width - image.height) / 2 / pr;
          let xOffset = Math.max(0, image.height - image.width) / 2 / pr;

          this.imagePos = {
            top: yOffset,
            bottom: yOffset,
            left: xOffset,
            right: xOffset,
            width: image.width / pr,
            height: image.height / pr,
          };

          this.pixelRatio = pr;
          this.image = image;

          this.setInitPos();
          this.updateInputs();
          this.draw();

          this.active = true;
          this.el.classList.add(activeClass);
        });
      });

      image.src = src;
    },

    setInitPos() {
      let initPos;

      let squareAspect = this.el.dataset["cropAspect"] === "square";
      if (squareAspect) {
        let imagePos = this.imagePos;
        let size = Math.min(imagePos.width, imagePos.height);

        initPos = {
          top: imagePos.top,
          bottom: imagePos.bottom + (imagePos.height - size),
          left: imagePos.left,
          right: imagePos.right + (imagePos.width - size),
          width: size,
          height: size,
        };
      } else {
        initPos = { ...this.imagePos };
      }

      this.pos = this.initPos = initPos;
    },

    updateInputs() {
      let inputs = this.el.querySelectorAll("input[data-crop-field]");
      let px = (i) => Math.round(i * this.pixelRatio);

      let left = px(this.pos.left - this.imagePos.left);
      let top = px(this.pos.top - this.imagePos.top);
      let width = px(this.pos.width);
      let height = px(this.pos.height);

      for (let i = 0; i < inputs.length; i++) {
        let inputEl = inputs[i];
        let cropField = inputEl.dataset["cropField"];
        if (cropField === "left") inputEl.value = left;
        if (cropField === "top") inputEl.value = top;
        if (cropField === "width") inputEl.value = width;
        if (cropField === "height") inputEl.value = height;
      }
    },

    draw() {
      if (!this.pos) return;

      let px = (i) => i * this.pixelRatio;

      // Clear draw space
      this.ctx.clearRect(0, 0, this.canvasEl.width, this.canvasEl.height);

      // Draw backdrop image
      this.ctx.drawImage(
        this.image,
        px(this.imagePos.left),
        px(this.imagePos.top),
        px(this.imagePos.width),
        px(this.imagePos.height),
      );

      // Draw opacity over backdrop image
      this.ctx.fillStyle = "rgba(0, 0, 0, 0.5)";
      this.ctx.fillRect(
        px(this.imagePos.left),
        px(this.imagePos.top),
        px(this.imagePos.width),
        px(this.imagePos.height),
      );

      // Draw light image inside crop area
      this.ctx.drawImage(
        this.image,
        px(this.pos.left - this.imagePos.left),
        px(this.pos.top - this.imagePos.top),
        px(this.pos.width),
        px(this.pos.height),
        px(this.pos.left),
        px(this.pos.top),
        px(this.pos.width),
        px(this.pos.height),
      );

      // Draw dashed border around crop area
      this.ctx.strokeStyle = "white";
      this.ctx.lineWidth = px(1);
      this.ctx.setLineDash([px(2), px(2)]);

      this.ctx.strokeRect(
        px(this.pos.left + 1),
        px(this.pos.top + 1),
        px(this.pos.width - 2),
        px(this.pos.height - 2),
      );
    },

    handleInputChange(event) {
      let file = event.target.files[0];
      if (file) {
        let src = URL.createObjectURL(file);
        this.initCanvasForImage(src);

        let onHasFile = this.el.dataset["onHasFile"];
        if (onHasFile) {
          liveSocket.execJS(this.el, onHasFile);
        }
      }
    },

    handleMouseDown(event) {
      if (!this.cursor) return;
      event.preventDefault();

      this.clientInitX = event.clientX;
      this.clientInitY = event.clientY;
      this.moving = true;

      document.addEventListener("mousemove", this.handleDocumentMouseMove);
      document.addEventListener("mouseup", this.handleDocumentMouseUp);
    },

    handleMouseMove(event) {
      if (this.moving || !this.pos) return;
      event.preventDefault();

      let rect = this.canvasEl.getBoundingClientRect();

      let top = rect.top + this.pos.top;
      let bottom = rect.bottom - this.pos.bottom;
      let left = rect.left + this.pos.left;
      let right = rect.right - this.pos.right;

      let dTop = event.clientY - top;
      let dBottom = bottom - event.clientY;
      let dLeft = event.clientX - left;
      let dRight = right - event.clientX;

      let active = (d) => d > 0 && d < threshold;

      let activeTop = active(dTop);
      let activeBottom = active(dBottom);
      let activeLeft = active(dLeft);
      let activeRight = active(dRight);

      let activeTopLeft = activeTop && activeLeft;
      let activeTopRight = activeTop && activeRight;
      let activeBottomLeft = activeBottom && activeLeft;
      let activeBottomRight = activeBottom && activeRight;

      let withinAll = dTop > 0 && dBottom > 0 && dLeft > 0 && dRight > 0;

      let cursor = (() => {
        if (activeTopLeft) return "nw-resize";
        if (activeTopRight) return "ne-resize";
        if (activeBottomLeft) return "sw-resize";
        if (activeBottomRight) return "se-resize";
        if (activeTop) return "n-resize";
        if (activeBottom) return "s-resize";
        if (activeLeft) return "w-resize";
        if (activeRight) return "e-resize";
        if (withinAll) return "move";
        return null;
      })();

      this.cursor = cursor;
      this.canvasEl.style.cursor = this.cursor || "auto";
    },

    handleDocumentMouseMove(event) {
      event.preventDefault();

      let cursor = this.cursor.replace("-resize", "");

      let deltaX = this.clientInitX - event.clientX;
      let deltaY = this.clientInitY - event.clientY;

      let imagePos = this.imagePos;
      let initTop = this.initPos.top - imagePos.top;
      let initBottom = this.initPos.bottom - imagePos.bottom;
      let initLeft = this.initPos.left - imagePos.left;
      let initRight = this.initPos.right - imagePos.right;

      let top = initTop;
      let bottom = initBottom;
      let left = initLeft;
      let right = initRight;

      // Apply boundary checks to maintain square aspect ratio
      let squareAspect = this.el.dataset["cropAspect"] === "square";
      if (squareAspect && cursor !== "move") {
        if (["n", "ne"].includes(cursor)) {
          top -= deltaY + Math.min(initRight - deltaY, 0);
          right -= deltaY + Math.min(initTop - deltaY, 0);
        }

        if (["s", "sw"].includes(cursor)) {
          bottom += deltaY - Math.min(initLeft + deltaY, 0);
          left += deltaY - Math.min(initBottom + deltaY, 0);
        }

        if (["w", "nw"].includes(cursor)) {
          left -= deltaX + Math.min(initTop - deltaX, 0);
          top -= deltaX + Math.min(initLeft - deltaX, 0);
        }

        if (["e", "se"].includes(cursor)) {
          right += deltaX - Math.min(initBottom + deltaX, 0);
          bottom += deltaX - Math.min(initRight + deltaX, 0);
        }
      } else {
        if (["move", "n", "nw", "ne"].includes(cursor)) top -= deltaY;
        if (["move", "s", "sw", "se"].includes(cursor)) bottom += deltaY;
        if (["move", "w", "nw", "sw"].includes(cursor)) left -= deltaX;
        if (["move", "e", "ne", "se"].includes(cursor)) right += deltaX;
      }

      // Apply min & max constraints
      let minMax = (val, min, max) => Math.max(Math.min(val, max), min);

      if (cursor === "move") {
        top = minMax(top, 0, imagePos.height - this.initPos.height);
        bottom = minMax(bottom, 0, imagePos.height - this.initPos.height);
        left = minMax(left, 0, imagePos.width - this.initPos.width);
        right = minMax(right, 0, imagePos.width - this.initPos.width);
      } else {
        top = minMax(top, 0, imagePos.height - initBottom - minSize);
        bottom = minMax(bottom, 0, imagePos.height - initTop - minSize);
        left = minMax(left, 0, imagePos.width - initRight - minSize);
        right = minMax(right, 0, imagePos.width - initLeft - minSize);
      }

      this.pos = {
        top: top + imagePos.top,
        bottom: bottom + imagePos.bottom,
        left: left + imagePos.left,
        right: right + imagePos.right,
        width: imagePos.width - left - right,
        height: imagePos.height - top - bottom,
      };

      this.draw();
    },

    handleDocumentMouseUp(event) {
      event.preventDefault();

      this.moving = false;
      this.initPos = this.pos;
      this.updateInputs();

      document.removeEventListener("mousemove", this.handleDocumentMouseMove);
      document.removeEventListener("mouseup", this.handleDocumentMouseUp);
    },
  };
}
