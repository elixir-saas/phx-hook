module.exports = function (options = {}) {
  const activeClass = options.activeClass || 'drop-active'

  return {
    mounted () {
      this.el.addEventListener('dragover', () => {
        this.el.classList.add(activeClass)
      })

      this.el.addEventListener('dragleave', () => {
        this.el.classList.remove(activeClass)
      })

      this.el.addEventListener('drop', () => {
        this.el.classList.remove(activeClass)
      })
    }
  }
}
