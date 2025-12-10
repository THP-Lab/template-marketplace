import { Controller } from "@hotwired/stimulus"

// Drag & drop reorder : le placeholder suit la ligne visée, même en se déplaçant rapidement.
export default class extends Controller {
  static targets = ["item"]
  static values = { url: String }

  connect() {
    this.draggingId = null
    this.placeholder = null

    this.itemTargets.forEach((row) => {
      row.setAttribute("draggable", "true")
      row.addEventListener("dragstart", this.onDragStart)
      row.addEventListener("dragend", this.onDragEnd)
    })

    this.element.addEventListener("dragover", this.onDragOver)
    this.element.addEventListener("drop", this.onDrop)
    this.element.addEventListener("dragleave", this.onDragLeave)
  }

  disconnect() {
    this.itemTargets.forEach((row) => {
      row.removeEventListener("dragstart", this.onDragStart)
      row.removeEventListener("dragend", this.onDragEnd)
    })
    this.element.removeEventListener("dragover", this.onDragOver)
    this.element.removeEventListener("drop", this.onDrop)
    this.element.removeEventListener("dragleave", this.onDragLeave)
  }

  onDragStart = (event) => {
    this.draggingId = event.currentTarget.dataset.id
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggingId)
    event.currentTarget.classList.add("table-active", "reorder-dragging")
  }

  onDragOver = (event) => {
    event.preventDefault()
    if (!this.draggingId) return
    const targetRow = event.target.closest("[data-reorder-target='item']")
    if (!targetRow || targetRow.dataset.id === this.draggingId) return
    const after = this.shouldPlaceAfter(event, targetRow)
    this.placePlaceholder(targetRow, after)
  }

  onDragLeave = (event) => {
    if (!event.relatedTarget || !this.element.contains(event.relatedTarget)) {
      this.clearPlaceholder()
    }
  }

  onDrop = (event) => {
    event.preventDefault()
    if (!this.draggingId || !this.placeholder) return
    const draggingEl = this.itemTargets.find((el) => el.dataset.id === this.draggingId)
    if (draggingEl && this.placeholder.parentElement) {
      this.placeholder.parentElement.insertBefore(draggingEl, this.placeholder)
      this.updatePositions()
      this.persistOrder()
    }
    this.clearPlaceholder()
    this.draggingId = null
  }

  onDragEnd = (event) => {
    event.currentTarget.classList.remove("table-active", "reorder-dragging")
    this.clearPlaceholder()
    this.draggingId = null
  }

  placePlaceholder(targetRow, after = false) {
    this.clearPlaceholder()
    const placeholder = document.createElement("tr")
    placeholder.classList.add("reorder-placeholder")
    const colSpan = targetRow.cells.length || 1
    const td = document.createElement("td")
    td.colSpan = colSpan
    td.classList.add("reorder-placeholder-cell")
    const bar = document.createElement("div")
    bar.classList.add("reorder-placeholder-bar")
    td.appendChild(bar)
    placeholder.appendChild(td)
    if (after) {
      targetRow.parentElement.insertBefore(placeholder, targetRow.nextElementSibling)
    } else {
      targetRow.parentElement.insertBefore(placeholder, targetRow)
    }
    this.placeholder = placeholder
  }

  clearPlaceholder() {
    if (this.placeholder && this.placeholder.parentElement) {
      this.placeholder.parentElement.removeChild(this.placeholder)
    }
    this.placeholder = null
  }

  updatePositions() {
    this.itemTargets.forEach((row, index) => {
      const cell = row.querySelector("[data-position-cell]")
      if (cell) cell.textContent = index + 1
    })
  }

  persistOrder() {
    const ids = this.itemTargets.map((el) => el.dataset.id)
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      body: JSON.stringify({ ids })
    })
  }

  shouldPlaceAfter(event, targetRow) {
    const rect = targetRow.getBoundingClientRect()
    return event.clientY > rect.top + rect.height / 2
  }

  csrfToken() {
    const meta = document.querySelector("meta[name='csrf-token']")
    return meta && meta.getAttribute("content")
  }
}
