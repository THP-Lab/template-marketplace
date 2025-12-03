import { Controller } from "@hotwired/stimulus"

// Simple modal to choose quantity before adding to cart
export default class extends Controller {
  static targets = ["dialog"]

  open(event) {
    event.preventDefault()
    this.dialogTarget.showModal()
  }

  close(event) {
    event.preventDefault()
    this.dialogTarget.close()
  }
}
