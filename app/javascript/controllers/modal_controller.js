import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    console.log("Modal controller connected! Ready to show/hide modals.");
    // デバッグ用
  }

  // --- モーダルを開くアクション ---
  open() {
    this.modalTarget.classList.remove("hidden");
    this.modalTarget.setAttribute("aria-hidden", "false")
    document.body.classList.add("overflow-hidden");

    // Escキーでの終了処理は、モーダルが開いた時にイベントリスナーを追加するのがスマートね
    // this.boundCloseWithEscape = this.closeWithEscape.bind(this); // thisの参照を正しく保つためよ
    // document.addEventListener("keydown", this.boundCloseWithEscape);
  }

  // --- モーダルを閉じるアクション ---
  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.setAttribute("aria-hidden", "true")
    document.body.classList.remove("overflow-hidden")
    // もしモーダル内のTurbo Frameをクリアしたいなら、ここに追加
    // 例: this.element.querySelector("#modal_content_frame").innerHTML = ""

    // イベントリスナーは、モーダルを閉じたら忘れずに削除するのよ。
    // これをしないと、メモリの無駄遣いになったり、予期せぬ動作につながることがあるからね。
    if (this.boundCloseWithEscape) {
      document.removeEventListener("keydown", this.boundCloseWithEscape);
      this.boundCloseWithEscape = null; // 参照もクリアしておくと丁寧よ
    }
  }

  // --- 背景クリックで閉じる機能 ---
  // data-action="click->modal#closeBackground" をオーバーレイ要素に設定
  closeBackground(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  // --- Escキーで閉じる機能 ---
  // open() メソッドで document にイベントリスナーを追加しているから、
  // Escキーが押されたらこのメソッドが呼ばれるわ


  // Escキーで閉じる（Stimulusのイベントリスナー）
  // data-action="keydown@window->modal#closeWithKeyboard" を<body>など親要素に設定
  closeWithKeyboard(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }
}