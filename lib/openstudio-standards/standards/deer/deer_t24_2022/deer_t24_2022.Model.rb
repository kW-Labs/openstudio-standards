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

  # this method returns required PV capacity per floor area from Title 24 2022 Table 140.10-A
  # @return [Double] pv capacity per square foot
  def model_get_pv_capacity_per_area(building_type, climate_zone)
    # populate search hash
    search_criteria = {
      'building_type' => building_type,
      'climate_zone_set' => climate_zone 
    }

    # search pv systems table for capacity per floor area
    pv_data = model_find_object(standards_data['pv_system'], search_criteria)
    capacity_per_area = pv_data["pv_capacity_per_square_foot"]

    return capacity_per_area
  end

  # this method returns battery capacity data from Title 24 2022 Table 140.10-B
  # @return [Hash] hash of battery capacity factor data
  def model_get_battery_capacity(building_type)
    # populate search hash
    search_criteria = {
      'building_type' => building_type,
    }

    # search battery storage table for energy capacity
    battery_capacity = model_find_object(standards_data['battery_storage_system'], search_criteria)
    return battery_capacity
  end

  # returns the 'optimal' fixed PV array tilt based on latitude
  # from: https://doi.org/10.1016/j.solener.2018.04.030, Figure 1.
  #
  # @param latitude [Double] building site latitude (degrees)
  # @return [Array] array of [tilt, azimuth]
  def model_pv_optimal_fixed_position(latitude)
    # ensure float
    latitude = latitude.to_f
    if latitude > 0
      # northern hemisphere
      tilt = 1.3793 + latitude * (1.2011 + latitude * (-0.014404 + latitude * 0.000080509))
      # from EnergyPlus I/O: An azimuth angle of 180◦ is for a south-facing array, and an azimuth angle of 0◦ is for anorth-facing array.
      a = 180.0
    else
      # southern hemisphere - calculates negative tilt from negative latitude
      tilt = -0.41657 + latitude * (1.4216 + latitude * (0.024051 + latitude * 0.00021828))
      tilt = abs(tilt)
      a = 0.0
    end
    # To allow for rain to naturally clean panels, optimal tilt angles between −10 and +10° latitude
    # are usually limited to either −10° (for negative values) or +10° (for positive values)
    if tilt.abs < 10.0
      tilt = 10.0
    end
    return tilt, azimuth
  end

  # creates a Generator:PVWatts
  # TODO modify for tracking systems
  def model_add_pvwatts_system(model,
                               name: 'PV System',
                               module_type: 'Standard',
                               array_type: 'Fixed Open Rack',
                               system_losses: nil,
                               azimuth_angle: nil,
                               tilt_angle: nil)

    pvw_generator = OpenStudio::Model::GeneratorPVWatts.new(model, pv_cap_w)
    pvw_generator.setName(name )
    pvw_generator.setModuleType(module_type)
    pvw_generator.setArrayType(array_type)
    pvw_generator.setSystemLosses(system_losses)

    # check if site is poulated
    latitude_defaulted = model.getSite.isLatitudeDefaulted
    if !latitude_defaulted
      latitude = model.getSite.latitude
      # calcaulate optimal fixed tilt
      tilt, azimuth = model_pv_optimal_fixed_position(latitude)
    else
      OpenStudio::logfree(OpenStudio::Info, 'openstudio.standards.Model', "No Site location found: Generator:PVWatts will be created with tilt of 25 degree tilt and 180 degree azimuth.")
      tilt = 25.0
      azimuth = 180.0
    end

    pvw_generator.setAzimuthAngle(azimuth_angle)
    pvw_generator.setTiltAngle(tilt)

    return pvw_generator
  end

  # creates an ElectricLoadCenter:Inverter:PVWatts
  def model_add_pvwatts_inverter(model,
                                 name: 'Default PV System Inverter',
                                 dc_to_ac_size_ratio: 1.10,
                                 inverter_efficiency: 0.96)
    
    pv_watt_inverter = OpenStudio::Model::ElectricLoadCenterInverterPVWatts.new(model)
    pv_watt_inverter.setName(name)
    pv_watt_inverter.setDCToACSizeRatio(dc_to_ac_size_ratio)
    pv_watt_inverter.setInverterEfficiency(inverter_efficiency)

    return pvwatt_inverter
  end

  # creates ElectricLoadCenter:Storage:Simple, modeling a simple battery
  # 
  # @param model [OpenStudio::Model::Model] OpenStudio model object
  # @param name [String] the name of the coil, or nil in which case it will be defaulted
  # @param schedule [String] name of the availability schedule, or [<OpenStudio::Model::Schedule>] Schedule object, or nil in which case default to always on
  # @param rated_inlet_water_temperature [Double] rated inlet water temperature in degrees Celsius, default is hot water loop design exit temperature
  # @return [OpenStudio::Model::ElectricLoadCenterStorageSimple] the battery
  def model_add_electric_storage_simple(model,
                                        name: 'Default Battery Storage',
                                        schedule: nil,
                                        discharge_eff: 0.9,
                                        charge_eff: 0.9,
                                        max_storage_capacity_kwh: nil,
                                        max_charge_power_kw: nil,
                                        max_discharge_power_kw: nil)
    
    battery = OpenStudio::Model::ElectricLoadCenterStorageSimple.new(model)
    battery.setName(name)

    # set battery availability schedule
    if schedule.nil?
      # default always on
      battey_schedule = model.alwaysOnDiscreteSchedule
    elsif schedule.class == String
      if schedule == 'alwaysOffDiscreteSchedule'
        battey_schedule = model.alwaysOffDiscreteSchedule
      else
        battey_schedule = model_add_schedule(model, schedule)
        if battey_schedule.nil?
          battey_schedule = model.alwaysOnDiscreteSchedule
        end
      end
    elsif !schedule.to_Schedule.empty?
      battey_schedule = schedule
    else
      battey_schedule = model.alwaysOnDiscreteSchedule
    end

    battery.setAvailabilitySchedule(battey_schedule)
    battery.setNominalDischargingEnergeticEfficiency(discharge_eff) unless discharge_eff.nil?
    battery.setNominalEnergeticEfficiencyforCharging(charge_eff) unless charge_eff.nil?
    battery.setMaximumPowerforDischarging(max_discharge_power_kw * 1000) unless max_discharge_power_kw.nil?
    battery.setMaximumPowerforCharging(max_charge_power_kw * 1000) unless max_charge_power_kw.nil?
    battery.setMaximumStorageCapacity(OpenStudio.convert(max_storage_capacity_kwh, 'kWh', 'J').get) unless max_storage_capacity_kwh.nil?

    return battery
  end

  # creates ElectricLoadCenter:Storage:Converter, modeling battery storage converter
  # 
  # 
  def model_add_electric_storage_converter(model,
                                           name: 'Storage Converter',
                                           simple_fixed_eff: 1.0)

    storage_converter = OpenStudio::Model::ElectricLoadCenterStorageConverter.new(model)
    storage_converter.setName(name)
    storage_converter.setSimpleFixedEfficiency(simple_fixed_eff)

    return storage_converter
  end

  # creates ElectricLoadCenter:Distribution, modeling an electrical generator and storage system
  # 
  # @param generator_operation_scheme [String] Baseload, DemandLimit, TrackElectrical, TrackSchedule, TrackMeter, FollowThermal, FollowThermalLimitElectrical, default is Baseload
  # @param electric_buss_type [String] AlternatingCurrent, AlternatingCurrentWithStorage, DirectCurrentWithInverter, DirectCurrentWithInverterDCStorage, DirectCurrentWithInverterACStorage, default is DirectCurrentWithInverterDCStorage
  # @param storage_operation_scheme [String] TrackFacilityElectricDemandStoreExcessOnSite, TrackMeterDemandStoreExcessOnSite, TrackChargeDischargeSchedules, FacilityDemandLeveling, default is TrackFacilityElectricDemandStoreExcessOnSite
  def model_add_electric_load_center_distribution(model,
                                                  name: 'PV Battery Load Center',
                                                  electrical_storage: nil,
                                                  storage_converter: nil,
                                                  inverter: nil,
                                                  generators: nil,
                                                  transformer: nil,
                                                  generator_operation_scheme: 'Baseload',
                                                  electric_buss_type: 'DirectCurrentWithInverterDCStorage',
                                                  storage_operation_scheme: 'TrackFacilityElectricDemandStoreExcessOnSite',
                                                  demand_limit_scheme_demand_limit: nil,
                                                  track_schedule_scheme_schedule: nil,
                                                  track_meter_scheme_meter_name: nil,
                                                  storage_control_track_meter_name: nil,
                                                  utility_demand_target: nil,
                                                  demand_target_fraction_schedule: nil,
                                                  charge_power_fraction_schedule: nil,
                                                  discharge_power_fraction_schedule: nil,
                                                  max_storage_state_charge_fraction: 1.0,
                                                  charge_power: nil,
                                                  discharge_power: nil)


    electric_load_center_distribution = OpenStudio::Model::ElectricLoadCenterDistribution.new(model)
    electric_load_center_distribution.setName(name)

    # generators
    if !generators.nil?
      # generator operation scheme
      if OpenStudio::Model::ElectricLoadCenterDistribution.generatorOperationSchemeTypeValues.include? generator_operation_scheme
        electric_load_center_distribution.setGeneratorOperationSchemeType(generator_operation_scheme)
        # TODO: check these inputs
        case generator_operation_scheme
        when 'DemandLimit'
          electric_load_center_distribution.setDemandLimitSchemePurchasedElectricDemandLimit(demand_limit_scheme_demand_limit)
        when 'TrackSchedule'
          electric_load_center_distribution.setTrackScheduleSchemeSchedule(track_schedule_scheme_schedule)
        when 'TrackMeter'
          electric_load_center_distribution.setTrackMeterSchemeMeterName(track_meter_scheme_meter_name)
        end
      else 
        # warn
        electric_load_center_distribution.setGeneratorOperationSchemeType('Baseload')
      end
      # add generators
      generators.each do |generator|
        electric_load_center_distribution.addGenerator(gpv)
      end
    else
      # warn nothing will be created
      return false
    end

    # buss type
    if OpenStudio::Model::ElectricLoadCenterDistribution.electricalBussTypeValues.include? electric_buss_type
      electric_load_center_distribution.setElectricalBussType(electric_buss_type)
      case 
      when electric_buss_type.match(/Inverter/)
        electric_load_center_distribution.setInverter(pv_inv)
      when electric_buss_type.match(/Storage/)
        electric_load_center_distribution.setElectricalStorage(elcs)
    else
      # warn
      electric_load_center_distribution.setElectricalBussType('DirectCurrentWithInverterDCStorage')
    end

    # storage operation scheme
    if OpenStudio::Model::ElectricLoadCenterDistribution.storageOperationSchemeValues.include? storage_operation_scheme 
      electric_load_center_distribution.setStorageOperationScheme(storage_operation_scheme)
      case storage_operation_scheme
      when "FacilityDemandLeveling"
        electric_load_center_distribution.setStorageControlUtilityDemandTarget(utility_demand_target * 1000) unless utility_demand_target.nil?
        electric_load_center_distribution.setStorageControlUtilityDemandTargetFractionSchedule(model.alwaysOnDiscreteSchedule)
        electric_load_center_distribution.setStorageDischargePowerFractionSchedule(model.alwaysOnDiscreteSchedule)
        electric_load_center_distribution.setStorageChargePowerFractionSchedule(model.alwaysOnDiscreteSchedule)
        electric_load_center_distribution.setStorageConverter(elcsc)
        electric_load_center_distribution.setDesignStorageControlChargePower(power * 1000)
        electric_load_center_distribution.setDesignStorageControlDischargePower(power * 1000)
      when "TrackChargeDischargeSchedules"
        electric_load_center_distribution.setStorageDischargePowerFractionSchedule(discharge_power_fraction_schedule)
        electric_load_center_distribution.setStorageChargePowerFractionSchedule(charge_power_fraction_schedule)
        electric_load_center_distribution.setStorageConverter(elcsc)
        electric_load_center_distribution.setDesignStorageControlChargePower(power * 1000)
        electric_load_center_distribution.setDesignStorageControlDischargePower(power * 1000)
      when 'TrackMeterDemandStoreExcessOnSite'
        electric_load_center_distribution.setStorageControlTrackMeterName(storage_control_track_meter_name)
      end
    else 
      # warn
      electric_load_center_distribution.setStorageOperationScheme("TrackFacilityElectricDemandStoreExcessOnSite")
    end

    electric_load_center_distribution.setMaximumStorageStateofChargeFraction(max_storage_state_charge_fraction)


    return electric_load_center_distribution 
  end


  # this method adds Photovoltaic system and battery storage systme required by Title 24 2022
  # TODO: Support multiple building types
  def model_create_t24_pv_storage_system(model, building_type, climate_zone)
    # calculate required pv system capacity

    # determine solar access roof area
    solar_roof_area_si = find_solar_access_roof_area(model)
    solar_roof_area_ip = OpenStudio.convert(solar_roof_area_si, "m^2", "ft^2").get

    # get conditioned floor area
    conditioned_area_si
    model.getSpaces.each do |space|
      cooled = space_cooled?(space)
      heated = space_heated?(space)
      if heated || cooled
        conditioned_area_si += space.grossArea * space.multiplier
      end
    end

    conditioned_area_ip = OpenStudio.convert(conditioned_area_si, "m^2", "ft^2").get

    # get required system capacity per area
    capacity_per_square_foot = model_get_pv_capacity_per_area(building_type, climate_zone)

    # PV size in kW_dc shall be not less than the smaller of the PV system size determined by Equation 140.10-A, 
    # or the total of all available Solar Access Roof Areas multiplied by 14 W/ft^2

    kw_dc_floor_area = (conditioned_area_ip * capacity_per_square_foot) / 1000
    kw_dc_roof_area = solar_roof_area_ip * 14.0
    pv_size_kw = min(kw_dc_floor_area, kw_dc_roof_area)

    # evaluate exceptions to 140.10(a)
    if solar_roof_area_ip < (conditioned_area_ip * 0.03)
      OpenStudio::logfree(OpenStudio::Info, 'openstudio.standards.Model', "Exception 1 to Section 140.10(a).  No PV system is required where the total of all available SARA is less than 
      three percent of the conditioned floor area.")
      return true
    elsif pv_size_kw < 4.0
      OpenStudio::logfree(OpenStudio::Info, 'openstudio.standards.Moodel', "Exception 2 to Section 140.10(a).  No PV system is required where the required PV system size is less than 4 
      kWdc.")
      return true
    elsif solar_roof_area_ip < 80.0
      OpenStudio::logfree(OpenStudio::Info, 'openstudio.standards.Moodel', "Exception 3 to Section 140.10(a). No PV system is required if the SARA contains less than 80 contiguous square 
      feet.")
      return true
    else
      OpenStudio::logfree(OpenStudio::Info, 'openstudio.standards.Moodel', "Creating a PV System with capacity of #{pv_size_kw.round(2)} kW DC.")
    end

    # calculate battery energy capacity per Equation 140.10-B

    battery_data = model_get_battery_capacity(building_type)
    b_factor = battery_data["battery_storage_factor_b_energy_capacity"]
    
    # D factor is Rated single charge-discharge cycle AC to AC (round-trip) efficiency of the battery storage system
    # default value is 0.95 * 0.95 from CBECC Rule Batt:RoundTripEff
    d_factor = 0.95 * 0.95

    battery_kwh = (pv_size_kw * b_factor) / (d_factor ** 0.5)

    # calculate battery power caapacity per Equation 140.10-C
    c_factor = battery_data["battery_storage_factor_c_power_capacity"]
    
    battery_kw = (pv_size_kw * c_factor)


  end

end