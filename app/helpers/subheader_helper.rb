# ================================================
# RUBY->SUBHEADER-HELPER =========================
# ================================================
module SubheaderHelper
  mattr_accessor :subheader

  self.subheader = []

  def subheader_is?(*path)
    self.subheader[0...path.length] == path.map(&:to_sym)
  end

  def subheader_set(*path)
    self.subheader = path
  end

  # NOTE: This is a helper to be used in filters
  def subheader_set_nil
    subheader_set nil
  end

end
