local activeLayer = 1
local buildingId = 'buildingId'
local layer = Array{Array{1,'animationId',1,1,1,1,0,0,0,1}} -- Array with contents
local temp = {} -- Empty table
local toDisplay = {} -- Empty table
local toFile = Array() -- Empty array

-- create a table to store animation id from user
local function userAnimationId()
  return Util.optStorage(TheoTown.getStorage(), 'userAnimationId')
end

-- functions to facilitate access to get and set values in nested arrays
-- recommended for values that is stored on child table of table
local function getDirection(index)
  local index = index or activeLayer
  return layer[index][1]
end

local function setDirection(newState)
  layer[activeLayer][1] = newState
end

local function getAnimationId(index)
  local index = index or activeLayer
  return layer[index][2]
end

local function setAnimationId(newState)
  layer[activeLayer][2] = newState
end

local function getAbsX(index)
  local index = index or activeLayer
  return layer[index][3]
end

local function setAbsX(newState)
  layer[activeLayer][3] = newState
end

local function getAbsY(index)
  local index = index or activeLayer
  return layer[index][4]
end

local function setAbsY(newState)
  layer[activeLayer][4] = newState
end

local function getColumn(index)
  local index = index or activeLayer
  return layer[index][5]
end

local function setColumn(newState)
  layer[activeLayer][5] = newState
end

local function getRow(index)
  local index = index or activeLayer
  return layer[index][6]
end

local function setRow(newState)
  layer[activeLayer][6] = newState
end

local function getDiffX(index)
  local index = index or activeLayer
  return layer[index][7]
end

local function setDiffX(newState)
  layer[activeLayer][7] = newState
end

local function getDiffY(index)
  local index = index or activeLayer
  return layer[index][8]
end

local function setDiffY(newState)
  layer[activeLayer][8] = newState
end

local function getOffsetY(index)
  local index = index or activeLayer
  return layer[index][9]
end

local function setOffsetY(newState)
  layer[activeLayer][9] = newState
end

local function getProbability(index)
  local index = index or activeLayer
  return layer[index][10]
end

local function setProbability(newState)
  layer[activeLayer][10] = newState
end

-- function to insert a string automatically under certain conditions
local function probabilityText(index)
  local index = index or activeLayer
  if getProbability(index) == 1 then
    return ''
  else
    return ', "night light probability": '..getProbability(index)
  end
end

-- reset all values.
-- in this plugin, this function will be called
-- when the dummy draft removed
local function reset()
  activeLayer = 1
  buildingId = 'buildingId'
  layer = Array{Array{1,'animationId',1,1,1,1,0,0,0,1}}
  toDisplay = {}
end

-- functions to manage a layer
local function newLayer()
  layer:add(Array{1,'animationId',1,1,1,1,0,0,0,1})
end

local function copyLayer(index)
  local temp = layer[index]:copy()
  layer:add(temp)
  temp = nil
end

local function removeLayer(index)
  table.remove(layer, index)
  activeLayer = 1
end

-- functions to calculate a raw data (integer)
local function horizontalLights(index)
  if index == nil then
    for i=1, #layer do
      for c=1, getColumn(i) do
        table.insert(temp, c, {x = getAbsX(i) + getDiffX(i) * (c - 1), y = getAbsY(i), probability = probabilityText(i)})
      end
    end
  else
    for c=1, getColumn(activeLayer) do
      table.insert(temp, c, {x = getAbsX(activeLayer) + getDiffX(activeLayer) * (c - 1), y = getAbsY(activeLayer), probability = probabilityText(activeLayer)})
    end
  end
end

local function verticalLights(index)
  if index == nil then
    for i=1, #layer do
      for r=1, getRow(i) do
        table.insert(temp, r, {x = getAbsX(i), y = getAbsY(i) + getDiffY(i) * (r - 1), probability = probabilityText(i)})
      end
    end
  else
    for r=1, getRow(activeLayer) do
      table.insert(temp, r, {x = getAbsX(activeLayer), y = getAbsY(activeLayer) + getDiffY(activeLayer) * (r - 1), probability = probabilityText(activeLayer)})
    end
  end
end

local function rectLights(index)
  if index == nil then
    for i=1, #layer do
      for c = 1, getColumn(i) do
        for r = 1, getRow(i) do
          table.insert(temp, c + 1 * (r - 1), {x = getAbsX(i) + getDiffX(i) * (c - 1), y = getAbsY(i) + getDiffY(i) * (r - 1), probability = probabilityText(i)})
        end
      end
    end
  else
    for c = 1, getColumn(activeLayer) do
      for r = 1, getRow(activeLayer) do
        table.insert(temp, c + 1 * (r - 1), {x = getAbsX(activeLayer) + getDiffX(activeLayer) * (c - 1), y = getAbsY(activeLayer) + getDiffY(activeLayer) * (r - 1), probability = probabilityText(activeLayer)})
      end
    end
  end
