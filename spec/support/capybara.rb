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
end