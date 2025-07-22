import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "content"]

  connect() {
    console.log("Modal controller connected! Ready to show/hide modals.");
    this.element.addEventListener("turbo:submit-end", this.handleSubmitEnd)
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmitEnd)
  }

  // --- モーダルを開くアクション ---
  open() {
    this.modalTarget.classList.remove("hidden");
    this.modalTarget.setAttribute("aria-hidden", "false")
    document.body.classList.add("overflow-hidden");
    this.modalTarget.focus()
  }

  // --- モーダルを閉じるアクション ---
  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.setAttribute("aria-hidden", "true")
    document.body.classList.remove("overflow-hidden")
    // もしモーダル内のTurbo Frameをクリアしたいなら、ここに追加
    // 例: this.element.querySelector("#modal_content_frame").innerHTML = ""
  }

  // --- 背景クリックで閉じる機能 ---
  // data-action="click->modal#closeBackground" をオーバーレイ要素に設定
  closeBackground(event) {
    if (!this.contentTarget.contains(event.target)) {
      this.close()
    }
  }

  // --- Escキーで閉じる機能 ---
  // data-action="keydown@window->modal#closeWithKeyboard" を<body>など親要素に設定
  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  // --- フォームSubmit成功時にモーダルを閉じる ---
  handleSubmitEnd = (event) => {
    // 成功（HTTPステータスが2xx）なら閉じる
    if (event.detail.success) {
      this.close()
    }
  }
}