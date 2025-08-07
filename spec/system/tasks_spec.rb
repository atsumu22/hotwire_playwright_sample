require "rails_helper"

RSpec.describe "Tasks", type: :system do
  let!(:project1) { FactoryBot.create(:project, name: "最初のプロジェクト") }
  let!(:project2) { FactoryBot.create(:project, name: "2番目のプロジェクト") }

  it "プロジェクト詳細画面が表示されること" do
    visit project_path(project1.id)
    expect(page).to have_selector("h1", text: project1.name)
    expect(page).to have_selector("h2", text: "Tasks")
  end

  it "プロジェクト一覧画面に戻れること" do
    visit project_path(project1.id)
    click_on "プロジェクト一覧に戻る"

    expect(page).to have_selector("h1", text: "Project一覧")
  end

  describe "タスク追加" do
    it "タスク追加ボタンをクリックすると、モーダルが現れること", js: true do
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

    it "タスク追加モーダルから新しくタスクを追加できること", js: true do
      visit project_path(project1.id)

      expect(page).not_to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector("a", text: "タスクを追加する")

      click_on "タスクを追加する"

      expect(page).to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector('[data-modal-target="content"]')

      expect{
        within('[data-modal-target="content"]') do
          fill_in "タスク名", with: "新しいタスク"
          click_on "登録する"
        end
      }.to change(Task, :count).by(1)

      expect(page).to have_content("新しいタスク")
      expect(page).to have_content("タスクを追加しました")
    end

    it "タスクの追加を中止できること", js: true do
      visit project_path(project1.id)

      expect(page).not_to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector("a", text: "タスクを追加する")

      click_on "タスクを追加する"

      expect(page).to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector('[data-modal-target="content"]')

      expect{
        within('[data-modal-target="content"]') do
          fill_in "タスク名", with: "新しいタスク"
          click_on "やめる"
        end
      }.to change(Task, :count).by(0)

      expect(page).not_to have_content("新しいタスク")
    end
  end

  desctibe "タスク修正" do
    it "既存タスクの修正ができること" do
    end
  end
end
