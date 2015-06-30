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
--
WheelLanes.enabled = true

-- Moved to addSpecialization.LUA instead
--function WheelLanes.consoleCommandWheelLanes(self, value)
--    if value ~= nil then
--        if     value == "on"  or value == "true"  or value=="1" then WheelLanes.enabled = true
--        elseif value == "off" or value == "false" or value=="0" then WheelLanes.enabled = false
--        end
--    end
--    return "WheelLanes:"..tostring(WheelLanes.enabled)
--end
--addConsoleCommand("modWheelLanes", "", "consoleCommandWheelLanes", WheelLanes)

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
      local cuttingAreasSend = {};

      -- Use the defined wheels, and calculate some "cuttingArea" for each of them.
      -- This code-fragment was inspired from wheelLanes.lua by Blacky_BPG
      for _,wheel in ipairs(self.wheels) do
        if  wheel.contact == Vehicle.WHEEL_GROUND_CONTACT     -- Found in script-docs patch 1.3
        and wheel.radius >= 0.5    -- we want only to use wheels that has a radius of more than 0.5 units.
        then
            local x,_,z = getWorldTranslation(wheel.repr);
            x = x - 0.05;
            z = z - 0.05;
            --local x1 = x + 0.1;
            --local z1 = z;
            --local x2 = x;
            --local z2 = z + 0.1;
            table.insert(cuttingAreasSend, {x,z, x+0.1,z, x,z+0.1});
        end
      end

      if table.getn(cuttingAreasSend) > 0 then
        WheelLanesEvent.runLocally(cuttingAreasSend);
        ---- NOTE! This is going to be very "chatty" in multiplayer, and therefore may cause massive lag!
        --g_server:broadcastEvent(WheelLanesEvent:new(cuttingAreasSend));
      end;
  end;
end;

function WheelLanes:draw()
end;

----
----
----

-- WheelLanes Event-class
WheelLanesEvent = {};
--WheelLanesEvent_mt = Class(WheelLanesEvent, Event);
--
--InitEventClass(WheelLanesEvent, "WheelLanesEvent");
--
--function WheelLanesEvent:emptyNew()
--  local self = Event:new(WheelLanesEvent_mt);
--  self.className="WheelLanesEvent";
--  return self;
--end;
--
--function WheelLanesEvent:new(cuttingAreas)
--  local self = WheelLanesEvent:emptyNew()
--  assert(table.getn(cuttingAreas) > 0);
--  self.cuttingAreas = cuttingAreas;
--  return self;
--end;
--
--function WheelLanesEvent:readStream(streamId, connection)
--  local numAreas = streamReadUIntN(streamId, 4);
--
--  local refX = streamReadFloat32(streamId);
--  local refY = streamReadFloat32(streamId);
--  local values = Utils.readCompressed2DVectors(streamId, refX, refY, numAreas*3-1, 0.01, true);
--
--  WheelLanesEvent.destroyFoliageLayers(numAreas,values)
--end;
--
--function WheelLanesEvent:writeStream(streamId, connection)
--  local numAreas = table.getn(self.cuttingAreas);
--  streamWriteUIntN(streamId, numAreas, 4);
--
--  local refX, refY;
--  local values = {};
--  for i=1, numAreas do
--    local d = self.cuttingAreas[i];
--    if i==1 then
--      refX = d[1];
--      refY = d[2];
--      streamWriteFloat32(streamId, d[1]);
--      streamWriteFloat32(streamId, d[2]);
--    else
--      table.insert(values, {x=d[1], y=d[2]});
--    end;
--    table.insert(values, {x=d[3], y=d[4]});
--    table.insert(values, {x=d[5], y=d[6]});
--  end;
--  assert(table.getn(values) == numAreas*3 - 1);
--  Utils.writeCompressed2DVectors(streamId, refX, refY, values, 0.01);
--end;
--
--function WheelLanesEvent:run(connection)
--  print("Error: Do not run WheelLanesEvent locally");
--end;

