require "rails_helper"

RSpec.describe "Tasks", type: :system do
  let!(:project1) { FactoryBot.create(:project, name: "最初のプロジェクト") }
  let!(:project2) { FactoryBot.create(:project, name: "2番目のプロジェクト") }
  let!(:project1_task_a) { FactoryBot.create(:task, title: "sample task1", project: project1) }
  let!(:project1_task_b) { FactoryBot.create(:task, title: "sample task2", project: project1) }

  describe "round 1" do
    it "タスク追加ボタンをクリックすると、モーダルが現れること", js: true do
      visit project_path(project1.id)

      expect(page).to have_selector('[data-modal-target="modal"]', visible: false)
      expect(page).to have_selector("a", text: "タスクを追加する")

      click_on "タスクを追加する"

      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      expect(page).to have_selector('[data-modal-target="content"]', visible: true)

      within('[data-modal-target="content"]') do
        expect(page).to have_content("タスクを登録する")
        expect(page).to have_field("タスク名")
        expect(page).to have_field("優先度")
        expect(page).to have_button("登録する")
        expect(page).to have_button("やめる")
      end
    end

    it "タスク追加ボタンをクリックすると、モーダルが現れること", playwright: true do
      visit project_path(project1.id)

      expect(page).to have_selector('[data-modal-target="modal"]', visible: false)
      expect(page).to have_selector("a", text: "タスクを追加する")

      click_on "タスクを追加する"

      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      expect(page).to have_selector('[data-modal-target="content"]', visible: true)

      within('[data-modal-target="content"]') do
        expect(page).to have_content("タスクを登録する")
        expect(page).to have_field("タスク名")
        expect(page).to have_field("優先度")
        expect(page).to have_button("登録する")
        expect(page).to have_button("やめる")
      end
    end
  end

  describe "round 2" do
    it "新規タスクがproject-tasks内に正しく追加されること", js: true do
      visit project_path(project1.id)
      expect(page).to have_selector('[data-modal-target="modal"]', visible: false)
      expect(page).to have_selector("a", text: "タスクを追加する")

      click_on "タスクを追加する"
      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      expect(page).to have_selector('[data-modal-target="content"]', visible: true)

      expect{
        within('[data-modal-target="content"]') do
          fill_in "タスク名", with: "テスト追加タスク"
          click_on "登録する"
        end
      }.to change(Task, :count).by(1)

      # project-tasks内に追加されていることを確認
      within("#project-tasks") do
        expect(page).to have_content("テスト追加タスク")
      end

      # project-tasks外に重複していないことを確認
      outside_project_tasks = page.all("#project-tasks ~ *", text: "テスト追加タスク")
      expect(outside_project_tasks).to be_empty
    end

    it "新規タスクがproject-tasks内に正しく追加されること", playwright: true do
      visit project_path(project1.id)
      expect(page).to have_selector('[data-modal-target="modal"]', visible: false)
      expect(page).to have_selector("a", text: "タスクを追加する")

      initial_count = Task.count

      click_on "タスクを追加する"
      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      expect(page).to have_selector('[data-modal-target="content"]', visible: true)

      within('[data-modal-target="content"]') do
        fill_in "タスク名", with: "テスト追加タスク"
        click_on "登録する"
      end

      within("#project-tasks") do
        expect(page).to have_content("テスト追加タスク")
      end

      expect(Task.count).to eq(initial_count + 1)

      outside_project_tasks = page.all("#project-tasks ~ *", text: "テスト追加タスク")
      expect(outside_project_tasks).to be_empty
    end

    # it "デバッグ: タスク追加でのchange検証", js: true do
    #   require 'benchmark'
      
    #   visit project_path(project1.id)
    #   puts "初期タスク数: #{Task.count}"
      
    #   click_on "タスクを追加する"
    #   expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      
    #   form_time = Benchmark.realtime do
    #     expect {
    #       within('[data-modal-target="content"]') do
    #         fill_in "タスク名", with: "検証タスク"
    #         click_on "登録する"
    #         puts "クリック直後のタスク数: #{Task.count}"
    #       end
    #     }.to change(Task, :count).by(1)
    #   end
    #   puts "フォーム処理時間: #{(form_time * 1000).round(1)}ms"
    #   puts "検証完了後タスク数: #{Task.count}"
    # end

    # it "デバッグ: 新規タスクがproject-tasks内に正しく追加されること", playwright: true do
    #   require 'benchmark'
      
    #   visit project_path(project1.id)
    #   initial_count = Task.count
    #   puts "初期タスク数: #{initial_count}"
      
    #   click_on "タスクを追加する"
    #   expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      
    #   form_time = Benchmark.realtime do
    #     within('[data-modal-target="content"]') do
    #       fill_in "タスク名", with: "検証タスク"
    #       click_on "登録する"
    #       puts "クリック直後のタスク数: #{Task.count}"
    #     end
    #   end
    #   puts "フォーム処理時間: #{(form_time * 1000).round(1)}ms"
      
    #   within("#project-tasks") do
    #     expect(page).to have_content("検証タスク")
    #   end
      
    #   puts "検証完了後タスク数: #{Task.count}"
    #   expect(Task.count).to eq(initial_count + 1)
    # end
  end

  describe "round 3" do
    it "すべて完了にするボタンで一定時間待機後全タスクが完了状態になること、また全て完了にするボタンは非表示になること", js: true do
      visit project_path(project1.id)
      expect(page).to have_selector("button", text: "すべて完了にする")

      within("#all-complete") do
        click_on "すべて完了にする"
      end

      expect(page).not_to have_selector("button", text: "すべて完了にする", wait: 6)

      within("#project-tasks") do
        expect(page).to have_content("Done", count: 2, wait: 1)
      end

      expect(project1_task_a.reload.status).to be true
      expect(project1_task_b.reload.status).to be true
    end

    it "すべて完了にするボタンで一定時間待機後全タスクが完了状態になること", playwright: true do
      visit project_path(project1.id)

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
