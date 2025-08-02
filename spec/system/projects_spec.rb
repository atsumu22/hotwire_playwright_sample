require "rails_helper"

RSpec.describe "Projects", type: :system do
  before do
    FactoryBot.create(:project, name: "最初のプロジェクト")
    FactoryBot.create(:project, name: "2番目のプロジェクト")
  end

  it "プロジェクト一覧が表示されること" do
    visit projects_path
    expect(page).to have_selector("h1", text: "Project一覧")
    expect(page).to have_content("最初のプロジェクト")
    expect(page).to have_content("2番目のプロジェクト")
  end

  describe "検索フォーム" do
    it "プロジェクトを検索できること", js: true do
      visit projects_path
      fill_in "q_name_cont", with: "最初"
      expect(page).to have_field("q_name_cont", with: "最初")
      # Turbo Frameが更新されるのを待つ
      expect(page).to have_content("最初のプロジェクト")
      expect(page).not_to have_content("2番目のプロジェクト")
    end

    it "クリアボタンで入力内容を消去できること", js: true do
      visit projects_path
      fill_in "q_name_cont", with: "最初"
      click_on "クリア"

      expect(page).to have_field("q_name_cont", with: "")
    end
  end

  describe "ソート機能" do
    it "プロジェクト名でソートできること", js: true do
      visit projects_path
      click_on "プロジェクト名"
      # Turbo Frameが更新されるのを待つ
      ordered_project_elements = all(".project-item")
      expect(ordered_project_elements[0]).to have_content("2番目のプロジェクト")
      expect(ordered_project_elements[1]).to have_content("最初のプロジェクト")

      click_on "プロジェクト名"
      reordered_project_elements = all(".project-item")
      expect(reordered_project_elements[0]).to have_content("最初のプロジェクト")
      expect(reordered_project_elements[1]).to have_content("2番目のプロジェクト")
    end

    it "登録順でソートできること" do
      FactoryBot.create(:project, name: "3番目のプロジェクト")

      visit projects_path
      click_on "登録順"

      ordered_project_elements = all(".project-item")
      expect(ordered_project_elements[0]).to have_content("最初のプロジェクト")
      expect(ordered_project_elements[1]).to have_content("2番目のプロジェクト")
      expect(ordered_project_elements[2]).to have_content("3番目のプロジェクト")

      click_on "登録順"
      reordered_project_elements = all(".project-item")
      expect(reordered_project_elements[0]).to have_content("3番目のプロジェクト")
      expect(reordered_project_elements[1]).to have_content("2番目のプロジェクト")
      expect(reordered_project_elements[2]).to have_content("最初のプロジェクト")
    end
  end


  describe "プロジェクト新規登録" do
    it "プロジェクトを追加できること", js: true do
      visit projects_path
      click_on "プロジェクトを追加する"
      # 数秒待つことで、turbo-frameによって確実に入力フォームが現れたことを保証する。
      expect(page).to have_selector("turbo-frame#new_project", wait: 10)

      # new_projectのturbo-frame内のボタンであることを保証している。例えばページの別の箇所に同じ表記のぼたんがあるとエラーになる可能性がある。
      within("#new_project") do
        fill_in "project_name", with: "新しいプロジェクト"
        click_on "登録する"
      end

      expect(page).to have_content("新しいプロジェクト")
      expect(page).to have_content("プロジェクトを登録しました")
    end

    it "プロジェクトの追加を途中でやめられること", js: true do
      visit projects_path
      click_on "プロジェクトを追加する"

      # 数秒待つことで、turbo-frameによって確実に入力フォームが現れたことを保証する。
      expect(page).to have_selector("turbo-frame#new_project", wait: 10)

      # new_projectのturbo-frame内のボタンであることを保証している。例えばページの別の箇所に同じ表記のぼたんがあるとエラーになる可能性がある。
      within("#new_project") do
        fill_in "project_name", with: "新しいプロジェクト"
        click_on "やめる"
      end

      expect(page).not_to have_content("新しいプロジェクト")
      expect(page).to have_selector("turbo-frame#new_project")
    end
  end

  describe "プロジェクト編集" do
    it "プロジェクトを編集できること", js: true do
      visit projects_path
      original_name = find("turbo-frame#project_2").text

      within("turbo-frame#project_2") do
        click_on "編集"
        fill_in "project_name" , with: "新しいプロジェクト名"
        click_on "更新"
      end

      expect(page).to have_content("新しいプロジェクト名")
      expect(original_name).not_to eq "新しいプロジェクト名"
    end

    it "プロジェクトの編集をやめられること", js: true do
      visit projects_path
      original_name = find("turbo-frame#project_2").text

      within("turbo-frame#project_2") do
        click_on "編集"
        fill_in "project_name" , with: "新しいプロジェクト名"
        click_on "やめる"
      end

      expect(page).to have_content(original_name)
      expect(original_name).not_to eq "新しいプロジェクト名"
    end

    it "複数のプロジェクトの編集フォームが独立して表示できる" do
  visit projects_path

  original_name = find("turbo-frame#project_2").text

  within("turbo-frame#project_1") do
    click_on "編集"
  end

  # Turboの非同期更新を待つ
  expect(page).to have_selector("turbo-frame#project_1 form")

  # **ここでproject_2があることを確認するが、待ち時間を明示的に増やす**
  using_wait_time 5 do
    expect(page).to have_selector("turbo-frame#project_2")
  end

  within("turbo-frame#project_2") do
    click_on "編集"
  end

  # project_2のフォーム表示を待つ
  expect(page).to have_selector("turbo-frame#project_2 form")
end

    it "同時に複数のプロジェクトの編集フォームが表示でき、それぞれの状況は互いに影響を及ぼさないこと" do
      visit projects_path
      original_project_2_name = find("turbo-frame#project_2").text
      p original_project_2_name

      within("turbo-frame#project_1") do
        click_on "編集"
      end

      save_and_open_page

      expect(page).to have_selector("turbo-frame#project_1 form")
      using_wait_time 5 do
        expect(page).to have_selector("turbo-frame#project_2")
      end
      # find("turbo-frame#project_2")
      # within("turbo-frame#project_2") do
      #   click_on "編集"
      # end
      # fill_in "project_name" , with: "新しいプロジェクト名2"

      # within("turbo-frame#project_1") do
        # click_on "編集"
      # end

      # expect(find("turbo-frame#project_1")).to have_content("新しいプロジェクト名1")
      # expect(find("turbo-frame#project_2")).to have_content(original_project_2_name)
      
      # within("turbo-frame#project_2") do
        # click_on "編集"
      # end

      # expect(find("turbo-frame#project_2")).to have_content("新しいプロジェクト名2")
    end
    # 同時に複数のプロジェクトの編集フォームが表示でき、それぞれ個別に編集をやめられること
    # 編集フォームと登録フォームを同時に表示でき、それぞれ個別に操作できること。
  end
end
