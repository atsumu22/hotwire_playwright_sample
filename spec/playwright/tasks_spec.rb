require "rails_helper"

RSpec.describe "Tasks with Playwright", type: :system do
  let!(:project1) { FactoryBot.create(:project, name: "最初のプロジェクト") }
  let!(:project2) { FactoryBot.create(:project, name: "2番目のプロジェクト") }
  let!(:project1_task_a) { FactoryBot.create(:task, title: "sample task1", project: project1) }
  let!(:project1_task_b) { FactoryBot.create(:task, title: "sample task2", project: project1) }

  it "(Playwright)タスク追加ボタンをクリックすると、モーダルが現れること", playwright: true do
    visit project_path(project1.id)

    expect(page).to have_selector("a", text: "タスクを追加する")
    click_on "タスクを追加する"

    expect(page).to have_selector('[data-modal-target="modal"]')
    expect(page).to have_selector('[data-modal-target="content"]')
  end

  it "(Playwright)新規タスクがproject-tasks内に正しく追加されること", playwright: true do
    visit project_path(project1.id)
    expect(page).not_to have_selector('[data-modal-target="modal"]')

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

  it "(Playwright)すべて完了にするボタンで一定時間待機後全タスクが完了状態になること", playwright: true do
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

  # it "デバッグ: タスクステータスの更新確認", playwright: true do
  #   visit project_path(project1.id)
    
  #   puts "更新前のステータス: #{project1_task_a.reload.status}"
    
  #   click_button "すべて完了にする"
    
  #   # オーバーレイ完了まで待機
  #   expect(page).to have_selector('[data-complete-all-target="overlay"]', visible: false, wait: 15)
    
  #   puts "更新後のステータス: #{project1_task_a.reload.status}"
  #   puts "画面上の.bg-green-100の数: #{page.all('.bg-green-100').count}"
  # end
end