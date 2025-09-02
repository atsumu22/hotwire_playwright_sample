require "rails_helper"

RSpec.describe "Tasks with Playwright", type: :system do
  let!(:project1) { FactoryBot.create(:project, name: "最初のプロジェクト") }
  let!(:project1_task_a) { FactoryBot.create(:task, title: "sample task1", project: project1) }
  let!(:project1_task_b) { FactoryBot.create(:task, title: "sample task2", project: project1) }

  it "タスク追加ボタンをクリックすると、モーダルが現れること", playwright: true do
    visit project_path(project1.id)

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

  it "新規タスクがproject-tasks内に正しく追加されること", playwright: true do
    visit project_path(project1.id)
    expect(page).not_to have_selector('[data-modal-target="modal"]')
    expect(page).to have_selector("a", text: "タスクを追加する")

    initial_count = Task.count

    click_on "タスクを追加する"

    expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
    expect(page).to have_selector('[data-modal-target="content"]')

    within('[data-modal-target="content"]') do
      fill_in "タスク名", with: "テスト追加タスク"
      click_button "登録する"
    end

    within("#project-tasks") do
      expect(page).to have_content("テスト追加タスク")
    end

    expect(Task.count).to eq(initial_count + 1)

    outside_project_tasks = page.all("#project-tasks ~ *", text: "テスト追加タスク")
    expect(outside_project_tasks).to be_empty
  end

  it "すべて完了にするボタンで一定時間待機後全タスクが完了状態になること", playwright: true do
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
end