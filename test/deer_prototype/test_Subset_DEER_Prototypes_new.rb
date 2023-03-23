require_relative '../helpers/minitest_helper'
require_relative '../helpers/create_deer_prototype_helper'

class TestSubsetDEERPrototypes < CreateDEERPrototypeBuildingTest
  
  building_types = [
      # 'Asm',
      # # 'ECC',
      # # 'EPr',
      # # 'ERC',
      # 'ESe',
      # 'EUn',
      'Gro',
      # 'Hsp',
      # # 'Nrs',
      # 'Htl',
      # # 'Mtl',
      # # 'MBT',
      # # 'MLI',
      # 'OfL',
      # 'OfS',
      # 'RFF',
      # 'RSD',
      # # 'Rt3',
      # 'RtL',
      # 'RtS',
      # 'SCn',
      # 'SUn',
      # 'WRf',
      # # 'MFm'
  ]

  # DEER HVAC type defaults by building type
  building_to_hvac_system_defaults = {
      'Asm' => ['DXGF'],
      'ECC' => ['SVVG'],
      'EPr' => ['DXGF'],
      'ERC' => ['DXHP'],
      'ESe' => [
        # 'DXGF',
        'PVVG'
      ],
      'EUn' => ['SVVG'],
      'Gro' => ['DXGF'],
      'Hsp' => ['SVVG'],
      'Nrs' => ['DXGF'],
      'Htl' => [
        # 'SVVG',
        'DXGF',
      ],
      'Mtl' => ['DXHP'],
      'MBT' => ['DXGF'],
      'MFm' => ['DXGF'],
      'MLI' => ['DXGF'],
      'OfL' => [
        'SVVG',
        # 'SVVE',
        'PVVG',
        # 'DXGF'
      ],
      'OfS' => [
        'PVVG',
        # 'DXGF'
      ],
      'RFF' => ['DXGF'],
      'RSD' => ['DXGF'],
      'Rt3' => ['SVVG'],
      'RtL' => ['DXGF'],
      'RtS' => ['DXGF'],
      'SCn' => ['DXGF'],
      'SUn' => ['Unc'], # listed as cNCGF in DEER database
      'WRf' => ['DXGF']
  }
  
  templates = ['DEER T24 2022']
  climate_zones = [
    'CEC T24-CEC5',
    # 'CEC T24-CEC6',
    # 'CEC T24-CEC8',
    # 'CEC T24-CEC9',
    # 'CEC T24-CEC10',
    # 'CEC T24-CEC13',
    # 'CEC T24-CEC14',
    # 'CEC T24-CEC15',
    # 'CEC T24-CEC16'
  ]

  create_models = true
  run_models = true
  compare_results = false
  
  debug = true
  
  # Create a new set of tests for each building type because HVAC systems aren't all the same
  building_types.each do |building_type|
    hvacs = building_to_hvac_system_defaults[building_type]
    TestSubsetDEERPrototypes.create_run_model_tests([building_type], templates, hvacs, climate_zones, create_models, run_models, compare_results, debug)
  end

end
