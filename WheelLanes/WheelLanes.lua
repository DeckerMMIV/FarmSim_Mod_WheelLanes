--
-- WheelLanes - Wheels will destroy crops!
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2015-04-xx
--

WheelLanes = {};
--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
WheelLanes.version = (modItem and modItem.version) and modItem.version or "?.?.?";
WheelLanes.enabled = true
WheelLanes.fruitTypeEffects = nil

--
function log(...)
    if false then
        local txt = ""
        for idx = 1,select("#", ...) do
            txt = txt .. tostring(select(idx, ...))
        end
        print(string.format("%7ums ", (g_currentMission ~= nil and g_currentMission.time or 0)) .. txt);
    end
end;
--

function WheelLanes.prerequisitesPresent(specializations)
  return true
end;

function WheelLanes:load(xmlFile)
    --self.modIsSowingMachine = SpecializationUtil.hasSpecialization(SowingMachine, this.specializations);
    --self.modWL_workarea_idx = 0;
    
    -- One time initialization
    if WheelLanes.fruitTypeEffects == nil then
        WheelLanes.fruitTypeEffects = {}
        
        local function addEffect(fruitIndex, defoliage, iterations)
            if  fruitIndex ~= nil
            and fruitIndex ~= 0
            then
                local fruit = g_currentMission.fruits[fruitIndex]
                if  fruit    ~= nil
                and fruit.id ~= 0
                then
                    WheelLanes.fruitTypeEffects[fruitIndex] = { i=iterations , d=defoliage }
                    log("addEffect(",fruitIndex,",",defoliage,",",iterations,")")
                end
            end
        end

        -- These crops are only reduced back to their 2nd growth-state.
        local newGrowthState = 2
        addEffect(FruitUtil.FRUITTYPE_GRASS   , false , { {value=newGrowthState,minGrowthState=newGrowthState+1,maxGrowthState=7} } )
        addEffect(FruitUtil.FRUITTYPE_LUZERNE , false , { {value=newGrowthState,minGrowthState=newGrowthState+1,maxGrowthState=7} } )
        addEffect(FruitUtil.FRUITTYPE_ALFALFA , false , { {value=newGrowthState,minGrowthState=newGrowthState+1,maxGrowthState=7} } )
        addEffect(FruitUtil.FRUITTYPE_CLOVER  , false , { {value=newGrowthState,minGrowthState=newGrowthState+1,maxGrowthState=7} } )

        -- Root-crops gets automatically "defoliaged" by wheels
        -- Root-crops are only destroyed in growth-states between #3 and #4, and at #8
        addEffect(FruitUtil.FRUITTYPE_SUGARBEET , true  , { {value=0,minGrowthState=3,maxGrowthState=4}, {value=0,minGrowthState=8,maxGrowthState=8} } )
        addEffect(FruitUtil.FRUITTYPE_POTATO    , true  , { {value=0,minGrowthState=3,maxGrowthState=4}, {value=0,minGrowthState=8,maxGrowthState=8} } )

        -- All other seedable fruits
        for fruitIndex,fruit in pairs(g_currentMission.fruits) do
            if  fruitIndex ~= FruitUtil.FRUITTYPE_DRYGRASS -- dryGrass will not be affected
            and fruit.id ~= 0 -- fruit must have a foliage-layer id
            and FruitUtil.fruitIndexToDesc[fruitIndex].allowsSeeding -- only destroy fruit that we can actually seed
            and WheelLanes.fruitTypeEffects[fruitIndex] == nil
            then
                -- Destroy all growth-states between #3 (second visible growth, after seeded) through #8 (withered).
                -- This will not affect growth-state #9 (cutted), #10 (defoliaged), nor growth-state #1 (seeded)
                addEffect(fruitIndex , false , { {value=0,minGrowthState=3,maxGrowthState=8} } )
            end
        end
    end
end;

function WheelLanes:delete()
end;

function WheelLanes:readStream(streamId, connection)
end;

function WheelLanes:writeStream(streamId, connection)
end;

function WheelLanes:mouseEvent(posX, posY, isDown, isUp, button)
end;

function WheelLanes:keyEvent(unicode, sym, modifier, isDown)
end;

