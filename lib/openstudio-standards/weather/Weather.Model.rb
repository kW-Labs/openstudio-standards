class Standard
  # Helper method to set the weather file, import the design days, set
  # water mains temperature, and set ground temperature.
  # Based on ChangeBuildingLocation measure by Nicholas Long

  # A method to return an array of .epw files names mapped to each climate zone
  #
  # @param epw_file [String] optional epw_file name for NECB methods
  # @return [Hash] a hash of ashrae climate zone weather file pairs
  def model_get_climate_zone_weather_file_map(epw_file = '')
    # Define the weather file for each climate zone
    climate_zone_weather_file_map = {
      'ASHRAE 169-2006-0A' => 'VNM_SVN_Ho.Chi.Minh-Tan.Son.Nhat.Intl.AP.489000_TMYx.epw',
      'ASHRAE 169-2006-0B' => 'ARE_DU_Dubai.Intl.AP.411940_TMYx.epw',
      'ASHRAE 169-2006-1A' => 'USA_FL_Miami.Intl.AP.722020_TMY3.epw',
      'ASHRAE 169-2006-1B' => 'SAU_RI_Riyadh.AB.404380_TMYx.epw',
      'ASHRAE 169-2006-2A' => 'USA_TX_Houston-Bush.Intercontinental.AP.722430_TMY3.epw',
      'ASHRAE 169-2006-2B' => 'USA_AZ_Phoenix-Sky.Harbor.Intl.AP.722780_TMY3.epw',
      'ASHRAE 169-2006-3A' => 'USA_TN_Memphis.Intl.AP.723340_TMY3.epw',
      'ASHRAE 169-2006-3B' => 'USA_TX_El.Paso.Intl.AP.722700_TMY3.epw',
      'ASHRAE 169-2006-3C' => 'USA_CA_San.Francisco.Intl.AP.724940_TMY3.epw',
      'ASHRAE 169-2006-4A' => 'USA_MD_Baltimore-Washington.Intl.AP.724060_TMY3.epw',
      'ASHRAE 169-2006-4B' => 'USA_NM_Albuquerque.Intl.AP.723650_TMY3.epw',
      'ASHRAE 169-2006-4C' => 'USA_OR_Salem-McNary.Field.726940_TMY3.epw',
      'ASHRAE 169-2006-5A' => 'USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.epw',
      'ASHRAE 169-2006-5B' => 'USA_ID_Boise.Air.Terminal.726810_TMY3.epw',
      'ASHRAE 169-2006-5C' => 'CAN_BC_Vancouver.718920_CWEC.epw',
      'ASHRAE 169-2006-6A' => 'USA_VT_Burlington.Intl.AP.726170_TMY3.epw',
      'ASHRAE 169-2006-6B' => 'USA_MT_Helena.Rgnl.AP.727720_TMY3.epw',
      'ASHRAE 169-2006-7A' => 'USA_MN_Duluth.Intl.AP.727450_TMY3.epw',
      'ASHRAE 169-2006-7B' => 'USA_MN_Duluth.Intl.AP.727450_TMY3.epw',
      'ASHRAE 169-2006-8A' => 'USA_AK_Fairbanks.Intl.AP.702610_TMY3.epw',
      'ASHRAE 169-2006-8B' => 'USA_AK_Fairbanks.Intl.AP.702610_TMY3.epw',
      'ASHRAE 169-2013-0A' => 'VNM_SVN_Ho.Chi.Minh-Tan.Son.Nhat.Intl.AP.489000_TMYx.epw',
      'ASHRAE 169-2013-0B' => 'ARE_DU_Dubai.Intl.AP.411940_TMYx.epw',
      'ASHRAE 169-2013-1A' => 'USA_HI_Honolulu.Intl.AP.911820_TMY3.epw',
      'ASHRAE 169-2013-1B' => 'IND_DL_New.Delhi-Safdarjung.AP.421820_TMYx.epw',
      'ASHRAE 169-2013-2A' => 'USA_FL_Tampa-MacDill.AFB.747880_TMY3.epw',
      'ASHRAE 169-2013-2B' => 'USA_AZ_Tucson-Davis-Monthan.AFB.722745_TMY3.epw',
      'ASHRAE 169-2013-3A' => 'USA_GA_Atlanta-Hartsfield.Jackson.Intl.AP.722190_TMY3.epw',
      'ASHRAE 169-2013-3B' => 'USA_TX_El.Paso.Intl.AP.722700_TMY3.epw',
      'ASHRAE 169-2013-3C' => 'USA_CA_San.Deigo-Brown.Field.Muni.AP.722904_TMY3.epw',
      'ASHRAE 169-2013-4A' => 'USA_NY_New.York-John.F.Kennedy.Intl.AP.744860_TMY3.epw',
      'ASHRAE 169-2013-4B' => 'USA_NM_Albuquerque.Intl.Sunport.723650_TMY3.epw',
      'ASHRAE 169-2013-4C' => 'USA_WA_Seattle-Tacoma.Intl.AP.727930_TMY3.epw',
      'ASHRAE 169-2013-5A' => 'USA_NY_Buffalo.Niagara.Intl.AP.725280_TMY3.epw',
      'ASHRAE 169-2013-5B' => 'USA_CO_Denver-Aurora-Buckley.AFB.724695_TMY3.epw',
      'ASHRAE 169-2013-5C' => 'USA_WA_Port.Angeles-William.R.Fairchild.Intl.AP.727885_TMY3.epw',
      'ASHRAE 169-2013-6A' => 'USA_MN_Rochester.Intl.AP.726440_TMY3.epw',
      'ASHRAE 169-2013-6B' => 'USA_MT_Great.Falls.Intl.AP.727750_TMY3.epw',
      'ASHRAE 169-2013-7A' => 'USA_MN_International.Falls.Intl.AP.727470_TMY3.epw',
      'ASHRAE 169-2013-7B' => 'USA_MN_International.Falls.Intl.AP.727470_TMY3.epw',
      'ASHRAE 169-2013-8A' => 'USA_AK_Fairbanks.Intl.AP.702610_TMY3.epw',
      'ASHRAE 169-2013-8B' => 'USA_AK_Fairbanks.Intl.AP.702610_TMY3.epw',
      # For measure input
      'NECB HDD Method' => epw_file.to_s,
      # For testing
      'NECB-CNEB-5' => epw_file.to_s,
      'NECB-CNEB-6' => epw_file.to_s,
      'NECB-CNEB-7a' => epw_file.to_s,
      'NECB-CNEB-7b' => epw_file.to_s,
      'NECB-CNEB-8' => epw_file.to_s,
      # For DEER
      'CEC T24-CEC1' => 'CTZ01S22A.epw',
      'CEC T24-CEC2' => 'CTZ02S22A.epw',
      'CEC T24-CEC3' => 'CTZ03S22A.epw',
      'CEC T24-CEC4' => 'CTZ04S22A.epw',
      'CEC T24-CEC5' => 'CTZ05S22A.epw',
      'CEC T24-CEC6' => 'CTZ06S22A.epw',
      'CEC T24-CEC7' => 'CTZ07S22A.epw',
      'CEC T24-CEC8' => 'CTZ08S22A.epw',
      'CEC T24-CEC9' => 'CTZ09S22A.epw',
      'CEC T24-CEC10' => 'CTZ10S22A.epw',
      'CEC T24-CEC11' => 'CTZ11S22A.epw',
      'CEC T24-CEC12' => 'CTZ12S22A.epw',
      'CEC T24-CEC13' => 'CTZ13S22A.epw',
      'CEC T24-CEC14' => 'CTZ14S22A.epw',
      'CEC T24-CEC15' => 'CTZ15S22A.epw',
      'CEC T24-CEC16' => 'CTZ16S22A.epw'
    }
    return climate_zone_weather_file_map
  end

  # Get absolute path of a weather file included within openstudio-standards
  #
  # @param weather_file_name [String] Name of a weather file include within openstudio-standards
  # @return [String] Weather file path
  def model_get_weather_file(weather_file_name)
    # Define where the weather files lives
    weather_dir = nil
    if __dir__[0] == ':' # Running from OpenStudio CLI
      # load weather file from embedded files
      epw_string = load_resource_relative("../../../data/weather/#{weather_file_name}")
      ddy_string = load_resource_relative("../../../data/weather/#{weather_file_name.gsub('.epw', '.ddy')}")
      stat_string = load_resource_relative("../../../data/weather/#{weather_file_name.gsub('.epw', '.stat')}")

      # extract to local weather dir
      weather_dir = File.expand_path(File.join(Dir.pwd, 'extracted_files/weather/'))
      OpenStudio.logFree(OpenStudio::Info, 'openstudio.weather.Model', "Extracting weather files from OpenStudio CLI to #{weather_dir}")
      FileUtils.mkdir_p(weather_dir)

      path_length = "#{weather_dir}/#{weather_file_name}".length
      if path_length > 260
        OpenStudio.logFree(OpenStudio::Warn, 'openstudio.weather.Model', "Weather file path length #{path_length} is >260 characters and may cause issues in Windows environments.")
      end
      File.open("#{weather_dir}/#{weather_file_name}", 'wb') { |f| f << epw_string; f.flush }
      File.open("#{weather_dir}/#{weather_file_name.gsub('.epw', '.ddy')}", 'wb') { |f| f << ddy_string; f.flush }
      File.open("#{weather_dir}/#{weather_file_name.gsub('.epw', '.stat')}", 'wb') { |f| f << stat_string; f.flush }
    else
      # loaded gem from system path
      top_dir = File.expand_path('../../..', File.dirname(__FILE__))
      weather_dir = File.expand_path("#{top_dir}/data/weather")
    end

    # Add Weather File
    unless (Pathname.new weather_dir).absolute?
      weather_dir = File.expand_path(File.join(File.dirname(__FILE__), weather_dir))
    end

    weather_file = File.join(weather_dir, weather_file_name)

    return weather_file
  end

  # Adds the design days and weather file for the specified climate zone
  #
  # @param model [OpenStudio::Model::Model] OpenStudio model object
  # @param climate_zone [String] ASHRAE climate zone, e.g. 'ASHRAE 169-2013-4A'
  # @param epw_file [String] the name of the epw file; if blank will default to epw file for the ASHRAE climate zone
  # @return [Bool] returns true if successful, false if not
  def model_add_design_days_and_weather_file(model, climate_zone, epw_file = '', weather_dir = nil)
    success = true
    require_relative 'Weather.stat_file'

    # Remove any existing Design Day objects that are in the file
    model.getDesignDays.each(&:remove)

    OpenStudio.logFree(OpenStudio::Info, 'openstudio.weather.Model', "Started adding weather file for climate zone: #{climate_zone}.")

    # Define the weather file for each climate zone
    climate_zone_weather_file_map = model_get_climate_zone_weather_file_map(epw_file)

    # Get the weather file name from the hash
    weather_file_name = if epw_file.nil? || (epw_file.to_s.strip == '')
                          climate_zone_weather_file_map[climate_zone]
                        else
                          epw_file.to_s
                        end
    if weather_file_name.nil?
      OpenStudio.logFree(OpenStudio::Error, 'openstudio.weather.Model', "Could not determine the weather file for climate zone: #{climate_zone}.")
      success = false
    end

    weather_file = model_get_weather_file(weather_file_name)

    epw_file = OpenStudio::EpwFile.new(weather_file)
    OpenStudio::Model::WeatherFile.setWeatherFile(model, epw_file).get

    weather_name = "#{epw_file.city}_#{epw_file.stateProvinceRegion}_#{epw_file.country}"
    weather_lat = epw_file.latitude
    weather_lon = epw_file.longitude
    weather_time = epw_file.timeZone
    weather_elev = epw_file.elevation

    # Add or update site data
    site = model.getSite
    site.setName(weather_name)
    site.setLatitude(weather_lat)
    site.setLongitude(weather_lon)
    site.setTimeZone(weather_time)
    site.setElevation(weather_elev)

    # Add SiteWaterMainsTemperature -- via parsing of STAT file.
    stat_filename = "#{File.join(File.dirname(weather_file), File.basename(weather_file, '.*'))}.stat"
    if File.exist? stat_filename
      stat_file = EnergyPlus::StatFile.new(stat_filename)
      water_temp = model.getSiteWaterMainsTemperature
      water_temp.setAnnualAverageOutdoorAirTemperature(stat_file.mean_dry_bulb)
      water_temp.setMaximumDifferenceInMonthlyAverageOutdoorAirTemperatures(stat_file.delta_dry_bulb)
      # OpenStudio::logFree(OpenStudio::Info, "openstudio.weather.Model", "Mean dry bulb is #{stat_file.mean_dry_bulb}")
      # OpenStudio::logFree(OpenStudio::Info, "openstudio.weather.Model", "Delta dry bulb is #{stat_file.delta_dry_bulb}")
    else
      OpenStudio.logFree(OpenStudio::Warn, 'openstudio.weather.Model', 'Could not find .stat file for weather, will use default water mains temperatures which may be inaccurate for the location.')
      success = false
    end

    # Load in the ddy file based on convention that it is in
    # the same directory and has the same basename as the epw file.
    ddy_file = "#{File.join(File.dirname(weather_file), File.basename(weather_file, '.*'))}.ddy"
    if File.exist? ddy_file
      ddy_model = OpenStudio::EnergyPlus.loadAndTranslateIdf(ddy_file).get
      ddy_model.getObjectsByType('OS:SizingPeriod:DesignDay'.to_IddObjectType).sort.each do |d|
        # Import the 99.6% Heating and 0.4% Cooling design days
        ddy_list = /(Htg 99.6. Condns DB)|(Clg .4% Condns DB=>MWB)|(Clg 0.4% Condns DB=>MCWB)/
        if d.name.get =~ ddy_list
          model.addObject(d.clone)
          OpenStudio.logFree(OpenStudio::Info, 'openstudio.weather.Model', "Added #{d.name} design day.")
        end
      end
      # Check to ensure that some design days were added
      if model.getDesignDays.size.zero?
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.weather.Model', "No design days were loaded, check syntax of .ddy file: #{ddy_file}.")
      end
    else
      OpenStudio.logFree(OpenStudio::Error, 'openstudio.weather.Model', "Could not find .ddy file for: #{ddy_file}.")
      success = false
    end

    return success
  end

  # Adds ground temperatures to the model based on a building type and climate zone lookup
  # It will first attempt to find ground temperatures from the .stat file associated with the epw
  # Otherwise, it will use values from the prototypes per a given template, building type, and climate zone
  # If neither are available, it will default to a set of typical ground temperatures
  #
  # @param model [OpenStudio::Model::Model] OpenStudio model object
  # @param [String] openstudio-standards building type
  # @param [String] ASHRAE climate zone, e.g. 'ASHRAE 169-2013-4A'
  # @return [Bool] returns true if successful, false if not
  def model_add_ground_temperatures(model, building_type, climate_zone)
    # Define the weather file for each climate zone
    climate_zone_weather_file_map = model_get_climate_zone_weather_file_map

    # Get the weather file name from the hash
    weather_file_name = climate_zone_weather_file_map[climate_zone]
    if weather_file_name.nil?
      OpenStudio.logFree(OpenStudio::Warn, 'openstudio.weather.Model', "Could not determine the weather file for climate zone: #{climate_zone}, cannot get ground temperatures from stat file.")
    end

    # Get the path to the stat file
    weather_file = model_get_weather_file(weather_file_name)

    # Add ground temperatures via parsing of STAT file.
    ground_temperatures = []
    stat_file_path = "#{File.join(File.dirname(weather_file), File.basename(weather_file, '.*'))}.stat"
    if File.exist? stat_file_path
      ground_temperatures = model_get_monthly_ground_temps_from_stat_file(stat_file_path)
      unless ground_temperatures.empty?
        # set the site ground temperature building surface
        ground_temp = model.getSiteGroundTemperatureFCfactorMethod
        ground_temp.setAllMonthlyTemperatures(ground_temperatures)
      end
    end

    # Return if ground temperatures were found
    return unless ground_temperatures.empty?

    # If stat_file_path did not turn up an EPW file, set default ground temperatures
    OpenStudio.logFree(OpenStudio::Warn, 'openstudio.weather.Model', 'Could not find ground temperatures in stat file; will use standards lookup.')

    # Look up ground temperatures from templates
    ground_temp_vals = standards_lookup_table_first(table_name: 'ground_temperatures', search_criteria: { 'template' => template, 'climate_zone' => climate_zone, 'building_type' => building_type })
    if ground_temp_vals && ground_temp_vals['jan']
      ground_temp = model.getSiteGroundTemperatureBuildingSurface
      ground_temp.setJanuaryGroundTemperature(ground_temp_vals['jan'])
      ground_temp.setFebruaryGroundTemperature(ground_temp_vals['feb'])
      ground_temp.setMarchGroundTemperature(ground_temp_vals['mar'])
      ground_temp.setAprilGroundTemperature(ground_temp_vals['apr'])
      ground_temp.setMayGroundTemperature(ground_temp_vals['may'])
      ground_temp.setJuneGroundTemperature(ground_temp_vals['jun'])
      ground_temp.setJulyGroundTemperature(ground_temp_vals['jul'])
      ground_temp.setAugustGroundTemperature(ground_temp_vals['aug'])
      ground_temp.setSeptemberGroundTemperature(ground_temp_vals['sep'])
      ground_temp.setOctoberGroundTemperature(ground_temp_vals['oct'])
      ground_temp.setNovemberGroundTemperature(ground_temp_vals['nov'])
      ground_temp.setDecemberGroundTemperature(ground_temp_vals['dec'])
    else
      OpenStudio.logFree(OpenStudio::Warn, 'openstudio.weather.Model', 'Could not find ground temperatures in standards lookup; will use generic temperatures, which will skew results.')
      ground_temp = model.getSiteGroundTemperatureBuildingSurface
      ground_temp.setJanuaryGroundTemperature(19.527)
      ground_temp.setFebruaryGroundTemperature(19.502)
      ground_temp.setMarchGroundTemperature(19.536)
      ground_temp.setAprilGroundTemperature(19.598)
      ground_temp.setMayGroundTemperature(20.002)
      ground_temp.setJuneGroundTemperature(21.640)
      ground_temp.setJulyGroundTemperature(22.225)
      ground_temp.setAugustGroundTemperature(22.375)
      ground_temp.setSeptemberGroundTemperature(21.449)
      ground_temp.setOctoberGroundTemperature(20.121)
      ground_temp.setNovemberGroundTemperature(19.802)
      ground_temp.setDecemberGroundTemperature(19.633)
    end
  end

  # Returns the winter design outdoor air dry bulb temperatures in the model
  #
  # @param model [OpenStudio::Model::Model] OpenStudio model object
  # @return [Array<Double>] an array of outdoor design dry bulb temperatures in degrees Celsius
  def model_get_heating_design_outdoor_temperatures(model)
    heating_design_outdoor_temps = []
    model.getDesignDays.each do |dd|
      next unless dd.dayType == 'WinterDesignDay'

      heating_design_outdoor_temps << dd.maximumDryBulbTemperature
    end

    return heating_design_outdoor_temps
  end

  # This function gets the average ground temperature averages, under the assumption that ground temperature
  # lags 3 months behind the ambient dry bulb temperature.
  # (e.g. April's ground temperature equal January's average dry bulb temperature)
  #
  # @param stat_file_path [String] path to STAT file
  # @return [Array<Double>] a length 12 array of monthly ground temperatures, one for each month
  def model_get_monthly_ground_temps_from_stat_file(stat_file_path)
    if File.exist? stat_file_path
      stat_file = EnergyPlus::StatFile.new(stat_file_path)
      monthly_dry_bulb = stat_file.monthly_dry_bulb[0..11]
      ground_temperatures = monthly_dry_bulb.rotate(-3)
      return ground_temperatures
    else
      OpenStudio.logFree(OpenStudio::Error, 'openstudio.weather.Model', "Stat file: #{stat_file_path} was not found when calculating ground temperatures.")
      return []
    end
  end
