require "rails_helper"

RSpec.describe "Tasks with Playwright", type: :system, playwright: true do
  let!(:project1) { FactoryBot.create(:project, name: "最初のプロジェクト") }
  let!(:project1_task_a) { FactoryBot.create(:task, title: "sample task1", project: project1) }
  let!(:project1_task_b) { FactoryBot.create(:task, title: "sample task2", project: project1) }

  # 前回CI環境で失敗したテストと同じものを実装
  it "【Playwright】タスク追加ボタンをクリックすると、モーダルが現れること" do
    visit "/projects/#{project1.id}"
    
    expect(page).to have_selector("a", text: "タスクを追加する")
    click_on "タスクを追加する"
    
    expect(page).to have_selector('[data-modal-target="modal"]')
    expect(page).to have_selector('[data-modal-target="content"]')
  end

  it "【Playwright】すべて完了にするボタンで一定時間待機後全タスクが完了状態になること" do
    visit "/projects/#{project1.id}"
    
    expect(page).to have_selector("button", text: "すべて完了にする")
    click_button "すべて完了にする"
    
    # Playwrightでの安定した待機
    expect(page).not_to have_selector("button", text: "すべて完了にする", wait: 6)
    
    expect(project1_task_a.reload.status).to be true
    expect(project1_task_b.reload.status).to be true
  end
end