module FlightsHelper
  def i_to_h(i)
    h = i / 60
    m = i % 60
    "#{h}:#{m < 10 ? "0": ""}#{m}"
  end
end