end

# *********************************************************************
# *  Copyright (c) 2008-2015, Natural Resources Canada
# *  All rights reserved.
# *
# *  This library is free software; you can redistribute it and/or
# *  modify it under the terms of the GNU Lesser General Public
# *  License as published by the Free Software Foundation; either
# *  version 2.1 of the License, or (at your option) any later version.
# *
# *  This library is distributed in the hope that it will be useful,
# *  but WITHOUT ANY WARRANTY; without even the implied warranty of
# *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# *  Lesser General Public License for more details.
# *
# *  You should have received a copy of the GNU Lesser General Public
# *  License along with this library; if not, write to the Free Software
# *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
# **********************************************************************/

# This module has been created to make it easier to manipulate weather files can contains region specific data.

module BTAP
  module Environment
    require_relative 'Weather.stat_file'

    # this method is used to populate user interfaces if needed from the hash above.
    def self.get_canadian_weather_file_names
      canadian_file_names = []
      if __dir__[0] == ':' # Running from OpenStudio CLI
        embedded_files_relative('../../../', /.*\.epw/).each do |file|
          canadian_file_names << File.basename(file).to_s
        end
      else
        Dir.glob("#{File.dirname(__FILE__)}/../../../**/*.epw").each do |file|
          canadian_file_names << File.basename(file).to_s
          # puts "File.basename = #{File.basename(file)}"
          # puts "File.dirname = #{File.dirname(file)}"
        end
      end
      return canadian_file_names
    end

    # This method will create a climate index file.
    # @author phylroy.lopez@nrcan.gc.ca
    # @param folder [String]
    # @param output_file [String]
    def self.create_climate_index_file(folder = "#{File.dirname(__FILE__)}/../../../weather", output_file = 'C:/test/phylroy.csv')
      data = ''
      counter = 0
      File.open(output_file, 'w') do |file|
        puts "outpus #{output_file}"
        data << "file,location_name,energy_plus_location_name,country,state_province_region,city,hdd10,hdd18,cdd10,cdd18,latitude,longitude,elevation, deltaDB, climate_zone, cz_standard, summer_wet_months, winter_dry_months,autumn_months, spring_months, typical_summer_wet_week, typical_winter_dry_week, typical_autumn_week, typical_spring_week, heating_design_info[1],cooling_design_info[1],extremes_design_info[1],db990\n"
        BTAP::FileIO.get_find_files_from_folder_by_extension(folder, 'epw').sort.each do |wfile|
          wf = BTAP::Environment::WeatherFile.new(wfile)
          data << "#{File.basename(wfile)}, #{wf.location_name}\,#{wf.energy_plus_location_name},#{wf.country}, #{wf.state_province_region}, #{wf.city}, #{wf.hdd10}, #{wf.hdd18},#{wf.cdd10},#{wf.cdd18},#{wf.latitude}, #{wf.longitude}, #{wf.elevation}, #{wf.delta_dry_bulb} ,#{wf.climate_zone},#{wf.standard},#{wf.summer_wet_months}, #{wf.winter_dry_months},#{wf.autumn_months}, #{wf.spring_months}, #{wf.typical_summer_wet_week}, #{wf.typical_winter_dry_week}, #{wf.typical_autumn_week}, #{wf.typical_spring_week},#{wf.heating_design_info[1]},#{wf.cooling_design_info[1]},#{wf.extremes_design_info[1]},#{wf.db990}\n"
          counter += 1
        end
        file.write(data)
      end
      puts "parsed #{counter} weather files."
    end

    # This method will create a climate index file.
    # @author phylroy.lopez@nrcan.gc.ca
    # @param folder [String]
    # @param output_file [String]
    def self.create_climate_json_file(folder = "#{File.dirname(__FILE__)}/../../../weather", output_file = 'C:/test/phylroy.csv')
      data_array = []
      File.open(output_file, 'w') do |file|
        BTAP::FileIO.get_find_files_from_folder_by_extension(folder, 'epw').sort.each do |wfile|
          wf = BTAP::Environment::WeatherFile.new(wfile)
          data = {}
          data_array << data
          data['file'] = File.basename(wfile).encode('UTF-8')
          data['location_name'] = wf.location_name.force_encoding('ISO-8859-1').encode('UTF-8')
          data['energy_plus_location_name'] = wf.energy_plus_location_name.force_encoding('ISO-8859-1').encode('UTF-8')
          data['country'] = wf.country.force_encoding('ISO-8859-1').encode('UTF-8')
          data['state_province_region'] = wf.state_province_region.force_encoding('ISO-8859-1').encode('UTF-8')
          data['city'] =  wf.city.force_encoding('ISO-8859-1').encode('UTF-8')
          data['hdd10'] = wf.hdd10
          data['hdd18'] = wf.hdd18
          data['cdd10'] = wf.cdd10
          data['cdd18'] = wf.cdd18
          data['latitude'] = wf.latitude
          data['longitude'] = wf.longitude
          data['elevation'] = wf.delta_dry_bulb
          data['climate_zone'] = wf.climate_zone.force_encoding('ISO-8859-1').encode('UTF-8')
          data['standard'] = wf.standard
          data['summer_wet_months'] = wf.summer_wet_months.force_encoding('ISO-8859-1').encode('UTF-8')
          data['winter_dry_months'] = wf.autumn_months.force_encoding('ISO-8859-1').encode('UTF-8')
          data['spring_months'] = wf.spring_months.force_encoding('ISO-8859-1').encode('UTF-8')
          data['typical_summer_wet_week'] = wf.typical_summer_wet_week
          data['typical_winter_dry_week'] = wf.typical_winter_dry_week
          data['typical_autumn_week'] = wf.typical_autumn_week
          data['typical_spring_week'] = wf.typical_spring_week
          data['wf.heating_design_info[1]'] = wf.heating_design_info[1]
          data['cooling_design_info[1]'] = wf.cooling_design_info[1]
          data['extremes_design_info[1]'] = wf.extremes_design_info[1]
          data['db990'] = wf.db990
        end
        File.write(output_file, JSON.pretty_generate(data_array))
      end
    end

    class WeatherFile
      attr_accessor :location_name,
                    :energy_plus_location_name,
                    :latitude,
                    :longitude,
                    :elevation,
                    :city,
                    :state_province_region,
                    :country,
                    :hdd18,
                    :cdd18,
                    :hdd10,
                    :cdd10,
                    :heating_design_info,
                    :cooling_design_info,
                    :extremes_design_info,
                    :monthly_dry_bulb,
                    :delta_dry_bulb,
                    :climate_zone,
                    :standard,
                    :summer_wet_months,
                    :winter_dry_months,
                    :autumn_months,
                    :spring_months,
                    :typical_summer_wet_week,
                    :typical_winter_dry_week,
                    :typical_autumn_week,
                    :typical_spring_week,
                    :epw_filepath,
                    :ddy_filepath,
                    :stat_filepath,
                    :db990

      YEAR = 0
      MONTH = 1
      DAY = 2
      HOUR = 3
      MINUTE = 4
      DATA_SOURCE = 5
      DRY_BULB_TEMPERATURE = 6
      DEW_POINT_TEMPERATURE = 7
      RELATIVE_HUMIDITY = 8
      ATMOSPHERIC_STATION_PRESSURE = 9
      EXTRATERRESTRIAL_HORIZONTAL_RADIATION = 10 # not used
      EXTRATERRESTRIAL_DIRECT_NORMAL_RADIATION = 11 # not used
      HORIZONTAL_INFRARED_RADIATION_INTENSITY = 12
      GLOBAL_HORIZONTAL_RADIATION = 13 # not used
      DIRECT_NORMAL_RADIATION = 14
      DIFFUSE_HORIZONTAL_RADIATION = 15
      GLOBAL_HORIZONTAL_ILLUMINANCE = 16 # not used
      DIRECT_NORMAL_ILLUMINANCE = 17 # not used
      DIFFUSE_HORIZONTAL_ILLUMINANCE = 18 # not used
      ZENITH_LUMINANCE = 19 # not used
      WIND_DIRECTION = 20
      WIND_SPEED = 21
      TOTAL_SKY_COVER = 22 # not used
      OPAQUE_SKY_COVER = 23 # not used
      VISIBILITY = 24 # not used
      CEILING_HEIGHT = 25 # not used
      PRESENT_WEATHER_OBSERVATION = 26
      PRESENT_WEATHER_CODES = 27
      PRECIPITABLE_WATER = 28 # not used
      AEROSOL_OPTICAL_DEPTH = 29 # not used
      SNOW_DEPTH = 30
      DAYS_SINCE_LAST_SNOWFALL = 31 # not used
      ALBEDO = 32 # not used
      LIQUID_PRECIPITATION_DEPTH = 33
      LIQUID_PRECIPITATION_QUANTITY = 34
      CALCULATED_SATURATION_PRESSURE_OF_WATER_VAPOR = 100 # pws
      CALCULATED_PARTIAL_PRESSURE_OF_WATER_VAPOR = 101 # pw
      CALCULATED_TOTAL_MIXTURE_PRESSURE = 102 # p
      CALCULATED_HUMIDITY_RATIO = 103 # w
      CALCULATED_HUMIDITY_RATIO_AVG_DAILY = 104 # w averaged daily
      CALCULATED_HUMIDITY_RATIO_AVG_DAILY_DIFF_BASE = 105 # difference of w_averaged_daily from base if w_averaged_daily > base

      # This method initializes and returns self.
      # @author phylroy.lopez@nrcan.gc.ca
      # @param weather_file [String]
      # @return [String] self
      def initialize(weather_file)
        # First check if the epw file exists at a full path.  If not found there,
        # check for the file in the openstudio-standards/data/weather directory.
        weather_file = weather_file.to_s
        @epw_filepath = nil
        @ddy_filepath = nil
        @stat_filepath = nil
        if File.exist?(weather_file)
          @epw_filepath = weather_file.to_s
          @ddy_filepath = weather_file.sub('epw', 'ddy').to_s
          @stat_filepath = weather_file.sub('epw', 'stat').to_s
        else
          # Run differently depending on whether running from embedded filesystem in OpenStudio CLI or not
          if __dir__[0] == ':' # Running from OpenStudio CLI
            # load weather file from embedded files
            epw_string = load_resource_relative("../../../data/weather/#{weather_file}")
            ddy_string = load_resource_relative("../../../data/weather/#{weather_file.gsub('.epw', '.ddy')}")
            stat_string = load_resource_relative("../../../data/weather/#{weather_file.gsub('.epw', '.stat')}")

            # extract to local weather dir
            weather_dir = File.expand_path(File.join(Dir.pwd, 'extracted_files/weather/'))
            puts "Extracting weather files to #{weather_dir}"
            FileUtils.mkdir_p(weather_dir)
            File.open("#{weather_dir}/#{weather_file}", 'wb') { |f| f << epw_string; f.flush }
            File.open("#{weather_dir}/#{weather_file.gsub('.epw', '.ddy')}", 'wb') { |f| f << ddy_string; f.flush }
            File.open("#{weather_dir}/#{weather_file.gsub('.epw', '.stat')}", 'wb') { |f| f << stat_string; f.flush }
          else # loaded gem from system path
            top_dir = File.expand_path('../../..', File.dirname(__FILE__))
            weather_dir = File.expand_path("#{top_dir}/data/weather")
          end

          @epw_filepath = "#{weather_dir}/#{weather_file}"
          @ddy_filepath = "#{weather_dir}/#{weather_file.sub('epw', 'ddy')}"
          @stat_filepath = "#{weather_dir}/#{weather_file.sub('epw', 'stat')}"
        end

        # Ensure that epw, ddy, and stat file all exist
        raise("Weather file #{@epw_filepath} not found.") unless File.exist?(@epw_filepath) && @epw_filepath.downcase.include?('.epw')
        raise("Weather file ddy #{@ddy_filepath} not found.") unless File.exist?(@ddy_filepath) && @ddy_filepath.downcase.include?('.ddy')
        raise("Weather file stat #{@stat_filepath} not found.") unless File.exist?(@stat_filepath) && @stat_filepath.downcase.include?('.stat')

        # load file objects.
        @epw_file = OpenStudio::EpwFile.new(OpenStudio::Path.new(@epw_filepath))
        if OpenStudio::EnergyPlus.loadAndTranslateIdf(@ddy_filepath).empty?
          raise "Unable to load ddy idf file#{@ddy_filepath}."
        else
          @ddy_file = OpenStudio::EnergyPlus.loadAndTranslateIdf(@ddy_filepath).get
        end

        @stat_file = EnergyPlus::StatFile.new(@stat_filepath)

        # assign variables.

        @latitude = @epw_file.latitude
        @longitude = @epw_file.longitude
        @elevation = @epw_file.elevation
        @city = @epw_file.city
        @state_province_region = @epw_file.stateProvinceRegion
        @country = @epw_file.country
        @hdd18 = @stat_file.hdd18
        @cdd18 = @stat_file.cdd18
        @hdd10 = @stat_file.hdd10
        @cdd10 = @stat_file.cdd10
        @heating_design_info = @stat_file.heating_design_info
        @cooling_design_info  = @stat_file.cooling_design_info
        @extremes_design_info = @stat_file.extremes_design_info
        @monthly_dry_bulb = @stat_file.monthly_dry_bulb
        @mean_dry_bulb = @stat_file.mean_dry_bulb
        @delta_dry_bulb = @stat_file.delta_dry_bulb
        @location_name = "#{@country}-#{@state_province_region}-#{@city}"
        @energy_plus_location_name = "#{@city}_#{@state_province_region}_#{@country}"
        @climate_zone = @stat_file.climate_zone
        @standard = @stat_file.standard
        @summer_wet_months = @stat_file.summer_wet_months
        @winter_dry_months = @stat_file.winter_dry_months
        @autumn_months = @stat_file.autumn_months
        @spring_months = @stat_file.spring_months
        @typical_summer_wet_week = @stat_file.typical_summer_wet_week
        @typical_winter_dry_week = @stat_file.typical_winter_dry_week
        @typical_autumn_week = @stat_file.typical_autumn_week
        @typical_spring_week = @stat_file.typical_spring_week
        @db990 = @heating_design_info[2]
        return self
      end

      # This method returns the Thermal Zone based on cdd10 and hdd18
      # @author padmassun.rajakareyar@canada.ca
      # @return [String] thermal_zone
      def a169_2006_climate_zone
        cdd10 = self.cdd10.to_f
        hdd18 = self.hdd18.to_f

        if cdd10 > 6000 # Extremely Hot  Humid (0A), Dry (0B)
          return 'ASHRAE 169-2013-0A'

        elsif (cdd10 > 5000) && (cdd10 <= 6000) # Very Hot  Humid (1A), Dry (1B)
          return 'ASHRAE 169-2013-1A'

        elsif (cdd10 > 3500) && (cdd10 <= 5000) # Hot  Humid (2A), Dry (2B)
          return 'ASHRAE 169-2013-2A'

        elsif ((cdd10 > 2500) && (cdd10 < 3500)) && (hdd18 <= 2000) # Warm  Humid (3A), Dry (3B)
          return 'ASHRAE 169-2013-3A' # and 'ASHRAE 169-2013-3B'

        elsif (cdd10 <= 2500) && (hdd18 <= 2000) # Warm  Marine (3C)
          return 'ASHRAE 169-2013-3C'

        elsif ((cdd10 > 1500) && (cdd10 < 3500)) && ((hdd18 > 2000) && (hdd18 <= 3000)) # Mixed  Humid (4A), Dry (4B)
          return 'ASHRAE 169-2013-4A' # and 'ASHRAE 169-2013-4B'

        elsif (cdd10 <= 1500) && ((hdd18 > 2000) && (hdd18 <= 3000)) # Mixed  Marine
          return 'ASHRAE 169-2013-4C'

        elsif ((cdd10 > 1000) && (cdd10 <= 3500)) && ((hdd18 > 3000) && (hdd18 <= 4000)) # Cool Humid (5A), Dry (5B)
          return 'ASHRAE 169-2013-5A' # and 'ASHRAE 169-2013-5B'

        elsif (cdd10 <= 1000) && ((hdd18 > 3000) && (hdd18 <= 4000)) # Cool  Marine (5C)
          return 'ASHRAE 169-2013-5C'

        elsif (hdd18 > 4000) && (hdd18 <= 5000) # Cold  Humid (6A), Dry (6B)
          return 'ASHRAE 169-2013-6A' # and 'ASHRAE 169-2013-6B'

        elsif (hdd18 > 5000) && (hdd18 <= 7000) # Very Cold (7)
          return 'ASHRAE 169-2013-7A'

        elsif hdd18 > 7000 # Subarctic/Arctic (8)
          return 'ASHRAE 169-2013-8A'

        else
          # raise ("invalid cdd10 of #{cdd10} or hdd18 of #{hdd18}")
          return '[INVALID]'
        end
      end

      # This method will set the weather file and returns a log string.
      # @author phylroy.lopez@nrcan.gc.ca
      # @param model [OpenStudio::model::Model] A model object
      # @return [String] log
      def set_weather_file(model, runner = nil)
        BTAP.runner_register('Info', 'BTAP::Environment::WeatherFile::set_weather', runner)
        OpenStudio::Model::WeatherFile.setWeatherFile(model, @epw_file)
        building_name = model.building.get.name
        weather_file_path = model.weatherFile.get.path.get
        BTAP.runner_register('Info', "Set model \"#{building_name}\" to weather file #{weather_file_path}.\n", runner)

        # Add or update site data
        site = model.getSite
        site.setName("#{@epw_file.city}_#{@epw_file.stateProvinceRegion}_#{@epw_file.country}")
        site.setLatitude(@epw_file.latitude)
        site.setLongitude(@epw_file.longitude)
        site.setTimeZone(@epw_file.timeZone)
        site.setElevation(@epw_file.elevation)

        BTAP.runner_register('Info', 'Setting water main temperatures via parsing of STAT file.', runner)
        water_temp = model.getSiteWaterMainsTemperature
        water_temp.setAnnualAverageOutdoorAirTemperature(@stat_file.mean_dry_bulb)
        water_temp.setMaximumDifferenceInMonthlyAverageOutdoorAirTemperatures(@stat_file.delta_dry_bulb)
        BTAP.runner_register('Info', "SiteWaterMainsTemperature.AnnualAverageOutdoorAirTemperature = #{@stat_file.mean_dry_bulb}.", runner)
        BTAP.runner_register('Info', "SiteWaterMainsTemperature.MaximumDifferenceInMonthlyAverageOutdoorAirTemperatures = #{@stat_file.delta_dry_bulb}.", runner)

        # Remove all the Design Day objects that are in the file
        model.getObjectsByType('OS:SizingPeriod:DesignDay'.to_IddObjectType).each(&:remove)

        # Load in the ddy file based on convention that it is in the same directory and has the same basename as the weather
        @ddy_file.getObjectsByType('OS:SizingPeriod:DesignDay'.to_IddObjectType).each do |d|
          # grab only the ones that matter
          ddy_list = /(Htg 99.6. Condns DB)|(Clg .4. Condns WB=>MDB)|(Clg .4% Condns DB=>MWB)/
          if d.name.get =~ ddy_list
            BTAP.runner_register('Info', "Adding design day '#{d.name}'.", runner)
            # add the object to the existing model
            model.addObject(d.clone)
          end
        end
        return true
      end

      # This method scans the epw file into memory.
      # @author phylroy.lopez@nrcan.gc.ca
      def scan
        @filearray = []
        file = File.new(@epw_filepath, 'r')
        while (line = file.gets)
          @filearray.push(line.split(','))
        end
        file.close
      end

      # This method will sets column to a value.
      # @author phylroy.lopez@nrcan.gc.ca
      # @param column [String]
      # @param value [Fixnum]
      def setcolumntovalue(column, value)
        @filearray.each do |line|
          unless line.first =~ /\D(.*)/
            line[column] = value
          end
        end
      end

      # This method will eliminate all radiation from the weather and returns self.
      # @author phylroy.lopez@nrcan.gc.ca
      # @return  [String] self
      def eliminate_all_radiation
        scan if @filearray.nil?
        setcolumntovalue(EXTRATERRESTRIAL_HORIZONTAL_RADIATION, '0') # not used
        setcolumntovalue(EXTRATERRESTRIAL_DIRECT_NORMAL_RADIATION, '0') # not used
        setcolumntovalue(HORIZONTAL_INFRARED_RADIATION_INTENSITY, '315')
        setcolumntovalue(GLOBAL_HORIZONTAL_RADIATION, '0') # not used
        setcolumntovalue(DIRECT_NORMAL_RADIATION, '0')
        setcolumntovalue(DIFFUSE_HORIZONTAL_RADIATION, '0')
        setcolumntovalue(TOTAL_SKY_COVER, '10') # not used
        setcolumntovalue(OPAQUE_SKY_COVER, '10') # not used
        setcolumntovalue(VISIBILITY, '0') # not used
        setcolumntovalue(CEILING_HEIGHT, '0') # not used
        # lux values
        setcolumntovalue(GLOBAL_HORIZONTAL_ILLUMINANCE, '0') # not used
        setcolumntovalue(DIRECT_NORMAL_ILLUMINANCE, '0') # not used
        setcolumntovalue(DIFFUSE_HORIZONTAL_ILLUMINANCE, '0') # not used
        setcolumntovalue(ZENITH_LUMINANCE, '0') # not used
        return self
      end

      # This method will eliminate solar radiation and returns self.
      # @author phylroy.lopez@nrcan.gc.ca
      # @return  [String] self
      def eliminate_only_solar_radiation
        scan if @filearray.nil?
        setcolumntovalue(GLOBAL_HORIZONTAL_RADIATION, '0') # not used
        setcolumntovalue(DIRECT_NORMAL_RADIATION, '0')
        setcolumntovalue(DIFFUSE_HORIZONTAL_RADIATION, '0')
        return self
      end

      # This method will eliminate all radiation except solar and returns self.
      # @author phylroy.lopez@nrcan.gc.ca
      # @return [String] self
      def eliminate_all_radiation_except_solar
        scan if @filearray.nil?
        setcolumntovalue(EXTRATERRESTRIAL_HORIZONTAL_RADIATION, '0') # not used
        setcolumntovalue(EXTRATERRESTRIAL_DIRECT_NORMAL_RADIATION, '0') # not used
        setcolumntovalue(HORIZONTAL_INFRARED_RADIATION_INTENSITY, '315')
        setcolumntovalue(TOTAL_SKY_COVER, '10') # not used
        setcolumntovalue(OPAQUE_SKY_COVER, '10') # not used
        setcolumntovalue(VISIBILITY, '0') # not used
        setcolumntovalue(CEILING_HEIGHT, '0') # not used
        # lux values
        setcolumntovalue(GLOBAL_HORIZONTAL_ILLUMINANCE, '0') # not used
        setcolumntovalue(DIRECT_NORMAL_ILLUMINANCE, '0') # not used
        setcolumntovalue(DIFFUSE_HORIZONTAL_ILLUMINANCE, '0') # not used
        setcolumntovalue(ZENITH_LUMINANCE, '0') # not used
        return self
      end

      # This method will eliminate percipitation and returns self.
      # @author phylroy.lopez@nrcan.gc.ca
      # @return  [String] self
      def eliminate_percipitation
        scan if @filearray.nil?
        setcolumntovalue(PRESENT_WEATHER_OBSERVATION, '0')
        setcolumntovalue(PRESENT_WEATHER_CODES, '999999999') # no weather. Clear day.
        setcolumntovalue(SNOW_DEPTH, '0')
        setcolumntovalue(LIQUID_PRECIPITATION_DEPTH, '0')
        setcolumntovalue(LIQUID_PRECIPITATION_QUANTITY, '0')
        return self
      end

      # This method eliminates wind and returns self.
      # @author phylroy.lopez@nrcan.gc.ca
      # @return  [String] self
      def eliminate_wind
        scan if @filearray.nil?
        setcolumntovalue(WIND_DIRECTION, '0')
        setcolumntovalue(WIND_SPEED, '0')
        return self
      end

      # This method sets Constant Dry and Dew Point Temperature Humidity And Pressure and returns self.
      # @author phylroy.lopez@nrcan.gc.ca
      # @param dbt [Float] dry bulb temperature
      # @param dpt [Float] dew point temperature
      # @param hum [Fixnum] humidity
      # @param press [Fixnum] pressure
      # @return [String] self
      def set_constant_dry_and_dewpoint_temperature_humidity_pressure(dbt = '0.0', dpt = '-1.1', hum = '92', press = '98500')
        scan if @filearray.nil?
        setcolumntovalue(DRY_BULB_TEMPERATURE, dbt)
        setcolumntovalue(DEW_POINT_TEMPERATURE, dpt)
        setcolumntovalue(RELATIVE_HUMIDITY, hum)
        setcolumntovalue(ATMOSPHERIC_STATION_PRESSURE, press)
        return self
      end

      # This method writes to a file.
      # @author phylroy.lopez@nrcan.gc.ca
      # @param filename [String]
      def writetofile(filename)
        scan if @filearray.nil?

        begin
          FileUtils.mkdir_p(File.dirname(filename))
          file = File.open(filename, 'w')
          @filearray.each do |line|
            firstvalue = true
            newline = ''
            line.each do |value|
              if firstvalue == true
                firstvalue = false
              else
                newline += ','
              end
              newline += value
            end
            file.puts(newline)
          end
        rescue IOError => e
          # some error occur, dir not writable etc.
        ensure
          file.close unless file.nil?
        end
        # copies original file
        FileUtils.cp(@ddy_filepath, "#{File.dirname(filename)}/#{File.basename(filename, '.epw')}.ddy")
        FileUtils.cp(@stat_filepath, "#{File.dirname(filename)}/#{File.basename(filename, '.epw')}.stat")
      end

      # This method calculates annual global horizontal irradiance (GHI)
      # @author sara.gilani@canada.ca
      # This value has been used as 'Irradiance, Global, Annual' (IGA) (kWh/m2.yr) for PHIUS performance targets calculation.
      def get_annual_ghi
        sum_hourly_ghi = 0.0
        scan if @filearray.nil?
        @filearray.each do |line|
          unless line.first =~ /\D(.*)/
            ghi_hourly = line[GLOBAL_HORIZONTAL_RADIATION].to_f
            sum_hourly_ghi += ghi_hourly
          end
        end
        annual_ghi_kwh_per_m_sq = sum_hourly_ghi / 1000.0
        return annual_ghi_kwh_per_m_sq
      end

      # This method calculates global horizontal irradiance on heating design day
      # @author sara.gilani@canada.ca
      # This value has been used as 'Irradiance, Global, at the heating design condition' (IGHL) for PHIUS performance targets calculation.
      def get_ghi_on_heating_design_day
        heating_design_day_number, cooling_design_day_number = get_heating_design_day_number
        coldest_month = @heating_design_info[0].to_f
        sum_hourly_ghi_on_heating_design_day = 0.0
        number_of_hours_with_sunshine = 0.0
        scan if @filearray.nil?
        @filearray.each do |line|
          unless line.first =~ /\D(.*)/
            if line[MONTH].to_f == coldest_month && line[DAY].to_f == heating_design_day_number.to_f && line[GLOBAL_HORIZONTAL_RADIATION].to_f > 0.0
              sum_hourly_ghi_on_heating_design_day += line[GLOBAL_HORIZONTAL_RADIATION].to_f
              number_of_hours_with_sunshine += 1.0
            end
          end
        end
        ghi_on_heating_design_day_w_per_m_sq = sum_hourly_ghi_on_heating_design_day / number_of_hours_with_sunshine
        return ghi_on_heating_design_day_w_per_m_sq
      end

      # This method calculates global horizontal irradiance on cooling design day
      # @author sara.gilani@canada.ca
      # This value has been used as 'Irradiance, Global, at the cooling design condition' (IGHL) for PHIUS performance targets calculation.
      def get_ghi_on_cooling_design_day
        heating_design_day_number, cooling_design_day_number = get_heating_design_day_number
        hottest_month = @cooling_design_info[0].to_f
        sum_hourly_ghi_on_cooling_design_day = 0.0
        number_of_hours_with_sunshine = 0.0
        scan if @filearray.nil?
        @filearray.each do |line|
          unless line.first =~ /\D(.*)/
            if line[MONTH].to_f == hottest_month && line[DAY].to_f == cooling_design_day_number.to_f && line[GLOBAL_HORIZONTAL_RADIATION].to_f > 0.0
              sum_hourly_ghi_on_cooling_design_day += line[GLOBAL_HORIZONTAL_RADIATION].to_f
              number_of_hours_with_sunshine += 1.0
            end
          end
        end
        ghi_on_cooling_design_day_w_per_m_sq = sum_hourly_ghi_on_cooling_design_day / number_of_hours_with_sunshine
        return ghi_on_cooling_design_day_w_per_m_sq
      end

      # This method finds which day of the coldest/hottest month is the heating/cooling design day
      # @author sara.gilani@canada.ca
      def get_heating_design_day_number
        heating_design_day_number = nil
        cooling_design_day_number = nil
        # which day of the coldest month is the heating design day
        @ddy_file.getObjectsByType('OS:SizingPeriod:DesignDay'.to_IddObjectType).each do |d|
          if d.name.to_s.include?('Htg 99.6% Condns DB')
            idf_object = d.idfObject
            idf_object.dataFields.each do |data_field|
              design_day_field = idf_object.fieldComment(data_field, true)
              if design_day_field.to_s.include?('Day of Month')
                heating_design_day_number = idf_object.getString(data_field)
                heating_design_day_number = heating_design_day_number.to_s
                # puts "heating_design_day_number is #{heating_design_day_number}"
              end
            end
          end

          # which day of the hottest month is the cooling design day
          if d.name.to_s.include?('Clg .4% Condns DB=>MWB')
            idf_object = d.idfObject
            idf_object.dataFields.each do |data_field|
              design_day_field = idf_object.fieldComment(data_field, true)
              if design_day_field.to_s.include?('Day of Month')
                cooling_design_day_number = idf_object.getString(data_field)
                cooling_design_day_number = cooling_design_day_number.to_s
                # puts "cooling_design_day_number is #{cooling_design_day_number}"
              end
            end
          end
        end
        return heating_design_day_number, cooling_design_day_number
      end # def get_heating_design_day_number

      # This method calculates dehumidification degree days (DDD)
      # @author sara.gilani@canada.ca
      # Reference: ASHRAE Handbook - Fundamentals > CHAPTER 1. PSYCHROMETRICS
      def calculate_humidity_ratio
        # coefficients for the calculation of pws (Reference: ASHRAE Handbook - Fundamentals > CHAPTER 1. PSYCHROMETRICS)
        c1 = -5.6745359E+03
        c2 = 6.3925247E+00
        c3 = -9.6778430E-03
        c4 = 6.2215701E-07
        c5 = 2.0747825E-09
        c6 = -9.4840240E-13
        c7 = 4.1635019E+00
        c8 = -5.8002206E+03
        c9 = 1.3914993E+00
        c10 = -4.8640239E-02
        c11 = 4.1764768E-05
        c12 = -1.4452093E-08
        c13 = 6.5459673E+00
        sum_w = 0.0
        w_base = 0.010 # Note: this is base for the calculation of 'dehumidification degree days' (REF: Wright, L. (2019). Setting the Heating/Cooling Performance Criteria for the PHIUS 2018 Passive Building Standard. In ASHRAE Topical Conference Proceedings, pp. 399-409)
        ddd = 0.0 # dehimudifation degree-days
        convert_c_to_k = 273.15 # convert degree C to kelvins (k)

        scan if @filearray.nil?
        @filearray.each do |line|
          unless line.first =~ /\D(.*)/
            # Note: the below Step 1, 2, 3, and 4 are the steps for the calculation of humidity ratio as per ASHRAE Handbook - Fundamentals > CHAPTER 1. PSYCHROMETRICS
            # Step 1: calculate pws (SATURATION_PRESSURE_OF_WATER_VAPOR), [Pascal]
            if line[DRY_BULB_TEMPERATURE].to_f <= 0.0
              line[CALCULATED_SATURATION_PRESSURE_OF_WATER_VAPOR] = c1 / (line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k) +
                                                                    c2 +
                                                                    c3 * (line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k) +
                                                                    c4 * (line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k)**2 +
                                                                    c5 * (line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k)**3 +
                                                                    c6 * (line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k)**4 +
                                                                    c7 * Math.log((line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k), Math.exp(1)) # 2.718281828459
              line[CALCULATED_SATURATION_PRESSURE_OF_WATER_VAPOR] = Math.exp(1)**line[CALCULATED_SATURATION_PRESSURE_OF_WATER_VAPOR].to_f
            else # if line[DRY_BULB_TEMPERATURE].to_f > 0.0
              line[CALCULATED_SATURATION_PRESSURE_OF_WATER_VAPOR] = c8 / (line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k) +
                                                                    c9 +
                                                                    c10 * (line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k) +
                                                                    c11 * (line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k)**2 +
                                                                    c12 * (line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k)**3 +
                                                                    c13 * Math.log((line[DRY_BULB_TEMPERATURE].to_f + convert_c_to_k), Math.exp(1))
              line[CALCULATED_SATURATION_PRESSURE_OF_WATER_VAPOR] = Math.exp(1)**line[CALCULATED_SATURATION_PRESSURE_OF_WATER_VAPOR].to_f
            end

            # Step 2: calculate pw (PARTIAL_PRESSURE_OF_WATER_VAPOR), [Pascal]
            # Relative Humidity (RH) = 100 * pw / pws
            line[CALCULATED_PARTIAL_PRESSURE_OF_WATER_VAPOR] = line[CALCULATED_SATURATION_PRESSURE_OF_WATER_VAPOR].to_f * line[RELATIVE_HUMIDITY].to_f / 100.0

            # Step 3: calculate p (TOTAL_MIXTURE_PRESSURE), [Pascal]
            line[CALCULATED_TOTAL_MIXTURE_PRESSURE] = line[CALCULATED_PARTIAL_PRESSURE_OF_WATER_VAPOR].to_f + line[ATMOSPHERIC_STATION_PRESSURE].to_f

            # Step 4: calculate w (HUMIDITY_RATIO)
            line[CALCULATED_HUMIDITY_RATIO] = 0.621945 * line[CALCULATED_PARTIAL_PRESSURE_OF_WATER_VAPOR].to_f / (line[CALCULATED_TOTAL_MIXTURE_PRESSURE].to_f - line[CALCULATED_PARTIAL_PRESSURE_OF_WATER_VAPOR].to_f)

            #-----------------------------------------------------------------------------------------------------------
            # calculate daily average of w AND its difference from base
            if line[HOUR].to_f < 24.0
              sum_w += line[CALCULATED_HUMIDITY_RATIO].to_f
              line[CALCULATED_HUMIDITY_RATIO_AVG_DAILY] = 0.0
            elsif line[HOUR].to_f == 24.0
              line[CALCULATED_HUMIDITY_RATIO_AVG_DAILY] = (sum_w + line[CALCULATED_HUMIDITY_RATIO].to_f) / 24.0
              if line[CALCULATED_HUMIDITY_RATIO_AVG_DAILY].to_f > w_base
                line[CALCULATED_HUMIDITY_RATIO_AVG_DAILY_DIFF_BASE] = line[CALCULATED_HUMIDITY_RATIO_AVG_DAILY].to_f - w_base
              else
                line[CALCULATED_HUMIDITY_RATIO_AVG_DAILY_DIFF_BASE] = 0.0
              end
              sum_w = 0.0
            end

            ddd += line[CALCULATED_HUMIDITY_RATIO_AVG_DAILY_DIFF_BASE].to_f

          end # unless line.first =~ /\D(.*)/
        end # @filearray.each do |line|
        # puts @filearray
        return ddd
      end # def calculate_humidity_ratio
    end # Environment
  end
end
