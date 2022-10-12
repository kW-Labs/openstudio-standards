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

    # searches the model for windows and sets construction based on wwr and orientation
  # modeled after Prototype.Model.rb model_set_floor_construction
  def model_set_subsurface_constructions(model, building_type, climate_zone)
    construction_set_data = model_get_construction_set(building_type)
    building_type_category = construction_set_data['exterior_fixed_window_building_cateogry']
    standards_construction_type = construction_set_data['exterior_fixed_window_standards_construction_type']

    # exterior window 
    ext_window_construction_properties = model_get_construction_properties(model, "ExteriorWindow", standards_construction_type, building_type_category, climate_zone)
    
    # If no construction properties are found at all, return and allow code to use default constructions
    return if ext_window_construction_properties.nil?

    # get wwr as fraction
    wwr = model_get_window_area_info(model, true) / 100
    
    if ext_window_construction_properties['building_category'] == "Nonresidential"
      #calculate VT per Equation 140.3-B 
      min_vlt = 0.11 / (min(0.4, wwr))

      ext_window_construction_properties['assembly_minimum_vt'] = min_vlt
    end

    window_construction_name = "DEER Metal Framed Window U-#{ext_window_construction_properties['assembly_maximum_u_value'].round(2)} SHGC #{ext_window_construction_properties['assembly_maximum_solar_heat_gain'].round(2)}"
    window_construction = model_add_simple_glazing_construction(model, window_construction_name, ext_window_construction_properties)

    # skylights
    standards_construction_type = construction_set_data['exterior_skylight_standards_construction_type']
    skylt_construction_properties = model_get_construction_properties(model, "Skylight", standards_construction_type)

    skylt_construction_name = "DEER Skylight U-#{ext_window_construction_properties['assembly_maximum_u_value'].round(2)} SHGC #{ext_window_construction_properties['assembly_maximum_solar_heat_gain'].round(2)}"
    skylt_construction = model_add_simple_glazing_construction(model, skylt_construction_name, skylt_construction_properties)

    model.getSubSurfaces.each do |subsurface|
      if subsurface.subSurfaceType == "FixedWindow" || subsurface.subSurfaceType == "Operable Window"
        subsurface.setConstruction(window_construction)

      elsif subsurface.subSurfaceType == "Skylight"
        subsurface.setConstruction(skylt_construction)
      end
    end
  end

  # adds simple glazing construction for exterior windows and skylights based on standards data in 'construction_properties'
  def model_add_simple_glazing_construction(model, contruction_name, construction_props = nil)
    # First check model and return construction if it already exists 
    model.getConstructions.sort.each do |construction|
      if construction.name.get.to_s == construction_name
        OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.Model', "Already added construction: #{construction_name}")
        return construction
      end
    end

    OpenStudio.logFree(OpenStudio::Debug, 'openstudio.standards.Model', "Adding construction: #{construction_name}")

    construction = OpenStudio::Model::Construction.new(model)
    construction.setName(construction_name)
    standards_info = construction.standardsInformation

    intended_surface_type = construction_props['intended_surface_type']
    intended_surface_type ||= ''
    standards_info.setIntendedSurfaceType(intended_surface_type)

    standards_construction_type = construction_props['standards_construction_type']
    standards_construction_type ||= ''
    standards_info.setStandardsConstructionType(standards_construction_type)

    # get construction properties
    # add material layers
    layers = OpenStudio::Model::MaterialVector.new

    # add simple glazing material
    material = OpenStudio::Model::SimpleGlazing.new(model)
    material.setName("Simple Glazing")

    material.setUFactor(OpenStudio.convert(construction_props['assembly_maximum_u_value'].to_f, 'Btu/hr*ft^2*R', 'W/m^2*K').get)
    material.setSolarHeatGainCoefficient(construction_props['assembly_maximum_solar_heat_gain'].to_f)
    material.setVisibleTransmittance(construction_props['assembly_minimum_vt'].to_f)

    layers << material
    construction.setLayers(material)

    # adjust U-value for air film
    u_includes_int_film = construction_props['u_value_includes_interior_film_coefficient']
    u_includes_ext_film = construction_props['u_value_includes_exterior_film_coefficient']
    construction_set_glazing_u_value(construction, construction_props['assembly_maximum_u_value'].to_f, construction_props['intended_surface_type'],u_includes_int_film, u_includes_ext_film )

    OpenStudio.logFree(OpenStudio::Info, 'openstudio.standards.Model', "Added construction #{construction.name}.")

    return construction
  end
end