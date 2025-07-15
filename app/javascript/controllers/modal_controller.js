import { Controller } from "@hotwired/stimulus"

// Connects with data-controller="modal"
export default class extends Controller {
  // ここがポイントよ！モーダルの要素を「modalElement」として指定するの。
  // Stimulusがこの名前でHTMLの中から要素を見つけてくれるわ。
  static targets = ["modalElement"]

  // コントローラがHTML要素に接続されたときに呼ばれるわ
  connect() {
    console.log("Modal controller connected! Ready to show/hide modals.");
    // デバッグ用よ。普段はなくてもいいわ。
  }

  // --- モーダルを開くアクション ---
  open() {
    // modalElementTarget の hidden クラスを外して表示するの
    this.modalElementTarget.classList.remove("hidden");
    // 背景のスクロールを止めて、モーダルに集中させるわ
    document.body.classList.add("overflow-hidden");

    // Escキーでの終了処理は、モーダルが開いた時にイベントリスナーを追加するのがスマートね
    this.boundCloseWithEscape = this.closeWithEscape.bind(this); // thisの参照を正しく保つためよ
    document.addEventListener("keydown", this.boundCloseWithEscape);
  }

  // --- モーダルを閉じるアクション ---
  close() {
    // modalElementTarget に hidden クラスを付けて非表示にするの
    this.modalElementTarget.classList.add("hidden");
    // 背景のスクロールを元に戻すのよ
    document.body.classList.remove("overflow-hidden");

    // イベントリスナーは、モーダルを閉じたら忘れずに削除するのよ。
    // これをしないと、メモリの無駄遣いになったり、予期せぬ動作につながることがあるからね。
    if (this.boundCloseWithEscape) {
      document.removeEventListener("keydown", this.boundCloseWithEscape);
      this.boundCloseWithEscape = null; // 参照もクリアしておくと丁寧よ
    }
  }

  // --- 背景クリックで閉じる機能 ---
  // data-action="click->modal#closeBackground" で呼び出されるわ
  closeBackground(event) {
    // クリックされたのがモーダルのオーバーレイ（背景部分）だったら閉じるのよ
    // モーダルのコンテンツ部分をクリックしても閉じないようにするためね
    if (event.target === this.modalElementTarget) {
      this.close();
    }
  }

  // --- Escキーで閉じる機能 ---
  // open() メソッドで document にイベントリスナーを追加しているから、
  // Escキーが押されたらこのメソッドが呼ばれるわ
  closeWithEscape(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }
}