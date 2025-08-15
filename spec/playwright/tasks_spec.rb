require "rails_helper"

RSpec.describe "Tasks with Playwright", type: :system, playwright: true do
  let!(:project1) { FactoryBot.create(:project, name: "最初のプロジェクト") }
  let!(:project1_task_a) { FactoryBot.create(:task, title: "sample task1", project: project1) }
  let!(:project1_task_b) { FactoryBot.create(:task, title: "sample task2", project: project1) }

  # 前回CI環境で失敗したテストと同じものを実装
  describe "【Playwright】" do
    it "タスク追加ボタンをクリックすると、モーダルが現れること" do
      visit "/projects/#{project1.id}"
      
      expect(page).to have_selector("a", text: "タスクを追加する")
      click_on "タスクを追加する"
      
      expect(page).to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector('[data-modal-target="content"]')
    end

    it "【Playwright】タスク追加モーダルから新しくタスクを追加できること" do
      visit "/projects/#{project1.id}"
      
      # モーダルを開く
      click_on "タスクを追加する"
      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      
      # フォームに入力
      within('[data-modal-target="content"]') do
        fill_in "task[title]", with: "新しいタスク"
        fill_in "task[sort_order]", with: "10"
        
        click_button "登録する"
      end
      
      # モーダルが閉じることを確認
      expect(page).to have_selector('[data-modal-target="modal"]', visible: false, wait: 5)
      
      # 新しいタスクが追加されたことを確認
      within("#project-tasks") do
        expect(page).to have_content("新しいタスク")
      end
      
      # データベースの確認
      new_task = project1.tasks.find_by(title: "新しいタスク")
      expect(new_task).to be_present
      expect(new_task.sort_order).to eq(10)
    end

    it "【Playwright】タスクの追加を中止できること" do
      visit "/projects/#{project1.id}"
      
      # 既存タスク数をカウント
      initial_task_count = page.all('#project-tasks [id^="task_"]').count
      
      # モーダルを開く
      click_on "タスクを追加する"
      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      
      # フォームに入力（途中まで）
      within('[data-modal-target="content"]') do
        fill_in "task[title]", with: "キャンセルするタスク"
        fill_in "task[sort_order]", with: "99"
        
        # ×ボタンをクリック
        click_button "×"
      end
      
      # モーダルが閉じることを確認
      expect(page).to have_selector('[data-modal-target="modal"]', visible: false, wait: 5)
      
      # タスクが追加されていないことを確認
      expect(page.all('#project-tasks [id^="task_"]').count).to eq(initial_task_count)
      expect(page).not_to have_content("キャンセルするタスク")
      
      # データベースの確認
      expect(project1.tasks.find_by(title: "キャンセルするタスク")).to be_nil
    end

    it "【Playwright】新規タスクがproject-tasks内に正しく追加されること" do
      visit "/projects/#{project1.id}"
      
      # モーダルを開いて新しいタスクを追加
      click_on "タスクを追加する"
      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      
      within('[data-modal-target="content"]') do
        fill_in "task[title]", with: "project-tasks内確認用タスク"
        fill_in "task[sort_order]", with: "5"
        
        click_button "登録する"
      end
      
      # モーダルが閉じることを確認
      expect(page).to have_selector('[data-modal-target="modal"]', visible: false, wait: 5)
      
      # シンプルに新しいタスクの存在確認
      using_wait_time(10) do
        within("#project-tasks") do
          expect(page).to have_content("project-tasks内確認用タスク")
        end
      end
      
      # データベースの確認
      new_task = project1.tasks.find_by(title: "project-tasks内確認用タスク")
      expect(new_task).to be_present
      expect(new_task.sort_order).to eq(5)
    end

    it "すべて完了にするボタンで一定時間待機後全タスクが完了状態になること" do
      visit "/projects/#{project1.id}"

      expect(page).to have_button("すべて完了にする")
      overlay = page.find('[data-complete-all-target="overlay"]', visible: false)
      expect(overlay[:class]).to include('hidden')
      
      click_button "すべて完了にする"

      expect(page).to have_selector('[data-complete-all-target="overlay"]', visible: true, wait: 3)

      expect(page).to have_selector('[data-complete-all-target="overlay"]', visible: false, wait: 15)
      expect(page).to have_selector('.bg-green-100', count: 2)
      expect(project1_task_a.reload.status).to be true
      expect(project1_task_b.reload.status).to be true
    end
  end
end