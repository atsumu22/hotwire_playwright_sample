require "rails_helper"

RSpec.describe "Projects", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    Project.create!(name: "最初のプロジェクト")
    Project.create!(name: "2番目のプロジェクト")
  end

  it "プロジェクト一覧が表示される" do
    visit projects_url
    expect(page).to have_selector("h1", text: "Project一覧")
    expect(page).to have_content("最初のプロジェクト")
    expect(page).to have_content("2番目のプロジェクト")
  end

  it "プロジェクトを検索できる" do
    visit projects_url
    fill_in "q_name_cont", with: "最初"
    # Turbo Frameが更新されるのを待つ
    expect(page).to have_content("最初のプロジェクト")
    expect(page).not_to have_content("2番目のプロジェクト")
  end

  it "プロジェクト名でソートできる" do
    visit projects_url
    click_on "プロジェクト名"
    # Turbo Frameが更新されるのを待つ
    expect(page).to have_content("2番目のプロジェクト")
    project_elements = all("[id^=project_]")
    expect(project_elements[0]).to have_content("2番目のプロジェクト")
    expect(project_elements[1]).to have_content("最初のプロジェクト")
  end

  it "プロジェクトを追加できる" do
    visit projects_url
    click_on "プロジェクトを追加する"

    within_frame("new_project") do
      fill_in "project_name", with: "新しいプロジェクト"
      click_on "登録する"
    end

    expect(page).to have_content("新しいプロジェクト")
    expect(page).to have_content("Project was successfully created.")
  end
end
