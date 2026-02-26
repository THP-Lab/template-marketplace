import { Controller } from "@hotwired/stimulus"

// Gère l'affichage conditionnel des champs en fonction du type de bloc.
export default class extends Controller {
  static targets = [
    "blocType",
    "targetSection",
    "shopSection",
    "contentSection",
    "splitOptionsSection",
    "buttonSection",
    "imageSection",
    "targetSelect"
  ]

  connect() {
    this.aboutOptions = this.hasTargetSelectTarget ? this._parseOptions(this.targetSelectTarget.dataset.aboutOptions) : []
    this.repairOptions = this.hasTargetSelectTarget ? this._parseOptions(this.targetSelectTarget.dataset.repairOptions) : []
    this.selectedValue = this.hasTargetSelectTarget ? this.targetSelectTarget.dataset.selectedValue : null
    this.toggle()
  }

  toggle() {
    if (!this.hasBlocTypeTarget) return

    const type = this.blocTypeTarget.value
    const isShop = type === "shop"
    const isCustom = type === "custom"

    this._toggleIfPresent("targetSection", ["about", "repair"].includes(type))
    this._toggleIfPresent("shopSection", isShop)
    this._toggleIfPresent("contentSection", isCustom)
    this._toggleIfPresent("splitOptionsSection", isCustom)
    this._toggleIfPresent("buttonSection", !isCustom)
    this._toggleIfPresent("imageSection", isCustom)
    this._populateTargetOptions(type)
  }

  _toggleSection(element, visible) {
    element.classList.toggle("d-none", !visible)
    element.hidden = !visible
    element.setAttribute("aria-hidden", (!visible).toString())
    element.querySelectorAll("select, textarea, input").forEach((input) => {
      input.disabled = !visible
    })
  }

  _populateTargetOptions(type) {
    if (!this.hasTargetSelectTarget) return

    const select = this.targetSelectTarget
    const current = select.value || this.selectedValue
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
    this.selectedValue = null
  }

  _toggleIfPresent(targetName, visible) {
    const hasTargetMethod = `has${this._capitalize(targetName)}Target`
    const targetMethod = `${targetName}Target`
    if (!this[hasTargetMethod]) return

    this._toggleSection(this[targetMethod], visible)
  }

  _capitalize(value) {
    return value.charAt(0).toUpperCase() + value.slice(1)
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
