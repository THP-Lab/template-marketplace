import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rowTotal", "overallTotal"]
  static values = { currency: String }

  connect() {
    this.formatter = new Intl.NumberFormat("fr-FR", {
      style: "currency",
      currency: this.currencyValue || "EUR"
    })
  }

  handle(event) {
    const input = event.target
    const form = input.closest("form")

    this.updateRowTotal(input)
    this.updateOverallTotal()
    this.queueSubmit(form, input)
  }

  updateRowTotal(input) {
    const row = input.closest("tr")
    const rowTotalElement = row?.querySelector("[data-auto-submit-target='rowTotal']")
    const price = parseFloat(input.dataset.unitPrice)
    const quantity = parseInt(input.value, 10) || 0

    if (rowTotalElement && !Number.isNaN(price)) {
      rowTotalElement.textContent = this.format(price * quantity)
    }
  }

  updateOverallTotal() {
    let total = 0

    this.element.querySelectorAll("input[data-unit-price]").forEach((input) => {
      const price = parseFloat(input.dataset.unitPrice)
      const quantity = parseInt(input.value, 10) || 0

      if (!Number.isNaN(price)) {
        total += price * quantity
      }
    })

    if (this.hasOverallTotalTarget) {
      this.overallTotalTarget.textContent = this.format(total)
    }
  }

  queueSubmit(form, input) {
    if (!form) return

    const value = input.value
    if (value === "") {
      return
    }

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => form.requestSubmit(), 300)
  }

  format(amount) {
    return this.formatter.format(amount || 0)
  }
}
