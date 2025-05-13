-- First, let's safely load Rayfield with error handling
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
end)

if not success or not Rayfield then
    warn("Failed to load Rayfield UI Library")
    return
end

-- Create the main window with error handling
local Window
local success, err = pcall(function()
    Window = Rayfield:CreateWindow({
        Name = "Auto Enchant",
        LoadingTitle = "Auto Enchant Loader",
        LoadingSubtitle = "by YourName",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "AutoEnchantConfig",
            FileName = "Config"
        },
        Discord = {
            Enabled = false,
            Invite = "noinvitelink",
            RememberJoins = true
        }
    })
end)

if not success then
    warn("Failed to create Rayfield window: "..tostring(err))
    return
end

-- Define enchant and pickaxe data
local enchants = {
    "Magic Ores",
    "Incredible Damage",
    "Deadly Damage++",
    "Deadly Damage",
    "More Damage",
    "Light Damage",
    "Incredible Luck",
    "Mighty Luck++",
    "Mighty Luck",
    "Considerable Luck",
    "Abnormal Speed"
}

local pickaxes = {
    ["Iron Pickaxe"] = {1, 1},
    ["Gold Pickaxe"] = {129, 1},
    ["Diamond Pickaxe"] = {128, 1},
    ["Gem Pickaxe"] = {4, 1},
    ["God Pickaxe"] = {130, 1},
    ["Grassy Pickaxe"] = {132, 1},
    ["Ice Pickaxe"] = {131, 1},
    ["Void Pickaxe"] = {6, 1},
    ["Hellfire Pickaxe"] = {133, 1},
    ["Pirate's Pickaxe"] = {8, 1},
    ["Coral Pickaxe"] = {127, 1},
    ["Sharkee Pick"] = {9, 1},
    ["Lava Pickaxe"] = {76, 1}
}

-- State variables
local selectedEnchant = enchants[1]
local selectedPickaxe = "Iron Pickaxe"
local selectedPickaxeArgs = pickaxes["Iron Pickaxe"]
local autoEnchanting = false

-- Create UI tab
local EnchantTab = Window:CreateTab("Auto Enchant", 4483362458)

-- Create dropdown for enchants
local EnchantDropdown = EnchantTab:CreateDropdown({
    Name = "Select Enchant",
    Options = enchants,
    CurrentOption = selectedEnchant,
    Flag = "EnchantDropdown",
    Callback = function(Option)
        selectedEnchant = Option
        Rayfield:Notify({
            Title = "Enchant Selected",
            Content = "Selected: "..Option,
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Create dropdown for pickaxes
local PickaxeDropdown = EnchantTab:CreateDropdown({
    Name = "Select Pickaxe",
    Options = {"Iron Pickaxe", "Gold Pickaxe", "Diamond Pickaxe", "Gem Pickaxe", "God Pickaxe", 
               "Grassy Pickaxe", "Ice Pickaxe", "Void Pickaxe", "Hellfire Pickaxe", "Pirate's Pickaxe",
               "Coral Pickaxe", "Sharkee Pick", "Lava Pickaxe"},
    CurrentOption = selectedPickaxe,
    Flag = "PickaxeDropdown",
    Callback = function(Option)
        selectedPickaxe = Option
        selectedPickaxeArgs = pickaxes[Option] or {1, 1}
        Rayfield:Notify({
            Title = "Pickaxe Selected",
            Content = "Selected: "..Option,
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Create auto-enchant toggle
local AutoEnchantToggle = EnchantTab:CreateToggle({
    Name = "Auto Enchant",
    CurrentValue = false,
    Flag = "AutoEnchantToggle",
    Callback = function(Value)
        autoEnchanting = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Enchant Started",
                Content = "Enchanting until: "..selectedEnchant,
                Duration = 3,
                Image = 4483362458
            })
            startAutoEnchant()
        else
            Rayfield:Notify({
                Title = "Auto Enchant Stopped",
                Content = "Stopped auto enchanting",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- Function to safely get current enchant
local function getCurrentEnchant()
    local success, result = pcall(function()
        local gui = game:GetService("Players").LocalPlayer.PlayerGui
        if gui and gui:FindFirstChild("ScreenGui") then
            local screenGui = gui.ScreenGui
            if screenGui and screenGui:FindFirstChild("Enchant") then
                local enchant = screenGui.Enchant
                if enchant and enchant:FindFirstChild("Content") then
                    local content = enchant.Content
                    if content and content:FindFirstChild("Slots") then
                        local slots = content.Slots
                        if slots and slots:FindFirstChild("1") then
                            local slot1 = slots["1"]
                            if slot1 and slot1:FindFirstChild("EnchantName") then
                                return slot1.EnchantName.ContentText
                            end
                        end
                    end
                end
            end
        end
        return nil
    end)
    return success and result or nil
end

-- Function to safely perform enchant
local function performEnchant()
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if remote then
        remote = remote:FindFirstChild("Enchant")
        if remote then
            pcall(function()
                remote:FireServer(unpack(selectedPickaxeArgs))
            end)
        end
    end
end

-- Main auto-enchant function
local function startAutoEnchant()
    spawn(function()
        while autoEnchanting and selectedEnchant ~= "" do
            local currentEnchant = getCurrentEnchant()
            
            if currentEnchant == selectedEnchant then
                autoEnchanting = false
                pcall(function() AutoEnchantToggle:Set(false) end)
                Rayfield:Notify({
                    Title = "Enchant Found!",
                    Content = "Successfully got: "..selectedEnchant,
                    Duration = 5,
                    Image = 4483362458
                })
                break
            else
                performEnchant()
                task.wait(0.5) -- Safer alternative to wait()
            end
        end
    end)
end

-- Initial notification
Rayfield:Notify({
    Title = "Auto Enchant Loaded",
    Content = "Select your options and start enchanting!",
    Duration = 5,
    Image = 4483362458
})
