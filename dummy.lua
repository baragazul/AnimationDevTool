-- prevent the draft loaded if the TheoTown version is not supported
-- only for plugins that published outside plugin store
if Runtime.getVersionCode() >= 1937 then
  -- create a dummy drafts
  -- the drafts will be added while init
  for i=1, 8 do
    Draft.append([[
        [
          {
            "id": "$dummy]]..i..[[",
            "type": "award",
            "title": "Dummy size ]]..i..[[ x ]]..i..[[",
            "category": "$dummyfolder00",
            "width": ]]..i..[[,
            "height": ]]..i..[[,
            "frames": [{"bmp": "dummy_frames.png"}],
            "script": "main.lua",
            "draw ground": true,
            "max count": 1,
            "build time": 0
          }
        ]
      ]]
    )
  end
end

-- dialog to select hidden draft
-- the draft only can be selected with this tool
local function showDraftDialog()
  local dialog = GUI.createDialog{
    w = 256,
    h = 256,
    title = 'Select Building Size'
  }
  local listBox = dialog.content:addListBox{}
  for i=1, 8 do
    local layout = listBox:addLayout{h=26,spacing=1}
    local label = layout:getFirstPart():addLabel{
      w = -26,
      text = Draft.getDraft('$dummy'..i):getTitle()
    }
    local button = layout:getLastPart():addButton{
      w = 0,
      icon = Icon.BUILD,
      onClick = function()
        City.createDraftDrawer('$dummy'..i).select()
        dialog.close()
      end
    }
  end
end

-- function to close the build mode and show the dialog
-- another function to prevent the dialog show
-- when the draft has been built
function script:event(x,y,level,event)
  if event == Script.EVENT_TOOL_ENTER then
    GUI.get'cmdCloseTool':click()
    -- prevent the funtion to be called and show an error message
    if Runtime.getVersionCode() >= 1937 then
      local draft = Array()
      for i=1, 8 do
        draft:add(City.countBuildings(Draft.getDraft('$dummy'..i)))
      end
      if draft:contains(1) then
        Debug.toast('Please remove the last building first')
      else
        showDraftDialog()
      end
    else
      Debug.toast('TheoTown version is not supported')
    end
  end
end
