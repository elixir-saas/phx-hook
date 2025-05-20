export default function (options = {}) {
  let activeClass = options.activeClass || "playing";
  let playEvent = options.playEvent || "phx:play";
  let pauseEvent = options.pauseEvent || "phx:pause";

  return {
    mounted() {
      this.audios = {};

      this.handlePlay = this.handlePlay.bind(this);
      this.handlePause = this.handlePause.bind(this);

      // Preload list of audio on mount to avoid network requests before playing
      let preload = this.el.dataset["preload"];
      if (preload) {
        preload.split(",").map((url) => new Audio(url));
      }

      this.el.addEventListener(playEvent, this.handlePlay);
      this.el.addEventListener(pauseEvent, this.handlePause);
    },

    initAudio(activeEl, audioPath) {
      let audio = new Audio(audioPath);

      let addClass = () => activeEl.classList.add(activeClass);
      let removeClass = () => activeEl.classList.remove(activeClass);

      audio.addEventListener("play", addClass);
      audio.addEventListener("ended", removeClass);
      audio.addEventListener("pause", removeClass);

      return audio;
    },

    handlePlay(event) {
      event.stopPropagation();

      let audioPath = event.detail["audio"];
      if (!audioPath) {
        throw new Error(
          `@phx-hook/audio requires an "audio" field in the dispatched event detail`,
        );
      }

      let activeEl =
        this.el.dataset["activeElement"] === "dispatcher"
          ? event.detail.dispatcher
          : this.el;

      let id = event.detail["id"];
      let audio =
        (id && this.audios[id]) || this.initAudio(activeEl, audioPath);
      if (id) this.audios[id] = audio;

      if (event.detail["restart"]) audio.currentTime = 0;
      audio.play();
    },

    handlePause(event) {
      let id = event.detail["id"];
      let audio = this.audios[id];

      if (audio) audio.pause();
    },
  };
}
