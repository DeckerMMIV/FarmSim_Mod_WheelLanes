--
-- WheelLanes - Wheels will destroy crops!
--
-- @author  Decker_MMIV - fs-uk.com, forum.farming-simulator.com, modhoster.com
-- @date    2015-04-xx
--
-- @history
--  2014-March
--      v0.1    - A modified version of WheelLanes.LUA by Manuel Leithner (SFM-Modding), that was edited by JoXXer (BJR-Modding)
--              - Added a bit more multiplayer support, though with a WARNING that it may cause massive lag.
--              - Published at http://fs-uk.com/forum/index.php?topic=155892.msg1045659#msg1045659
--      v0.2    - Tweaks regarding which crops to destroy or not.
--                A crop that has "just been seeded" is not destroyed, nor will "defoliated" sugarbeet and potato.
--                Grass will only be reduced back to "seeded" growth-state (#1).
--                Else any other fruit with foliage-layer and growth-states #2-#8 will be destroyed.
--              - Not yet tested in multiplayer.
--      v0.3    - http://fs-uk.com/forum/index.php?topic=158093.0
--              - Misc. "optimizations", though they are not actually measured.
--  2014-May
--      v0.4    - Console command added, to turn on/off WheelLanes.
--  2014-June
--      v0.4b   - Moved console command to addSpecialization.LUA
--      v0.5    - Destroy weed that is in FMC's soil management mod.
--      v0.6    - Minor tweak.
--  2015-April
--      v0.7    - Upgraded to FS15

WheelLanes = {};
--
local modItem = ModsUtil.findModItemByModName(g_currentModName);
WheelLanes.version = (modItem and modItem.version) and modItem.version or "?.?.?";
WheelLanes.enabled = true
--

function WheelLanes.prerequisitesPresent(specializations)
  return true
end;

function WheelLanes:load(xmlFile)
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

function WheelLanes:update(dt)
    -- This update() is called way to often for 'wheel lanes'.
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

function WheelLanes:draw()
end;

function WheelLanes.destroyFoliageLayers(areas)
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
    end
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
