# This class holds methods that apply to DEER T24 2022
# to a given model.
# @ref [Refrences::DEERT24]
class DEERT242022 < DEER
  register_standard 'DEER T24 2022'
  attr_reader :templates

  def initialize
    @template = 'DEER T24 2022'
    load_standards_database
  end

  # Loads the openstudio standards dataset for this standard.
  #
  # @param data_directories [Array<String>] array of file paths that contain standards data
  # @return [Hash] a hash of standards data
  def load_standards_database(data_directories = [])
    super([__dir__] + data_directories)
  end
end