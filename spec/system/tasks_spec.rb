require "rails_helper"

RSpec.describe "Tasks", type: :system do
  let!(:project1) { FactoryBot.create(:project, name: "最初のプロジェクト") }
  let!(:project2) { FactoryBot.create(:project, name: "2番目のプロジェクト") }
  let!(:project1_task_a) { FactoryBot.create(:task, title: "sample task1", project: project1) }
  let!(:project1_task_b) { FactoryBot.create(:task, title: "sample task2", project: project1) }

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

      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      expect(page).to have_selector('[data-modal-target="content"]')

      expect{
        within('[data-modal-target="content"]') do
          fill_in "タスク名", with: "新しいタスク"
          click_on "登録する"
        end
      }.to change(Task, :count).by(1)

      expect(page).to have_selector('[data-modal-target="modal"]', visible: false, wait: 5)

      within("#project-tasks") do
        expect(page).to have_content("新しいタスク")
      end
      expect(page).to have_content("タスクを追加しました")
      
      new_task = project1.tasks.find_by(title: "新しいタスク")
      expect(new_task).to be_present
    end

    it "タスクの追加を中止できること", js: true do
      visit project_path(project1.id)

      expect(page).not_to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector("a", text: "タスクを追加する")

      click_on "タスクを追加する"

      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      expect(page).to have_selector('[data-modal-target="content"]')

      expect{
        within('[data-modal-target="content"]') do
          fill_in "タスク名", with: "キャンセルするタスク"
          click_on "やめる"
        end
      }.to change(Task, :count).by(0)

      expect(page).to have_selector('[data-modal-target="modal"]', visible: false, wait: 5)
      expect(page).not_to have_content("キャンセルするタスク")
    end

    it "新規タスクがproject-tasks内に正しく追加されること", js: true do
      visit project_path(project1.id)
      expect(page).not_to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector("a", text: "タスクを追加する")

      click_on "タスクを追加する"

      expect(page).to have_selector('[data-modal-target="modal"]', visible: true)
      expect(page).to have_selector('[data-modal-target="content"]')

      expect{
        within('[data-modal-target="content"]') do
          fill_in "タスク名", with: "テスト追加タスク"
          click_on "登録する"
        end
      }.to change(Task, :count).by(1)
      # # project-tasks内に追加されていることを確認
      within("#project-tasks") do
        expect(page).to have_content("テスト追加タスク")
      end

      # # project-tasks外に重複していないことを確認
      outside_project_tasks = page.all("#project-tasks ~ *", text: "テスト追加タスク")
      expect(outside_project_tasks).to be_empty
    end
  end

  describe "タスク修正" do
    it "既存タスクの修正ができること", js: true do
      visit project_path(project1.id)
      original_task_name = find("turbo-frame#task_#{project1_task_a.id}").text

      within("turbo-frame#task_#{project1_task_a.id}") do
        expect(page).to have_selector("a", text: "編集")
        click_on "編集"
      end

      expect(page).to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector('[data-modal-target="content"]')

      within('[data-modal-target="content"]') do
        fill_in "タスク名", with: "更新したタスク名"
        click_on "更新する"
      end
      expect(project1_task_a.title).not_to eq(original_task_name)
      expect(page).to have_content("更新したタスク名")
    end

    it "既存タスクの修正をやめられること", js: true do
      visit project_path(project1.id)
      original_task_name = find("turbo-frame#task_#{project1_task_a.id} p").text

      within("turbo-frame#task_#{project1_task_a.id}") do
        expect(page).to have_selector("a", text: "編集")
        click_on "編集"
      end

      expect(page).to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector('[data-modal-target="content"]')

      within('[data-modal-target="content"]') do
        fill_in "タスク名", with: "更新したタスク名"
        click_on "やめる"
      end
      expect(project1_task_a.title).to eq(original_task_name)
      expect(page).not_to have_content("更新したタスク名")
    end

    it "1つのモーダルを開いている間は別のモーダルは開けないこと", js: true do
      visit project_path(project1.id)
      expect(page).to have_selector("turbo-frame#task_#{project1_task_a.id}")
      expect(page).to have_selector("turbo-frame#task_#{project1_task_b.id}")

      within("turbo-frame#task_#{project1_task_a.id}") do
        expect(page).to have_selector("a", text: "編集")
        click_on "編集"
      end

      expect(page).to have_selector('[data-modal-target="modal"]')
      expect(page).to have_selector('[data-modal-target="content"]')

      within("turbo-frame#task_#{project1_task_b.id}") do
        expect(page).to have_selector("a", text: "編集")
        expect { click_on "編集" }.to raise_error(Capybara::Cuprite::MouseEventFailed)
      end
    end
  end

  describe "タスク削除" do
    it "タスクを削除できること", js: true do
      visit project_path(project1.id)
      expect(page).to have_selector("turbo-frame#task_#{project1_task_a.id}")
      expect(page).to have_selector("turbo-frame#task_#{project1_task_b.id}")

      expect{
        within("turbo-frame#task_#{project1_task_a.id}") do
          accept_confirm("本当に削除しますか？") do
            click_on "削除"
          end
        end
      }.to change(Task, :count).by(-1)

      expect(page).not_to have_content(project1_task_a.title)
    end

    it "タスクの削除を中止できること", js: true do
      visit project_path(project1.id)
      expect(page).to have_selector("turbo-frame#task_#{project1_task_a.id}")
      expect(page).to have_selector("turbo-frame#task_#{project1_task_b.id}")

      expect{
        within("turbo-frame#task_#{project1_task_a.id}") do
          dismiss_confirm("本当に削除しますか？") do
            click_on "削除"
          end
        end
      }.to change(Task, :count).by(0)

      expect(page).to have_content(project1_task_a.title)
    end
  end

  describe "タスク完了" do
    it "チェックボックスクリックでタスクが完了状態にできること", js: true do
      visit project_path(project1.id)
      expect(page).to have_selector("turbo-frame#task_#{project1_task_a.id}")
      expect(page).to have_selector("turbo-frame#task_#{project1_task_b.id}")
    
      within("turbo-frame#task_#{project1_task_a.id}") do
        # カスタムチェックボックスのラベル部分をクリック
        find('label').click
      end
    
      # Turbo Frameの更新を待つ
      expect(page).to have_selector("turbo-frame#task_#{project1_task_a.id} .bg-green-100")
    
      within("turbo-frame#task_#{project1_task_a.id}") do
        expect(page).to have_content('Done')
      end
    
      expect(project1_task_a.reload.status).to be true
    end

    it "完了状態のタスクのチェックボックスクリックでタスクが未完了にできること", js: true do
      visit project_path(project1.id)
      expect(page).to have_selector("turbo-frame#task_#{project1_task_a.id}")
      expect(page).to have_selector("turbo-frame#task_#{project1_task_b.id}")
    
      within("turbo-frame#task_#{project1_task_a.id}") do
        # カスタムチェックボックスのラベル部分をクリック
        find('label').click
      end
      # Turbo Frameの更新を待つ
      expect(page).to have_selector("turbo-frame#task_#{project1_task_a.id} .bg-green-100")
      within("turbo-frame#task_#{project1_task_a.id}") do
        expect(page).to have_content('Done')
      end

      within("turbo-frame#task_#{project1_task_a.id}") do
        # カスタムチェックボックスのラベル部分をクリック
        find('label').click
      end

      expect(page).to have_selector("turbo-frame#task_#{project1_task_a.id}")
      within("turbo-frame#task_#{project1_task_a.id}") do
        expect(page).not_to have_content('Done')
      end
      expect(project1_task_a.reload.status).to be false
    end

    it "すべて完了にするボタンで一定時間待機後全タスクが完了状態になること、また全て完了にするボタンは非表示になること", js: true do
      visit project_path(project1.id)
      expect(page).to have_selector("button", text: "すべて完了にする")
      
      within("#all-complete") do
        click_on "すべて完了にする"
      end
      
      # ボタンが消えるまで待つ（処理完了の指標として使用）
      expect(page).not_to have_selector("button", text: "すべて完了にする", wait: 6)
      
      # 各タスクに"Done"が表示されることを確認
      within("#project-tasks") do
        expect(page).to have_content("Done", count: 2, wait: 1)
      end
      
      # データベースの状態確認
      expect(project1_task_a.reload.status).to be true
      expect(project1_task_b.reload.status).to be true
    end
  end
end
