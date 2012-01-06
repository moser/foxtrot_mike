require "date"
#Formulas and constants from http://www.astro.uu.nl/~strous/AA/en/reken/zonpositie.html
#Usage:
#  a = SRSS.new(49.2111111111111, 12.6583333333333) #approx. location of my home airfield
#  date = Date.new(2011, 6, 12, 0)
#  p a.sunrise(date).to_s #=> "2011-06-12T03:07:14+00:00"
#  p a.sunset(date).to_s #=> "2011-06-12T19:12:29+00:00"
class SRSS
  attr_reader :ln, :lw

  def sin(x)
    Math.sin(x * Math::PI / 180.0)
  end

  def cos(x)
    Math.cos(x * Math::PI / 180.0)
  end

  def tan(x)
    Math.tan(x * Math::PI / 180.0)
  end

  def asin(x)
    Math.asin(x) * 180.0 / Math::PI
  end

  def acos(x)
    Math.acos(x) * 180.0 / Math::PI
  end

  def atan(x)
    Math.atan(x) * 180.0 / Math::PI
  end

  J2000 = 2451545
  M0 = 357.5291
  M1 = 0.98560028

  def m(jd)
    (M0 + M1 * (jd - J2000)) % 360
  end

  C1 = 1.9148
  C2 = 0.0200
  C3 = 0.0003

  def c(jd)
    mjd = m(jd)
    (C1 * sin(mjd) + C2 * sin(2 * mjd) + C3 * sin(3 * mjd)) % 360
  end

  Pi = 102.9372

  def lamdda(jd)
    m(jd) + c(jd) + Pi + 180
  end

  A2 = -2.4680
  A4 = 0.053
  A6 = -0.0014

  def alpha(jd)
    l = lamdda(jd)
    (l + A2 * sin(2 * l) + A4 * sin(4 * l) + A6 * sin(6 * l)) % 360
  end

  D1 = 22.8008
  D3 = 0.5999
  D5 = 0.0493

  def delta(jd)
    l = lamdda(jd)
    (D1 * sin(l) + D3 * sin(l)**3 + D5 * sin(l)**5) % 360
  end

  Theta0 = 280.16
  Theta1 = 360.9856235

  def theta(jd, lw)
    (Theta0 + Theta1 * (jd - J2000) - lw) % 360
  end

  J3 = 360.0 / (Theta1 - M1)
  J0 = ((M0 + Pi + 180.0 - Theta0) * J3/360.0) % J3
  J1 = C1 * J3 / 360.0
  J2 = A2 * J3 / 360.0

  def j(jd, lw, htarget)
    m = m(jd)
    lsun = (m + Pi + 180.0) % 360
    n = ((jd - J2000 - J0) / J3 - (htarget + lw) / 360.0).round
    jstar = J2000 + J0 + (htarget + lw) * J3 / 360.0 + J3 * n
    jstar = jstar + J1 * sin(m) + J2 * sin(2 * lsun)
  # correction does not work
  #  20.times do
  #    p jstar
  #    jstar = jstar + (htarget - theta(jstar, lw) + alpha(jstar)) / 360.0 * J3
  #  end
    jstar
  end

  H0 = -0.83

  def h(jd, ln)
    acos((sin(H0) - sin(ln) * sin(delta(jd))/(cos(ln) * cos(delta(jd)))))
  end

  def initialize(north, west)
    @ln = north
    @lw = -west
  end

  def sunrise(date)
    jd = date.jd
    DateTime.jd(j(jd, lw, -h(jd, ln)) + 0.5)
  end

  def sunset(date)
    jd = date.jd
    DateTime.jd(j(jd, lw, h(jd, ln)) + 0.5)
  end

  def sunrise_i(date)
    time_to_minutes(sunrise(date))
  end

  def sunset_i(date)
    time_to_minutes(sunset(date))
  end

private
  def time_to_minutes(t)
    t.hour * 60 + t.min
  end
end
