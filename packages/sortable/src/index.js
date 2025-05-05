export default function (Sortable, opts = {}) {
  return {
    mounted() {
      let config = processConfig(opts, {
        group: data(this.el, "group"),
        delay: data(this.el, "delay", "integer"),
        delayOnTouchOnly: data(this.el, "delayOnTouchOnly", "boolean"),
        touchStartThreshold: data(this.el, "touchStartThreshold", "boolean"),
        disabled: data(this.el, "disabled", "boolean"),
        animation: data(this.el, "animation", "integer"),
        easing: data(this.el, "easing"),
        handle: data(this.el, "handle"),
        filter: data(this.el, "filter"),
        preventOnFilter: data(this.el, "preventOnFilter", "boolean"),
        draggable: data(this.el, "draggable"),
        dataIdAttr: data(this.el, "dataIdAttr"),
        ghostClass: data(this.el, "ghostClass"),
        chosenClass: data(this.el, "chosenClass"),
        dragClass: data(this.el, "dragClass"),
        swapThreshold: data(this.el, "swapThreshold", "integer"),
        invertSwap: data(this.el, "invertSwap", "boolean"),
        invertedSwapThreshold: data(
          this.el,
          "invertedSwapThreshold",
          "integer",
        ),
        direction: data(this.el, "direction"),
        forceFallback: data(this.el, "forceFallback", "boolean"),
        fallbackClass: data(this.el, "fallbackClass"),
        fallbackOnBody: data(this.el, "fallbackOnBody", "boolean"),
        fallbackTolerance: data(this.el, "fallbackTolerance", "integer"),
        dragoverBubble: data(this.el, "dragoverBubble", "boolean"),
        removeCloneOnHide: data(this.el, "removeCloneOnHide", "boolean"),
        emptyInsertThreshold: data(this.el, "emptyInsertThreshold", "integer"),
      });

      new Sortable(this.el, {
        ...config,

        onChoose: (event) => {
          opts.onChoose && opts.onChoose(event);
        },

        onUnchoose: (event) => {
          opts.onUnchoose && opts.onUnchoose(event);
        },

        onStart: (event) => {
          opts.onStart && opts.onStart(event);
        },

        onEnd: (event) => {
          opts.onEnd && opts.onEnd(event);

          let pushEvent = this.el.dataset["onEnd"];

          if (pushEvent) {
            let prevSibling = event.item.previousElementSibling;
            let nextSibling = event.item.nextElementSibling;

            this.pushEventTo(this.el, pushEvent, {
              group_id: event.to.dataset["groupId"],
              item_id: event.item.dataset["itemId"],
              prev_item_id: prevSibling && prevSibling.dataset["itemId"],
              next_item_id: nextSibling && nextSibling.dataset["itemId"],
            });
          }
        },

        onAdd: (event) => {
          opts.onAdd && opts.onAdd(event);
        },

        onUpdate: (event) => {
          opts.onUpdate && opts.onUpdate(event);
        },

        onSort: (event) => {
          opts.onSort && opts.onSort(event);
        },

        onRemove: (event) => {
          opts.onRemove && opts.onRemove(event);
        },

        onFilter: (event) => {
          opts.onFilter && opts.onFilter(event);
        },

        onMove: (event) => {
          opts.onMove && opts.onMove(event);
        },

        onClone: (event) => {
          opts.onClone && opts.onClone(event);
        },

        onChange: (event) => {
          opts.onChange && opts.onChange(event);
        },
      });
    },
  };
}

// Helpers

function processConfig(opts, obj) {
  let result = {};
  for (let key in obj) {
    if (obj[key] !== undefined) {
      result[key] = obj[key];
    } else if (opts[key] !== undefined) {
      result[key] = opts[key];
    }
  }
  return result;
}

function data(el, name, type) {
  let value = el.dataset[name];
  if (value === undefined) return undefined;
  if (type === "boolean") return true && value !== "false";
  if (type === "integer") return parseInt(value);
  return value;
}
