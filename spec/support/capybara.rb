require 'capybara/playwright'

Capybara.server = :puma, { Silent: true }
Capybara.default_max_wait_time = 15

# CI環境での追加設定
if ENV['CI'] # GitHub ActionsなどのCI環境
  Capybara.default_max_wait_time = 30  # より長い待機時間
end

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(app,
    browser_type: :chromium,
    headless: true,
    playwright_options: {
      args: [
        '--no-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--disable-web-security',
        '--disable-features=VizDisplayCompositor'
      ]
    }
  )
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end
  
  config.before(:each, type: :system, playwright: true) do
    driven_by(:playwright, screen_size: [1400, 1400])
  end
  
  # CI環境でのテスト前の追加待機
  config.before(:each, type: :system, playwright: true) do
    if ENV['CI']
      # CI環境では少し長めに待機
      sleep 0.5
    end
  end
end