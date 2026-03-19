import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]

  addRate() {
    if (!this.hasListTarget || !this.hasTemplateTarget) return

    const uniqueKey = `${Date.now()}${Math.floor(Math.random() * 100000)}`
    const templateHtml = this.templateTarget.innerHTML.replace(/NEW_SHIPPING_RATE/g, uniqueKey)
    this.listTarget.insertAdjacentHTML("beforeend", templateHtml)
  }

  removeRate(event) {
    const row = event.currentTarget.closest("[data-shipping-rates-form-item]")
    if (!row) return

    const destroyInput = row.querySelector("input[data-role='shipping-rate-destroy']")
    if (destroyInput) destroyInput.value = "1"

    row.classList.add("d-none")
  }
}
