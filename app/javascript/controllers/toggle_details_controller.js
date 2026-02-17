import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details"]

  toggle(event) {
    event.preventDefault()
    this.detailsTarget.classList.toggle("d-none")
  }
}
