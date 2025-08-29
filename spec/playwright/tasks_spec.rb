require "rails_helper"

RSpec.describe "Tasks with Playwright", type: :system, playwright: true do
  let!(:project1) { FactoryBot.create(:project, name: "最初のプロジェクト") }
  let!(:project1_task_a) { FactoryBot.create(:task, title: "sample task1", project: project1) }
  let!(:project1_task_b) { FactoryBot.create(:task, title: "sample task2", project: project1) }

  # 前回CI環境で失敗したテストと同じものを実装
  describe "【Playwright】" do
    it "タスク追加ボタンをクリックすると、モーダルが現れること" do
      visit "/projects/#{project1.id}"
      
      expect(page).not_to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector("a", text: "タスクを追加する")
      
      click_on "タスクを追加する"
      
      expect(page).to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector('[data-modal-target="content"]')
    
      within('[data-modal-target="content"]') do
        expect(page).to have_content("タスクを登録する")
        expect(page).to have_field("タスク名")
        expect(page).to have_field("優先度")
        expect(page).to have_button("登録する")
        expect(page).to have_button("やめる")
      end
    end

    it "タスク追加モーダルから新しくタスクを追加できること" do
      visit "/projects/#{project1.id}"
      
      initial_count = Task.count

      expect(page).not_to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector("a", text: "タスクを追加する")
      
      click_on "タスクを追加する"
      
      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      expect(page).to have_selector('[data-modal-target="content"]')

      within('[data-modal-target="content"]') do
        fill_in "タスク名", with: "新しいタスク"
        click_on "登録する"
      end
      
      expect(page).to have_selector('[data-modal-target="modal"]', visible: false, wait: 5)
      
      within("#project-tasks") do
        expect(page).to have_content("新しいタスク")
      end
      expect(page).to have_content("タスクを追加しました")
      
      new_task = project1.tasks.find_by(title: "新しいタスク")
      expect(new_task).to be_present
      expect(Task.count).to eq(initial_count + 1)
    end

    it "タスクの追加を中止できること" do
      visit "/projects/#{project1.id}"
      
      initial_task_count = page.all('#project-tasks [id^="task_"]').count

      expect(page).not_to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector("a", text: "タスクを追加する")

      click_on "タスクを追加する"

      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      expect(page).to have_selector('[data-modal-target="content"]')

      within('[data-modal-target="content"]') do
        fill_in "タスク名", with: "キャンセルするタスク"
        click_on "やめる"
      end

      expect(page).to have_selector('[data-modal-target="modal"]', visible: false, wait: 5)
      expect(page.all('#project-tasks [id^="task_"]').count).to eq(initial_task_count)
      expect(page).not_to have_content("キャンセルするタスク")
      expect(project1.tasks.find_by(title: "キャンセルするタスク")).to be_nil
    end

    it "新規タスクがproject-tasks内に正しく追加されること" do
      visit "/projects/#{project1.id}"
      
      # モーダルを開いて新しいタスクを追加
      click_on "タスクを追加する"
      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      
      within('[data-modal-target="content"]') do
        fill_in "タスク名", with: "project-tasks内確認用タスク"
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