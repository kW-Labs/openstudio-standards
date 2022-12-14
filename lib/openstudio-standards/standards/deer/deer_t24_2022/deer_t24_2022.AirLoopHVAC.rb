class DEERT242022 < DEER
  # @!group AirLoopHVAC
  # Determine if the system required supply air temperature (SAT) reset.
  # Defaults to true for T24 2022.
  #
  # @param air_loop_hvac [OpenStudio::Model::AirLoopHVAC] air loop
  # @param climate_zone [String] ASHRAE climate zone, e.g. 'ASHRAE 169-2013-4A'
  # @return [Bool] returns true if required, false if not
  def air_loop_hvac_supply_air_temperature_reset_required?(air_loop_hvac, climate_zone)
    is_sat_reset_required = true
    return is_sat_reset_required
  end

  # Determine if a system's fans must shut off when not required.
  # Per Title 24 120.2(e), HVAC systems are required to have off-hour controls
  #
  # @param air_loop_hvac [OpenStudio::Model::AirLoopHVAC] air loop
  # @return [Bool] returns true if required, false if not
  def air_loop_hvac_unoccupied_fan_shutoff_required?(air_loop_hvac)
    shutoff_required = true
    return shutoff_required
  end

  # Determine if a motorized OA damper is required
  # Defaults to true for DEER 2020.
  #
  # @param air_loop_hvac [OpenStudio::Model::AirLoopHVAC] air loop
  # @param climate_zone [String] ASHRAE climate zone, e.g. 'ASHRAE 169-2013-4A'
  # @return [Bool] returns true if required, false if not
  def air_loop_hvac_motorized_oa_damper_required?(air_loop_hvac, climate_zone)
    motorized_oa_damper_required = true
    return motorized_oa_damper_required
  end

  # Shut off the system during unoccupied periods.
  # During these times, systems will cycle on briefly if temperature drifts below setpoint.
  # For systems with fan-powered terminals, the whole system (not just the terminal fans) will cycle on.
  # Terminal-only night cycling is not used because the terminals cannot provide cooling,
  # so terminal-only night cycling leads to excessive unmet cooling hours during unoccupied periods.
  # If the system already has a schedule other than Always-On, no change will be made.
  # If the system has an Always-On schedule assigned, a new schedule will be created.
  # In this case, occupied is defined as the total percent occupancy for the loop for all zones served.
  #
  # @param air_loop_hvac [OpenStudio::Model::AirLoopHVAC] air loop
  # @param min_occ_pct [Double] the fractional value below which the system will be considered unoccupied.
  # @return [Bool] returns true if successful, false if not
  def air_loop_hvac_enable_unoccupied_fan_shutoff(air_loop_hvac, min_occ_pct = 0.05)
    # Set the system to night cycle
    air_loop_hvac.setNightCycleControlType('CycleOnAny')

    # Check if already using a schedule other than always on
    avail_sch = air_loop_hvac.availabilitySchedule
    unless avail_sch == air_loop_hvac.model.alwaysOnDiscreteSchedule
      OpenStudio.logFree(OpenStudio::Info, 'openstudio.standards.AirLoopHVAC', "For #{air_loop_hvac.name}: Availability schedule is already set to #{avail_sch.name}.  Will assume this includes unoccupied shut down; no changes will be made.")
      return true
    end

    # Get the airloop occupancy schedule
    loop_occ_sch = air_loop_hvac_get_occupancy_schedule(air_loop_hvac, occupied_percentage_threshold: min_occ_pct)
    flh = schedule_ruleset_annual_equivalent_full_load_hrs(loop_occ_sch)
    OpenStudio.logFree(OpenStudio::Info, 'openstudio.standards.AirLoopHVAC', "For #{air_loop_hvac.name}: Annual occupied hours = #{flh.round} hr/yr, assuming a #{min_occ_pct} occupancy threshold.  This schedule will be used as the HVAC operation schedule.")

    # Set HVAC availability schedule to follow occupancy
    air_loop_hvac.setAvailabilitySchedule(loop_occ_sch)
    air_loop_hvac.supplyComponents.each do |comp|
      if comp.to_AirLoopHVACUnitaryHeatPumpAirToAirMultiSpeed.is_initialized
        comp.to_AirLoopHVACUnitaryHeatPumpAirToAirMultiSpeed.get.setSupplyAirFanOperatingModeSchedule(loop_occ_sch)
      elsif comp.to_AirLoopHVACUnitarySystem.is_initialized
        unless comp.to_AirLoopHVACUnitarySystem.get.controlType == "SetPoint"
          comp.to_AirLoopHVACUnitarySystem.get.setSupplyAirFanOperatingModeSchedule(loop_occ_sch)
        end
      end
    end

    return true
  end


end
