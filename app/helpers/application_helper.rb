module ApplicationHelper
  def turbo_stream_flash
    turbo_stream.update "flash", partial: "flash"
  end
end
