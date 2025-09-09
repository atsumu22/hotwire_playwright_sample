require 'capybara/playwright'

Capybara.default_max_wait_time = 15

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(app,
    browser_type: :chromium,
    headless: true
  )
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end

  config.before(:each, type: :system, js: true) do
    driven_by(:cuprite, screen_size: [1400, 1400], options: {
      timeout: 30,
      headless: true,
    })
  end

  config.before(:each, type: :system, playwright: true) do
    driven_by(:playwright, screen_size: [1400, 1400])
  end
end