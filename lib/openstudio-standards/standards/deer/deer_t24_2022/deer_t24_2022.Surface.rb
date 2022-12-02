class DEERT242022 < DEER
  # @!group Surface

  # this method finds the Solar Access Roof Area (SARA)
  # 1. SARA includes the area of the building’s roof space capable of structurally supporting a PV system, and the 
  # area of all roof space on covered parking areas, carports and all other newly constructed structures on the 
  # site that are compatible with supporting a PV system per Title 24, Part 2, Section 1511.2.  
  # 2. SARA does NOT include:  
  # TODO:
  # A. Any area that has less than 70 percent annual solar access. Annual solar access is determined by 
  # dividing the total annual solar insolation (accounting for shading obstructions) by the total annual 
  # solar insolation if the same areas were unshaded by those obstructions. For all roofs, all obstructions, 
  # including those that are external to the building, and obstructions that are part of the building design 
  # and elevation features may be considered for the annual solar access calculations. 
  # B. Occupied roofs as specified by CBC Section 503.1.4.  
  # C. Roof space that is otherwise not available due to compliance with other building code requirements if 
  # confirmed by the Executive Director.  

  # @param model [OpenStudio::Model::Model] OpenStudio model object
  # @return [Double] total exterior roof area
  def find_solar_access_roof_area(model)
    total_sara = 0

    model.getSurfaces.sort.each do |surface|
      next unless surface.surfaceType == 'RoofCeiling'
      next unless surface.outsideBoundaryCondition == 'Outdoors'

      total_sara += surface.grossArea * surface.space.get.multiplier
    end

    return total_sara
  end


end
