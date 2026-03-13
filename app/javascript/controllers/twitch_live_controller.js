import { Controller } from "@hotwired/stimulus"

const POLL_INTERVAL_MS = 30000

export default class extends Controller {
  static targets = [
    "popup",
    "headline",
    "streamTitle",
    "meta",
    "thumbnail",
    "iframe",
    "watchLink"
  ]

  static values = {
    endpoint: String,
    streamId: String
  }

  connect() {
    this.refresh()
    this.interval = window.setInterval(() => this.refresh(), POLL_INTERVAL_MS)
  }

  disconnect() {
    if (this.interval) window.clearInterval(this.interval)
  }

  dismiss() {
    if (this.streamIdValue) this.writeDismissedStreamId(this.streamIdValue)
    this.hidePopup()
  }

  async refresh() {
    if (!this.hasEndpointValue) return

    try {
      const response = await fetch(this.endpointValue, {
        headers: { Accept: "application/json" },
        credentials: "same-origin"
      })
      if (!response.ok) return

      const state = await response.json()
      this.applyState(state)
    } catch (_error) {
      // Keep the last known UI state when polling fails.
    }
  }

  applyState(state) {
    this.streamIdValue = state.stream_id || ""

    if (!state.enabled || !state.live) {
      this.hidePopup()
      return
    }

    if (this.dismissedStreamId() === this.streamIdValue) {
      this.hidePopup()
      return
    }

    if (this.hasHeadlineTarget) this.headlineTarget.textContent = state.popup_title || "En direct sur Twitch"
    if (this.hasStreamTitleTarget) this.streamTitleTarget.textContent = state.title || state.channel_name || ""
    if (this.hasMetaTarget) this.metaTarget.textContent = this.metaText(state)

    if (this.hasThumbnailTarget) {
      this.thumbnailTarget.src = state.thumbnail_url || ""
      this.thumbnailTarget.alt = state.title || state.channel_name || "Twitch live"
    }

    if (this.hasWatchLinkTarget) this.watchLinkTarget.href = state.channel_url || "#"
    if (this.hasIframeTarget) this.syncIframe(state.embed_url)

    this.popupTarget.hidden = false
  }

  hidePopup() {
    if (this.hasIframeTarget) this.iframeTarget.src = ""
    if (this.hasPopupTarget) this.popupTarget.hidden = true
  }

  syncIframe(embedUrl) {
    if (!embedUrl) {
      this.iframeTarget.src = ""
      return
    }

    if (this.iframeTarget.src !== embedUrl) this.iframeTarget.src = embedUrl
  }

  metaText(state) {
    const parts = ["En direct"]

    if (state.game_name) parts.push(state.game_name)
    if (state.viewer_count > 0) parts.push(`${state.viewer_count} spectateurs`)
    if (state.started_at_label) parts.push(`depuis ${state.started_at_label}`)

    return parts.join(" · ")
  }

  dismissedStreamId() {
    try {
      return window.localStorage.getItem(this.storageKey()) || ""
    } catch (_error) {
      return ""
    }
  }

  writeDismissedStreamId(streamId) {
    try {
      window.localStorage.setItem(this.storageKey(), streamId)
    } catch (_error) {
      // Ignore browsers that block storage.
    }
  }

  storageKey() {
    return "twitch-live-dismissed-stream-id"
  }
}
