require 'httparty'

class Peggy
  include HTTParty
  base_uri '10.105.4.251/litebrite/peggy'
  attr_accessor :lease_code, :expires
  COLORS = [:red, :green, :orange]
  
  def lease(t = 1)
    l = self.class.get("/get_lease/#{t}")
    if l["result"] == "success"
      self.lease_code = l["lease_code"]
      self.expires = Time.parse(l["lease_expiry"])
      return true
    else
      raise "Could not obtain lease"
    end
  end
  
  def clear()
    ensure_lease
    self.class.get("/clear/#{self.lease_code}/")
  end
  
  def green
    color(:green)
  end
  
  def red
    color(:red)
  end
  
  def orange
    color(:orange)
  end
  
  def color(c=:red)
    ensure_lease
    if COLORS.include?(c)
      self.class.get("/set_color/#{self.lease_code}/#{c}")
    end
  end
  
  def write(x,y,text = "")
    ensure_lease
    self.class.get("/write/#{self.lease_code}/#{x}/#{y}/#{URI::encode(text)}")
  end
  
  def expired?
    self.expires > Time.now
  end
  
  protected
  
  def ensure_lease
    lease() if self.lease_code.nil? || self.lease_code.empty?
  end
  
end