function WheelLanes:draw()
--[[
    if self.workAreas ~= nil and self.modWL_workarea_idx > 0 and self.modWL_workarea_idx <= #self.workAreas then
        local wa = self.workAreas[self.modWL_workarea_idx];
        --local x,y,z = localToWorld(wa.start
        local x1,y1,z1 = getWorldTranslation(wa.start);
        local x2,y2,z2 = getWorldTranslation(wa.width);
        local x3,y3,z3 = getWorldTranslation(wa.height);
        
        drawDebugPoint(x1,y1,z1, 1,1,0,1);
        drawDebugPoint(x2,y2,z2, 1,1,0,1);
        drawDebugPoint(x3,y3,z3, 1,1,0,1);
        
        drawDebugLine(x1,y1,z1, 1,0,0, x2,y2,z2, 0,0,1);
        drawDebugLine(x1,y1,z1, 1,0,0, x3,y3,z3, 0,0,1);
    end
--]]
--[[
    if self.modWL_showWheels and self.wheels ~= nil then --and self.modWL_wheel_idx > 0 and self.modWL_wheel_idx <= #self.wheels then
        for _,w in pairs(self.wheels) do
            --local x1,y1,z1 = localToWorld(w.repr, -0.05 ,0, -0.05 );
            --local x2,y2,z2 = localToWorld(w.repr,  0.1  ,0,  0.0  );
            --local x3,y3,z3 = localToWorld(w.repr,  0.0  ,0,  0.1  );
            
            local x,y,z = getWorldTranslation(w.repr);
            x=x-0.05;y=y-0.05;
            local x1,y1,z1 = x+0.0 ,y,z+0.0
            local x2,y2,z2 = x+0.1 ,y,z+0.0 
            local x3,y3,z3 = x+0.0 ,y,z+0.1 
            
            drawDebugPoint(x1,y1,z1, 1,1,0,1);
            drawDebugPoint(x2,y2,z2, 1,1,0,1);
            drawDebugPoint(x3,y3,z3, 1,1,0,1);
            
            drawDebugLine(x1,y1,z1, 1,1,1, x2,y2,z2, 1,1,1);
            drawDebugLine(x1,y1,z1, 1,1,1, x3,y3,z3, 1,1,1);
        end
    end
--]]    
end;

function WheelLanes:update(dt)
    -- This update() is called way to often for 'wheel lanes'.

    -- 
--[[    
    if InputBinding.hasEvent(InputBinding.ACTIVATE_OBJECT) and self.workAreas ~= nil then
        if self:getIsActiveForInput() then
            self.modWL_workarea_idx = (self.modWL_workarea_idx + 1) % (#self.workAreas + 1)
            local wa = self.workAreas[self.modWL_workarea_idx];
            if wa ~= nil then
                log("idx=",self.modWL_workarea_idx,", type=",wa.type,"/",WorkArea.areaTypeIntToName[wa.type])
            else
                log("idx=",self.modWL_workarea_idx)
            end
        end
    end
--]]    
--[[
    if InputBinding.hasEvent(InputBinding.ACTIVATE_OBJECT) and self.wheels ~= nil then
        if self:getIsActiveForInput() then
            self.modWL_showWheels = not self.modWL_showWheels;
        end
    end
--]]    
end;

function WheelLanes:updateTick(dt)
  if  WheelLanes.enabled            -- Only when wheellanes are "enabled"
  and self.isActive                 -- Only when vehicle is actually active
  and self.hasWheelGroundContact    -- Only when (at least one) wheel have ground-contact (Found in script-docs patch 1.3)
  and self.movingDirection ~= 0     -- Only "destroy foliage" when vehicle is actually moving
  then
      local areasSend = {};
      local sx,sz

      -- Use the defined wheels, and calculate some "cuttingArea" for each of them.
      for _,wheel in pairs(self.wheels) do
        if  wheel.contact == Vehicle.WHEEL_GROUND_CONTACT -- Found in script-docs patch 1.3
        and wheel.radius >= 0.5 -- We want only to use wheels that has a radius of more than 0.5 units.
        then
            sx,_,sz = getWorldTranslation(wheel.repr);
            table.insert(areasSend, {sx=sx-0.05,sz=sz-0.05, wx=0.1,wz=0, hx=0,hz=0.1})
        end
      end

      if table.getn(areasSend) > 0 then
        WheelLanes.destroyFoliageLayers(areasSend);
      end;
  end;
end;

function WheelLanes.destroyFoliageLayers(areas)
--[[  
  -- Destroy ALL fruits with foliage-layers that allows-seeding, disregarding whatever growth-state they are at.
  -- - Ignore "just seeded"
  -- - Ignore "defoliaged"
  -- - Do not kill grass, only reduce it to growth-state #2.
  -- - Do not kill dryGrass, as it is basically only windrows anyway.

  local iterations;
  for fruitIndex,fruit in pairs(g_currentMission.fruits) do
    if  fruitIndex ~= FruitUtil.FRUITTYPE_DRYGRASS -- dryGrass will not be affected
    and fruit.id ~= 0 -- fruit must have a foliage-layer id
    and FruitUtil.fruitIndexToDesc[fruitIndex].allowsSeeding -- only destroy fruit that we can actually seed
    then
      if fruitIndex == FruitUtil.FRUITTYPE_GRASS 
      or fruitIndex == FruitUtil.FRUITTYPE_LUZERNE
      or fruitIndex == FruitUtil.FRUITTYPE_ALFALFA
      or fruitIndex == FruitUtil.FRUITTYPE_CLOVER
      then 
        -- These crops are only reduced back to their second growth-state.
        iterations = { {value=2,minGrowthState=3,maxGrowthState=7} }
      elseif fruitIndex == FruitUtil.FRUITTYPE_SUGARBEET
      or     fruitIndex == FruitUtil.FRUITTYPE_POTATO 
      then
        -- Root-crops gets automatically "defoliaged" by wheels
        WheelLanes.updateFruitPreparerArea(areas, fruit, FruitUtil.fruitIndexToDesc[fruitIndex])
        -- Root-crops are only destroyed in growth-states between #3 and #4, and at #8
        iterations = { {value=0,minGrowthState=3,maxGrowthState=4}, {value=0,minGrowthState=8,maxGrowthState=8} }
      else
        -- Destroy all growth-states between #3 (second visible growth, after seeded) through #8 (withered).
        -- This will not affect growth-state #9 (cutted), #10 (defoliaged), nor growth-state #1 (seeded)
        iterations = { {value=0,minGrowthState=3,maxGrowthState=8} }
      end

      --
      for _,iteration in pairs(iterations) do
--]]


  local fruit
  for fruitIndex,effect in pairs(WheelLanes.fruitTypeEffects) do
      fruit = g_currentMission.fruits[fruitIndex]
  
      if effect.d == true then
        WheelLanes.updateFruitPreparerArea(areas, fruit, FruitUtil.fruitIndexToDesc[fruitIndex])
      end
    
      for _,iteration in pairs(effect.i) do
        setDensityMaskParams(
          fruit.id, -- masked foliage-id
          "between", -- algorithm/compare-function to use when "masking" (I think)
          iteration.minGrowthState, iteration.maxGrowthState -- parameter(s) for the algorithm
        );

        for _,area in pairs(areas) do
          setDensityMaskedParallelogram(
            fruit.id, -- destination foliage-id
            area.sx,area.sz, area.wx,area.wz, area.hx,area.hz, -- destination parallelogram
            0, -- destination foliage's channel-start-offset-bit
            g_currentMission.numFruitStateChannels, -- destination foliage's number-of-bits-the-value-affects
            fruit.id, -- source/masked foliage-id
            0, -- source/masked foliage's channel-start-offset-bit
            g_currentMission.numFruitStateChannels, -- source/masked foliage's number-of-bits-to-mask-against
            iteration.value  -- destination foliage's value-to-set
          );
        end
      end

      -- Restore to "normal" masking parameters (I wonder if this is actually needed anyway?)
      setDensityMaskParams(
        fruit.id, -- masked foliage-id
        "greater",
        0
      );
--[[      
    end
--]]    
  end;

  -- Support for SoilMod's weeds.
  if g_currentMission.fmcFoliageWeed ~= nil and g_currentMission.fmcFoliageWeed ~= 0 then
    for _,area in pairs(areas) do
      setDensityParallelogram(
        g_currentMission.fmcFoliageWeed, -- destination foliage-id
        area.sx,area.sz, area.wx,area.wz, area.hx,area.hz, -- destination parallelogram
        0, -- destination foliage's channel-start-offset-bit
        2, -- destination foliage's number-of-bits-the-value-affects
        0  -- destination foliage's value-to-set
      );
    end
  end

end;

function WheelLanes.updateFruitPreparerArea(areas,fruit,fruitDesc)

    setDensityCompareParams(fruit.id, "between", fruitDesc.minPreparingGrowthState+1, fruitDesc.maxPreparingGrowthState+1); -- add 1 since growth state 0 has density value 1

    local preparedGrowthState = fruitDesc.preparedGrowthState+1
    if fruit.preparingOutputId ~= 0 then
        local numChangedPixels
        for _,area in pairs(areas) do
            _,numChangedPixels = setDensityParallelogram(
                fruit.id, 
                area.sx,area.sz, area.wx,area.wz, area.hx,area.hz,
                0, g_currentMission.numFruitStateChannels, 
                preparedGrowthState
            );
            if numChangedPixels > 0 then
                setDensityMaskedParallelogram(
                    fruit.preparingOutputId, 
                    area.sx,area.sz, area.wx,area.wz, area.hx,area.hz,
                    0, 1, 
                    fruit.id, 0, g_currentMission.numFruitStateChannels, 
                    1
                );
            end
        end
    else
        for _,area in pairs(areas) do
            setDensityParallelogram(
                fruit.id, 
                area.sx,area.sz, area.wx,area.wz, area.hx,area.hz,
                0, g_currentMission.numFruitStateChannels, 
                preparedGrowthState
            );
        end
    end
    
    setDensityCompareParams(fruit.id, "greater", -1);

end

--
print(string.format("Script loaded: WheelLanes.lua (v%s)  - (Making wheels destroy crops!)", WheelLanes.version));
