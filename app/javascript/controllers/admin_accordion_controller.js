import { Controller } from "@hotwired/stimulus"

// Lightweight accordion controller that works without Bootstrap's JS (Turbo-safe).
export default class extends Controller {
  static targets = ["button"]
  static values = { parent: String }

  connect() {
    const parentSelector = this.parentValue
    this.parentElement = (parentSelector && document.querySelector(parentSelector)) || this.element
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const button = event.currentTarget
    const targetSelector = button.dataset.bsTarget
    if (!targetSelector) return

    const target = document.querySelector(targetSelector)
    if (!target) return

    const isOpen = target.classList.contains("show")
    this.closeAll(target)

    if (!isOpen) {
      this.open(button, target)
    } else {
      this.close(button, target)
    }
  }

  closeAll(except = null) {
    if (!this.parentElement) return

    this.parentElement.querySelectorAll(".accordion-collapse").forEach((element) => {
      if (element === except) return
      this.close(this.findButtonFor(element), element)
    })
  }

  open(button, target) {
    target.classList.add("show")
    if (button) {
      button.classList.remove("collapsed")
      button.setAttribute("aria-expanded", "true")
    }
  }

  close(button, target) {
    target.classList.remove("show")
    if (button) {
      button.classList.add("collapsed")
      button.setAttribute("aria-expanded", "false")
    }
  }

  findButtonFor(collapseElement) {
    if (!collapseElement?.id || !this.parentElement) return null
    return this.parentElement.querySelector(`[data-bs-target="#${collapseElement.id}"]`)
  }
}