function WheelLanesEvent.runLocally(cuttingAreas)
  local numAreas = table.getn(cuttingAreas);
  local refX, refY;
  local values = {};
  for i=1, numAreas do
    local d = cuttingAreas[i];
    if i==1 then
      refX = d[1];
      refY = d[2];
    else
      table.insert(values, {x=d[1], y=d[2]});
    end;
    table.insert(values, {x=d[3], y=d[4]});
    table.insert(values, {x=d[5], y=d[6]});
  end;
  assert(table.getn(values) == numAreas*3 - 1);
  local values = Utils.simWriteCompressed2DVectors(refX, refY, values, 0.01, true);

  WheelLanesEvent.destroyFoliageLayers(numAreas,values)
end

function WheelLanesEvent.destroyFoliageLayers(numAreas,values)
  -- Destroy ALL fruits with foliage-layers that allows-seeding, disregarding whatever growth-state they are at.
  -- - Ignore "just seeded"
  -- - Ignore "defoliaged"
  -- - Do not kill grass, only reduce it to growth-state #1.
  -- - Do not kill dryGrass, as it is basically only windrows anyway.

  --
  local areas = {}
  local x,z, widthX,widthZ, heightX,heightZ
  for i=1, numAreas do
    vi = (i-1)*3;
    x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(
      nil,
      values[vi+1].x, values[vi+1].y,
      values[vi+2].x, values[vi+2].y,
      values[vi+3].x, values[vi+3].y
    );
    table.insert(areas, {x=x,z=z, widthX=widthX,widthZ=widthZ, heightX=heightX,heightZ=heightZ})
  end
  --
  for fruitIndex,fruit in pairs(g_currentMission.fruits) do
    if  fruitIndex ~= FruitUtil.FRUITTYPE_DRYGRASS -- dryGrass will not be affected
    and fruit.id ~= 0 -- fruit must have a foliage-layer id
    and FruitUtil.fruitIndexToDesc[fruitIndex].allowsSeeding -- only destroy fruit that we can actually seed
    then
      local iterations = {}
      if fruitIndex == FruitUtil.FRUITTYPE_GRASS then -- grass is only reduced back to "seeded"
        iterations = { {value=1,minGrowthState=2,maxGrowthState=7} }
      elseif fruitIndex == FruitUtil.FRUITTYPE_SUGARBEET
      or     fruitIndex == FruitUtil.FRUITTYPE_POTATO then
        -- v0.3
        -- Root-crops gets automatically "defoliaged" by wheels
        for i=1, numAreas do
          vi = (i-1)*3;
          Utils.updateFruitPreparerArea(
            fruitIndex,
            values[vi+1].x,values[vi+1].y, values[vi+2].x,values[vi+2].y, values[vi+3].x,values[vi+3].y,
            values[vi+1].x,values[vi+1].y, values[vi+2].x,values[vi+2].y, values[vi+3].x,values[vi+3].y
          )
        end
        -- Root-crops are only destroyed in growth-states between #3 and #4, and at #8
        iterations = { {value=0,minGrowthState=3,maxGrowthState=4}, {value=0,minGrowthState=8,maxGrowthState=8} }
      else
        -- Destroy all growth-states between #3 (second visible growth, after seeded) through #8 (withered).
        -- This will not affect growth-state #9 (cutted), #10 (defoliaged), nor growth-state #1 (seeded)
        iterations = { {value=0,minGrowthState=3,maxGrowthState=8} }
      end

      for _,iteration in pairs(iterations) do
        setDensityMaskParams(
          fruit.id, -- masked foliage-id
          "between", -- algorithm/compare-function to use when "masking" (I think)
          iteration.minGrowthState, iteration.maxGrowthState -- parameter(s) for the algorithm
        );

        for _,area in pairs(areas) do
          setDensityMaskedParallelogram(
            fruit.id, -- destination foliage-id
            area.x, area.z, area.widthX, area.widthZ, area.heightX, area.heightZ, -- destination parallelogram
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
        area.x, area.z, area.widthX, area.widthZ, area.heightX, area.heightZ, -- destination parallelogram
        0, -- destination foliage's channel-start-offset-bit
        2, -- destination foliage's number-of-bits-the-value-affects
        0  -- destination foliage's value-to-set
      );
    end
  end

end;

--
print(string.format("Script loaded: WheelLanes.lua (v%s)  - (Making wheels destroy crops!)", WheelLanes.version));
