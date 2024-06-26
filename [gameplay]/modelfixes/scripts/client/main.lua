addEvent("modelfixes:client:loadAllComponents", true)
addEvent("modelfixes:client:togOneComponent", true)

local mapFixComponents = {}

local function loadOneMapFixComponent(name, data)
    -- Restore previously replaced models if any
    local modelsToReplace = data.modelsToReplace
    if modelsToReplace then
        for _, v in pairs(modelsToReplace) do
            engineRestoreCOL(v.modelID)
            engineRestoreModel(v.modelID)
        end
    end
    -- Clear the previous elements if any
    local createdElements = data.createdElements
    if createdElements then
        for _, element in pairs(createdElements) do
            if isElement(element) then
                destroyElement(element)
            end
        end
        data.createdElements = {}
    end

    -- Don't proceed if the component is disabled
    if not data.enabled then
        return
    end

    -- Replace models if any
    if modelsToReplace then
        for _, v in pairs(modelsToReplace) do
            if v.colPath then
                local colElement = engineLoadCOL("models/" .. v.colPath)
                if colElement then
                    engineReplaceCOL(colElement, v.modelID)
                    if not data.createdElements then data.createdElements = {} end
                    data.createdElements[#data.createdElements + 1] = colElement
                end
            end
        end
    end
end

local function loadMapFixComponents(mapFixComponentsFromServer)
    assert(type(mapFixComponentsFromServer) == "table")
    mapFixComponents = mapFixComponentsFromServer
    for name, data in pairs(mapFixComponents) do
        loadOneMapFixComponent(name, data)
    end
end
addEventHandler("modelfixes:client:loadAllComponents", localPlayer, loadMapFixComponents, false)

local function toggleOneMapFixComponent(name, enable)
    assert(type(name) == "string")
    assert(type(enable) == "boolean")
    local data = mapFixComponents[name]
    if not data then
        return
    end
    data.enabled = (enable == true)
    loadOneMapFixComponent(name, data)
    if eventName ~= "onClientResourceStop" then
        outputDebugString("Map fix component '" .. name .. "' is now " .. (data.enabled and "enabled" or "disabled"))
    end
end
addEventHandler("modelfixes:client:togOneComponent", resourceRoot, toggleOneMapFixComponent, false)

local function unloadAllMapFixComponents()
    for name, _ in pairs(mapFixComponents) do
        toggleOneMapFixComponent(name, false)
    end
end
addEventHandler("onClientResourceStop", resourceRoot, unloadAllMapFixComponents, false)
