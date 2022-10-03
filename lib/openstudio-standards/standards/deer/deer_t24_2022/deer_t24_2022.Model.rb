class DEERT242022 < DEER
  # @!group Model
  
  # Determines how ventilation for the standard is specified.
  # When 'Sum', all min OA flow rates are added up.  Commonly used by 90.1.
  # When 'Maximum', only the biggest OA flow rate.  Used by T24.
  #
  # @param model [OpenStudio::Model::Model] the model
  # @return [String] the ventilation method, either Sum or Maximum
  def model_ventilation_method(model)
    ventilation_method = 'Maximum'
    return ventilation_method
  end
end