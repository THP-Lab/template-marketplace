import { Controller } from "@hotwired/stimulus"

// Handles dynamic product options (size, color, custom) in admin product form.
export default class extends Controller {
  static targets = ["toggle", "fields", "optionsList", "optionTemplate"]

  connect() {
    this.updateVisibility()
  }

  updateVisibility() {
    if (!this.hasToggleTarget || !this.hasFieldsTarget) return

    const visible = this.toggleTarget.checked
    this.fieldsTarget.classList.toggle("d-none", !visible)
    this.optionItems().forEach((optionElement) => this.syncOption(optionElement, visible))
  }

  addOption() {
    if (!this.hasOptionTemplateTarget || !this.hasOptionsListTarget) return

    this.toggleTarget.checked = true
    this.fieldsTarget.classList.remove("d-none")

    const uniqueKey = this.generateKey()
    const templateHtml = this.optionTemplateTarget.innerHTML
      .replace(/NEW_OPTION/g, uniqueKey)

    this.optionsListTarget.insertAdjacentHTML("beforeend", templateHtml)

    const addedOption = this.optionsListTarget.lastElementChild
    if (addedOption) {
      this.appendValue(addedOption)
      this.syncOption(addedOption, true)
    }
  }

  removeOption(event) {
    const optionElement = event.currentTarget.closest("[data-product-options-form-item]")
    if (!optionElement) return

    const destroyInput = optionElement.querySelector("input[data-role='option-destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
    }

    this.syncOption(optionElement, this.toggleTarget.checked)
  }

  addValue(event) {
    const optionElement = event.currentTarget.closest("[data-product-options-form-item]")
    if (!optionElement) return

    this.appendValue(optionElement)

    this.syncOption(optionElement, this.toggleTarget.checked)
  }

  removeValue(event) {
    const valueElement = event.currentTarget.closest("[data-product-options-form-value]")
    if (!valueElement) return

    const destroyInput = valueElement.querySelector("input[data-role='value-destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
    }

    const optionElement = event.currentTarget.closest("[data-product-options-form-item]")
    if (optionElement) {
      this.syncOption(optionElement, this.toggleTarget.checked)
    }
  }

  optionKindChanged(event) {
    const optionElement = event.currentTarget.closest("[data-product-options-form-item]")
    if (!optionElement) return

    const nameInput = optionElement.querySelector("input[data-role='option-name']")
    const kindSelect = optionElement.querySelector("select[data-role='option-kind']")
    if (nameInput && kindSelect && nameInput.value.trim() === "") {
      nameInput.value = this.defaultNameForKind(kindSelect.value)
    }

    this.syncOption(optionElement, this.toggleTarget.checked)
  }

  optionItems() {
    return this.hasOptionsListTarget
      ? Array.from(this.optionsListTarget.querySelectorAll("[data-product-options-form-item]"))
      : []
  }

  syncOption(optionElement, formVisible) {
    const destroyInput = optionElement.querySelector("input[data-role='option-destroy']")
    const destroyed = destroyInput && destroyInput.value === "1"
    optionElement.classList.toggle("d-none", destroyed)

    const interactiveEnabled = !!formVisible && !destroyed
    const kindSelect = optionElement.querySelector("select[data-role='option-kind']")
    const optionKind = kindSelect ? kindSelect.value : "custom"

    optionElement.querySelectorAll("input, select, textarea, button").forEach((input) => {
      if (input.dataset.role === "option-destroy" || input.dataset.role === "value-destroy") return
      input.disabled = !interactiveEnabled
    })

    this.valueItems(optionElement).forEach((valueElement) => {
      this.syncValue(valueElement, optionKind, interactiveEnabled)
    })
  }

  valueItems(optionElement) {
    return Array.from(optionElement.querySelectorAll("[data-product-options-form-value]"))
  }

  syncValue(valueElement, optionKind, interactiveEnabled) {
    const destroyInput = valueElement.querySelector("input[data-role='value-destroy']")
    const destroyed = destroyInput && destroyInput.value === "1"
    valueElement.classList.toggle("d-none", destroyed)

    const enabled = interactiveEnabled && !destroyed
    valueElement.querySelectorAll("input, select, textarea, button").forEach((input) => {
      if (input.dataset.role === "value-destroy") return
      input.disabled = !enabled
    })

    const hexWrap = valueElement.querySelector("[data-role='hex-wrap']")
    const hexInput = valueElement.querySelector("input[data-role='hex-input']")
    const isColor = optionKind === "color"

    if (hexWrap) {
      hexWrap.classList.toggle("d-none", !isColor)
    }

    if (hexInput) {
      hexInput.disabled = !enabled || !isColor
      hexInput.required = enabled && isColor
    }
  }

  defaultNameForKind(kind) {
    if (kind === "size") return "Taille"
    if (kind === "color") return "Couleur"
    return "Option"
  }

  generateKey() {
    return `${Date.now()}${Math.floor(Math.random() * 100000)}`
  }

  appendValue(optionElement) {
    const valueTemplate = optionElement.querySelector("template[data-role='value-template']")
    const valuesList = optionElement.querySelector("[data-role='values-list']")
    if (!valueTemplate || !valuesList) return

    const uniqueKey = this.generateKey()
    const templateHtml = valueTemplate.innerHTML.replace(/NEW_VALUE/g, uniqueKey)
    valuesList.insertAdjacentHTML("beforeend", templateHtml)
  }
}
