import { Controller } from "@hotwired/stimulus"

// Reused for both quantity selection and destructive action confirmation dialogs.
export default class extends Controller {
  static targets = ["dialog", "title", "message", "confirmButton"]

  connect() {
    this.pendingForm = null
  }

  open(event) {
    event.preventDefault()
    const trigger = event.currentTarget

    this.pendingForm = trigger.form || null

    if (this.hasTitleTarget) {
      this.titleTarget.textContent =
        trigger.dataset.modalTitle || trigger.dataset.confirmModalTitle || "Confirmer l'action"
    }
    if (this.hasMessageTarget) {
      this.messageTarget.textContent =
        trigger.dataset.modalMessage || trigger.dataset.confirmModalMessage || "Cette action est définitive."
    }
    if (this.hasConfirmButtonTarget) {
      this.confirmButtonTarget.textContent =
        trigger.dataset.modalConfirmLabel || trigger.dataset.confirmModalConfirmLabel || "Confirmer"
    }

    this.dialogTarget.showModal()
  }

  confirm(event) {
    event.preventDefault()
    const form = this.pendingForm
    this.close()
    if (!form) return

    if (typeof form.requestSubmit === "function") {
      form.requestSubmit()
    } else {
      form.submit()
    }
  }

  close(event) {
    if (event) event.preventDefault()
    this.pendingForm = null
    if (this.dialogTarget.open) this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) {
      this.close()
    }
  }
}
