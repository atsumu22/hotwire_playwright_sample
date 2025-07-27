import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "button", "task", "buttonArea", "overlay" ]

  connect() {
    this.toggleButtonAndLoaderVisibility()
  }

  taskTargetConnected() {
    this.toggleButtonAndLoaderVisibility()
  }
  taskTargetDisconnected() {
    this.toggleButtonAndLoaderVisibility()
  }

  start() {
    this.overlayTarget.classList.remove('hidden')
    this.buttonAreaTarget.querySelector('button').disabled = true
  }

  toggleButtonAndLoaderVisibility() {
    this.overlayTarget.classList.add('hidden')

    const hasIncompleteTasks = this.hasTaskTarget && this.taskTargets.some(task => task.dataset.taskStatus === "incomplete");

    if (hasIncompleteTasks) {
      this.buttonAreaTarget.classList.remove('hidden');
    } else {
      this.buttonAreaTarget.classList.add('hidden');
    }
  }
}