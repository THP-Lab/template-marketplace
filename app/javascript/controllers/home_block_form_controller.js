import { Controller } from "@hotwired/stimulus"

// Gère l'affichage conditionnel des champs en fonction du type de bloc.
export default class extends Controller {
  static targets = ["blocType", "targetSection", "shopSection", "contentSection", "buttonSection", "targetSelect"]

  connect() {
    this.aboutOptions = this._parseOptions(this.targetSelectTarget.dataset.aboutOptions)
    this.repairOptions = this._parseOptions(this.targetSelectTarget.dataset.repairOptions)
    this.selectedValue = this.targetSelectTarget.dataset.selectedValue
    this.toggle()
  }

  toggle() {
    const type = this.blocTypeTarget.value
    this._toggleSection(this.targetSectionTarget, ["about", "repair"].includes(type))
    this._toggleSection(this.shopSectionTarget, type === "shop")
    this._toggleSection(this.contentSectionTarget, type === "custom")
    this._toggleSection(this.buttonSectionTarget, ["about", "repair", "shop"].includes(type))
    this._populateTargetOptions(type)
  }

  _toggleSection(element, visible) {
    element.classList.toggle("d-none", !visible)
    element.querySelectorAll("select, textarea, input").forEach((input) => {
      input.disabled = !visible
    })
  }

  _populateTargetOptions(type) {
    const select = this.targetSelectTarget
    const current = this.selectedValue || select.value
    let options = []

    if (type === "about") {
      options = this.aboutOptions
    } else if (type === "repair") {
      options = this.repairOptions
    }

    select.innerHTML = ""
    this._addOption(select, "", "— Aucune sélection —")

    options.forEach(([label, value]) => {
      this._addOption(select, value, label)
    })

    select.value = current
  }

  _addOption(select, value, label) {
    const opt = document.createElement("option")
    opt.value = value
    opt.textContent = label
    select.appendChild(opt)
  }

  _parseOptions(json) {
    try {
      return JSON.parse(json || "[]")
    } catch (_e) {
      return []
    }
  }
}
