class Standard
  # @!group AirConditionerVariableRefrigerantFlow

  def air_conditioner_variable_refrigerant_flow_find_cooling_capacity(air_conditioner_vrf)
    cooling_capacity_w = nil
    heating_capacity_w = nil

    if air_conditioner_vrf.grossRatedTotalCoolingCapacity.is_initialized
      capacity_w = air_conditioner_vrf.grossRatedTotalCoolingCapacity.get
    elsif air_conditioner_vrf.autosizedGrossRatedTotalCoolingCapacity.is_initialized
      capacity_w = air_conditioner_vrf.autosizedGrossRatedTotalCoolingCapacity.get
    else
      OpenStudio.logFree(OpenStudio::Warn, 'openstudio.standards.AirConditionerVariableRefrigerantFlow', "For #{air_conditioner_vrf.name} capacity is not available, cannot apply efficiency standard.")
      return 0.0
    end

    return capacity_w
  end

  def air_conditioner_variable_refrigerant_flow_standard_minimum_cooling_and_heating_cops(air_conditioner_vrf, rename = false)
    search_criteria = {}
    search_criteria['template'] = template
    search_criteria['cooling_type'] = 'AirCooled'
    search_criteria['heating_type'] = 'HeatPump'
    cooling_type = search_criteria['cooling_type']
    heating_type = search_criteria['heating_type']
    capacity_w = air_conditioner_variable_refrigerant_flow_find_cooling_capacity(air_conditioner_vrf)
    capacity_btu_per_hr = OpenStudio.convert(capacity_w, 'W', 'Btu/hr').get
    capacity_kbtu_per_hr = OpenStudio.convert(capacity_w, 'W', 'kBtu/hr').get.round(2)
    return nil unless capacity_btu_per_hr > 0.0
    
    # Look up the efficiency characteristics
    vrf_props = model_find_object(standards_data['air_conditioner_vrf'], search_criteria, capacity_btu_per_hr)

    # Check to make sure properties were found
    if vrf_props.nil?
      OpenStudio.logFree(OpenStudio::Warn, 'openstudio.standards.AirConditionerVariableRefrigerantFlow', "For #{air_conditioner_vrf.name}, cannot find efficiency info using #{search_criteria}, cannot apply efficiency standard.")
      successfully_set_all_properties = false
      return successfully_set_all_properties
    end

    # get the minimum efficiency standards
    cooling_cop = nil
    heating_cop = nil 

    # if cooling specified as SEER
    unless vrf_props['minimum_seasonal_energy_efficiency_ratio'].nil?
      min_seer = vrf_props['minimum_seasonal_energy_efficiency_ratio']
      cooling_cop = seer_to_cop_with_fan(min_seer)
      new_comp_name = "#{air_conditioner_vrf.name.get} #{capacity_kbtu_per_hr}kBtu/hr #{min_seer}SEER"
      OpenStudio.logFree(OpenStudio::Info, 'openstudio.standards.AirConditionerVariableRefrigerantFlow', "For #{template}: #{air_conditioner_vrf.name}: #{cooling_type} #{heating_type} Capacity = #{capacity_kbtu_per_hr.round}kBtu/hr; SEER = #{min_seer}")
    end

    # if cooling specified as EER
    unless vrf_props['minimum_energy_efficiency_ratio'].nil?
      min_eer = vrf_props['minimum_energy_efficiency_ratio']
      cooling_cop = eer_to_cop(min_eer)
      new_comp_name = "#{air_conditioner_vrf.name.get} #{capacity_kbtu_per_hr}kBtu/hr #{min_eer}EER"
      OpenStudio.logFree(OpenStudio::Info, 'openstudio.standards.AirConditionerVariableRefrigerantFlow', "For #{template}: #{air_conditioner_vrf.name}: #{cooling_type} #{heating_type} Capacity = #{capacity_kbtu_per_hr.round}kBtu/hr; EER = #{min_eer}")
    end

    # if heating specified as COP
    unless vrf_props['minimum_heating_efficiency'].nil?
      heating_cop = vrf_props['minimum_heating_efficiency']
      new_comp_name = "#{new_comp_name} #{heating_cop}HCOP"
      OpenStudio.logFree(OpenStudio::Info, 'openstudio.standards.AirConditionerVariableRefrigerantFlow', "For #{template}: #{air_conditioner_vrf.name}: #{cooling_type} #{heating_type} Cooling Capacity = #{capacity_kbtu_per_hr.round}kBtu/hr; Heating COP = #{heating_cop}")
    end

    # if specified as HSPF
    unless vrf_props['minimum_heating_seasonal_performance_factor'].nil?
      min_hspf = vrf_props['minimum_heating_seasonal_performance_factor']
      heating_cop = hspf_to_cop_heating_with_fan(min_hspf)
      new_comp_name = "#{new_comp_name} #{min_hspf}HSPF"
      OpenStudio.logFree(OpenStudio::Info, 'openstudio.standards.AirConditionerVariableRefrigerantFlow', "For #{template}: #{air_conditioner_vrf.name}: #{cooling_type} #{heating_type} Cooling Capacity = #{capacity_kbtu_per_hr.round}kBtu/hr; HSPF = #{min_hspf}")
    end

    if rename
      air_conditioner_vrf.setName(new_comp_name)
    end

    return [cooling_cop, heating_cop]
  end


  # TODO: make curves from data - for now use default curves and just set efficiency
  def air_conditioner_variable_refrigerant_flow_apply_efficiency_and_curves(air_conditioner_vrf, sql_db_vars_map)
    successfully_set_all_properties = true

    # preserve original name
    orig_name = air_conditioner_vrf.name.to_s

    # find minimum cooling cop
    cop_cooling, cop_heating = air_conditioner_variable_refrigerant_flow_standard_minimum_cooling_and_heating_cops(air_conditioner_vrf, true)
    
    # map the original name to th enew name
    sql_db_vars_map[air_conditioner_vrf.name.to_s] = orig_name

    # set the efficiency values
    unless cop_cooling.nil?
      air_conditioner_vrf.setRatedCoolingCOP(cop_cooling)
    end
    unless cop_heating.nil?
      air_conditioner_vrf.setRatedHeatingCOP(cop_heating)
    end
    
    return sql_db_vars_map
  end

end
