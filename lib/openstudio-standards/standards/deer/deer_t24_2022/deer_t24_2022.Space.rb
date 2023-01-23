class DEERT242022 < DEER
  # @!group Space

  # Baseline infiltration rate
  #
  # @return [Double] the baseline infiltration rate, in cfm/ft^2 exterior above grade wall area at 75 Pa
  def space_infiltration_rate_75_pa(space)
    basic_infil_rate_cfm_per_ft2 = 0.2352
    return basic_infil_rate_cfm_per_ft2
  end
end