end

local function diagonalLights(index)
  if index == nil then
    for i=1, #layer do
      for c = 1, getColumn(i) do
        for r = 1, getRow(i) do
          table.insert(temp, c + 1 * (r - 1), {x = getAbsX(i) + getDiffX(i) * (c - 1), y = (getAbsY(i) + getDiffY(i) * (r - 1)) + (getOffsetY(i) * (c - 1)), probability = probabilityText(i)})
        end
      end
    end
  else
    for c = 1, getColumn(activeLayer) do
      for r = 1, getRow(activeLayer) do
        table.insert(temp, c + 1 * (r - 1), {x = getAbsX(activeLayer) + getDiffX(activeLayer) * (c - 1), y = (getAbsY(activeLayer) + getDiffY(activeLayer) * (r - 1)) + (getOffsetY(activeLayer) * (c - 1)), probability = probabilityText(activeLayer)})
      end
    end
  end
end

-- function to update realtime display when the value is changed
-- temp table is always empty before and after proccess to save the space.
-- toDisplay table only contains light defs from the active layer
-- to prevent lagging on some devices.
local function updateDisplay()
  temp = {}
  toDisplay = {}
  if getDirection() == 1 then
    horizontalLights(1)
  elseif getDirection() == 2 then
    verticalLights(1)
  elseif getDirection() == 3 then
    rectLights(1)
  elseif getDirection() == 4 then
    diagonalLights(1)
  end
  for i=1, #temp do
    table.insert(toDisplay, #toDisplay + 1, {x = 'nil', y = 'nil'})
    toDisplay[#toDisplay].x = temp[i].x
    toDisplay[#toDisplay].y = temp[i].y
  end
  temp = {}
end

-- function to convert a calculated data into clipboard or file.
-- clipboard has a size limitation, but simply to use.
-- save to text can handle a big size than clipboard, but has path limitation
-- on .plugin, .mpf, and .zip format.
local function convert(type)
  temp = {}
  toFile:clear()
  -- create a condition to prevent nil animation id inserted into clipboard or file.
  if getAnimationId() ~= 'animationId' then
    if getDirection() == 1 then
      horizontalLights()
    elseif getDirection() == 2 then
      verticalLights()
    elseif getDirection() == 3 then
      rectLights()
    elseif getDirection() == 4 then
      diagonalLights()
    end
    if #temp == 1 then
      toFile:add('{"id": "'..getAnimationId()..'", "x":'..temp[1]['x']..', "y":'..temp[1]['y']..''..temp[1].probability..'}')
    elseif #temp > 1 then 
      for i=1, #temp do
        toFile:add('{"id": "'..getAnimationId()..'", "x":'..temp[i]['x']..', "y":'..temp[i]['y']..''..temp[i].probability..'}')
      end
    end
    if type == 'save' then
      if Draft.getDraft(buildingId) ~= nil then
        Runtime.saveText('../Animation Dev Tool/'..Draft.getDraft(buildingId):getTitle()..'_anim.txt', ''..toFile:join(',\n'))
      else
        Debug.toast('Err : building id is nil')
      end
    elseif type == 'copy' then
      Runtime.setClipboard(''..toFile:join(',\n'))
      Debug.toast('Put the code into clipboard')
    end
  else
    -- show a message when animation id is nil
    Debug.toast('Err : animation id is nil')
  end
  temp = {}
  toFile:clear()
end

-- create an array of light animation ids.
local lightDrafts = Array{'1x1l', '1x2l', '1x3l', '1x4l', '1x4lsmth', '1x4lsmth_weird', '2x2l', '2x2_ltr', '2x2_rtl', '2x3l', '2x3butnot', '2x3butnotandflipped', '2x4l', '3x2l', '3x2l_WEIRD', '3x2l_right_1', '3x3l_right_1', '3x3_ltr', '3x3_rtl', '3x4l', '3x4_uh', '3x4_uh_side', '3x6_iso', '3x6_iso_side', '4x2', '4x2_side', '4x3l', '4x3lsmth', '4x3lsmth_weird', '4x3_kluche', '4x3_kluche2', '4x3_kluche3', '4x3_kluche4', '4x4l', '4x4l2', '4x4_iso', '4x4_iso_side', '5x5l', '5x7l', '10x3l', '10x3l_side', '12x3l', '12x3l_side', '$animationblinkingredlight3x3', '$animationblinkingyellowlight3x3', '$animationblinkingwhitelight3x3', '$animationblinkinggreenlight3x3', '$animationblinkingbluelight3x3', 'BIGGA', 'cutelamp', 'cutelamp_traffoc', 'enslavedstupid', 'lamppost_night', 'lamppost_night_1', 'outacoolnames', 'somewhatweird', 'stair_ltr2', 'stair_ltr2inverted', 'stair_rtl2', 'stair_rtl2inverted', 'stair_ltr3', 'stair_rtl3'}

-- function to convert direction numbers to be string
local function directionName()
  if getDirection() == 1 then
    return 'Horizontal'
  elseif getDirection() == 2 then
    return 'Vertical'
  elseif getDirection() == 3 then
    return 'Rect'
  elseif getDirection() == 4 then
    return 'Diagonal'
  end
end

-- cache the global function and make it short
local function master()
  return GUI.getRoot()
end

-- suspend / pause mode when enter the tools
local lastSpeed
local function enterTool()
  lastSpeed = City.getSpeed()
  City.setSpeed(0)
  TheoTown.SETTINGS.hideUI = true
  if Runtime.getPlatform() == 'desktop' then
    master():getChild(5):setVisible(false)
  else
    master():getChild(6):setVisible(false)
  end
  GUI.get'sidebarLine':setVisible(false)
end

-- return to the last conditions when exit the tools
local function exitTool()
  City.setSpeed(lastSpeed)
  lastSpeed = nil
  TheoTown.SETTINGS.hideUI = false
  if Runtime.getPlatform() == 'desktop' then
    master():getChild(5):setVisible(true)
  else
    master():getChild(6):setVisible(true)
  end
  GUI.get'sidebarLine':setVisible(true)
end

-- convert a building id into the title of draft or some text if no valid id
local function buildingIdText()
  if Draft.getDraft(buildingId) == nil then
    return 'Please enter the building id'
  else
    return Draft.getDraft(buildingId):getTitle()
  end
end

-- declares the variable used in a function
-- to make it can be called outside of the function.
-- in this case, to delete the gui.
local base

-- main function of this tool that is contains input(set function)
-- and output(get function, realtime display, save and copy to clipboard).
local function showLightsDevTool()
  updateDisplay()

  base = master():addLayout{vertical=true,spacing=1}

  -- create a title and buttons layout like build mode.
  local titleRow = base:addLayout{h=111,vertical=true,spacing=0}

  local function addTitleRowEntry(tbl)
    local x = tbl.x or 0
    local h = tbl.h or 30
    local frameDefault = tbl.frameDefault or NinePatch.BUTTON
    local frameDown = tbl.frameDown or NinePatch.BUTTON_DOWN

    local layout = titleRow:getFirstPart():addLayout{h=tbl.h,spacing=2}
    local label = layout:getLastPart():addLabel{
      w = tbl.font:getWidth(tbl.title) + 1,
      text = tbl.title
    }
    label:setFont(tbl.font)
    label:setColor(256,256,256)

    local button = layout:getLastPart():addButton{
      x = x,
      w = 0,
      h = h,
      icon = tbl.icon,
      frameDefault = frameDefault,
      frameDown = frameDown,
      onUpdate = tbl.onUpdate,
      onClick = tbl.onClick
    }
  end
  addTitleRowEntry{
    h = 30,
    title = 'Animation Dev. Tool',
    font = Font.BIG,
    icon = Icon.CANCEL,
    frameDefault = NinePatch.BLUE_BUTTON,
    frameDown = NinePatch.BLUE_BUTTON_PRESSED,
    onClick = function()
      base:delete()
      base = nil
      exitTool()
    end
  }
  addTitleRowEntry{
    title = 'Copy to clipboard',
    font = Font.DEFAULT,
    x = 4,
    h = 26,
    icon = Icon.COPY,
    onClick = function()
      GUI.createDialog{
        w = 256,
        h = 160,
        title = 'Copy to clipboard',
        icon = Icon.PEOPLE_MECHANIC,
        text = [[Warning! This action may caused fatal error, please notice the total of the light definitions is under 25 columns x 25 rows. Please use "Save to file" option for big amount of light definitions.]],
        actions = {
          {
            text = 'Cancel',
            icon = Icon.CANCEL
          },
          {
            text = 'Copy',
            icon = Icon.OK,
            golden = true,
            onClick = function()
              convert('copy')
            end
          }
        }
      }
    end
  }
  addTitleRowEntry{
    title = 'Save to file',
    font = Font.DEFAULT,
    x = 4,
    h = 26,
    icon = Icon.DOWNLOAD,
    onClick = function()
      convert('save')
      Debug.toast('Success')
    end
  }
  addTitleRowEntry{
    title = 'About',
    font = Font.DEFAULT,
    x = 4,
    h = 26,
    icon = Icon.ABOUT,
    onClick = function()
      GUI.createDialog{
        w = 224,
        h = 128,
        title = 'About',
        icon = Icon.ABOUT,
        text = 'Plugin Title : Animation Dev. Tool\nPlugin Author : ian`\nPlugin Version : 1.0'
      }
    end
  }

  -- create a controls layout.
  local mainRow = base:getLastPart():addLayout{h=108,spacing=1}

  local leftSidebar = mainRow:getFirstPart():addLayout{w=160,vertical=true,spacing=2}
  local leftSidebarLine = leftSidebar:getLastPart():addLayout{vertical=true,h=216,spacing=1}
  
  local function addLeftSidebarEntry(tbl)
    local buttonLayout = leftSidebarLine:getLastPart():addLayout{h=26,spacing=1}
    local titleCanvas = buttonLayout:getLastPart():addCanvas{
      w = Font.DEFAULT:getWidth('Probability') + 6,
      onDraw = function(self,x,y,w,h)
        Drawing.drawNinePatch(NinePatch.PANEL,x,y,w,h)
      end
    }
    local titleLabel = titleCanvas:addLabel{
      text = tbl.text
    }
    titleLabel:setAlignment(0.5,0.5)
    local plusButton = buttonLayout:getLastPart():addButton{
      w = 0,
      icon = Icon.PLUS,
      frameDefault = NinePatch.BLUE_BUTTON,
      frameDown = NinePatch.BLUE_BUTTON_PRESSED,
      onClick = tbl.plusButtonOnclick,
      onUpdate = tbl.plusButtonOnUpdate
    }
    local minusButton = buttonLayout:getLastPart():addButton{
      w = 0,
      icon = Icon.MINUS,
      frameDefault = NinePatch.BLUE_BUTTON,
      frameDown = NinePatch.BLUE_BUTTON_PRESSED,
      onClick = tbl.minusButtonOnClick,
      onUpdate = tbl.minusButtonOnUpdate
    }
    local displayButton = buttonLayout:getLastPart():addButton{
      w = 35,
      frameDefault = NinePatch.BLUE_BUTTON,
      frameDown = NinePatch.BLUE_BUTTON_PRESSED,
      onUpdate = tbl.onUpdate,
      onClick = function()
        GUI.createRenameDialog{
          icon = Icon.EDIT,
          title = tbl.renameTitle,
          text = tbl.renameText,
          value = tbl.value,
          okText = 'Enter',
          cancelText = 'Cancel',
          onOk = tbl.onOk,
          onCancel = function() end,
          filter = function(value)
            return value:len() > 0 and tonumber(value) >= tbl.minValue and tonumber(value) <= tbl.maxValue
          end
        }
      end
    }
    local textLabel = displayButton:addLabel{
      h = 26,
      onUpdate = tbl.textLabelOnUpdate
    }
  end

  local function addLeftSidebarButton(tbl)
    local buttonLayout = leftSidebarLine:getLastPart():addLayout{h=26,spacing=1}
    local button = buttonLayout:getLastPart():addButton{
      w = 151,
      frameDefault = NinePatch.PANEL,
      frameDown = NinePatch.PANEL,
      onUpdate = tbl.onUpdate,
      onClick = tbl.onClick
    }
    return button
  end

  addLeftSidebarEntry{
    text = 'Column',
    onUpdate = function(self)
      self:setEnabled(getDirection() ~= 2)
    end,
    plusButtonOnclick = function()
      setColumn(getColumn() + 1)
      updateDisplay()
    end,
    minusButtonOnClick = function()
      setColumn(getColumn() - 1)
      updateDisplay()
    end,
    plusButtonOnUpdate = function(self)
      self:setEnabled(getColumn() < 50 and getDirection() ~= 2)
    end,
    minusButtonOnUpdate = function(self)
      self:setEnabled(getColumn() > 1 and getDirection() ~= 2)
    end,
    renameTitle = 'Set Column',
    renameText = 'Enter number for column.',
    value = '',
    onOk = function(value)
      setColumn(value)
      updateDisplay()
    end,
    textLabelOnUpdate = function(self)
      self:setText(getColumn())
      self:setAlignment(0.5,0.5)
    end,
    minValue = 1,
    maxValue = 100
  }

  addLeftSidebarEntry{
    text = 'X',
    plusButtonOnclick = function()
      setAbsX(getAbsX() + 1)
      updateDisplay()
    end,
    minusButtonOnClick = function()
      setAbsX(getAbsX() - 1)
      updateDisplay()
    end,
    plusButtonOnUpdate = function(self)
      self:setEnabled(getAbsX() < 500)
    end,
    minusButtonOnUpdate = function(self)
      self:setEnabled(getAbsX() > -500)
    end,
    renameTitle = 'Set X',
    renameText = 'Enter number for X.',
    onOk = function(value)
      setAbsX(value)
      updateDisplay()
    end,
    textLabelOnUpdate = function(self)
      self:setText(getAbsX())
      self:setAlignment(0.5,0.5)
    end,
    minValue = -500,
    maxValue = 500
  }

  addLeftSidebarEntry{
    text = 'Diff X',
    onUpdate = function(self)
      self:setEnabled(getDirection() ~= 2)
    end,
    plusButtonOnclick = function()
      setDiffX(getDiffX() + 1)
      updateDisplay()
    end,
    minusButtonOnClick = function()
      setDiffX(getDiffX() - 1)
      updateDisplay()
    end,
    plusButtonOnUpdate = function(self)
      self:setEnabled(getDiffX() < 500 and getDirection() ~= 2)
    end,
    minusButtonOnUpdate = function(self)
      self:setEnabled(getDiffX() > -500 and getDirection() ~= 2)
    end,
    renameTitle = 'Set Diff X',
    renameText = 'Enter number for diff X.',
    onOk = function(value)
      setDiffX(value)
      updateDisplay()
    end,
    textLabelOnUpdate = function(self)
      self:setText(getDiffX())
      self:setAlignment(0.5,0.5)
    end,
    minValue = -500,
    maxValue = 500
  }

  addLeftSidebarEntry{
    text = 'Probability',
    plusButtonOnclick = function()
      setProbability(math.ceil((getProbability() + 0.1) * 10) / 10)
    end,
    minusButtonOnClick = function()
      setProbability(math.floor((getProbability() - 0.1) * 10) / 10)
    end,
    plusButtonOnUpdate = function(self)
      self:setEnabled(getProbability() < 1)
    end,
    minusButtonOnUpdate = function(self)
      self:setEnabled(getProbability() > 0)
    end,
    renameTitle = 'Set Probability',
    renameText = 'Enter number for probability the light to spawn. If probability is 1, "night light probability" code will not be included',
    onOk = function(value)
      setProbability(value)
    end,
    textLabelOnUpdate = function(self)
      self:setText(getProbability())
      self:setAlignment(0.5,0.5)
    end,
    minValue = 0,
    maxValue = 1
  }

  addLeftSidebarButton{
    onUpdate = function(self)
      self:setText(buildingIdText())
    end,
    onClick = function()
      GUI.createRenameDialog{
        icon = Icon.EDIT,
        title = 'Enter Building Id',
        text = 'Please enter the building id that will be used.',
        value = '',
        okText = 'Enter',
        cancelText = 'Cancel',
        onOk = function(value)
          buildingId = value
        end,
        onCancel = function() end,
        filter = function(value)
          return Draft.getDraft(value) ~= nil
        end
      }
    end
  }

  addLeftSidebarButton{
    onUpdate = function(self)
      self:setText(getAnimationId())
    end,
    onClick = function()
      local dialog = GUI.createDialog{
        w = 256,
        h = 320,
        icon = Icon.WEATHER_SUNNY,
        title = 'Select animation id'
      }

      local listBox
      local updateListBox
      local function showListBox()
        listBox = dialog.content:addListBox{}
        lightDrafts:forEach(function(id)
          local entry = listBox:addLayout{h=26,spacing=1}
          local icon = entry:getFirstPart():addCanvas{
            w = 26,
            onDraw = function(self,x,y,w,h)
              Drawing.setColor(0,0,0)
              Drawing.setAlpha(0.3)
              Drawing.drawRect(x,y,w,h)
              Drawing.reset()
              Drawing.drawImageRect(Draft.getDraft(id):getFrame(1),x,y,w,h)
              Drawing.reset()
            end
          }
          local label = entry:getCenterPart():addLabel{
            w = Font.DEFAULT:getWidth(id),
            text = id
          }
          label:setColor(60,75,244)
          local button = entry:getLastPart():addButton{
            w = 26,
            frameDefault = NinePatch.BLUE_BUTTON,
            frameDown = NinePatch.BLUE_BUTTON_PRESSED,
            isPressed = function(self)
              return getAnimationId() == id
            end,
            onUpdate = function(self)
              if getAnimationId() == id then
                self:setIcon(Icon.OK)
              else
                self:setIcon(Icon.PLUS)
              end
            end,
            onClick = function()
              setAnimationId(id)
              dialog.close()
            end
          }
        end)
        if userAnimationId() then
          for key,id in pairs(userAnimationId()) do
            local entry = listBox:addLayout{h=26,spacing=1}
            local icon = entry:getFirstPart():addCanvas{
              w = 26,
              onDraw = function(self,x,y,w,h)
                Drawing.setColor(0,0,0)
                Drawing.setAlpha(0.3)
                Drawing.drawRect(x,y,w,h)
                Drawing.reset()
                Drawing.drawImageRect(Draft.getDraft(id):getFrame(1),x,y,w,h)
                Drawing.reset()
              end
            }
            local label = entry:getCenterPart():addLabel{
              w = Font.DEFAULT:getWidth(id),
              text = id
            }
            local button = entry:getLastPart():addButton{
              w = 26,
              icon = Icon.REMOVE,
              frameDefault = NinePatch.BLUE_BUTTON,
              frameDown = NinePatch.BLUE_BUTTON_PRESSED,
              onClick = function()
                userAnimationId()[key] = nil
                updateListBox()
              end
            }
            local button = entry:getLastPart():addButton{
              w = 26,
              frameDefault = NinePatch.BLUE_BUTTON,
              frameDown = NinePatch.BLUE_BUTTON_PRESSED,
              isPressed = function(self)
                return getAnimationId() == id
              end,
              onUpdate = function(self)
                if getAnimationId() == id then
                  self:setIcon(Icon.OK)
                else
                  self:setIcon(Icon.PLUS)
                end
              end,
              onClick = function()
                setAnimationId(id)
                dialog.close()
              end
            }
          end
        end
        local entry = listBox:addLayout{h=26,spacing=1}
        local addLabel = entry:getFirstPart():addLabel{
          w = -26,
          text = 'Add New Animation'
        }
        local addButton = entry:getLastPart():addButton{
          w = 0,
          icon = Icon.PLUS,
          frameDefault = NinePatch.BLUE_BUTTON,
          frameDown = NinePatch.BLUE_BUTTON_PRESSED,
          onClick = function()
            GUI.createRenameDialog{
              icon = Icon.PLUS,
              title = 'Add New Animation',
              text = 'Please insert animation id.',
              okText = 'Add',
              cancelText = 'Close',
              value = '',
              onOk = function(value)
                table.insert(userAnimationId(), value)
                updateListBox()
              end,
              onCancel = function() end,
              filter = function(value)
                local draft = Draft.getDraft(value)
                return value:len() > 0 and draft:isAnimation()
              end
            }
          end
        }
      end
      showListBox()
      
      updateListBox = function()
        listBox:delete()
        listBox = nil
        showListBox()
      end
    end
  }
  
  local rightSidebar = mainRow:getLastPart():addLayout{w=160,vertical=true,spacing=2}
  local rightSidebarLine = rightSidebar:getLastPart():addLayout{vertical=true,h=216,spacing=1}

  local function addRightSidebarEntry(tbl)
    local buttonLayout = rightSidebarLine:getLastPart():addLayout{h=26,spacing=1}
    local displayButton = buttonLayout:getFirstPart():addButton{
      w = 35,
      frameDefault = NinePatch.BLUE_BUTTON,
      frameDown = NinePatch.BLUE_BUTTON_PRESSED,
      onUpdate = tbl.onUpdate,
      onClick = function()
        GUI.createRenameDialog{
          icon = Icon.EDIT,
          title = tbl.renameTitle,
          text = tbl.renameText,
          value = '',
          okText = 'Enter',
          cancelText = 'Cancel',
          onOk = tbl.onOk,
          onCancel = function() end,
          filter = function(value)
            return value:len() > 0 and tonumber(value) >= tbl.minValue and tonumber(value) <= tbl.maxValue
          end
        }
      end
    }
    local textLabel = displayButton:addLabel{
      h = 26,
      onUpdate = tbl.textLabelOnUpdate
    }
    local minusButton = buttonLayout:getFirstPart():addButton{
      w = 0,
      icon = Icon.MINUS,
      frameDefault = NinePatch.BLUE_BUTTON,
      frameDown = NinePatch.BLUE_BUTTON_PRESSED,
      onClick = tbl.minusButtonOnClick,
      onUpdate = tbl.minusButtonOnUpdate
    }
    local plusButton = buttonLayout:getFirstPart():addButton{
      w = 0,
      icon = Icon.PLUS,
      frameDefault = NinePatch.BLUE_BUTTON,
      frameDown = NinePatch.BLUE_BUTTON_PRESSED,
      onClick = tbl.plusButtonOnclick,
      onUpdate = tbl.plusButtonOnUpdate
    }
    local titleCanvas = buttonLayout:getFirstPart():addCanvas{
      w = Font.DEFAULT:getWidth('Probability') + 6,
      onDraw = function(self,x,y,w,h)
        Drawing.drawNinePatch(NinePatch.PANEL,x,y,w,h)
      end
    }
    local titleLabel = titleCanvas:getFirstPart():addLabel{
      text = tbl.text
    }
    titleLabel:setAlignment(0.5,0.5)
  end

  addRightSidebarEntry{
    text = 'Row',
    onUpdate = function(self)
      self:setEnabled(getDirection() ~= 1)
    end,
    plusButtonOnclick = function()
      setRow(getRow() + 1)
      updateDisplay()
    end,
    minusButtonOnClick = function()
      setRow(getRow() - 1)
      updateDisplay()
    end,
    plusButtonOnUpdate = function(self)
      self:setEnabled(getRow() < 100 and getDirection() ~= 1)
    end,
    minusButtonOnUpdate = function(self)
      self:setEnabled(getRow() > 1 and getDirection() ~= 1)
    end,
    renameTitle = 'Set Row',
    renameText = 'Enter number for row.',
    onOk = function(value)
      setRow(value)
      updateDisplay()
    end,
    textLabelOnUpdate = function(self)
      self:setText(getRow())
      self:setAlignment(0.5,0.5)
    end,
    minValue = 1,
    maxValue = 50
  }
  
  addRightSidebarEntry{
    text = 'Y',
    plusButtonOnclick = function()
      setAbsY(getAbsY() + 1)
      updateDisplay()
    end,
    minusButtonOnClick = function()
      setAbsY(getAbsY() - 1)
      updateDisplay()
    end,
    plusButtonOnUpdate = function(self)
      self:setEnabled(getAbsY() < 500)
    end,
    minusButtonOnUpdate = function(self)
      self:setEnabled(getAbsY() > -500)
    end,
    renameTitle = 'Set Y',
    renameText = 'Enter number for Y.',
    onOk = function(value)
      setAbsY(value)
      updateDisplay()
    end,
    textLabelOnUpdate = function(self)
      self:setText(getAbsY())
      self:setAlignment(0.5,0.5)
    end,
    minValue = -500,
    maxValue = 500
  }
  
  addRightSidebarEntry{
    text = 'Diff Y',
    onUpdate = function(self)
      self:setEnabled(getDirection() ~= 1)
    end,
    plusButtonOnclick = function()
      setDiffY(getDiffY() + 1)
      updateDisplay()
    end,
    minusButtonOnClick = function()
      setDiffY(getDiffY() - 1)
      updateDisplay()
    end,
    plusButtonOnUpdate = function(self)
      self:setEnabled(getDiffY() < 500 and getDirection() ~= 1)
    end,
    minusButtonOnUpdate = function(self)
      self:setEnabled(getDiffY() > -500 and getDirection() ~= 1)
    end,
    renameTitle = 'Set Diff Y',
    renameText = 'Enter number for Diff Y.',
    onOk = function(value)
      setDiffY(value)
      updateDisplay()
    end,
    textLabelOnUpdate = function(self)
      self:setText(getDiffY())
      self:setAlignment(0.5,0.5)
    end,
    minValue = -500,
    maxValue = 500
  }
  
  addRightSidebarEntry{
    text = 'Offset Y',
    onUpdate = function(self)
      self:setEnabled(getDirection() == 3 or getDirection() == 4)
    end,
    plusButtonOnclick = function()
      setOffsetY(getOffsetY() + 1)
      updateDisplay()
    end,
    minusButtonOnClick = function()
      setOffsetY(getOffsetY() - 1)
      updateDisplay()
    end,
    plusButtonOnUpdate = function(self)
      self:setEnabled(getOffsetY() < 500 and getDirection() == 3 or getOffsetY() < 500 and getDirection() == 4)
    end,
    minusButtonOnUpdate = function(self)
      self:setEnabled(getOffsetY() > -500 and getDirection() == 3 or getOffsetY() > -500 and getDirection() == 4)
    end,
    renameTitle = 'Set Offset Y',
    renameText = 'Enter number for Offset Y.',
    onOk = function(value)
      setOffsetY(value)
      updateDisplay()
    end,
    textLabelOnUpdate = function(self)
      self:setText(getOffsetY())
      self:setAlignment(0.5,0.5)
    end,
    minValue = -500,
    maxValue = 500
  }

  local buttonLayout = rightSidebarLine:getLastPart():addLayout{h=26,spacing=1}
  local directionbutton = buttonLayout:getFirstPart():addButton{
    w = 151,
    frameDefault = NinePatch.PANEL,
    frameDown = NinePatch.PANEL,
    onUpdate = function(self)
      self:setText(''..directionName())
    end,
    onClick = function(directionbutton)
      GUI.createMenu{
        source = directionbutton,
        actions = {
          {
            text = 'Horizontal',
            onClick = function()
              setDirection(1)
              updateDisplay()
            end
          },
          {
            text = 'Vertical',
            onClick = function()
              setDirection(2)
              updateDisplay()
            end
          },
          {
            text = 'Rect',
            onClick = function()
              setDirection(3)
              updateDisplay()
            end
          },
          {
            text = 'Diagonal',
            onClick = function()
              setDirection(4)
              updateDisplay()
            end
          }
        }
      }
    end
  }

  local buttonLayout = rightSidebarLine:getLastPart():addLayout{h=26,spacing=1}
  local prevLayerButton = buttonLayout:getFirstPart():addButton{
    w = 0,
    icon = Icon.PREVIOUS,
    frameDefault = NinePatch.BLUE_BUTTON,
    frameDown = NinePatch.BLUE_BUTTON_PRESSED,
    onUpdate = function(self)
      self:setEnabled(activeLayer ~= 1)
    end,
    onClick = function()
      activeLayer = activeLayer - 1
      updateDisplay()
    end
  }
  local selectLayerButton = buttonLayout:getFirstPart():addButton{
    w = 99,
    frameDefault = NinePatch.PANEL,
    frameDown = NinePatch.PANEL,
    onUpdate = function(self)
      if #layer == 0 then
        self:setText('Create New Layer')
      else
        self:setText('Layer : '..activeLayer)
      end
    end,
    onClick = function()
      local dialog = GUI.createDialog{
        w = 256,
        h = 320,
        title = 'Layer Settings',
        icon = Icon.COPY
      }

      local listBox
      local listBoxUpdate

      local function listBoxEntry()
        listBox = dialog.content:addListBox{}

        if #layer ~= 0 then
          if #layer == 1 then
            local layout = listBox:addLayout{h=26,spacing=1}
            local label = layout:getFirstPart():addLabel{
              w = -78,
              text = 'Layer 1'
            }
            local copyButton = layout:getLastPart():addButton{
              w = 0,
              icon = Icon.COPY,
              onClick = function()
                copyLayer(1)
                listBoxUpdate()
              end
            }
            local selectButton = layout:getLastPart():addButton{
              w = 0,
              onUpdate = function(self)
                self:setEnabled(activeLayer ~= 1)
                if activeLayer == 1 then
                  self:setIcon(Icon.CHECKBOX_ON)
                else
                  self:setIcon(Icon.CHECKBOX_OFF)
                end
              end,
              onClick = function()
                activeLayer = 1
                updateDisplay()
              end
            }
          elseif #layer > 1 then
            for i=1, #layer do
              local layout = listBox:addLayout{h=26,spacing=1}
              local label = layout:getFirstPart():addLabel{
                w = -78,
                text = 'Layer '..i
              }
              if i ~= 1 then
                local removeButton = layout:getLastPart():addButton{
                  w = 0,
                  icon = Icon.MINUS,
                  onClick = function()
                    removeLayer(i)
                    listBoxUpdate()
                    updateDisplay()
                  end
                }
              end
              local copyButton = layout:getLastPart():addButton{
                w = 0,
                icon = Icon.COPY,
                onClick = function()
                  copyLayer(i)
                  listBoxUpdate()
                end
              }
              local selectButton = layout:getLastPart():addButton{
                w = 0,
                onUpdate = function(self)
                  self:setEnabled(activeLayer ~= i)
                  if activeLayer == i then
                    self:setIcon(Icon.CHECKBOX_ON)
                  else
                    self:setIcon(Icon.CHECKBOX_OFF)
                  end
                end,
                onClick = function()
                  activeLayer = i
                  updateDisplay()
                end
              }
            end
          end
        end
        local layout = listBox:addLayout{h=26,spacing=1}
        local addNewLayerLabel = layout:getFirstPart():addLabel{
          w = -26,
          text = 'Create New Layer'
        }
        local addNewLayerButton = layout:getLastPart():addButton{
          w = 0,
          icon = Icon.PLUS,
          onClick = function()
            newLayer()
            listBoxUpdate()
          end
        }
      end
      listBoxEntry()

      listBoxUpdate = function()
        listBox:delete()
        listBoxEntry()
      end
    end
  }
  local nextLayerButton = buttonLayout:getFirstPart():addButton{
    w = 0,
    icon = Icon.NEXT,
    frameDefault = NinePatch.BLUE_BUTTON,
    frameDown = NinePatch.BLUE_BUTTON_PRESSED,
    onUpdate = function(self)
      self:setEnabled(#layer ~= 0 and activeLayer ~= #layer)
    end,
    onClick = function()
      activeLayer = activeLayer + 1
      updateDisplay()
    end
  }
end

-- reset a values of all variables when then building removed
function script:event(x,y,level,event)
  if event == Script.EVENT_REMOVE then
    reset()
  end
end

-- draw the main building and realtime display of animations
function script:draw(tileX, tileY)
  if Draft.getDraft(buildingId) ~= nil then
    Drawing.setColor(160,160,160)
    Drawing.setTile(tileX, tileY)
    Drawing.drawImage(Draft.getDraft(buildingId):getFrame(1))
    Drawing.reset()
  else
    local size = script:getDraft():getWidth()
    for i=1, size do
      for v=1, size do
        Drawing.setTile(tileX + 1 * (i - 1), tileY + 1 * (v - 1))
        Drawing.drawTileFrame(Icon.TOOLMARK + 16 + 10)
      end
    end
  end
  if Draft.getDraft(getAnimationId()) ~= nil then
    if #toDisplay == 1 then
      Drawing.setTile(tileX, tileY, toDisplay[1].x, toDisplay[1].y)
      Drawing.drawImage(Draft.getDraft(getAnimationId()):getFrame(1))
    elseif #toDisplay > 1 then
      for i=1, #toDisplay do
        Drawing.setTile(tileX, tileY, toDisplay[i].x, toDisplay[i].y)
        Drawing.drawImage(Draft.getDraft(getAnimationId()):getFrame(1))
      end
    end
  end
end

-- turn false the default building dialog and show the gui of this tool
-- prevent a multiple dialog created when the building clicked more than once
function script:click(x,y)
  if base == nil then
    enterTool()
    showLightsDevTool()
  else
    base:delete()
    base = nil
    enterTool()
    showLightsDevTool()
  end
  return false
end
