import { Controller } from "@hotwired/stimulus"

// Show or hide the highlight-box fields based on the product option toggle.
export default class extends Controller {
  static targets = ["toggle", "fields", "itemToggle", "itemPanel", "documentToggle", "documentSelectGroup", "documentSelect"]

  connect() {
    this.update()
  }

  update() {
    const visible = this.toggleTarget.checked
    this.fieldsTarget.classList.toggle("d-none", !visible)
    this.fieldsTarget.querySelectorAll("input, textarea, select").forEach((input) => {
      if (input === this.toggleTarget) return
      if (input.dataset.productHighlightsFormTarget === "itemToggle") return
      input.disabled = !visible
    })
    this.itemToggleTargets.forEach((checkbox, index) => this.updateItem(index))
  }

  updateItem(eventOrIndex) {
    const index = typeof eventOrIndex === "number"
      ? eventOrIndex
      : Number(eventOrIndex.currentTarget.dataset.index)
    const panel = this.itemPanelTargets[index]
    if (!panel) return
    const itemEnabled = this.itemToggleTargets[index].checked
    const formEnabled = this.toggleTarget.checked
    const visible = formEnabled && itemEnabled

    panel.classList.toggle("is-open", visible)
    panel.classList.toggle("d-none", !visible)
    panel.setAttribute("aria-hidden", visible ? "false" : "true")
    panel.querySelectorAll("input, textarea, select").forEach((input) => {
      input.disabled = !visible
    })

    this.updateDocumentSelection(index)
  }

  updateDocumentSelection(eventOrIndex) {
    const index = typeof eventOrIndex === "number"
      ? eventOrIndex
      : Number(eventOrIndex.currentTarget.dataset.index)

    const documentToggle = this.documentToggleTargets[index]
    const documentSelectGroup = this.documentSelectGroupTargets[index]
    const documentSelect = this.documentSelectTargets[index]
    const highlightToggle = this.itemToggleTargets[index]
    if (!documentToggle || !documentSelectGroup || !highlightToggle) return

    const visible = this.toggleTarget.checked && highlightToggle.checked && documentToggle.checked
    documentSelectGroup.classList.toggle("d-none", !visible)
    if (documentSelect) {
      documentSelect.disabled = !visible
    }
  }
}
