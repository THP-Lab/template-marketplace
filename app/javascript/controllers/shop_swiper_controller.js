import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wrapper", "slide", "scrollbar"]

  connect() {
    this.activeIndex = 0
    this.autoplayDelay = 3200
    this.boundRefresh = this.refresh.bind(this)

    window.addEventListener("resize", this.boundRefresh)
    this.observeImages()
    this.refresh()
    this.resume()
  }

  disconnect() {
    window.removeEventListener("resize", this.boundRefresh)
    this.pause()
  }

  next(event) {
    if (event) event.preventDefault()
    if (this.slideTargets.length <= 1) return

    this.activeIndex = (this.activeIndex + 1) % this.slideTargets.length
    this.update()
  }

  previous(event) {
    if (event) event.preventDefault()
    if (this.slideTargets.length <= 1) return

    this.activeIndex = (this.activeIndex - 1 + this.slideTargets.length) % this.slideTargets.length
    this.update()
  }

  advanceFromClick(event) {
    if (event.button !== 0) return
    if (event.target.closest("a, button")) return

    this.next()
  }

  wheel(event) {
    if (Math.abs(event.deltaY) < 8) return

    event.preventDefault()
    if (event.deltaY > 0) {
      this.next()
    } else {
      this.previous()
    }
  }

  pause() {
    if (!this.autoplayTimer) return

    clearInterval(this.autoplayTimer)
    this.autoplayTimer = null
  }

  resume() {
    this.pause()
    if (this.slideTargets.length <= 1) return

    this.autoplayTimer = setInterval(() => this.next(), this.autoplayDelay)
  }

  refresh() {
    const tallestSlide = this.slideTargets.reduce((maxHeight, slide) => {
      return Math.max(maxHeight, slide.offsetHeight)
    }, 0)

    if (tallestSlide > 0) {
      this.wrapperTarget.style.height = `${tallestSlide}px`
    }

    this.update()
  }

  update() {
    const total = this.slideTargets.length
    if (total === 0) return

    this.slideTargets.forEach((slide, index) => {
      slide.classList.remove(
        "is-active",
        "is-prev",
        "is-next",
        "is-prev-2",
        "is-next-2",
        "is-hidden-left",
        "is-hidden-right"
      )

      const offset = index - this.activeIndex

      if (offset === 0) {
        slide.classList.add("is-active")
      } else if (offset === -1) {
        slide.classList.add("is-prev")
      } else if (offset === 1) {
        slide.classList.add("is-next")
      } else if (offset === -2) {
        slide.classList.add("is-prev-2")
      } else if (offset === 2) {
        slide.classList.add("is-next-2")
      } else if (offset < 0) {
        slide.classList.add("is-hidden-left")
      } else {
        slide.classList.add("is-hidden-right")
      }
    })

    const progress = total > 1 ? this.activeIndex / (total - 1) : 0
    this.scrollbarTarget.style.setProperty("--shop-swiper-progress", progress)
  }

  observeImages() {
    this.element.querySelectorAll("img").forEach((image) => {
      if (image.complete) return
      image.addEventListener("load", this.boundRefresh, { once: true })
    })
  }
}
